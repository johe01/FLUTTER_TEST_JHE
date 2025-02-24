import 'package:test_application/database_helper.dart';
import 'package:test_application/models/board.dart';

class BoardService {
  // 데이터 목록 조회
  Future<List<Map<String, dynamic>>> list() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('board');
  }

  // 데이터 조회
  Future<Map<String, dynamic>?> select(String id) async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> result =
        await db.query('board', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // 데이터 등록
  Future<int> insert(Board board) async {
    final db = await DatabaseHelper.instance.database;
    int result = await db.insert('board', board.toMap());
    return result;
  }

  // 데이터 수정
  Future<int> update(Board board) async {
    final db = await DatabaseHelper.instance.database;
    int result = await db
        .update('board', board.toMap(), where: 'id = ?', whereArgs: [board.id]);
    return result;
  }

  // 데이터 삭제
  Future<int> delete(String id) async {
    final db = await DatabaseHelper.instance.database;
    int result = await db.delete('board', where: 'id = ?', whereArgs: [id]);
    return result;
  }
}
