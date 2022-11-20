import 'package:connects_you/data/localDB/db_ops.dart';
import 'package:connects_you/data/localDB/ddls.dart';
import 'package:connects_you/data/models/shared_key.dart';
import 'package:connects_you/constants/room_constants.dart';
import 'package:dart_utils/dart_utils.dart';
import 'package:flutter/rendering.dart';

class SharedKeysOpsDataSource {
  const SharedKeysOpsDataSource._();

  static const _instance = SharedKeysOpsDataSource._();

  factory SharedKeysOpsDataSource() {
    return _instance;
  }

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
      final db = await DBOpsDataSource().getDB();
      final insertedRows = await db.rawInsert(query);
      debugPrint('roomUsers inserted $insertedRows');
      return insertedRows;
    }
    return 0;
  }

  Future<List<Map<String, dynamic>>> fetchLocalSharedKey(String id) async {
    final db = await DBOpsDataSource().getDB();
    return await db.query(TableNames.sharedKeys, where: "id = $id");
  }

  Future<List<Map<String, dynamic>>> fetchLocalSharedKeys(
      List<String> ids) async {
    final db = await DBOpsDataSource().getDB();
    return await db.query(TableNames.sharedKeys,
        where: "id IN (${ids.toStringWithoutBrackets()})");
  }

  Future<List<Map<String, dynamic>>> fetchLocalSharedKeyACCRoomIds(
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
    final db = await DBOpsDataSource().getDB();
    return await db.rawQuery(query);
  }
}
