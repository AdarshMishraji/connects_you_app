import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_cryptography/helper.dart';

class _AES_GCM_256 {
  static final AesGcm _aesGcm = AesGcm.with256bits(nonceLength: 16);

  static AesGcm get instance {
    return _aesGcm;
  }
}

class AesGcmEncryption {
  SecretKey? _secretKey;

  AesGcmEncryption({required String secretKey}) {
    _secretKey = SecretKey(fromHex(secretKey));
  }

  Future<String?> encryptString(String string) async {
    if (_secretKey != null) {
      final aesGcm = _AES_GCM_256.instance;
      return await aesGcm
          .encrypt(utf8.encode(string), secretKey: _secretKey!)
          .then((value) => toHex(value.concatenation()));
    }
    return null;
  }

  Future<Map<String, String?>?> encryptMultiple(
      Map<String, String> keyStringMap) async {
    if (_secretKey != null) {
      final Map<String, String?> dataToSend = {};
      for (final keyVal in keyStringMap.entries) {
        final key = keyVal.key;
        final value = keyVal.value;
        final encryptedString = await encryptString(value);
        dataToSend[key] = encryptedString;
      }
      return dataToSend;
    }
    return null;
  }

  Future<String?> decryptString(String string) async {
    if (_secretKey != null) {
      final byteArray = fromHex(string);
      final secretBox = SecretBox.fromConcatenation(byteArray,
          nonceLength: 16, macLength: 16);
      final aesGcm = _AES_GCM_256.instance;
      return await aesGcm
          .decrypt(secretBox, secretKey: _secretKey!)
          .then((value) => utf8.decode(value));
    }
    return null;
  }

  Future<Map<String, String?>?> decryptMultiple(
      Map<String, String> keyStringMap) async {
    if (_secretKey != null) {
      final Map<String, String?> dataToSend = {};
      for (final keyVal in keyStringMap.entries) {
        final key = keyVal.key;
        final value = keyVal.value;
        final decryptedString = await decryptString(value);
        dataToSend[key] = decryptedString;
      }
      return dataToSend;
    }
    return null;
  }
}
