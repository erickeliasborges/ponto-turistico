

import 'package:intl/intl.dart';

class PontoTuristico {

  static const CAMPO_ID = 'id';
  static const CAMPO_DESCRICAO = 'descricao';
  static const CAMPO_DATA = 'data';
  static const CAMPO_CARACTERISTICAS = 'caracteristicas';
  static const NOME_TABLE = 'ponto_turistico';

  int id;
  String descricao;
  DateTime? data;
  String caracteristicas;

  PontoTuristico({required this.id, required this.descricao, this.data, required this.caracteristicas});

  String get dataFormatada {
    if (data == null){
      return "";
    }
    return DateFormat('dd/MM/yyyy').format(data!);
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    CAMPO_ID: id,
    CAMPO_DESCRICAO: descricao,
    CAMPO_DATA: data == null ? null : DateFormat("dd/MM/yyyy").format(data!),
    CAMPO_CARACTERISTICAS: caracteristicas,
  };

  factory PontoTuristico.fromMap(Map<String, dynamic> map) => PontoTuristico(
    id: map[CAMPO_ID] is int ? map[CAMPO_ID] : null,
    descricao: map[CAMPO_DESCRICAO] is String ?  map[CAMPO_DESCRICAO] : '',
    data: map[CAMPO_DATA] == null ? null : DateFormat("dd/MM/yyyy").parse(map[CAMPO_DATA]),
    caracteristicas: map[CAMPO_CARACTERISTICAS] is String ?  map[CAMPO_CARACTERISTICAS] : '',
  );
}