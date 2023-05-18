import 'package:flutter/cupertino.dart';
import 'package:gerenciador_pontos_turisticos/model/ponto_turistico.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static const _dbName = 'cadastro_pontos_turisticos.db';
  static const _dbVersion = 2;

  DatabaseProvider._init();

  static final DatabaseProvider instance = DatabaseProvider._init();

  Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    String dataBasePath = await getDatabasesPath();
    String dbPath = '$dataBasePath/$_dbName';
    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(getSQLCreateTable());
  }

  String getSQLCreateTable() {
    return '''
      CREATE TABLE ${PontoTuristico.NOME_TABLE}(
      ${PontoTuristico.CAMPO_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${PontoTuristico.CAMPO_DESCRICAO} TEXT NOT NULL,
      ${PontoTuristico.CAMPO_DATA} TEXT,
      ${PontoTuristico.CAMPO_DATA_INCLUSAO} TEXT,
      ${PontoTuristico.CAMPO_DETALHES} TEXT,
      ${PontoTuristico.CAMPO_DIFERENCIAIS} TEXT);
     ''';
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {    
    if (oldVersion == newVersion)
      return;

    db.execute("ALTER TABLE ${PontoTuristico.NOME_TABLE} ADD COLUMN ${PontoTuristico.CAMPO_LATITUDE} DECIMAL(9,6);");  
    db.execute("ALTER TABLE ${PontoTuristico.NOME_TABLE} ADD COLUMN ${PontoTuristico.CAMPO_LONGITUDE} DECIMAL(9,6);");  
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
