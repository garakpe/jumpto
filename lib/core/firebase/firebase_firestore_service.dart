import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/paps/domain/entities/paps_record.dart';
import '../../features/paps/data/models/paps_record_model.dart';

/// Firebase Firestore 서비스
class FirebaseFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 컬렉션 참조
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get studentsCollection => _firestore.collection('students');
  CollectionReference get papsRecordsCollection => _firestore.collection('paps_records');
  CollectionReference get papsStandardsCollection => _firestore.collection('paps_standards');

  /// 사용자 정보 가져오기
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await usersCollection.doc(uid).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print('사용자 정보 가져오기 오류: $e');
      rethrow;
    }
  }

  /// 학생 정보 가져오기
  Future<Map<String, dynamic>?> getStudentData(String studentId) async {
    try {
      final doc = await studentsCollection.doc(studentId).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print('학생 정보 가져오기 오류: $e');
      rethrow;
    }
  }

  /// 특정 학급의 학생 목록 가져오기
  Future<List<Map<String, dynamic>>> getClassStudents({
    required String teacherId,
    required String className,
  }) async {
    try {
      final querySnapshot = await studentsCollection
          .where('teacherId', isEqualTo: teacherId)
          .where('classId', isEqualTo: className)
          .get();
          
      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('학급 학생 목록 가져오기 오류: $e');
      rethrow;
    }
  }

  /// 팝스 측정 기록 저장
  Future<PapsRecord> savePapsRecord(PapsRecord record) async {
    try {
      final recordModel = PapsRecordModel.fromEntity(record);
      final recordData = recordModel.toJson();
      
      // 기존 레코드가 있는지 확인
      if (record.id.isNotEmpty) {
        await papsRecordsCollection.doc(record.id).set(recordData);
        return record;
      } else {
        // 새 레코드 생성
        final docRef = await papsRecordsCollection.add(recordData);
        // id가 추가된 레코드 모델 생성하여 반환
        return recordModel.copyWith(id: docRef.id);
      }
    } catch (e) {
      print('팝스 측정 기록 저장 오류: $e');
      rethrow;
    }
  }

  /// 학생의 팝스 측정 기록 가져오기
  Future<List<PapsRecord>> getStudentPapsRecords(String studentId) async {
    try {
      final querySnapshot = await papsRecordsCollection
          .where('studentId', isEqualTo: studentId)
          .orderBy('recordedAt', descending: true)
          .get();
          
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // 문서 ID 추가
        return PapsRecordModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('학생 팝스 측정 기록 가져오기 오류: $e');
      rethrow;
    }
  }

  /// 교사의 팝스 종목 선택 설정 저장
  Future<void> saveTeacherEventSelections({
    required String teacherId,
    required Map<String, String> selectedEvents,
  }) async {
    try {
      await usersCollection.doc(teacherId).update({
        'papsEventSelections': selectedEvents,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('교사 팝스 종목 설정 저장 오류: $e');
      rethrow;
    }
  }

  /// 교사의 팝스 종목 선택 설정 가져오기
  Future<Map<String, String>> getTeacherEventSelections(String teacherId) async {
    try {
      final doc = await usersCollection.doc(teacherId).get();
      if (!doc.exists) {
        return {};
      }
      
      final data = doc.data() as Map<String, dynamic>;
      final selections = data['papsEventSelections'] as Map<String, dynamic>?;
      
      if (selections == null) {
        return {};
      }
      
      return selections.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      print('교사 팝스 종목 설정 가져오기 오류: $e');
      return {};
    }
  }
}
