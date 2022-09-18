import 'dart:convert';

import 'package:connects_you/constants/keys.dart';
import 'package:connects_you/data/gDriveOps/gDriveOps.dart';
import 'package:connects_you/data/models/sharedKey.dart';
import 'package:connects_you/enums/room.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cryptography/AesGcmEncryption.dart';

class GDriveOpsRepository {
  const GDriveOpsRepository();

  final GDriveOpsDataSource gDriveOpsDataSource = GDriveOpsDataSource.instance;

  Future<bool> saveUserKeys({
    required String userId,
    required String privateKey,
    String? publicKey,
  }) async {
    try {
      final jsonEncodedString = jsonEncode({
        'privateKey': privateKey,
        ...(publicKey != null ? {'publicKey': publicKey} : {})
      });
      final encryptedJsonString =
          await AesGcmEncryption(secretKey: Keys.ENCRYTION_KEY)
              .encryptString(jsonEncodedString);
      if (encryptedJsonString != null) {
        return await gDriveOpsDataSource.saveToDrive(
            '$userId.json', encryptedJsonString);
      }
      throw Exception('unable to encrypt');
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  Future<dynamic> getDriveSharedKeys(
      [bool shouldDecryptAndInArray = false, String? existedFileId]) async {
    try {
      final fileResponse =
          await gDriveOpsDataSource.getDriveSharedKeys(existedFileId);
      if (shouldDecryptAndInArray) {
        if (fileResponse != null && fileResponse.isNotEmpty) {
          final Map<String, dynamic> duetKeys =
              fileResponse[RoomType.DUET.value];
          final Map<String, dynamic> groupKeys =
              fileResponse[RoomType.GROUP.value];
          final List<SharedKey> dataToSend = [];
          final aes = AesGcmEncryption(secretKey: Keys.ENCRYTION_KEY);

          for (final keyValue in duetKeys.entries) {
            final key = keyValue.key;
            final value = keyValue.value;
            final encryptedSharedKey = value?.get('sharedKey');
            if (encryptedSharedKey != null) {
              final sharedKey = await aes.decryptString(encryptedSharedKey);
              if (sharedKey != null) {
                dataToSend.add(
                  SharedKey(
                    id: key,
                    keyType: RoomType.GROUP,
                    sharedKey: sharedKey,
                  ),
                );
              } else {
                break;
              }
            }
          }
          assert(duetKeys.length == dataToSend.length);

          for (final keyValue in groupKeys.entries) {
            final key = keyValue.key;
            final value = keyValue.value;
            final encryptedSharedKey = value?.get('sharedKey');
            if (encryptedSharedKey != null) {
              final sharedKey = await aes.decryptString(encryptedSharedKey);
              if (sharedKey != null) {
                dataToSend.add(
                  SharedKey(
                    id: key,
                    keyType: RoomType.GROUP,
                    sharedKey: sharedKey,
                  ),
                );
              } else {
                break;
              }
            } else {
              break;
            }
          }
          assert(groupKeys.length == (dataToSend.length - duetKeys.length));
          return dataToSend;
        }
        return null;
      }
      return fileResponse;
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<bool> saveSharedKeysToDrive(List<SharedKey> sharedKeys) async {
    try {
      final sharedKeyFileId = await gDriveOpsDataSource.getSharedKeyFileId();
      final prevSharedKeyData = await getDriveSharedKeys(false, sharedKeyFileId)
          as Map<String, Map<String, String>>;
      AesGcmEncryption aesGcm = AesGcmEncryption(secretKey: Keys.ENCRYTION_KEY);

      final Map<String, dynamic> toUpdateResData = prevSharedKeyData;
      final sharedAtMilliSec = DateTime.now().millisecondsSinceEpoch;
      for (var element in sharedKeys) {
        final encryptedString = await aesGcm.encryptString(element.sharedKey);
        toUpdateResData[element.keyType][element.id] = {
          'sharedKey': encryptedString,
          'sharedAt': sharedAtMilliSec
        };
      }
      return await gDriveOpsDataSource.saveToDrive(
        GDriveOpsDataSource.sharedKeyFileName,
        jsonEncode(toUpdateResData),
        sharedKeyFileId,
      );
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  Future<Map<String, dynamic>?> getDriveUserData(String userId) async {
    try {
      final response = await gDriveOpsDataSource.getDriveUserData(userId);
      final decryptedJSON =
          await AesGcmEncryption(secretKey: Keys.ENCRYTION_KEY)
              .decryptString(response);
      if (decryptedJSON != null) {
        final jsonDecoded = jsonDecode(decryptedJSON);
        return jsonDecoded;
      }
      throw Exception('decrypted json null');
    } catch (error) {
      debugPrint(error.toString());
      return {};
    }
  }
}
