// uploadStudents 메서드 리팩토링
// Auth 계정 생성 로직을 클라이언트 측에서만 담당하고 학교 코드 일관성 유지

@override
Future<List<StudentModel>> uploadStudents(List<StudentModel> students) async {
  try {
    final createdStudents = <StudentModel>[];
    
    // 학생 데이터 준비
    final updatedStudents = <StudentModel>[];
    
    // 현재 로그인한 교사 정보 가져오기
    String teacherSchoolName = '';
    String teacherSchoolCode = '';
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final teacherDoc = await _firestore
            .collection('users')
            .where('authUid', isEqualTo: currentUser.uid)
            .limit(1)
            .get();
        
        if (teacherDoc.docs.isNotEmpty) {
          final teacherData = teacherDoc.docs.first.data();
          teacherSchoolName = teacherData['schoolName'] ?? '';
          teacherSchoolCode = teacherData['schoolCode'] ?? '';
          debugPrint('교사 학교 정보: $teacherSchoolName (코드: $teacherSchoolCode)');
        }
      }
    } catch (e) {
      debugPrint('교사 정보 가져오기 오류: $e');
    }
    
    // 항상 학교 코드의 마지막 4자리만 사용
    String shortSchoolCode = '';
    if (teacherSchoolCode.isNotEmpty) {
      shortSchoolCode = teacherSchoolCode.length > 4 
          ? teacherSchoolCode.substring(teacherSchoolCode.length - 4) 
          : teacherSchoolCode.padLeft(4, '0');
    } else {
      shortSchoolCode = '0000';
    }
    
    // 학생 수정 (학교명 및 이메일 형식 수정)
    for (final student in students) {
      // 이메일 생성 - 일관된 형식 사용
      final DateTime now = DateTime.now();
      final String currentYearSuffix = now.year.toString().substring(2);
      final String email = '$currentYearSuffix${student.studentId}@school$shortSchoolCode.com';
      
      // 학교명은 교사 정보에서 가져오기
      final String schoolName = teacherSchoolName.isNotEmpty ? teacherSchoolName : student.schoolName;
      
      // 수정된 학생 모델 생성
      final updatedStudent = StudentModel(
        id: student.id,
        authUid: student.authUid,
        email: email,
        name: student.name,
        grade: student.grade,
        classNum: student.classNum,
        studentNum: student.studentNum,
        studentId: student.studentId,
        teacherId: student.teacherId,
        schoolCode: shortSchoolCode, // 짧은 학교 코드 사용
        schoolName: schoolName,
        attendance: student.attendance,
        createdAt: student.createdAt,
        password: '123456', // Firebase 요구사항 충족을 위한 6자 이상 비밀번호
        gender: student.gender,
      );
      
      updatedStudents.add(updatedStudent);
    }
    
    // Auth 계정 생성 및 Firestore 저장 로직
    final batch = _firestore.batch();
    
    for (final student in updatedStudents) {
      debugPrint('처리 중인 학생: ${student.name}, 이메일: ${student.email}');
      
      if (student.email == null || student.password == null) {
        throw ServerException(message: '이메일 또는 비밀번호가 없습니다: ${student.name}');
      }
      
      // 이메일 유효성 검사
      final email = student.email!.trim();
      if (!email.contains('@') || !email.contains('.')) {
        throw ServerException(message: '유효하지 않은 이메일 형식: $email (학생: ${student.name})');
      }
      
      debugPrint('새 학생 계정 만들기: ${student.name}, 이메일: $email, 학교: ${student.schoolName}');
      
      // 1. Firebase Authentication 계정 생성
      firebase_auth.UserCredential userCredential;
      try {
        // 여기서 클라이언트 측에서 명시적으로 Auth 계정 생성
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: student.password!,
        );
        debugPrint('Auth 계정 생성 성공: $email (UID: ${userCredential.user!.uid})');
      } catch (authError) {
        // 자세한 에러 로깅
        debugPrint('Auth 계정 생성 오류: $authError (학생: ${student.name}, 이메일: $email)');
        
        // Firebase 오류 코드에 따른 세분화된 처리
        if (authError is firebase_auth.FirebaseAuthException) {
          final code = authError.code;
          if (code == 'email-already-in-use') {
            debugPrint('이미 사용 중인 이메일입니다. 기존 계정을 찾아서 사용합니다.');
            try {
              // 기존 계정에 대한 정보 확인
              final existingUser = await _auth.fetchSignInMethodsForEmail(email);
              if (existingUser.isNotEmpty) {
                debugPrint('기존 계정 존재: ${existingUser.join(', ')}');
                continue; // 이 학생은 건너뜀
              }
            } catch (e) {
              debugPrint('기존 계정 확인 오류: $e');
            }
          } else {
            // 다른 Firebase Auth 오류 처리
            debugPrint('Firebase Auth 오류: ${authError.code} - ${authError.message}');
          }
        }
        continue; // 이 학생은 건너뜀 (배치 작업 계속)
      }
      
      // 2. Authentication UID 가져오기
      final authUid = userCredential.user!.uid;
      
      // 3. Firestore 문서 참조 생성
      final docRef = _firestore.collection('students').doc();
      
      // 4. authUid와 email이 포함된 학생 모델 생성 (비밀번호 필드 제외)
      final studentWithAuth = StudentModel(
        id: docRef.id,
        authUid: authUid, // 중요: Firebase Auth에서 생성된 UID 포함
        email: email,
        name: student.name,
        grade: student.grade,
        classNum: student.classNum,
        studentNum: student.studentNum,
        studentId: student.studentId,
        teacherId: student.teacherId,
        schoolCode: student.schoolCode,
        schoolName: student.schoolName,
        attendance: student.attendance,
        createdAt: student.createdAt,
        gender: student.gender,
        // 비밀번호 필드는 제외 (보안상 Firestore에 저장하지 않음)
      );
      
      // 5. Firestore에 학생 정보 저장 (배치에 추가) - 비밀번호 없이
      final firestoreData = studentWithAuth.toFirestore();
      debugPrint('학생 Firestore 데이터 확인: ${firestoreData.keys.join(', ')}');
      batch.set(docRef, firestoreData);
      
      // 6. 생성된 학생 저장
      createdStudents.add(studentWithAuth);
    }
    
    // 배치 요청 실행
    await batch.commit();
    debugPrint('학생 일괄 업로드 완료: ${createdStudents.length}명 생성됨');
    return createdStudents;
  } catch (e, stackTrace) {
    debugPrint('학생 일괄 업로드 실패: $e');
    debugPrint('Stack trace: $stackTrace');
    throw ServerException(message: '학생 일괄 업로드 실패: $e');
  }
}