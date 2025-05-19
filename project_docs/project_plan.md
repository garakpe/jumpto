# 온라인 팝스(PAPS) 교육 플랫폼 개발 계획

## 프로젝트 개요

- **프로젝트명**: 온라인 팝스(PAPS) 교육 플랫폼
- **개발 목표**: 학교 현장의 팝스(PAPS) 단원 운영을 내실화하고, 학생들의 자기 주도 학습 및 교사의 효율적인 수업 운영/평가를 지원하는 웹 기반 교육 플랫폼 개발
- **아키텍처**: Flutter + Firebase 기반, 클린 아키텍처 적용

## 개발 현황

### 완료된 작업
(이전 내용 생략)

### 현재 진행 중인 작업

- 사용자 모델 구조 리팩토링
  - BaseUser, Teacher, Student, Admin 모델로 분리
  - Firestore 데이터베이스 구조 개선 (users, teachers_details, students_details, admins_details 컬렉션)
  - 관련 데이터 소스, 레포지토리, 유스케이스, Cubit 수정
  - 리팩토링 문서 작성 (project_docs/refactoring/auth_models/리팩토링_적용_가이드.md)

- 교사용 대시보드 개발 진행 중
  - 나머지 탭 (출석부, 측정결과조회, 평가, 되돌아보기) 상세 기능 구현

- 학생 관리 기능 구현
  - 학생 마이페이지 비밀번호 재설정 기능 연결

- Cloud Functions 배포 및 테스트
  - Firebase CLI를 이용한 함수 배포
  - 학생 계정 자동 생성 및 비밀번호 초기화 테스트
  - 성별 업데이트 기능 테스트
  - 학생 로그인 이메일 조회 및 직접 로그인 테스트

### 새로 추가된 작업 계획

- 사용자 모델 리팩토링 진행
  - 기존 User/Student 모델을 BaseUser/Teacher/Student/Admin 모델로 세분화
  - 역할별 책임 명확히 분리
  - 데이터베이스 구조 변경 (컬렉션 분리)
  - 기존 코드와의 호환성 유지

## 클린 아키텍처 구현 현황

### 도메인 계층 (Domain Layer)

- **엔티티 추가 및 수정**:
  - BaseUser 엔티티 신규 추가
  - Teacher 엔티티 신규 추가
  - Student 엔티티 리팩토링 (BaseUser 컴포지션 적용)
  - Admin 엔티티 신규 추가

### 데이터 계층 (Data Layer)

- **모델 추가 및 수정**:
  - BaseUserModel 신규 추가
  - TeacherModel 신규 추가
  - StudentModel 리팩토링 (BaseUserModel 컴포지션 적용)
  - AdminModel 신규 추가

### 프레젠테이션 계층 (Presentation Layer)

- **상태 관리 개선**:
  - AuthCubit, AuthState 리팩토링
  - StudentCubit, StudentState 리팩토링

## 향후 개선 사항

- **사용자 모델 구조 개선**: 역할별 책임 명확화 및 확장성 향상
- **코드 구조 개선**: 클린 아키텍처 원칙 일관성 있게 적용
- **데이터베이스 구조 개선**: 적절한 컬렉션 분리로 권한 관리 강화
- **테스트 자동화**: 새로운 모델 구조에 맞는 단위 테스트 작성
