import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/teacher_settings.dart';
import '../models/teacher_settings_model.dart';

/// 교사 설정 원격 데이터 소스 인터페이스
abstract class TeacherSettingsRemoteDataSource {
  /// 교사 ID로 교사 설정 조회
  /// 
  /// [teacherId] 교사 ID
  /// 
  /// 성공 시 [TeacherSettingsModel] 반환, 실패 시 [ServerException] 발생
  Future<TeacherSettingsModel> getTeacherSettings(String teacherId);

  /// 교사 설정 저장
  /// 
  /// [settings] 저장할 교사 설정
  /// 
  /// 성공 시 [TeacherSettingsModel] 반환, 실패 시 [ServerException] 발생
  Future<TeacherSettingsModel> saveTeacherSettings(TeacherSettingsModel settings);
}

/// 교사 설정 원격 데이터 소스 구현체 (Firebase Firestore)
class TeacherSettingsRemoteDataSourceImpl implements TeacherSettingsRemoteDataSource {
  final FirebaseFirestore firestore;

  TeacherSettingsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<TeacherSettingsModel> getTeacherSettings(String teacherId) async {
    try {
      final documentSnapshot = await firestore
          .collection('teacher_settings')
          .doc(teacherId)
          .get();

      if (documentSnapshot.exists) {
        return TeacherSettingsModel.fromJson(
          documentSnapshot.data() as Map<String, dynamic>,
        );
      } else {
        // 설정이 없는 경우 기본 설정 반환
        final defaultSettings = TeacherSettingsModel.fromDomain(
          TeacherSettings.defaultSettings(teacherId),
        );
        
        // 기본 설정을 Firestore에 저장
        await saveTeacherSettings(defaultSettings);
        
        return defaultSettings;
      }
    } catch (e) {
      throw ServerException(message: '교사 설정 조회 실패: $e');
    }
  }

  @override
  Future<TeacherSettingsModel> saveTeacherSettings(TeacherSettingsModel settings) async {
    try {
      // 저장 시간 업데이트
      final updatedSettings = settings.copyWith(
        updatedAt: DateTime.now(),
      );
      
      // Firestore에 저장
      await firestore
          .collection('teacher_settings')
          .doc(updatedSettings.teacherId)
          .set(updatedSettings.toJson());

      return updatedSettings;
    } catch (e) {
      throw ServerException(message: '교사 설정 저장 실패: $e');
    }
  }
}