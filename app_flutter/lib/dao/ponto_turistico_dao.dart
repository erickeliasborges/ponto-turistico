import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../database/database_provider.dart';
import 'package:gerenciador_pontos_turisticos/model/ponto_turistico.dart';

class PontoTuristicoDao {
  final dbProvider = DatabaseProvider.instance;

  Future<bool> salvar(PontoTuristico pontoTuristico) async {
    final database = await dbProvider.database;
    final valores = pontoTuristico.toMap();
    if (pontoTuristico.id == null || pontoTuristico.id == 0) {
      try {
        // Alterado id para null pois se deixar como 0 sempre faz o insert com o valor 0 ao invés de incrementar
        valores.update(PontoTuristico.CAMPO_ID, (value) => null);
        pontoTuristico.id = await database.insert(
          PontoTuristico.NOME_TABLE,
          valores,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        print(e);
      }

      return true;
    } else {
      final registrosAtualizados = await database.update(
        PontoTuristico.NOME_TABLE,
        valores,
        where: '${PontoTuristico.CAMPO_ID} = ?',
        whereArgs: [pontoTuristico.id],
      );
      return registrosAtualizados > 0;
    }
  }

  Future<bool> remover(int id) async {
    final database = await dbProvider.database;
    final registrosAtualizados = await database.delete(
      PontoTuristico.NOME_TABLE,
      where: '${PontoTuristico.CAMPO_ID} = ?',
      whereArgs: [id],
    );
    return registrosAtualizados > 0;
  }

  Future<List<PontoTuristico>> listar(
      {String filtroDescricao = '',
      String filtroDetalhes = '',
      String filtroDataInclusao = '',
      String filtroDiferenciais = '',
      String campoOrdenacao = PontoTuristico.CAMPO_ID,
      bool usarOrdemDecrescente = false}) async {
    String? where = "(1 = 1)";

    if (filtroDescricao.isNotEmpty && filtroDescricao != "") {
      where +=
          "AND UPPER(${PontoTuristico.CAMPO_DESCRICAO}) LIKE '${filtroDescricao.toUpperCase()}%'";
    }
    if (filtroDetalhes.isNotEmpty && filtroDetalhes != "") {
      where +=
          "${where != "" ? " AND " : ""} UPPER(${PontoTuristico.CAMPO_DETALHES}) LIKE '${filtroDetalhes.toUpperCase()}%'";
    }
    if (filtroDataInclusao.isNotEmpty && filtroDataInclusao != "") {
      where +=
          "${where != "" ? " AND " : ""} UPPER(${PontoTuristico.CAMPO_DATA_INCLUSAO}) LIKE '${filtroDataInclusao.toUpperCase()}%'";
    }
    if (filtroDiferenciais.isNotEmpty && filtroDiferenciais != "") {
      where +=
          "${where != "" ? " AND " : ""} UPPER(${PontoTuristico.CAMPO_DIFERENCIAIS}) LIKE '${filtroDiferenciais.toUpperCase()}%'";
    }

    var orderBy = campoOrdenacao;

    if (usarOrdemDecrescente) {
      orderBy += ' DESC';
    }
    final database = await dbProvider.database;
    final resultado = await database.query(
      PontoTuristico.NOME_TABLE,
      columns: [
        PontoTuristico.CAMPO_ID,
        PontoTuristico.CAMPO_DESCRICAO,
        PontoTuristico.CAMPO_DATA,
        PontoTuristico.CAMPO_DATA_INCLUSAO,
        PontoTuristico.CAMPO_DETALHES,
        PontoTuristico.CAMPO_DIFERENCIAIS,
        PontoTuristico.CAMPO_LATITUDE,
        PontoTuristico.CAMPO_LONGITUDE,
      ],
      where: where,
      orderBy: orderBy,
    );
    return resultado.map((m) => PontoTuristico.fromMap(m)).toList();
  }
}
