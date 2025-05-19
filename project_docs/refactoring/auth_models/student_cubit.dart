import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/student.dart';
import '../../../domain/usecases/change_student_password.dart';
import '../../../domain/usecases/get_students_by_teacher.dart';
import '../../../domain/usecases/reset_student_password.dart';
import '../../../domain/usecases/update_student_gender.dart';
import '../../../domain/usecases/upload_students.dart';

part 'student_state.dart';

class StudentCubit extends Cubit<StudentState> {
  final GetStudentsByTeacher _getStudentsByTeacher;
  final UploadStudents _uploadStudents;
  final ChangeStudentPassword _changeStudentPassword;
  final UpdateStudentGender _updateStudentGender;
  final ResetStudentPassword _resetStudentPassword;

  StudentCubit({
    required GetStudentsByTeacher getStudentsByTeacher,
    required UploadStudents uploadStudents,
    required ChangeStudentPassword changeStudentPassword,
    required UpdateStudentGender updateStudentGender,
    required ResetStudentPassword resetStudentPassword,
  })  : _getStudentsByTeacher = getStudentsByTeacher,
        _uploadStudents = uploadStudents,
        _changeStudentPassword = changeStudentPassword,
        _updateStudentGender = updateStudentGender,
        _resetStudentPassword = resetStudentPassword,
        super(StudentInitial());

  Future<void> getStudentsByTeacher(String teacherId) async {
    emit(StudentLoading());

    final result = await _getStudentsByTeacher(
      GetStudentsByTeacherParams(teacherId),
    );

    result.fold(
      (failure) {
        emit(StudentError(message: failure.message));
      },
      (students) {
        emit(StudentLoaded(students: students));
      },
    );
  }

  Future<void> uploadStudents({
    required List<Map<String, dynamic>> studentsData,
    required String teacherId,
    required String schoolCode,
    required String schoolName,
  }) async {
    emit(StudentLoading());

    final result = await _uploadStudents(
      UploadStudentsParams(
        studentsData: studentsData,
        teacherId: teacherId,
        schoolCode: schoolCode,
        schoolName: schoolName,
      ),
    );

    result.fold(
      (failure) {
        emit(StudentError(message: failure.message));
      },
      (students) {
        emit(StudentLoaded(students: students));
      },
    );
  }

  Future<void> changeStudentPassword({
    required String studentId,
    required String oldPassword,
    required String newPassword,
  }) async {
    final currentState = state;
    emit(StudentLoading());

    final result = await _changeStudentPassword(
      ChangeStudentPasswordParams(
        studentId: studentId,
        oldPassword: oldPassword,
        newPassword: newPassword,
      ),
    );

    result.fold(
      (failure) {
        emit(StudentError(message: failure.message));
        // 오류 후에는 이전 상태로 복원
        if (currentState is StudentLoaded) {
          emit(currentState);
        }
      },
      (_) {
        // 성공 시 성공 메시지 표시 후 이전 상태로 복원
        emit(StudentSuccess(message: '비밀번호가 성공적으로 변경되었습니다.'));
        if (currentState is StudentLoaded) {
          emit(currentState);
        }
      },
    );
  }

  Future<void> updateStudentGender({
    required String studentId,
    required String gender,
  }) async {
    final currentState = state;
    
    if (currentState is StudentLoaded) {
      // 현재 상태에서 성별이 업데이트된 학생 목록 생성
      final updatedStudents = currentState.students.map((student) {
        if (student.id == studentId) {
          // Student는 불변 객체이므로 새 인스턴스 생성
          // 실제 구현에서는 적절한 생성자나 팩토리 메서드 사용
          // 여기서는 개념적으로만 표현
          return Student(
            baseUser: student.baseUser,
            grade: student.grade,
            classNum: student.classNum,
            studentNum: student.studentNum,
            studentId: student.studentId,
            teacherId: student.teacherId,
            schoolCode: student.schoolCode,
            schoolName: student.schoolName,
            attendance: student.attendance,
            gender: gender, // 새 성별로 업데이트
          );
        }
        return student;
      }).toList();
      
      // 낙관적 UI 업데이트 (즉시 변경 표시)
      emit(StudentLoaded(students: updatedStudents));
    }

    // API 호출
    final result = await _updateStudentGender(
      UpdateStudentGenderParams(
        studentId: studentId,
        gender: gender,
      ),
    );

    result.fold(
      (failure) {
        emit(StudentError(message: failure.message));
        // 실패 시 이전 상태로 롤백
        if (currentState is StudentLoaded) {
          emit(currentState);
        }
      },
      (_) {
        // 이미 낙관적 업데이트 완료, 성공 메시지 표시
        emit(StudentSuccess(message: '성별 정보가 성공적으로 업데이트되었습니다.'));
        if (currentState is StudentLoaded) {
          // 업데이트된 상태 유지
          final updatedState = currentState as StudentLoaded;
          emit(StudentLoaded(students: updatedState.students));
        }
      },
    );
  }

  Future<void> resetStudentPassword(String studentId) async {
    final currentState = state;
    emit(StudentLoading());

    final result = await _resetStudentPassword(
      ResetStudentPasswordParams(studentId),
    );

    result.fold(
      (failure) {
        emit(StudentError(message: failure.message));
        // 오류 후에는 이전 상태로 복원
        if (currentState is StudentLoaded) {
          emit(currentState);
        }
      },
      (_) {
        // 성공 시 성공 메시지 표시 후 이전 상태로 복원
        emit(StudentSuccess(message: '학생 비밀번호가 초기화되었습니다.'));
        if (currentState is StudentLoaded) {
          emit(currentState);
        }
      },
    );
  }
}
