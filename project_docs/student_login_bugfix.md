# 학생 로그인 버그 수정 내역

## 문제 분석

교사 회원가입, 관리자 승인, 학생 명단 업로드, 학생 로그인 시도 과정에서 발생한 문제점을 분석했습니다.

### 발견된 문제

학생 로그인 시 다음과 같은 오류가 발생했습니다:
```
(index):64 Firebase Auth 로그인 성공 (UID: 8Xj7W5JEJpQVWpjTmToZoz0xQcS2)
(index):64 Firebase 인증 후 사용자 정보를 찾을 수 없습니다.
(index):64 학생 로그인 오류: Instance of 'minified:l9'
```

### 원인

1. **인증 및 데이터 불일치**:
   - Firebase Authentication에서는 로그인(인증)이 성공하지만, Firestore에서 해당 UID로 사용자 정보를 찾지 못하는 상황입니다.
   
2. **데이터 저장 문제**:
   - 학생 계정 생성 시 Firestore의 `students` 컬렉션에만 정보가 저장되고, `users` 컬렉션에는 저장되지 않았습니다.
   - Auth 인증 생성 후 `authUid` 필드가 제대로 업데이트되지 않았을 가능성이 있었습니다.

3. **사용자 정보 조회 로직 제한**:
   - `_getUserData()` 메서드가 `users` 컬렉션만 조회하여, `students` 컬렉션에 있는 데이터를 찾지 못했습니다.

## 적용한 수정 사항

### 1. 학생 계정 생성 시 `users` 컬렉션에도 저장

`StudentRemoteDataSourceImpl` 클래스의 `uploadStudents` 메서드에서 Firebase Auth 계정 생성 후, `users` 컬렉션에도 학생 정보를 저장하도록 변경했습니다.

```dart
// Auth 계정 생성 성공 후
await _firestore.collection('users').doc(userCredential.user!.uid).set({
  'email': email,
  'displayName': student.name,
  'role': 'student',
  'authUid': userCredential.user!.uid,
  'schoolCode': student.schoolCode,
  'schoolName': student.schoolName,
  'grade': student.grade,
  'classNum': student.classNum,
  'studentNum': student.studentNum,
  'studentId': student.studentId,
  'gender': student.gender,
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
});
```

### 2. 사용자 정보 조회 로직 개선

`AuthRemoteDataSourceImpl` 클래스의 `_getUserData()` 메서드를 개선하여 `users` 컬렉션에서 데이터를 찾지 못한 경우, `students` 컬렉션에서도 `authUid` 필드로 검색하도록 변경했습니다.

```dart
// users 컬렉션에 사용자 정보가 없으면 students 컬렉션에서 authUid로 조회
if (userData == null) {
  debugPrint('users 컬렉션에서 사용자($uid) 정보를 찾을 수 없음, students 컬렉션 조회');
  final studentQuery = await _firestore.collection('students')
      .where('authUid', isEqualTo: uid)
      .limit(1)
      .get();
      
  if (studentQuery.docs.isEmpty) {
    debugPrint('students 컬렉션에서도 authUid가 $uid인 학생을 찾을 수 없음');
    return null;
  }
  
  final studentData = studentQuery.docs.first.data() as Map<String, dynamic>;
  debugPrint('students 컬렉션에서 학생 정보 발견: ${studentQuery.docs.first.id}');
  
  // Students 데이터에서 User 객체로 변환
  return domain.User(
    id: uid,
    email: studentData['email'],
    displayName: studentData['name'],
    role: domain.UserRole.student,
    schoolCode: studentData['schoolCode'],
    schoolName: studentData['schoolName'],
    classNum: studentData['classNum'],
    studentNum: studentData['studentNum'],
    studentId: studentData['studentId'],
    gender: studentData['gender'],
  );
}
```

### 3. 로그인 과정 디버깅 로그 추가

`signInStudent()` 메서드에 추가 디버깅 로그를 추가하여 실패 지점을 정확히 파악할 수 있도록 했습니다.

```dart
final uid = userCredential.user!.uid;
debugPrint('Firebase Auth 로그인 성공, UID: $uid, 이메일: $email');

// 학생 정보 조회 시도 - 여기에 디버깅 로그 추가
debugPrint('Firestore에서 사용자 정보 조회 시도 (UID: $uid)');
final userData = await _getUserData(uid);

if (userData == null) {
  debugPrint('사용자 정보 조회 실패: userData는 null, UID: $uid');
  
  // 추가 디버그: users 컬렉션 확인
  final userDoc = await _firestore.collection('users').doc(uid).get();
  if (!userDoc.exists) {
    debugPrint('users 컬렉션에 문서가 없음: $uid');
  } else {
    debugPrint('users 컬렉션 문서 데이터: ${userDoc.data()}');
  }
  
  throw ServerException(message: '사용자 정보를 찾을 수 없습니다.');
}
```

## 기대 효과

1. 학생 계정 생성 시 `users` 컬렉션에도 데이터가 저장되어 로그인 후 사용자 정보 조회가 정상적으로 이루어집니다.

2. `users` 컬렉션에 데이터가 없더라도 `students` 컬렉션에서 정보를 찾을 수 있도록 백업 조회 로직이 추가되어, 데이터 일관성이 완벽하지 않은 상황에서도 로그인이 정상 작동합니다.

3. 추가된 디버깅 로그를 통해 앞으로 발생할 수 있는 다른 인증 관련 문제를 더 정확히 진단할 수 있게 되었습니다.

## 테스트 권장 사항

다음 시나리오를 테스트하여 변경 사항이 제대로 적용되었는지 확인하세요:

1. 새 학생 계정 생성 후 Firestore의 `users` 컬렉션에 정보가 저장되는지 확인

2. 학생 로그인 시 정상적으로 로그인되고 홈 화면으로 이동하는지 확인

3. 기존에 생성된 학생 계정도 로그인이 정상 작동하는지 확인 (`students` 컬렉션 백업 조회 로직 테스트)
