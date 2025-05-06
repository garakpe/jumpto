# 개발 로그

## 2025년 5월 6일

### 학생 데이터 모델 통합 및 필드 명 표준화

#### 작업 내용
- Student 엔티티와 StudentModel 클래스에 gender 필드 추가
- 다양한 학생 관련 클래스를 StudentModel로 통합
- gender 필드를 Firestore에 저장할 수 있도록 toFirestore() 메서드 업데이트
- 기존 학생 관련 메서드(fromFirestore, fromMap, fromEntity)도 gender 필드를 지원하도록 수정
- 학생 관련 필드 명 표준화
  - auth_remote_data_source.dart 파일의 className → classNum으로 변경
  - auth_remote_data_source.dart 파일의 studentNumber → studentNum/studentId로 변경
  - User 엔티티의 classId → classNum으로 변경
  - User 엔티티의 studentNumber → studentNum으로 변경
  - User 엔티티에 studentId 필드 추가

#### 수정된 파일
- `/lib/features/auth/domain/entities/student.dart`
- `/lib/features/auth/data/models/student_model.dart`
- `/lib/features/auth/domain/entities/user.dart`
- `/lib/features/auth/data/datasources/auth_remote_data_source.dart`

#### 개선 효과
- 학생 성별에 따른 PAPS 기준표 조회 및 등급 산출 기능 구현 가능
- 학생 데이터 모델의 일관성 확보
- 필드 명 표준화로 코드의 가독성 및 유지보수성 향상
- 전체 시스템에서 일관된 용어 사용으로 혼동 방지
- 향후 새로운 기능 개발 시 출돌 위험 최소화
- 클린 아키텍처 원칙에 따른 코드 구조 개선

## 2025년 5월 4일

### 웹 환경 팝스 측정 기능 문제 해결

#### 문제 상황
- 웹 환경에서 '팝스 측정' 기능이 작동하지 않는 문제 발생
- 직전에 해결했던 팝스 기준표 조회 문제와 유사한 증상
- 원인: 웹 빌드 시 assets 폴더가 중첩되어 생성되어 파일 참조 경로 문제 발생

#### 해결 방안

1. **LoadPapsStandards 클래스 개선**
   - 웹 환경에서 localStorage 활용 캐싱 기능 구현
   - 다양한 경로로 JSON 파일 로드 시도 로직 추가
   - 모든 로드 시도 실패 시 기본 폴백 데이터 제공 메커니즘 추가

2. **앱 시작 시 미리 로드 기능 추가**
   - main.dart 파일에 웹 환경 전용 사전 로드 로직 추가
   - 앱 시작 시 JSON 파일을 미리 로드하여 localStorage에 캐싱
   - 다양한 경로 시도 메커니즘 구현

3. **의존성 추가**
   - `universal_html` 패키지 추가로 웹 환경에서 localStorage 접근 지원

4. **프로젝트 문서 업데이트**
   - 문제 해결 과정 및 결과 기록
   - 웹 환경에서의 동작 메커니즘 설명 추가

#### 수정된 파일
- `/lib/features/paps/domain/usecases/load_paps_standards.dart`
- `/lib/main.dart`
- `/pubspec.yaml`
- `/project_docs/project_plan.md`
- `/project_docs/development_log.md`

#### 개선 효과
- 웹 환경에서 팝스 측정 기능 정상 작동
- 다양한 경로 시도 및 캐싱으로 안정성 향상
- 모든 로드 시도 실패 시에도 기본 폴백 데이터로 앱 작동 보장
- 웹 환경에서의 에셋 로드 메커니즘 강화

### 추가 작업 예정
- 팝스 기록 조회 화면 구현
- 모든 화면에 대한 캐싱 메커니즘 강화
- 부모나 교사가 학생 기록을 조회할 수 있는 기능 구현

### 팝스 기준표 조회 기능 문제 해결 (이전 작업)

#### 문제 상황
- Firebase 호스팅 환경에서 팝스 기준표를 조회할 수 없는 문제 발생
- 개발 환경(flutter run -d chrome)에서는 정상적으로 작동하지만, 배포 환경에서는 오류 발생
- 원인: Firebase 호스팅에서 파일(paps_standards.json)을 제대로 로드하지 못하는 문제

#### 해결 방안

1. **에셋 로딩 개선**
   - PapsLocalDataSource 클래스 수정
   - 여러 경로에서 파일을 로드하는 방식 구현
   - LocalStorage를 활용한 캐싱 기능 추가
   - 기본 기준표 데이터 폴백 기능 구현

2. **Firebase 호스팅 최적화**
   - firebase.json 수정
   - JSON 파일에 대한 MIME 타입 정의
   - CORS 헤더 설정 추가

3. **분석과 디버깅 기능 추가**
   - 로그 추가로 데이터 로드 과정 추적 가능
   - 상태 변경을 효과적으로 모니터링
   - 에러 상황 추적 로직 추가

4. **배포 프로세스 개선**
   - build_and_deploy.sh 스크립트 추가
   - 에셋 파일을 웹 빌드 폴더에 직접 복사하는 과정 추가
   - 배포 자동화 구현

5. **index.html 개선**
   - 에셋 사전 로드 메커니즘 추가
   - 여러 경로를 시도하는 방식으로 안정성 강화
   - 로컬스토리지를 활용한 캐싱 기능 적용

#### 수정된 파일
- `/lib/features/paps/data/datasources/paps_local_data_source.dart`
- `/web/index.html`
- `/lib/features/paps/presentation/pages/paps_standards_page.dart`
- `/lib/features/paps/presentation/pages/paps_measurement_page.dart`
- `/firebase.json`
- `/build_and_deploy.sh` (새로 추가)
- `/paps_standards.json` (새로 추가)# 개발 로그

## 2025-05-03: 팝스 기준표 조회 문제 해결

### 발생한 문제
- 웹 배포 환경에서 팝스 기준표 조회 및 측정 기능 작동하지 않음
- Firebase 호스팅 환경에서 에셋 파일(paps_standards.json) 로드 실패
- JavaScript 콘솔에 Firebase 스크립트 관련 오류 발생

### 수행한 작업

#### 1. 에셋 로딩 방식 개선
- PapsLocalDataSource 클래스 수정
  - 여러 가지 에셋 로드 경로 시도 기능 추가
  - 로컬 스토리지(localStorage) 활용 캐싱 기능 구현
  - 데이터 로드 실패 시 대체 데이터 제공 기능 추가

#### 2. 웹 인덱스 파일 최적화
- web/index.html 파일 수정
  - 불필요한 Firebase 스크립트 제거
  - 여러 경로로 에셋 로드 시도 기능 개선
  - 에셋 사전 로드 및 캐싱 기능 강화

#### 3. 디버깅 로그 추가
- 팝스 기준표 조회 화면에 디버깅 로그 추가
- 팝스 측정 화면에 디버깅 로그 추가
- 데이터 로드 과정 추적 가능하도록 로그 개선

#### 4. Firebase 호스팅 설정 개선
- firebase.json 파일 수정
  - JSON 파일에 대한 MIME 타입 및 CORS 헤더 추가
  - 에셋 파일 접근 관련 설정 최적화

#### 5. 배포 프로세스 개선
- 빌드 및 배포 스크립트 작성
  - 에셋 파일을 웹 빌드 폴더에 직접 복사하는 로직 추가
  - 루트 경로에도 데이터 파일 배치하여 접근성 향상
- 최소 데이터 파일 추가하여 확실한 폴백 제공

### 개선 효과
- 다양한 경로로 에셋 파일 로드 시도하여 접근성 향상
- 로컬 스토리지를 활용한 캐싱으로 성능 및 안정성 개선
- 에셋 로드 실패 시에도 기본 데이터 제공으로 앱 작동 보장
- 디버깅 용이성 향상으로 추후 문제 발생 시 원인 파악 용이
