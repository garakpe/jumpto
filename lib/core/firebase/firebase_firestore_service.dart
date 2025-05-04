import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Firestore 서비스
///
/// Firestore와 상호작용하는 서비스
class FirebaseFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Firestore 인스턴스 가져오기
  FirebaseFirestore get firestore => _firestore;

  /// 문서 가져오기
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collection,
    required String documentId,
  }) async {
    return await _firestore.collection(collection).doc(documentId).get();
  }

  /// 문서 저장/업데이트
  Future<void> setDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    await _firestore.collection(collection).doc(documentId).set(data, SetOptions(merge: merge));
  }

  /// 컬렉션 쿼리
  Future<QuerySnapshot<Map<String, dynamic>>> queryCollection({
    required String collection,
    required List<QueryFilter> filters,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);

    for (var filter in filters) {
      query = query.where(filter.field, isEqualTo: filter.value);
    }

    return await query.get();
  }
}

/// 쿼리 필터
class QueryFilter {
  final String field;
  final dynamic value;

  QueryFilter({required this.field, required this.value});
}