import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  /// 로컬에 저장된 사용자 정보 가져오기
  ///
  /// 성공 시 [UserModel] 반환, 실패 시 예외 발생
  Future<UserModel?> getLastLoggedInUser();

  /// 사용자 정보 로컬에 저장
  ///
  /// [userModel] 저장할 사용자 정보
  Future<void> cacheUser(UserModel userModel);

  /// 로컬에 저장된 사용자 정보 삭제
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel?> getLastLoggedInUser() async {
    final jsonString = sharedPreferences.getString('CACHED_USER');
    if (jsonString != null) {
      return UserModel.fromJson(json.decode(jsonString));
    }
    return null;
  }

  @override
  Future<void> cacheUser(UserModel userModel) async {
    await sharedPreferences.setString(
      'CACHED_USER',
      json.encode(userModel.toJson()),
    );
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.remove('CACHED_USER');
  }
}