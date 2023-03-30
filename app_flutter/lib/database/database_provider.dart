import 'package:flutter/cupertino.dart';
import 'package:gerenciador_pontos_turisticos/model/ponto_turistico.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static const _dbName = 'cadastro_pontos_turisticos.db';
  static const _dbVersion = 1;

  DatabaseProvider._init();

  static final DatabaseProvider instance = DatabaseProvider._init();

  Database? _databese;

  Future<Database> get databese async {
    if (_databese == null){
      _databese = await _initDatabase();
    }
    return _databese!;
  }

  Future<Database> _initDatabase() async{
    String dataBasePath = await getDatabasesPath();
    String dbPath = '$dataBasePath/$_dbName';
    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate (Database db, int version) async {
     await db.execute('''
      CREATE TABLE ${PontoTuristico.NOME_TABLE}(
      ${PontoTuristico.CAMPO_ID} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${PontoTuristico.CAMPO_DESCRICAO} TEXT NOT NULL,
      ${PontoTuristico.CAMPO_DATA} TEXT );
      ${PontoTuristico.CAMPO_CARACTERISTICAS} TEXT );
     ''');
  }

  Future<void> _onUpgrade (Database db, int oldVersion, int newVersion) async {

  }

  Future<void> close() async{
    if(_databese != null){
      await _databese!.close();
    }
  }

}