part of 'student_cubit.dart';

abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentLoaded extends StudentState {
  final List<Student> students;

  const StudentLoaded({required this.students});

  @override
  List<Object> get props => [students];
}

class StudentSuccess extends StudentState {
  final String message;

  const StudentSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class StudentError extends StudentState {
  final String message;

  const StudentError({required this.message});

  @override
  List<Object> get props => [message];
}
