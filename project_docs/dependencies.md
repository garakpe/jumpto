# 프로젝트 의존성(Dependencies) 문서

이 문서는 온라인 팝스(PAPS) 교육 플랫폼 프로젝트에서 사용하는 주요 의존성 패키지들과 그 용도를 설명합니다.

## 주요 프레임워크 및 패키지

### Flutter 및 Dart
- **flutter**: UI 프레임워크
- **dart**: 프로그래밍 언어

### Firebase 관련
- **firebase_core**: Firebase 서비스 초기화
- **firebase_auth**: 사용자 인증(로그인, 회원가입)
- **cloud_firestore**: NoSQL 데이터베이스
- **firebase_storage**: 파일 저장소

### 상태 관리
- **flutter_bloc**: BLoC/Cubit 패턴을 통한 상태 관리
- **equatable**: 객체 동등성(equality) 비교 단순화

### 의존성 주입
- **get_it**: 서비스 로케이터 패턴을 통한 의존성 주입
- **injectable**: 의존성 주입 코드 생성기

### 라우팅
- **go_router**: 앱 내 화면 전환 및 라우팅 처리

### 유틸리티
- **intl**: 국제화 및 지역화, 날짜 포맷팅
- **uuid**: 고유 식별자 생성
- **rxdart**: 반응형 프로그래밍
- **universal_html**: 플랫폼 독립적인 HTML/localStorage 접근 (웹 환경 최적화)

### 함수형 프로그래밍
- **dartz**: Either 타입 등 함수형 프로그래밍 구조 지원

### 코드 생성 및 도구
- **freezed_annotation**: 불변(immutable) 클래스 생성 어노테이션
- **json_annotation**: JSON 직렬화/역직렬화 어노테이션
- **flutter_lints**: 코드 스타일 및 오류 분석
- **build_runner**: 코드 생성 실행 도구
- **freezed**: 불변(immutable) 클래스 생성기
- **json_serializable**: JSON 직렬화/역직렬화 코드 생성기
- **injectable_generator**: 의존성 주입 코드 생성기

## 패키지 버전 및 의존성 관리

패키지 버전은 pubspec.yaml 파일에서 관리됩니다. 최신 버전 확인 및 업데이트를 위해 다음 명령어를 사용할 수 있습니다:

```bash
# 의존성 업데이트
flutter pub upgrade

# 현재 버전 확인
flutter pub outdated
```

## 최근 추가된 패키지

### universal_html
- **버전**: ^2.2.4
- **용도**: 웹 환경에서 localStorage 접근 및 에셋 로드 문제 해결
- **추가 날짜**: 2025-05-04
- **관련 기능**: 웹 환경에서 팝스 측정 기능 문제 해결
