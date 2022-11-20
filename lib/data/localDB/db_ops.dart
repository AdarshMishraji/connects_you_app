import 'dart:io';

import 'package:connects_you/config/db_config.dart';
import 'package:connects_you/data/localDB/DDLs.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as path_util;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sqflite_sqlcipher/sqflite.dart';

class DBOpsDataSource {
  DBOpsDataSource._();

  static final _instance = DBOpsDataSource._();

  factory DBOpsDataSource() {
    return _instance;
  }

  Database? _db;

  Future<String> _getDatabasePath() async {
    Directory documentsDirectory =
        await path_provider.getApplicationDocumentsDirectory();
    String path = path_util.join(
      documentsDirectory.path,
      DBConfig.dbFileName,
    );
    return path;
  }

  Future<Database> _initDB() async {
    final path = await _getDatabasePath();
    Database db = await openDatabase(
      path,
      singleInstance: true,
      password: DBConfig.dbPassword,
      version:
          1, // the value of the version gets changed on db migration, and accordingly, callbacks will be called;
      onCreate:
          _defineTables, // it is like init for the database (it's only get called when app open for the first time);
      onUpgrade:
          _defineTables, // this gets called when there is verison diff +1, or on create not specified;
      onDowngrade: (db, _, __) async {
        await deleteDB();
        _defineTables(db, _, __);
      },
      onOpen: (db) {
        debugPrint('Database opened');
      },
    );
    return db;
  }

// on migration of the db from one version to another, below function will be different.
// so for the first time, this function would be called by onCreate
// on version diff +1, this function would be called by onUpgrade
// on version diff -1, this function would be called by onDowngrade
  Future<void> _defineTables(Database db, _, [__]) async {
    final isUsersTableCreated = await _createTable(TableNames.users, db);
    debugPrint(isUsersTableCreated
        ? 'user table created'
        : 'user table has not created');
    final isSharedKeysTableCreated =
        await _createTable(TableNames.sharedKeys, db);
    debugPrint(isSharedKeysTableCreated
        ? 'sharedKeys table created'
        : 'sharedKeys table has not created');
    final isLocalEncryptedStorageTableCreated =
        await _createTable(TableNames.localEncryptedStorage, db);
    debugPrint(isLocalEncryptedStorageTableCreated
        ? 'localEncryptedStorage table created'
        : 'localEncryptedStorage table has not created');
    debugPrint(isSharedKeysTableCreated
        ? 'sharedKeys table created'
        : 'sharedKeys table has not created');
    if (isUsersTableCreated) {
      final isRoomsTableCreated = await _createTable(TableNames.rooms, db);
      debugPrint(isRoomsTableCreated
          ? 'rooms table created'
          : 'rooms table has not created');
      if (isRoomsTableCreated) {
        final isRoomUsersTableCreated =
            await _createTable(TableNames.roomUsers, db);
        debugPrint(isRoomUsersTableCreated
            ? 'roomUsers table created'
            : 'roomUsers table has not created');
        if (!isRoomUsersTableCreated) return;
        final isMessageThreadsTableCreated =
            await _createTable(TableNames.messageThreads, db);
        debugPrint(isMessageThreadsTableCreated
            ? 'messages thread table created'
            : 'messages thread table has not created');
        if (isMessageThreadsTableCreated) {
          final isMessagesTableCreated =
              await _createTable(TableNames.messages, db);
          debugPrint(isMessagesTableCreated
              ? 'messages table created'
              : 'messages table has not created');
          if (isMessagesTableCreated) {
            // altering the message_threads table for adding foreign key because, both messages and message_threads table are in relationship with each other (They are interlinked)
            // so ideally, for creating one table other should be present, but that's not possible
            // so we create message_threads first without messageId, and after it we create messages table, so that, messages table can be created with foreign keys referring to threadId
            // and after that we add messageId as a foreign key to threadId

            // we are adding messageId as foreign key, because in sqlite, we cannot update the constraints, instead we can add a column with the constraints;
            db
                .execute(DDLs.alterTableCommands[TableNames.messageThreads]!)
                .then((_) => debugPrint('message thread table altered'))
                .catchError((e) {
              debugPrint('$e error while altering message threads table');
            });
          }
        }
      }
    }
  }

  Future<Database> getDB() async {
    if (_db != null) return _db!;
    debugPrint('need to create db');
    _db = await _initDB();
    return _db!;
  }

  Future<bool> deleteDB() async {
    final path = await _getDatabasePath();
    await deleteDatabase(path);
    _db = null;
    debugPrint('DB deleted');
    return true;
  }

  Future<bool> _createTable(String tableName, [Database? paramDB]) async {
    try {
      if (DDLs.createTableStatements.containsKey(tableName)) {
        final Database db = paramDB ?? _db ?? await getDB();
        await db.execute(DDLs.createTableStatements[tableName]!);
        return true;
      } else {
        return false;
      }
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }
}
