# 학생 로그인 기능 보안 취약점 개선 내역

## 개요

이 문서는 온라인 팝스(PAPS) 교육 플랫폼의 학생 로그인 시스템에서 발견된 보안 취약점과 그 개선 과정에 대해 설명합니다. 기존 시스템의 심각한 보안 문제를 해결하고 Firebase 표준 인증 방식을 구현하였습니다.

## 문제점

기존 `studentLogin` Cloud Function은 다음과 같은 치명적인 보안 취약점을 가지고 있었습니다:

1. **비밀번호 미검증**: 서버에서 사용자가 입력한 비밀번호를 검증하지 않고 Custom Token을 발급했습니다.
2. **취약한 인증 흐름**: 학교명과 학번만 알면 비밀번호 없이도 인증 토큰을 발급받을 수 있었습니다.
3. **불필요한 복잡성**: 여러 단계의 통신을 거쳐 인증하는 방식으로, 클라이언트-서버-Firebase 간에 불필요한 왕복이 발생했습니다.
4. **높은 비용**: 여러 차례의 Firebase 함수 호출과 Firestore 읽기/쓰기가 필요했습니다.

## 구현된 해결책

보안 취약점을 해결하기 위해 다음과 같은 방식으로 학생 로그인 시스템을 재설계했습니다:

1. **새로운 Cloud Function 구현**: `getStudentLoginEmail` 함수를 구현하여 학교명과 학번만으로 이메일을 조회할 수 있도록 했습니다.
2. **Firebase 표준 인증 방식 적용**: 클라이언트에서 Firebase Authentication SDK의 `signInWithEmailPassword` 메서드를 사용하도록 변경했습니다.
3. **명확한 역할 구분**:
   - 서버: 학교명과 학번을 기반으로 Firebase Auth 이메일 주소 생성
   - 클라이언트: Firebase Auth SDK를 통해 비밀번호 검증 및 로그인 처리

## 이점

1. **강화된 보안**: 비밀번호가 개발자 서버를 거치지 않고 Firebase Auth에서 직접 처리됩니다.
2. **효율성 향상**: 인증 흐름을 단순화하고 불필요한 함수 호출을 제거했습니다.
3. **비용 절감**: Cloud Functions 호출 횟수와 Firestore 작업이 감소했습니다.
4. **사용자 경험 유지**: 학생들은 여전히 학교명과 학번으로 로그인하는 경험을 유지합니다.

## 구현 세부 사항

### 1. Cloud Functions

- `getStudentLoginEmail`: 학교명과 학번을 받아 Firebase Auth 이메일 주소 반환
  - 형식: `(연도 두자리)(학번)@school(학교코드 뒤 4자리).com`
  - 예: `2530101@school3550.com`

### 2. 클라이언트 로직

- `CloudFunctionsService`: Cloud Functions 호출 로직 개선
  - `getStudentLoginEmail` 메서드 추가
  - `studentLogin` 메서드 제거 (더 이상 사용하지 않음)

- `AuthRemoteDataSourceImpl`: 인증 로직 개선
  - `signInStudent` 메서드에서 2단계 인증 프로세스 구현:
    1. `getStudentLoginEmail`로 이메일 가져오기
    2. Firebase Auth SDK로 직접 로그인

### 3. 인터페이스 변경 없음

도메인 계층의 인터페이스(UseCase, Repository)는 변경되지 않았으며, 기존 코드와의 호환성을 유지했습니다.

## 테스트 결과

- 학교명과 학번으로 이메일 조회 성공
- Firebase Auth SDK로 비밀번호 검증 성공
- 로그인 실패 시 적절한 오류 메시지 표시
- 인증 상태 유지 및 라우팅 정상 작동

## 향후 계획

- 사용자 경험 개선을 위한 오류 메시지 상세화
- 비밀번호 정책 강화 (길이, 복잡성 등)
- 로그인 시도 제한 기능 추가 (브루트 포스 공격 방지)
