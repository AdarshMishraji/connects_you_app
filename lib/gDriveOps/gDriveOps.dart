import 'dart:convert';
import 'dart:developer';

import 'package:connects_you/constants/encryptedStorageKeys.dart';
import 'package:connects_you/constants/keys.dart';
import 'package:connects_you/enums/room.dart';
import 'package:connects_you/extensions/map.dart';
import 'package:connects_you/helpers/secureStorage.dart';
import 'package:connects_you/models/sharedKey.dart';
import 'package:connects_you/providers/auth.dart';
import 'package:flutter_cryptography/AesGcmEncryption.dart';
import 'package:gdrive/gdrive.dart';

class GDriveOps {
  static const sharedKeyFileName = 'sharedKeys.json';

  static Future<String?> get _sharedKeyFileId async {
    return await SecureStorage.instance
        .read(key: EncryptedStorageKeys.SHARED_KEY_FILE_ID);
  }

  static Future<bool> _saveToDrive(String fileName, String fileContent,
      [String? existedFileId]) async {
    final token = await Auth().refreshGoogleTokens();
    final accessToken = token.accessToken;
    if (accessToken != null) {
      String? fileId = existedFileId;
      if (fileId == null) {
        if (fileName == sharedKeyFileName) {
          fileId = await _sharedKeyFileId;
        } else {
          fileId = await SecureStorage.instance.read(key: fileName);
        }
        if (fileId == null) {
          final response = await GDrive.getFileAndWriteFileContent(
              fileName, fileContent, accessToken);
          if (response != null && response.get('response', null) != null) {
            final responseFileId = response.get('fileId', null);
            if (responseFileId != null) {
              await SecureStorage.instance
                  .write(key: fileName, value: responseFileId);
              log('_saveToDrive fileid cached for file name $fileName');
            }
            return true;
          }
          throw Exception('response null 1');
        }
      } else {
        final response = await GDrive.writeFileContent(
            fileName, fileContent, accessToken, fileId);
        if (response != null && response.get('response', null) != null) {
          throw Exception('response null 2');
        }
      }
    }
    throw Exception('accessToken null');
  }

  static Future<bool> saveUserKeys({
    required String userId,
    required String privateKey,
    String? publicKey,
  }) async {
    final jsonEncodedString = jsonEncode({
      'privateKey': privateKey,
      ...(publicKey != null ? {'publicKey': publicKey} : {})
    });
    final encryptedJsonString =
        await AesGcmEncryption(secretKey: Keys.ENCRYTION_KEY)
            .encryptString(jsonEncodedString);
    if (encryptedJsonString != null) {
      return await _saveToDrive('$userId.json', encryptedJsonString);
    }
    throw Exception('unable to encrypt');
  }

  static Future<bool> saveSharedKeysToDrive(List<SharedKey> sharedKeys) async {
    final sharedKeyFileId = await _sharedKeyFileId;
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
    return _saveToDrive(
        sharedKeyFileName, jsonEncode(toUpdateResData), sharedKeyFileId);
  }

  static Future<Map<String, dynamic>?> getDriveUserData(String userId) async {
    final fileName = '$userId.json';
    final token = await Auth().refreshGoogleTokens();
    final accessToken = token.accessToken;
    if (accessToken != null) {
      String? fileId;
      fileId = await SecureStorage.instance.read(key: fileName);

      if (fileId == null) {
        final fileResponse =
            await GDrive.getFileAndReadFileContent(fileName, accessToken);
        if (fileResponse != null) {
          final fileId = fileResponse['fileId'];
          final response = fileResponse['response'];
          if (fileId != null) {
            await SecureStorage.instance.write(key: fileName, value: fileId);
            log('getDriveUserData fileid cached for file name $fileName');
          }
          if (response != null) {
            final decryptedJSON =
                await AesGcmEncryption(secretKey: Keys.ENCRYTION_KEY)
                    .decryptString(response.body);
            if (decryptedJSON != null) {
              final jsonDecoded = jsonDecode(decryptedJSON);
              return jsonDecoded;
            }
            throw Exception('decrypted json null');
          }
          throw Exception('response null');
        }
        throw Exception('fileResponse null');
      } else {
        final response =
            (await GDrive.readFileContent(fileId, accessToken)).decodedBody;
        if (response != null) {
          final decryptedJSON =
              await AesGcmEncryption(secretKey: Keys.ENCRYTION_KEY)
                  .decryptString(response);
          if (decryptedJSON != null) {
            final jsonDecoded = jsonDecode(decryptedJSON);
            return jsonDecoded;
          }
          throw Exception('decrypted json null');
        }
        throw Exception('response null');
      }
    }
    throw Exception('acess token null');
  }

  static Future<dynamic> getDriveSharedKeys(
      [bool shouldDecryptAndInArray = false, String? existedFileId]) async {
    final token = await Auth().refreshGoogleTokens();
    final accessToken = token.accessToken;
    if (accessToken != null) {
      final fileId = existedFileId ?? (await _sharedKeyFileId);
      Map<String, dynamic>? fileResponse;
      if (fileId != null) {
        final res = await GDrive.readFileContent(fileId, accessToken);
        fileResponse = res.decodedBody;
      } else {
        final response = await GDrive.getFileAndReadFileContent(
            GDriveOps.sharedKeyFileName, accessToken);
        if (response != null) {
          final res = response.get('response', null);
          fileResponse = res?.decodedBody;
          await SecureStorage.instance.write(
            key: EncryptedStorageKeys.SHARED_KEY_FILE_ID,
            value: response['fileId'],
          );
          log('getDriveSharedKeys fileid cached for key ${EncryptedStorageKeys.SHARED_KEY_FILE_ID}');
        }
      }
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
    }
    return null;
  }
}
