import 'package:connects_you/data/localDB/DBOps.dart';

class DBOpsRepository {
  DBOpsRepository();

  final DBOpsDataSource dbOpsDataSource = DBOpsDataSource.instance;

  Future initialiseDB() async {
    return dbOpsDataSource.getDB();
  }

  Future deleteDB() async {
    return dbOpsDataSource.deleteDB();
  }
}
