# 학생 로그인 시스템 보안 강화 (Auth System Refactoring Guide)

## 개요

이 문서는 온라인 팝스(PAPS) 교육 플랫폼의 학생 로그인 시스템에 대한 보안 강화 작업에 대한 설명입니다. 기존의 Custom Token 방식에서 Firebase Auth SDK의 `signInWithEmailAndPassword`를 직접 사용하는 방식으로 변경하여 보안성을 높였습니다.

## 배경

기존 로그인 시스템은 다음과 같은 문제점이 있었습니다:

1. **비밀번호 검증 누락**: Cloud Function `studentLogin`에서 이메일 존재 여부만 확인하고 비밀번호는 검증하지 않는 구조였습니다.
2. **보안 취약점**: 학교명과 학번만 알면 비밀번호 없이도 로그인이 가능한 잠재적 위험이 있었습니다.
3. **복잡성**: Custom Token 발급 과정이 불필요하게 복잡했습니다.
4. **비용 증가**: 여러 번의 Firestore 읽기/쓰기 작업, Auth 조회 및 Custom Token 생성 등 불필요한 작업이 많았습니다.

## 수정 방향

전문가 분석에 따라 다음과 같은 방향으로 수정했습니다:

1. **직접 인증 방식 채택**: Firebase Auth SDK의 `signInWithEmailAndPassword` 메서드를 사용하여 직접 인증하도록 변경했습니다.
2. **인증 분리**: 비밀번호 검증을 Cloud Function이 아닌 Firebase Auth에서 처리하도록 하여 보안성을 높였습니다.
3. **이메일 조회 함수 추가**: 학교명과 학번으로 이메일 주소만 조회하는 새로운 Cloud Function `getStudentLoginEmail`을 추가했습니다.

## 구현 단계

### 1. 새로운 Cloud Function 추가

```javascript
/**
 * 학생 로그인 이메일 조회 함수 (HTTPS Callable)
 * 
 * 학생이 학교명과 학번을 제공하면 해당 학생의 Firebase Auth 이메일 주소를 반환합니다.
 * 이 이메일은 클라이언트에서 signInWithEmailAndPassword 메서드에 사용됩니다.
 */
exports.getStudentLoginEmail = onCall(
  { region: REGION },
  async (request) => {
    // 학교명과 학번으로 이메일 생성 후 반환하는 로직
    // 기존 studentLogin 함수에서 이메일 조회 부분만 분리
  }
);
```

### 2. CloudFunctionsService 클래스 수정

```dart
/// 학생 로그인 이메일 가져오기
///
/// 학생이 학교명과 학번으로 로그인 이메일을 가져올 때 사용
Future<String> getStudentLoginEmail({
  required String schoolName,
  required String studentId,
}) async {
  // 학교명과 학번으로 Cloud Function을 호출하여 이메일 주소만 반환
}
```

### 3. AuthRemoteDataSourceImpl 클래스의 signInStudent 메서드 수정

```dart
@override
Future<domain.User> signInStudent({
  required String schoolName,
  required String studentId,
  required String password,
}) async {
  try {
    // 1. 학생 로그인 이메일 조회
    final email = await _cloudFunctionsService.getStudentLoginEmail(
      schoolName: trimmedSchoolName,
      studentId: trimmedStudentId,
    );
    
    // 2. Firebase Auth SDK를 사용하여 직접 로그인
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 3. 로그인 성공 후 사용자 정보 조회 및 반환
    final userData = await _getUserData(userCredential.user!.uid);
    if (userData == null) {
      throw ServerException(message: '학생 정보를 찾을 수 없습니다.');
    }
    
    return userData;
  } catch (e) {
    // 오류 처리
  }
}
```

## 장점

1. **보안 강화**: 비밀번호가 Firebase Auth에서 직접 검증되므로 보안성이 높아졌습니다.
2. **표준화**: Firebase의 표준 인증 흐름을 따르므로 구현과 유지보수가 더 쉬워졌습니다.
3. **단순성**: Custom Token 발급 과정을 제거하여 로그인 과정이 간소화되었습니다.
4. **비용 절감**: Firestore 읽기/쓰기 작업 및 Custom Token 생성 비용이 절감되었습니다.

## 테스트 방법

1. 학생 계정으로 로그인 페이지 접속
2. 학교명과 학번, 비밀번호 입력
3. 로그인 버튼 클릭 시 다음과 같은 과정 확인:
   - 학교명과 학번으로 이메일 주소 조회 요청
   - 반환된 이메일과 입력한 비밀번호로 Firebase Auth 직접 로그인
   - 로그인 성공 시 학생 정보 조회 후 화면 전환

## 주의사항

1. 기존 Custom Token 방식 코드는 삭제되었으므로, 해당 방식을 사용하는 다른 기능이 있다면 함께 수정해야 합니다.
2. Firebase 콘솔에서 이메일/비밀번호 로그인이 활성화되어 있어야 합니다.
3. 학생 계정 생성 시 이메일 주소 형식이 "(연도 두자리)(학번)@school(학교코드 뒤 4자리).com"으로 일관되게 유지되어야 합니다.
