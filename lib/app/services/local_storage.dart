import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum Key {
  user,
  authToken,
  fcmToken,
  userPic,
  audioCommand,
  isFirstTime,
  deviceDetails,
  deviceName,
  notificationData,
  isLoggedInKey,
}

class LocalStorageService {
  SharedPreferences? _prefs;

  static final _singleton = LocalStorageService();

  static LocalStorageService get instance => _singleton;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    if (isFirstTime) {
      await _prefs?.clear();
      isFirstTime = false;
    }
  }

  String userKey = 'user_data';

  // set user(UserResponseDto? value) {
  //   if (value != null) {
  //     final jsonString = jsonEncode(value.toJson());
  //     _prefs?.setString(userKey, jsonString);
  //   } else {
  //     _prefs?.remove(userKey);
  //   }
  // }

  // UserResponseDto? get user {
  //   final rawJson = _prefs?.getString(userKey);
  //   if (rawJson == null) {
  //     return null;
  //   }
  //   return UserResponseDto.fromRawJson(rawJson);
  // }

  String? get authToken {
    final token = _prefs?.getString(Key.authToken.toString());
    if (token == null) {
      return null;
    }
    return token;
  }

  set authToken(String? token) {
    if (token != null) {
      _prefs?.setString(Key.authToken.toString(), token);
    } else {
      _prefs?.remove(Key.authToken.toString());
    }
  }

  String? get fcmToken {
    final token = _prefs?.getString(Key.fcmToken.toString());
    if (token == null) {
      return null;
    }
    return token;
  }

  set fcmToken(String? token) {
    if (token != null) {
      _prefs?.setString(Key.fcmToken.toString(), token);
    } else {
      _prefs?.remove(Key.fcmToken.toString());
    }
  }

  String? get deviceName {
    final deviceName = _prefs?.getString(Key.deviceName.toString());
    if (deviceName == null) {
      return null;
    }
    return deviceName;
  }

  set deviceName(String? token) {
    if (token != null) {
      _prefs?.setString(Key.deviceName.toString(), token);
    } else {
      _prefs?.remove(Key.deviceName.toString());
    }
  }

  bool get isLoggedIn {
    return _prefs?.getBool(Key.isLoggedInKey.toString()) ?? false;
  }

  set isLoggedIn(bool value) {
    if (value) {
      _prefs?.setBool(Key.isLoggedInKey.toString(), value);
    } else {
      _prefs?.remove(Key.isLoggedInKey.toString());
    }
  }

  bool get isFirstTime {
    final isFirst = _prefs?.getBool(Key.isFirstTime.name);
    if (isFirst == null) {
      return true;
    }
    return isFirst;
  }

  set isFirstTime(bool? isFirst) {
    if (isFirst != null) {
      _prefs?.setBool(Key.isFirstTime.name, isFirst);
    } else {
      _prefs?.remove(Key.isFirstTime.name);
    }
  }

  String? get userPic {
    final base64Pic = _prefs?.getString(Key.userPic.toString());
    if (base64Pic == null) {
      return null;
    }
    return base64Pic;
  }

  set userPic(String? userImage) {
    if (userImage != null) {
      _prefs?.setString(Key.userPic.toString(), userImage);
    } else {
      _prefs?.remove(Key.userPic.toString());
    }
  }

  Map<String, dynamic>? get notificationData {
    final rawJson = _prefs?.getString(Key.notificationData.toString());
    if (rawJson == null) {
      return null;
    }
    try {
      return json.decode(rawJson) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding notification data: $e');
      return null;
    }
  }

  set notificationData(Map<String, dynamic>? value) {
    if (value != null) {
      _prefs?.setString(Key.notificationData.toString(), json.encode(value));
    } else {
      _prefs?.remove(Key.notificationData.toString());
    }
  }

  // logoutUser() async {
  //   LocalStorageService.instance.user = null;
  //   LocalStorageService.instance.authToken = null;
  // }
}
