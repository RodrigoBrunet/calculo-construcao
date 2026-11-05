/// Scripts SQL por versão do banco. Para mudar o esquema:
/// 1. adicione uma nova entrada com a próxima versão;
/// 2. aumente [AppDatabase.versao].
/// Nunca edite uma versão que já foi publicada.
const Map<int, List<String>> migrations = {
  1: [
    '''
    CREATE TABLE calculos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tipo TEXT NOT NULL,
      titulo TEXT NOT NULL,
      entradas_json TEXT NOT NULL,
      resultado_json TEXT NOT NULL,
      criado_em INTEGER NOT NULL
    )
    ''',
    'CREATE INDEX idx_calculos_criado_em ON calculos (criado_em DESC)',
  ],
};
