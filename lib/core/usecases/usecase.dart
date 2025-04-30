import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// 유스케이스 기본 인터페이스
/// 
/// Type 매개변수:
/// - Type: 유스케이스가 반환할 데이터 타입
/// - Params: 유스케이스 실행에 필요한 매개변수 타입
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// 매개변수가 필요 없는 유스케이스용 빈 클래스
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
