import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/paps_record.dart';
import '../models/paps_record_model.dart';

/// 팝스 관련 원격 데이터 소스
/// 
/// Firebase Firestore를 사용하여 팝스 측정 기록을 관리합니다.
abstract class PapsRemoteDataSource {
  /// 학생의 팝스 측정 기록 저장
  Future<PapsRecord> savePapsRecord(PapsRecord record);
  
  /// 학생의 모든 팝스 측정 기록 가져오기
  Future<List<PapsRecord>> getStudentPapsRecords(String studentId);
  
  /// 특정 반의 모든 학생의 팝스 측정 기록 가져오기
  Future<Map<String, List<PapsRecord>>> getClassPapsRecords({
    required String teacherId,
    required String className,
  });
}

/// 팝스 원격 데이터 소스 구현체
class PapsRemoteDataSourceImpl implements PapsRemoteDataSource {
  final FirebaseFirestore _firestore;
  
  /// 팝스 측정 기록 컬렉션 참조
  CollectionReference get _papsRecordsCollection => 
      _firestore.collection('paps_records');
  
  /// 학생 컬렉션 참조
  CollectionReference get _studentsCollection => 
      _firestore.collection('students');
  
  /// 생성자
  PapsRemoteDataSourceImpl(this._firestore);
  
  @override
  Future<PapsRecord> savePapsRecord(PapsRecord record) async {
    try {
      // 측정 기록을 FireStore에 저장할 형태로 변환
      final recordModel = PapsRecordModel.fromEntity(record);
      final recordData = recordModel.toJson();
      
      // 기존 레코드가 있는지 확인 (id가 있는 경우)
      if (record.id.isNotEmpty) {
        await _papsRecordsCollection.doc(record.id).set(recordData);
      } else {
        // 새 레코드 생성
        final docRef = await _papsRecordsCollection.add(recordData);
        // id가 추가된 레코드 모델 생성하여 반환
        return recordModel.copyWith(id: docRef.id);
      }
      
      return record;
    } catch (e) {
      throw Exception('팝스 측정 기록을 저장할 수 없습니다: $e');
    }
  }
  
  @override
  Future<List<PapsRecord>> getStudentPapsRecords(String studentId) async {
    try {
      // 학생 ID로 측정 기록 검색
      final querySnapshot = await _papsRecordsCollection
          .where('studentId', isEqualTo: studentId)
          .orderBy('recordedAt', descending: true)
          .get();
      
      // 쿼리 결과를 PapsRecord 객체 리스트로 변환
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // 문서 ID 추가
            return PapsRecordModel.fromJson(data);
          })
          .toList();
    } catch (e) {
      throw Exception('학생의 팝스 측정 기록을 가져올 수 없습니다: $e');
    }
  }
  
  @override
  Future<Map<String, List<PapsRecord>>> getClassPapsRecords({
    required String teacherId,
    required String className,
  }) async {
    try {
      // 1. 해당 반 학생 목록 조회
      final studentsSnapshot = await _studentsCollection
          .where('teacherId', isEqualTo: teacherId)
          .where('className', isEqualTo: className)
          .get();
      
      final studentIds = studentsSnapshot.docs.map((doc) => doc.id).toList();
      
      // 2. 각 학생별 측정 기록 조회
      final Map<String, List<PapsRecord>> result = {};
      
      for (final studentId in studentIds) {
        final records = await getStudentPapsRecords(studentId);
        result[studentId] = records;
      }
      
      return result;
    } catch (e) {
      throw Exception('반 학생들의 팝스 측정 기록을 가져올 수 없습니다: $e');
    }
  }
}
