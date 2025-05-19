import 'package:equatable/equatable.dart';

import '../../../../../core/usecases/usecase.dart';
import '../entities/base_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser implements UseCase<BaseUser?, NoParams> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<BaseUser?> call(NoParams params) {
    return repository.getCurrentUser();
  }
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
