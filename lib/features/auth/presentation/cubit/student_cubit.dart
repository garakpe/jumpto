import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:file_picker/file_picker.dart'; // file_picker는 Cubit에서 직접 사용하지 않으므로 제거해도 무방합니다. UI 레이어에서 사용됩니다.
import 'package:excel/excel.dart';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/student.dart';
import '../../domain/usecases/get_students_by_teacher.dart';
import '../../domain/usecases/update_student_gender.dart';
import '../../domain/usecases/upload_students.dart';
import '../../domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';

/// 학생 상태
abstract class StudentState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// 학생 초기 상태
class StudentInitial extends StudentState {}

/// 학생 로딩 상태
class StudentLoading extends StudentState {}

/// 학생 로드 완료 상태
class StudentLoaded extends StudentState {
  final List<Student> students;

  StudentLoaded({required this.students});

  @override
  List<Object?> get props => [students];
}

/// 학생 업로드 중 상태
class StudentUploading extends StudentState {
  final int totalCount;
  final int uploadedCount; // 실제 구현에서는 이 값을 점진적으로 업데이트하기 어려울 수 있습니다.
  // Batch 업로드의 경우 시작/성공/실패 상태만으로 충분할 수 있습니다.
  // 필요하다면 UploadStudents usecase에서 콜백 등을 통해 진행률을 받아와야 합니다.

  StudentUploading({required this.totalCount, required this.uploadedCount});

  @override
  List<Object?> get props => [totalCount, uploadedCount];
}

/// 학생 업로드 완료 상태
class StudentUploadSuccess extends StudentState {
  final List<Student> uploadedStudents;
  final Map<String, int> classCount;

  StudentUploadSuccess({
    required this.uploadedStudents,
    required this.classCount,
  });

  @override
  List<Object?> get props => [uploadedStudents, classCount];
}

/// 학생 오류 상태
class StudentError extends StudentState {
  final String message;

  StudentError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// 학생 Cubit
///
/// 학생 관리 기능에 대한 상태 관리를 담당합니다.
class StudentCubit extends Cubit<StudentState> {
  final GetStudentsByTeacher _getStudentsByTeacher;
  final UploadStudents _uploadStudents;
  final GetCurrentUser _getCurrentUser;
  final UpdateStudentGender _updateStudentGender;

  StudentCubit({
    required GetStudentsByTeacher getStudentsByTeacher,
    required UploadStudents uploadStudents,
    required GetCurrentUser getCurrentUser,
    required UpdateStudentGender updateStudentGender,
  }) : _getStudentsByTeacher = getStudentsByTeacher,
       _uploadStudents = uploadStudents,
       _getCurrentUser = getCurrentUser,
       _updateStudentGender = updateStudentGender,
       super(StudentInitial());

  /// 현재 교사가 담당하는 학생 목록 조회
  Future<void> loadStudents() async {
    emit(StudentLoading());

    // 1. 현재 인증된 사용자(교사) 정보 가져오기
    final userResult = await _getCurrentUser(NoParams());

    // 2. userResult를 처리하여 학생 목록을 가져오거나 에러 처리
    await userResult.fold(
      // 2a. 사용자 정보 가져오기 실패 시
      (failure) async {
        emit(StudentError(message: '사용자 정보를 가져오지 못했습니다: ${failure.message}'));
      },
      // 2b. 사용자 정보 가져오기 성공 시
      (user) async {
        // 3. 사용자 유효성 검사 (교사인지 확인)
        if (user == null || !user.isTeacher) {
          emit(StudentError(message: '유효한 교사 계정이 아닙니다.'));
          return; // 처리 중단
        }

        // 4. 유효한 교사인 경우 학생 목록 조회
        final studentsResult = await _getStudentsByTeacher(
          GetStudentsByTeacherParams(teacherId: user.id),
        );

        // 5. 학생 목록 조회 결과 처리
        studentsResult.fold(
          (failure) => emit(StudentError(message: failure.message)),
          (students) => emit(StudentLoaded(students: students)),
        );
      },
    );
  }

  /// 엑셀 파일에서 학생 정보 추출 및 업로드 준비
  Future<void> processExcelFile(Uint8List bytes) async {
    emit(StudentLoading()); // 파일 처리 시작을 나타내는 로딩 상태

    try {
      // 1. 현재 인증된 사용자(교사) 정보 가져오기
      final userResult = await _getCurrentUser(NoParams());
      User? currentUser;

      // userResult 처리 (fold 사용)
      final errorOrUser = userResult.fold<Either<Failure, User?>>(
        (failure) => Left(failure), // 실패 시 Failure 반환
        (user) {
          if (user == null || !user.isTeacher) {
            return Left(
              ServerFailure(message: '유효한 교사 계정이 아닙니다.'),
            ); // 유효하지 않으면 Failure 반환
          }
          return Right(user); // 성공 시 User 반환
        },
      );

      // 에러가 있으면 StudentError 상태를 emit하고 종료
      if (errorOrUser.isLeft()) {
        final failure = errorOrUser.fold(
          (l) => l,
          (r) => null,
        ); // Left에서 Failure 추출
        emit(StudentError(message: failure?.message ?? '사용자 인증 중 오류 발생'));
        return;
      }

      // 성공 시 currentUser 할당 (여기서는 null이 아님을 보장)
      currentUser = errorOrUser.fold((l) => null, (r) => r)!;
      
      // 교사 정보 출력 (디버깅용)
      print('교사 정보: ID=${currentUser.id}, 이름=${currentUser.displayName}, 학교코드=${currentUser.schoolCode}');

      // 2. 엑셀 파일 파싱
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        emit(StudentError(message: '엑셀 파일을 열 수 없거나 시트가 없습니다.'));
        return;
      }
      final sheetName = excel.tables.keys.first;
      final table = excel.tables[sheetName];
      final rows = table?.rows;

      if (rows == null || rows.length <= 1) {
        // 헤더만 있거나 빈 파일인 경우
        emit(StudentError(message: '엑셀 파일에 데이터가 없습니다 (헤더 제외).'));
        return;
      }

      // 3. 데이터 추출 및 유효성 검사
      final dataRows = rows.sublist(1); // 첫 번째 행(헤더) 제외
      List<Student> studentsData = [];
      Map<String, int> classCount = {};
      List<String> errors = []; // 처리 중 발생한 오류 메시지 저장
      
      // 헤더 행 확인 (디버깅용)
      final headerRow = rows[0];
      print('헤더 행: ${headerRow.map((cell) => cell?.value?.toString() ?? '').join(', ')}');

      for (int i = 0; i < dataRows.length; i++) {
        final row = dataRows[i];
        final rowIndex = i + 2; // 실제 엑셀 행 번호 (헤더 포함, 1부터 시작)
        
        // 디버깅을 위한 행 전체 콘텐츠 출력
        print('행 #$rowIndex 원본 데이터: ${row.map((cell) => cell?.value?.toString() ?? 'null').join(', ')}');

        // 셀 데이터 추출 (null 안전 처리 강화)
        String grade =
            row.isNotEmpty && row[0] != null ? row[0]!.value?.toString().trim() ?? '' : '';
        String rawClassNum =
            row.length > 1 && row[1] != null ? row[1]!.value?.toString().trim() ?? '' : '';
        String rawStudentNum =
            row.length > 2 && row[2] != null ? row[2]!.value?.toString().trim() ?? '' : '';
        String name =
            row.length > 3 && row[3] != null ? row[3]!.value?.toString().trim() ?? '' : '';
        String password =
            row.length > 4 && row[4] != null
                ? row[4]!.value?.toString().trim() ?? '1234'
                : '1234'; // 기본 비밀번호
                
        // 추출된 데이터 출력 (디버깅용)
        print('추출된 데이터: 학년=$grade, 반=$rawClassNum, 번호=$rawStudentNum, 이름=$name, 비밀번호=$password');

        // 필수 데이터 누락 확인
        if (grade.isEmpty ||
            rawClassNum.isEmpty ||
            rawStudentNum.isEmpty ||
            name.isEmpty) {
          errors.add('$rowIndex행: 학년, 반, 번호, 이름 중 누락된 값이 있습니다.');
          continue;
        }

        // 반, 번호 숫자 변환 및 유효성 검사
        int? classNumInt = int.tryParse(rawClassNum);
        int? studentNumInt = int.tryParse(rawStudentNum);

        if (classNumInt == null || studentNumInt == null) {
          errors.add(
            '$rowIndex행: 반($rawClassNum) 또는 번호($rawStudentNum)가 숫자가 아닙니다.',
          );
          continue;
        }

        // 두 자리 문자열로 포맷팅
        final formattedClassNum = classNumInt.toString().padLeft(2, '0');
        final formattedStudentNum = studentNumInt.toString().padLeft(2, '0');

        // 학번 생성 (5자리)
        final studentId = '$grade$formattedClassNum$formattedStudentNum';
        
        // 학번 출력 (디버깅용)
        print('생성된 학번: $studentId');

        // 추가 데이터 유효성 검증 (_validateStudentData 호출)
        if (!_validateStudentData(
          grade,
          formattedClassNum,
          formattedStudentNum,
          name,
        )) {
          errors.add(
            '$rowIndex행: 데이터 형식이 유효하지 않습니다 (학년: $grade, 반: $formattedClassNum, 번호: $formattedStudentNum, 이름: $name). 학년(1-9), 반/번호(1-99), 이름(2-10자).',
          );
          continue;
        }
        
        // 학생 엔티티 생성
        // 이메일 생성
        final DateTime now = DateTime.now();
        final String currentYearSuffix = now.year.toString().substring(2);
        String emailSchoolCode = currentUser.schoolCode ?? 'default';
        if (emailSchoolCode.isNotEmpty) {
          // 숫자만 추출
          final RegExp regExp = RegExp(r'\d+');
          final match = regExp.firstMatch(emailSchoolCode);
          if (match != null) {
            emailSchoolCode = match.group(0) ?? 'default';
          }
        }
        final email = '$currentYearSuffix$studentId@school$emailSchoolCode.com';
        print('생성된 이메일: $email');
        
        // 학교 이름 처리 - 교사의 displayName 대신 학교코드를 기반으로 학교 이름 설정
        // 가락고등학교와 같이 학교코드에서 학교 이름 추출
        // 예제: A000003550 -> 가락고등학교
        String schoolName = '기본학교'; // 기본 학교 이름
        if (currentUser.schoolCode != null && currentUser.schoolCode!.startsWith('A')) {
          schoolName = '고등학교'; // 기본적으로 고등학교로 설정
          
          // 학교코드에서 학교 이름 추출 시도 - 다른 방법을 사용할 수도 있음
          // 예시: 학교 이름 매핑 사용 또는 Firestore에서 학교 정보 조회 등
          schoolName = '가락고등학교'; // 기본 가정 학교이름
        }
        
        final student = Student(
          id: '', // Firestore에서 자동 생성될 ID
          name: name,
          grade: grade,
          classNum: formattedClassNum,
          studentNum: formattedStudentNum,
          studentId: studentId, // 5자리 학번
          teacherId: currentUser.id,
          schoolCode: currentUser.schoolCode ?? '', // 교사 정보에서 가져오기
          schoolName: schoolName, // 생성된 학교 이름 사용
          attendance: true, // 기본값
          createdAt: DateTime.now(),
          password: password, // 초기 비밀번호
          email: email, // 생성된 이메일 사용
        );
        // 이메일 검증 (디버깅용) - 이미 학생 객체에 이메일이 설정되어 있으민 중복 제거
        
        studentsData.add(student);

        // 학급별 카운트 증가
        classCount[formattedClassNum] =
            (classCount[formattedClassNum] ?? 0) + 1;
      }

      // 처리 중 오류가 있었는지 확인
      if (errors.isNotEmpty) {
        // 모든 행이 오류였을 경우 처리 중단
        if (studentsData.isEmpty) {
          emit(StudentError(message: '파일 처리 중 오류 발생:\n${errors.join('\n')}'));
          return;
        }
        // 일부 오류가 있었지만 유효한 데이터도 있는 경우
        emit(
          StudentError(
            message:
                '일부 데이터 처리 중 오류 발생:\n${errors.join('\n')}\n\n유효한 데이터 ${studentsData.length}건만 처리됩니다.',
          ),
        );
        // 여기서는 오류 메시지를 보여주고 나서 계속 진행하도록 변경
      }

      // 유효한 학생 데이터가 없는 경우
      if (studentsData.isEmpty) {
        emit(StudentError(message: '엑셀 파일에서 유효한 학생 데이터를 찾을 수 없습니다.'));
        return;
      }

      // 4. 학생 일괄 업로드
      emit(
        StudentUploading(totalCount: studentsData.length, uploadedCount: 0),
      ); // 업로드 시작 상태

      final result = await _uploadStudents(
        UploadStudentsParams(students: studentsData),
      );

      result.fold(
        (failure) => emit(StudentError(message: failure.message)),
        (uploadedStudents) => emit(
          StudentUploadSuccess(
            uploadedStudents: uploadedStudents,
            classCount: classCount,
          ),
        ),
      );
    } catch (e, stacktrace) {
      // 예상치 못한 오류 처리
      print('Excel 처리 중 예외 발생: $e');
      print(stacktrace);
      emit(StudentError(message: '파일 처리 중 예상치 못한 오류가 발생했습니다: $e'));
    }
  }

  /// 엑셀 템플릿 생성
  Future<Uint8List?> createExcelTemplate() async {
    try {
      // 엑셀 객체 생성
      final excel = Excel.createExcel();

      // Excel 4.0.6에서는 시트 가져오는 방법이 다름
      final defaultSheetName = excel.getDefaultSheet()!;
      final sheet = excel.sheets[defaultSheetName]!;
      excel.rename(defaultSheetName, '학생명단'); // 시트 객체가 아닌 시트 이름만 전달

      // 헤더 추가 (최신 excel 패키지는 CellValue 클래스를 사용)
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = TextCellValue('학년');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = TextCellValue('반');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = TextCellValue('번호');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
          .value = TextCellValue('이름');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
          .value = TextCellValue('초기비밀번호 (선택, 기본값 1234)'); // 설명 추가

      // 샘플 데이터 추가 - 첫 번째 행
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value = IntCellValue(1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1)).value = IntCellValue(1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1)).value = IntCellValue(1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 1)).value = TextCellValue('김민준');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 1)).value = TextCellValue('1234');
      
      // 샘플 데이터 추가 - 두 번째 행
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).value = IntCellValue(1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2)).value = IntCellValue(1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 2)).value = IntCellValue(2);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 2)).value = TextCellValue('이서연');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 2)).value = TextCellValue('1234');
      
      // 샘플 데이터 추가 - 세 번째 행
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3)).value = IntCellValue(1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3)).value = IntCellValue(2);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 3)).value = IntCellValue(1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 3)).value = TextCellValue('박지원');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 3)).value = TextCellValue('1234');

      // Excel 4.0.6에서는 setColumnAutoFit 메서드를 사용
      // 각 열의 너비를 쉘에 맞게 자동 조절
      // 열 너비를 더 넓게 설정
      sheet.setColumnWidth(0, 12.0); // 학년
      sheet.setColumnWidth(1, 12.0); // 반
      sheet.setColumnWidth(2, 12.0); // 번호
      sheet.setColumnWidth(3, 20.0); // 이름
      sheet.setColumnWidth(4, 25.0); // 초기비밀번호

      // 엑셀 파일을 바이트 배열로 변환
      // encode() 메서드는 List<int>? 를 반환하므로 Uint8List로 변환 필요
      final fileBytes = excel.encode();

      if (fileBytes == null) {
        emit(StudentError(message: '엑셀 파일 생성 실패')); // Cubit 상태 변경으로 오류 알림
        return null;
      }

      return Uint8List.fromList(fileBytes);
    } catch (e, stacktrace) {
      print('Excel 템플릿 생성 중 예외 발생: $e');
      print(stacktrace);
      emit(StudentError(message: '엑셀 템플릿 생성 중 오류가 발생했습니다: $e'));
      return null;
    }
  }

  /// 데이터 유효성 검증
  bool _validateStudentData(
    String grade,
    String classNum, // 이미 2자리로 포맷된 문자열
    String studentNum, // 이미 2자리로 포맷된 문자열
    String name,
  ) {
    // 학년, 이름이 비어있지 않은지 확인 (processExcelFile에서 이미 확인했지만 중복 검사도 무방)
    if (grade.isEmpty || name.isEmpty) {
      return false;
    }

    // 학년 형식 검증 (1~9 사이의 숫자)
    if (!RegExp(r'^[1-9]$').hasMatch(grade)) {
      return false;
    }

    // 반과 번호는 이미 두 자리 문자열로 변환되었으므로, 정수 변환 및 범위 체크
    int? classNumInt = int.tryParse(classNum);
    int? studentNumInt = int.tryParse(studentNum);

    if (classNumInt == null ||
        classNumInt < 1 || // 01 ~ 99 허용
        classNumInt > 99 ||
        studentNumInt == null ||
        studentNumInt < 1 || // 01 ~ 99 허용
        studentNumInt > 99) {
      return false;
    }

    // 이름 길이 확인 (예: 2자 이상 10자 이하)
    if (name.length < 2 || name.length > 10) {
      return false;
    }

    // 비밀번호 유효성 검사는 여기서 하지 않음 (processExcelFile에서 기본값 처리)
    // 필요하다면 추가 가능

    return true;
  }
  
  /// 학생 성별 업데이트
  Future<void> updateGender(String gender) async {
    try {
      emit(StudentLoading()); // 로딩 상태 시작
      
      // 성별 유효성 검사 ("남" 또는 "여"만 허용)
      if (gender != '남' && gender != '여') {
        emit(StudentError(message: '유효하지 않은 성별입니다. ("남" 또는 "여"만 가능)'));
        return;
      }
      
      // 업데이트 요청 전송
      final result = await _updateStudentGender(UpdateStudentGenderParams(gender: gender));
      
      // 결과 처리
      result.fold(
        (failure) => emit(StudentError(message: failure.message)),
        (_) async {
          // 성공 시, 학생 리스트를 다시 가져와서 화면 새로고침
          await loadStudents();
        },
      );
    } catch (e) {
      emit(StudentError(message: '성별 업데이트 중 오류가 발생했습니다: $e'));
    }
  }
}
