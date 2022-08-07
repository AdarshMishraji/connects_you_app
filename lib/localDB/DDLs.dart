// ignore_for_file: file_names

import 'package:connects_you/extensions/iterable.dart';

class TableNames {
  static const String users = 'users';
  static const String rooms = 'rooms';
  static const String roomUsers = 'room_users';
  static const String messages = 'messages';
  static const String messageThreads = 'message_threads';
  static const String sharedKeys = 'sharedKeys';
  static const String localEncryptedStorage = 'localEncryptedStorage';
}

class _TableConstants {
  static const String createTableIfNotExists = 'CREATE TABLE IF NOT EXISTS';
  static const String integer = 'INTEGER';
  static const String text = 'TEXT';
  static const String json = 'JSON';
  static const String boolean = 'BOOLEAN';
  static const String notnull = 'NOT NULL';
  static const String notnullUnique = '${_TableConstants.notnull} UNIQUE';
  static const String primaryKey = 'PRIMARY KEY';
  static const String primaryKeyAutoincrement =
      '${_TableConstants.primaryKey} AUTOINCREMENT';
  static const String alterTable = 'ALTER TABLE';
  static const String add = 'ADD';
  static const String foreignKey = 'FOREIGN KEY';
  static const String references = 'REFERENCES';
  static const String updateAndDeleteRestrict =
      'ON UPDATE RESTRICT ON DELETE RESTRICT';
}

class TableColumnInfo {
  final String columnName;
  final String columnType;
  final String columnProperties;

  const TableColumnInfo({
    required this.columnName,
    required this.columnType,
    required this.columnProperties,
  });
}

class UsersTableColumns {
  static const userId = 'userId';
  static const name = 'name';
  static const email = 'email';
  static const photo = 'photo';
  static const publicKey = 'publicKey';
  static const privateKey = 'privateKey';
}

class RoomsTableColumns {
  static const roomId = 'roomId';
  static const roomName = 'roomName';
  static const roomLogo = 'roomLogo';
  static const roomDescription = 'roomDescription';
  static const roomType = 'roomType';
  static const createdByUserId = 'createdByUserId';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
  static const lastMessageBody = 'lastMessageBody';
}

class RoomUsersTableColumns {
  static const String roomId = 'roomId';
  static const String userId = 'userId';
  static const String userRole = 'userRole';
  static const String joinedAt = 'joinedAt';
}

class SharedKeysTableColumns {
  static const String id = 'id';
  static const String sharedKey = 'sharedKey';
  static const String keyType = 'keyType';
}

class MessagesTableColumns {
  static const messageId = 'messageId';
  static const messageText = 'messageText';
  static const messageType = 'messageType';
  static const senderUserId = 'senderUserId';
  static const recieverUserId = 'recieverUserId';
  static const roomId = 'roomId';
  static const replyMessageId = 'replyMessageId';
  static const sendAt = 'sendAt';
  static const updatedAt = 'updatedAt';
  static const haveThreadId = 'haveThreadId';
  static const belongsToThreadId = 'belongsToThreadId';
  static const messageSeenInfo = 'messageSeenInfo';
  static const isSent = 'isSent';
}

class MessageThreadsTableColumns {
  static const String threadId = 'threadId';
  static const String messageId = 'messageId';
  static const String createdAt = 'createdAt';
  static const String createdByUserId = 'createdByUserId';
}

class LocalEncryptedStorageTableColumns {
  static const String localStorageJSON = 'localStorageJSON';
}

class DDLs {
  static const TableColumnInfo _idColumn = TableColumnInfo(
    columnName: '_id',
    columnType: _TableConstants.integer,
    columnProperties: _TableConstants.primaryKeyAutoincrement,
  );
  static const Map<String, List<TableColumnInfo>> tableProperties = {
    TableNames.users: [
      _idColumn,
      TableColumnInfo(
        columnName: UsersTableColumns.userId,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnullUnique,
      ),
      TableColumnInfo(
        columnName: UsersTableColumns.email,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnullUnique,
      ),
      TableColumnInfo(
          columnName: UsersTableColumns.name,
          columnType: _TableConstants.text,
          columnProperties: _TableConstants.notnull),
      TableColumnInfo(
          columnName: UsersTableColumns.photo,
          columnType: _TableConstants.text,
          columnProperties: _TableConstants.notnull),
      TableColumnInfo(
          columnName: UsersTableColumns.publicKey,
          columnType: _TableConstants.text,
          columnProperties: _TableConstants.notnull),
      TableColumnInfo(
        columnName: UsersTableColumns.privateKey,
        columnType: _TableConstants.text,
        columnProperties: '',
      )
    ],
    TableNames.rooms: [
      _idColumn,
      TableColumnInfo(
        columnName: RoomsTableColumns.roomId,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnullUnique,
      ),
      TableColumnInfo(
        columnName: RoomsTableColumns.roomName,
        columnType: _TableConstants.text,
        columnProperties: '',
      ),
      TableColumnInfo(
        columnName: RoomsTableColumns.roomLogo,
        columnType: _TableConstants.text,
        columnProperties: '',
      ),
      TableColumnInfo(
        columnName: RoomsTableColumns.roomDescription,
        columnType: _TableConstants.text,
        columnProperties: '',
      ),
      TableColumnInfo(
        columnName: RoomsTableColumns.roomType,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnull,
      ),
      TableColumnInfo(
        columnName: RoomsTableColumns.createdByUserId,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnull,
      ),
      TableColumnInfo(
        columnName: RoomsTableColumns.createdAt,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnull,
      ),
      TableColumnInfo(
        columnName: RoomsTableColumns.updatedAt,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnull,
      ),
    ],
    TableNames.roomUsers: [
      TableColumnInfo(
        columnName: RoomUsersTableColumns.roomId,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnull,
      ),
      TableColumnInfo(
        columnName: RoomUsersTableColumns.userId,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnull,
      ),
      TableColumnInfo(
        columnName: RoomUsersTableColumns.userRole,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnull,
      ),
      TableColumnInfo(
        columnName: RoomUsersTableColumns.joinedAt,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnull,
      ),
    ],
    TableNames.sharedKeys: [
      _idColumn,
      TableColumnInfo(
        columnName: SharedKeysTableColumns.id,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnullUnique,
      ),
      TableColumnInfo(
        columnName: SharedKeysTableColumns.sharedKey,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnull,
      ),
      TableColumnInfo(
        columnName: SharedKeysTableColumns.keyType,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnull,
      ),
    ],
    TableNames.messages: [
      _idColumn,
      TableColumnInfo(
        columnName: MessagesTableColumns.messageId,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnullUnique,
      ),
      TableColumnInfo(
        columnName: MessagesTableColumns.messageText,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnull,
      ),
      TableColumnInfo(
        columnName: MessagesTableColumns.messageType,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnull,
      ),
      TableColumnInfo(
        columnName: MessagesTableColumns.senderUserId,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnull,
      ),
      TableColumnInfo(
        columnName: MessagesTableColumns.recieverUserId,
        columnType: _TableConstants.text,
        columnProperties: '',
      ),
      TableColumnInfo(
        columnName: MessagesTableColumns.roomId,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnull,
      ),
      TableColumnInfo(
        columnName: MessagesTableColumns.replyMessageId,
        columnType: _TableConstants.text,
        columnProperties: '',
      ),
      TableColumnInfo(
        columnName: MessagesTableColumns.sendAt,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnull,
      ),
      TableColumnInfo(
        columnName: MessagesTableColumns.updatedAt,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnull,
      ),
      TableColumnInfo(
        columnName: MessagesTableColumns.haveThreadId,
        columnType: _TableConstants.text,
        columnProperties: '',
      ),
      TableColumnInfo(
        columnName: MessagesTableColumns.belongsToThreadId,
        columnType: _TableConstants.text,
        columnProperties: '',
      ),
      TableColumnInfo(
        columnName: MessagesTableColumns.messageSeenInfo,
        columnType: _TableConstants.json,
        columnProperties: '',
      ),
      TableColumnInfo(
        columnName: MessagesTableColumns.isSent,
        columnType: _TableConstants.boolean,
        columnProperties: 'DEFAULT false',
      ),
    ],
    TableNames.messageThreads: [
      _idColumn,
      TableColumnInfo(
        columnName: MessageThreadsTableColumns.threadId,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnullUnique,
      ),
      TableColumnInfo(
        columnName: MessageThreadsTableColumns.createdAt,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnull,
      ),
      TableColumnInfo(
        columnName: MessageThreadsTableColumns.createdByUserId,
        columnType: _TableConstants.text,
        columnProperties: _TableConstants.notnull,
      ),
    ],
    TableNames.localEncryptedStorage: [
      TableColumnInfo(
        columnName: LocalEncryptedStorageTableColumns.localStorageJSON,
        columnType: _TableConstants.json,
        columnProperties: 'DEFAULT "{}"',
      ),
    ]
  };

  static String _foreignKey(
    String referencingProperty,
    String tableName,
    String referencedProperty,
  ) {
    return """${_TableConstants.foreignKey} ($referencingProperty) ${_TableConstants.references} $tableName($referencedProperty) ${_TableConstants.updateAndDeleteRestrict}""";
  }

  static String _createTableStatments(String tableName,
      [List<String> otherProperties = const []]) {
    return """${_TableConstants.createTableIfNotExists} $tableName (
        ${DDLs.tableProperties[tableName]!.map((props) => "${props.columnName} ${props.columnType} ${props.columnProperties}").toStringWithoutBrackets()} ${otherProperties.isEmpty ? '' : ', '}
        ${otherProperties.toStringWithoutBrackets()}
      )""";
  }

  static Map<String, String> createTableStatements = {
    TableNames.users: _createTableStatments(TableNames.users),
    TableNames.rooms: _createTableStatments(TableNames.rooms, [
      DDLs._foreignKey(RoomsTableColumns.createdByUserId, TableNames.users,
          UsersTableColumns.userId)
    ]),
    TableNames.roomUsers: _createTableStatments(TableNames.roomUsers, [
      DDLs._foreignKey(RoomUsersTableColumns.userId, TableNames.users,
          UsersTableColumns.userId),
      DDLs._foreignKey(RoomUsersTableColumns.roomId, TableNames.rooms,
          RoomsTableColumns.createdByUserId)
    ]),
    TableNames.sharedKeys: _createTableStatments(TableNames.sharedKeys),
    TableNames.localEncryptedStorage:
        _createTableStatments(TableNames.localEncryptedStorage),
    TableNames.messageThreads:
        _createTableStatments(TableNames.messageThreads, [
      DDLs._foreignKey(MessageThreadsTableColumns.createdByUserId,
          TableNames.users, UsersTableColumns.userId),
    ]),
    TableNames.messages: _createTableStatments(TableNames.messages, [
      DDLs._foreignKey(MessagesTableColumns.senderUserId, TableNames.users,
          UsersTableColumns.userId),
      DDLs._foreignKey(MessagesTableColumns.recieverUserId, TableNames.users,
          UsersTableColumns.userId),
      DDLs._foreignKey(MessagesTableColumns.roomId, TableNames.rooms,
          RoomsTableColumns.createdByUserId),
      DDLs._foreignKey(MessagesTableColumns.replyMessageId, TableNames.messages,
          'messageId'),
      DDLs._foreignKey(MessagesTableColumns.haveThreadId,
          TableNames.messageThreads, 'threadId'),
      DDLs._foreignKey(MessagesTableColumns.belongsToThreadId,
          TableNames.messageThreads, 'threadId'),
    ])
  };

  static Map<String, String> alterTableCommands = {
    TableNames.messageThreads:
        """${_TableConstants.alterTable} ${TableNames.messageThreads} ${_TableConstants.add} ${MessageThreadsTableColumns.messageId} ${_TableConstants.text} ${_TableConstants.notnull} ${_TableConstants.references} ${TableNames.messages}(${MessagesTableColumns.messageId}) ${_TableConstants.updateAndDeleteRestrict}""",
  };
}
