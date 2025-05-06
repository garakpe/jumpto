import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/student.dart';

/// 학생 레포지토리 인터페이스
///
/// 학생 데이터 관리를 위한 레포지토리 인터페이스
abstract class StudentRepository {
  /// 교사가 관리하는 학생 목록 조회
  Future<Either<Failure, List<Student>>> getStudentsByTeacherId(String teacherId);
  
  /// 특정 학교의 학생 조회
  Future<Either<Failure, List<Student>>> getStudentsBySchoolId(String schoolId);
  
  /// 특정 학급의 학생 조회
  Future<Either<Failure, List<Student>>> getStudentsByClass(String teacherId, String grade, String classNum);
  
  /// 학생 계정 생성 (단일)
  Future<Either<Failure, Student>> createStudent(Student student);
  
  /// 학생 계정 일괄 생성
  Future<Either<Failure, List<Student>>> uploadStudents(List<Student> students);
  
  /// 학생 정보 수정
  Future<Either<Failure, Student>> updateStudent(Student student);
  
  /// 학생 비밀번호 재설정
  Future<Either<Failure, void>> resetStudentPassword(String studentId, String newPassword);
  
  /// 학생 ID로 학생 조회
  Future<Either<Failure, Student>> getStudentById(String id);
  
  /// 학번으로 학생 조회
  Future<Either<Failure, Student>> getStudentByStudentId(String studentId);
  
  /// 학생 계정 삭제
  Future<Either<Failure, void>> deleteStudent(String id);
  
  /// 학생 성별 업데이트
  Future<Either<Failure, void>> updateStudentGender(String gender);
}
