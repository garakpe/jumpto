# 인증 시스템 버그 수정 내역

## 문제 상황

앱 실행 시 회색 화면만 나타나는 현상이 발생했습니다. 콘솔 로그에서 다음과 같은 오류가 확인되었습니다:

```
Bad state: GetIt: Object/factory with type minified:bmL is not registered inside GetIt.
(Did you accidentally do GetIt sl=GetIt.instance(); instead of GetIt sl=GetIt.instance;
Did you forget to register it?)
```

이 오류는 의존성 주입 라이브러리인 GetIt과 관련된 문제로, 필요한 클래스가 적절히 등록되지 않았거나 참조할 수 없는 상태였습니다.

## 원인 분석

코드를 분석한 결과, 다음과 같은 여러 문제가 발견되었습니다:

1. **CloudFunctionsService 클래스 구조 문제**:
   - 클래스 내에 정의되어야 할 메서드들이 클래스 외부에 정의되어 있었습니다.
   - `studentLogin`, `createBulkStudentAccounts` 등의 메서드가 잘못된 위치에 있었습니다.

2. **의존성 주입 문제**:
   - `injection_container.dart`에서 `CloudFunctionsService`의 import 경로가 잘못되어 있었습니다.
   - `AuthRemoteDataSourceImpl`의 생성자가 세 개의 매개변수를 필요로 하도록 변경되었지만, `CloudFunctionsService`가 제대로 주입되지 않았습니다.

3. **삭제된 파일 참조 문제**:
   - `LoginWithEmailPassword` 유스케이스 파일이 비어 있거나 삭제되었지만, 다른 코드에서 여전히 이를 참조하고 있었습니다.

4. **import 경로 불일치**:
   - `StudentRemoteDataSource`에서 `CloudFunctionsService`의 import 경로가 잘못되어 있었습니다.

## 수행한 수정 내용

다음과 같은 수정을 통해 문제를 해결했습니다:

1. **CloudFunctionsService 클래스 구조 수정**:
   - 클래스 외부에 정의된 메서드들을 클래스 내부로 이동시켰습니다.
   - 모든 메서드가 올바른 형태로 클래스에 포함되도록 구조를 재구성했습니다.

2. **의존성 주입 경로 수정**:
   - `injection_container.dart`에서 잘못된 import 경로를 수정했습니다:
     ```dart
     import '../core/firebase/cloud_functions_service.dart';
     ```
     
   - `StudentRemoteDataSource`에서 잘못된 import 경로를 수정했습니다:
     ```dart
     import '../../../../core/firebase/cloud_functions_service.dart';
     ```

3. **삭제된 파일 복원**:
   - 빈 `login_with_email_password.dart` 파일을 복원하고 기존 기능과 동일한 코드를 추가했습니다.
   - `injection_container.dart`에 `LoginWithEmailPassword` 의존성을 등록했습니다:
     ```dart
     sl.registerLazySingleton(() => LoginWithEmailPassword(sl()));
     ```

4. **코드 문서화 업데이트**:
   - `login_with_email_password.dart`에 이 파일이 레거시 코드 호환성을 위해 유지된다는 주석을 추가했습니다.
   - 프로젝트 계획 문서에 문제 해결 내역을 기록했습니다.

## 교훈 및 향후 개선 사항

1. **일관된 코드 구조 유지**: 모든 클래스에서 일관된 구조를 유지해야 합니다. 메서드 위치, import 경로 등이 일관되어야 합니다.

2. **의존성 체계 관리**: 의존성을 추가하거나 변경할 때는 항상 의존성 주입 컨테이너를 업데이트해야 합니다.

3. **리팩토링 주의사항**: 파일을 삭제하거나 내용을 비울 때는 해당 파일을 참조하는 모든 코드를 확인해야 합니다.

4. **명확한 문서화**: 코드 변경 시 주석과 프로젝트 문서를 함께 업데이트하여 다른 개발자가 변경 내용을 이해할 수 있도록 해야 합니다.

이번 버그 수정을 통해 앱이 정상적으로 실행되는 것을 확인했습니다. 이제 서울 지역(asia-northeast3)에 Cloud Functions를 배포하고 추가 기능을 개발할 수 있게 되었습니다.