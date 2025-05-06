import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/student_repository.dart';

/// 학생 성별 업데이트를 위한 파라미터
class UpdateStudentGenderParams extends Equatable {
  /// 성별 ("남" 또는 "여")
  final String gender;

  const UpdateStudentGenderParams({required this.gender});

  @override
  List<Object?> get props => [gender];
}

/// 학생 성별 업데이트 유스케이스
///
/// 학생 마이페이지에서 성별 정보를 저장할 때 사용합니다.
class UpdateStudentGender implements UseCase<void, UpdateStudentGenderParams> {
  final StudentRepository _repository;

  UpdateStudentGender(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdateStudentGenderParams params) {
    return _repository.updateStudentGender(params.gender);
  }
}
