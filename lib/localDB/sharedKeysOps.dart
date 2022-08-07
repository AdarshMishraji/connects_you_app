import 'package:connects_you/enums/room.dart';
import 'package:connects_you/extensions/iterable.dart';
import 'package:connects_you/extensions/map.dart';
import 'package:connects_you/localDB/DBProvider.dart';
import 'package:connects_you/localDB/DDLs.dart';
import 'package:connects_you/models/sharedKey.dart';
import 'package:flutter/rendering.dart';

class SharedKeysOps {
  const SharedKeysOps();

  Future<int> insertSharedKeys(List<SharedKey> sharedKeys) async {
    if (sharedKeys.isNotEmpty) {
      final query = """INSERT OR IGNORE INTO ${TableNames.sharedKeys} (
        ${SharedKeysTableColumns.id},
        ${SharedKeysTableColumns.keyType},
        ${SharedKeysTableColumns.sharedKey}
      ) VALUES ${sharedKeys.map((sharedKey) => {
                SharedKeysTableColumns.id: sharedKey.id,
                SharedKeysTableColumns.keyType: sharedKey.keyType,
                SharedKeysTableColumns.sharedKey: sharedKey.sharedKey
              })} """;
      final db = await DBProvider.getDB();
      final insertedRows = await db.rawInsert(query);
      debugPrint('roomUsers inserted $insertedRows');
      return insertedRows;
    }
    return 0;
  }

  List<SharedKey> _createResponse(List<Map<String, dynamic>> sharedKeys) {
    return sharedKeys
        .map((sharedKey) => SharedKey(
              id: sharedKey.get(SharedKeysTableColumns.id, ''),
              keyType: sharedKey.get(SharedKeysTableColumns.keyType, ''),
              sharedKey: sharedKey.get(SharedKeysTableColumns.sharedKey, ''),
            ))
        .toList();
  }

  Future<SharedKey?> fetchLocalSharedKey(String id) async {
    final db = await DBProvider.getDB();
    final response = await db.query(TableNames.sharedKeys, where: "id = $id");
    final sharedKeys = _createResponse(response);
    return sharedKeys.isNotEmpty ? sharedKeys[0] : null;
  }

  Future<List<SharedKey>?> fetchLocalSharedKeys(List<String> ids) async {
    final db = await DBProvider.getDB();
    final response = await db.query(TableNames.sharedKeys,
        where: "id IN (${ids.toStringWithoutBrackets()})");
    return _createResponse(response);
  }

  Future<List<SharedKeyRoomIdMap>?> fetchLocalSharedKeyACCRoomIds(
      List<String> roomIds) async {
    final roomIdsString = '(${roomIds.toStringWithoutBrackets()})';
    final query = """WITH 
                        roomUsersResult 
                      AS (SELECT * FROM ${TableNames.roomUsers})
                      SELECT
                        s.* ,
                        r.roomId
                      FROM 
                        ${TableNames.sharedKeys} s,
                        roomUsersResult r
                      WHERE
                        s.id
                      IN
                        (
                            SELECT
                              DISTINCT(userId)
                            FROM 
                              roomUsersResult
                            WHERE
                              roomId
                            IN
                              $roomIdsString
                              
                            UNION

                            SELECT
                              roomId
                            FROM
                              ${TableNames.rooms} 
                            WHERE
                              roomId
                            IN
                              $roomIdsString
                            AND
                              roomType = '${RoomType.GROUP}'
                        )
                      AND (r.roomId = s.id OR r.userId = s.id )
                      GROUP BY s.id""";
    // above query results in giving result in following format
    /**
     * // "roomId" in below format is same as "id" in case of group, but in case of duet, it gives the roomId of the user;
     * keyId---id---keyType---sharedKey---roomId
     */
    final db = await DBProvider.getDB();
    final List<Map<String, dynamic>> response = await db.rawQuery(query);
    return response
        .map((sharedKey) => SharedKeyRoomIdMap(
              id: sharedKey.get(SharedKeysTableColumns.id, ''),
              keyType: sharedKey.get(SharedKeysTableColumns.keyType, ''),
              sharedKey: sharedKey.get(SharedKeysTableColumns.sharedKey, ''),
              roomId: sharedKey.get(RoomsTableColumns.roomId, ''),
            ))
        .toList();
  }
}
