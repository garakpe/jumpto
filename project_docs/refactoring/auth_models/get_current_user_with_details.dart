import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserWithDetails implements UseCase<Either<Failure, dynamic>, NoParams> {
  final AuthRepository repository;

  GetCurrentUserWithDetails(this.repository);

  @override
  Future<Either<Failure, dynamic>> call(NoParams params) {
    return repository.getCurrentUserWithDetails();
  }
}
