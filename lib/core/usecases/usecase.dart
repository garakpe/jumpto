import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// 유스케이스 추상 클래스
///
/// [Type]은 반환 타입, [Params]는 파라미터 타입
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// 파라미터가 필요 없는 유스케이스를 위한 NoParams 클래스
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}