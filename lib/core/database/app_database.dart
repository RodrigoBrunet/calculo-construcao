import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'migrations.dart';

/// Abre o banco SQLite local e aplica as migrações.
class AppDatabase {
  AppDatabase._(this.db);

  static const nomeArquivo = 'calculo_construcao.db';
  static const versao = 1;

  final Database db;

  /// [factory] e [path] existem para os testes usarem um banco em memória.
  static Future<AppDatabase> open({
    DatabaseFactory? factory,
    String? path,
  }) async {
    final dbFactory = factory ?? databaseFactory;
    final caminho =
        path ?? p.join(await dbFactory.getDatabasesPath(), nomeArquivo);

    final db = await dbFactory.openDatabase(
      caminho,
      options: OpenDatabaseOptions(
        version: versao,
        onCreate: (db, version) => _migrar(db, 0, version),
        onUpgrade: _migrar,
      ),
    );
    return AppDatabase._(db);
  }

  static Future<void> _migrar(Database db, int de, int para) async {
    for (var v = de + 1; v <= para; v++) {
      for (final sql in migrations[v] ?? const <String>[]) {
        await db.execute(sql);
      }
    }
  }

  Future<void> close() => db.close();
}
