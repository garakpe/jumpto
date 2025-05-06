# Cloud Functions 구현 문서

## 학생 계정 관리를 위한 Firebase Cloud Functions

이 문서는 학생 계정 관리를 위한 Firebase Cloud Functions 구현에 대한 설명입니다.

### 개요

온라인 팝스(PAPS) 교육 플랫폼에서는 다음과 같은 Cloud Functions을 사용하여 학생 계정을 관리합니다:

1. **createStudentAuthAccount**: 학생 Firestore 문서 생성 시 Firebase Authentication 계정 자동 생성
2. **resetStudentPassword**: 교사가 학생 비밀번호를 초기화하기 위한 함수
3. **updateStudentGender**: 학생이 마이페이지에서 성별 정보 업데이트를 위한 함수

### 배포 방법

함수를 배포하려면 다음 단계를 따르세요:

```bash
cd firebase/functions
npm install
firebase deploy --only functions
```

### 함수 상세 설명

#### createStudentAuthAccount

- **트리거**: Firestore `students` 컬렉션에 문서 생성 시
- **기능**: 
  - 생성된 학생 문서에서 이메일과 비밀번호 정보 추출
  - Firebase Authentication 계정 생성
  - 생성된 계정의 UID를 Firestore 문서에 `authUid` 필드로 저장
  - 보안을 위해 Firestore에서 비밀번호 필드 삭제

#### resetStudentPassword

- **호출 방법**: `firebase.functions().httpsCallable('resetStudentPassword')`
- **매개변수**: 
  - `studentId`: 학생 ID(학번)
  - `newPassword`: 새 비밀번호
- **권한 검사**:
  - 호출자가 인증된 사용자인지 확인
  - 호출자가 교사 역할인지 확인
  - 대상 학생이 호출자(교사)에게 속해 있는지 확인
- **기능**:
  - 학생의 Firebase Authentication 계정 비밀번호 변경
  - Firestore 문서에 업데이트 시간 기록

#### updateStudentGender

- **호출 방법**: `firebase.functions().httpsCallable('updateStudentGender')`
- **매개변수**:
  - `gender`: 성별 ('남' 또는 '여')
- **권한 검사**:
  - 호출자가 인증된 사용자인지 확인
  - 호출자가 학생 역할인지 확인
- **기능**:
  - 학생의 Firestore 문서에 성별 정보 업데이트
  - 업데이트 시간 기록

### 클라이언트측 연동 방법

Flutter 앱에서 Cloud Functions를 호출하려면 다음과 같이 구현합니다:

```dart
// Cloud Functions 호출을 위한 서비스 클래스
import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionsService {
  final FirebaseFunctions _functions;
  
  CloudFunctionsService({FirebaseFunctions? functions}) 
    : _functions = functions ?? FirebaseFunctions.instance;
  
  // 학생 비밀번호 초기화
  Future<void> resetStudentPassword({
    required String studentId,
    required String newPassword,
  }) async {
    try {
      final result = await _functions.httpsCallable('resetStudentPassword').call({
        'studentId': studentId,
        'newPassword': newPassword,
      });
      
      if (result.data['success'] != true) {
        throw Exception(result.data['message'] ?? '비밀번호 초기화 실패');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // 학생 성별 업데이트
  Future<void> updateStudentGender({
    required String gender,
  }) async {
    try {
      final result = await _functions.httpsCallable('updateStudentGender').call({
        'gender': gender,
      });
      
      if (result.data['success'] != true) {
        throw Exception(result.data['message'] ?? '성별 정보 업데이트 실패');
      }
    } catch (e) {
      rethrow;
    }
  }
}
```

### 주의사항

1. 보안 규칙: Firestore 보안 규칙에서 학생 정보에 대한 적절한 접근 제어가 필요합니다.
2. 오류 처리: 클라이언트에서 함수 호출 실패 시 적절한 오류 처리가 필요합니다.
3. 비용 고려: Cloud Functions 사용량에 따른 비용이 발생할 수 있으므로 모니터링이 필요합니다.
