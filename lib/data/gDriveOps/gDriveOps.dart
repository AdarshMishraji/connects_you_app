import 'dart:developer';

import 'package:connects_you/constants/secureStorageKeys.dart';
import 'package:connects_you/data/server/auth.dart';
import 'package:connects_you/extensions/map.dart';
import 'package:connects_you/helpers/secureStorage.dart';
import 'package:gdrive/gdrive.dart';

class GDriveOpsDataSource {
  const GDriveOpsDataSource._();
  static const _instance = GDriveOpsDataSource._();
  static const instance = _instance;

  static const sharedKeyFileName = 'sharedKeys.json';

  Future<String?> getSharedKeyFileId() async {
    return await SecureStorage.instance
        .read(key: SecureStorageKeys.SHARED_KEY_FILE_ID);
  }

  Future<bool> saveToDrive(String fileName, String fileContent,
      [String? existedFileId]) async {
    final token = await AuthDataSource.instance.refreshGoogleTokens();
    final accessToken = token.accessToken;
    if (accessToken != null) {
      String? fileId = existedFileId;
      if (fileId == null) {
        if (fileName == GDriveOpsDataSource.sharedKeyFileName) {
          fileId = await getSharedKeyFileId();
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
              log('saveToDrive fileid cached for file name $fileName');
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

  Future<String> getDriveUserData(String userId) async {
    final fileName = '$userId.json';
    final token = await AuthDataSource.instance.refreshGoogleTokens();
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
            return response.body;
          }
          throw Exception('response null');
        }
        throw Exception('fileResponse null');
      } else {
        final response =
            (await GDrive.readFileContent(fileId, accessToken)).decodedBody;
        if (response != null) {
          return response.body;
        }
        throw Exception('response null');
      }
    }
    throw Exception('acess token null');
  }

  Future<Map<String, dynamic>?> getDriveSharedKeys(
      [String? existedFileId]) async {
    final token = await AuthDataSource.instance.refreshGoogleTokens();
    final accessToken = token.accessToken;
    if (accessToken != null) {
      final fileId = existedFileId ?? (await getSharedKeyFileId());
      Map<String, dynamic>? fileResponse;
      if (fileId != null) {
        final res = await GDrive.readFileContent(fileId, accessToken);
        fileResponse = res.decodedBody;
      } else {
        final response = await GDrive.getFileAndReadFileContent(
            GDriveOpsDataSource.sharedKeyFileName, accessToken);
        if (response != null) {
          final res = response.get('response', null);
          fileResponse = res?.decodedBody;
          await SecureStorage.instance.write(
            key: SecureStorageKeys.SHARED_KEY_FILE_ID,
            value: response['fileId'],
          );
          log('getDriveSharedKeys fileid cached for key ${SecureStorageKeys.SHARED_KEY_FILE_ID}');
        }
      }
      return fileResponse;
    }
    return null;
  }
}
