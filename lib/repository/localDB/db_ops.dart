import 'package:connects_you/data/localDB/db_ops.dart';

class DBOpsRepository {
  DBOpsRepository._();

  static final DBOpsRepository _instance = DBOpsRepository._();

  factory DBOpsRepository() {
    return _instance;
  }

  final DBOpsDataSource dbOpsDataSource = DBOpsDataSource();

  Future initialiseDB() async {
    return dbOpsDataSource.getDB();
  }

  Future deleteDB() async {
    return dbOpsDataSource.deleteDB();
  }
}
