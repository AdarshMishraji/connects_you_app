import 'package:connects_you/data/localDB/DDLs.dart';
import 'package:connects_you/data/localDB/shared_keys_ops.dart';
import 'package:connects_you/data/models/shared_key.dart';
import 'package:dart_utils/dart_utils.dart';
import 'package:flutter/rendering.dart';

class SharedKeysOpsRepository {
  SharedKeysOpsRepository._();

  static final SharedKeysOpsRepository _instance = SharedKeysOpsRepository._();

  factory SharedKeysOpsRepository() {
    return _instance;
  }

  final SharedKeysOpsDataSource sharedKeysOpsDataSource =
      SharedKeysOpsDataSource();

  List<SharedKey> _createResponse(List<Map<String, dynamic>> sharedKeys) {
    return sharedKeys
        .map((sharedKey) => SharedKey(
              id: sharedKey.get(SharedKeysTableColumns.id, ''),
              keyType: sharedKey.get(SharedKeysTableColumns.keyType, ''),
              sharedKey: sharedKey.get(SharedKeysTableColumns.sharedKey, ''),
            ))
        .toList();
  }

  Future<int> insertSharedKeys(List<SharedKey> sharedKeys) async {
    try {
      final response =
          await sharedKeysOpsDataSource.insertSharedKeys(sharedKeys);
      return response;
    } catch (error) {
      debugPrint(error.toString());
      return 0;
    }
  }

  Future<SharedKey?> fetchLocalSharedKey(String id) async {
    try {
      final response = await sharedKeysOpsDataSource.fetchLocalSharedKey(id);
      final sharedKeys = _createResponse(response);
      return sharedKeys.isNotEmpty ? sharedKeys[0] : null;
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<List<SharedKey>?> fetchLocalSharedKeys(List<String> ids) async {
    try {
      final response = await sharedKeysOpsDataSource.fetchLocalSharedKeys(ids);
      return _createResponse(response);
    } catch (error) {
      debugPrint(error.toString());
      return [];
    }
  }

  Future<List<SharedKeyRoomIdMap>?> fetchLocalSharedKeyACCRoomIds(
      List<String> roomIds) async {
    try {
      final response =
          await sharedKeysOpsDataSource.fetchLocalSharedKeyACCRoomIds(roomIds);
      return response
          .map((sharedKey) => SharedKeyRoomIdMap(
                id: sharedKey.get(SharedKeysTableColumns.id, ''),
                keyType: sharedKey.get(SharedKeysTableColumns.keyType, ''),
                sharedKey: sharedKey.get(SharedKeysTableColumns.sharedKey, ''),
                roomId: sharedKey.get(RoomsTableColumns.roomId, ''),
              ))
          .toList();
    } catch (error) {
      debugPrint(error.toString());
      return [];
    }
  }
}
