import 'package:intl/intl.dart';

class PontoTuristico {

  static const NOME_TABLE = 'ponto_turistico';

  static const CAMPO_ID = '_id';
  static const CAMPO_DESCRICAO = 'descricao';
  static const CAMPO_DATA = 'data';
  static const CAMPO_DATA_INCLUSAO = 'data_inclusao';
  static const CAMPO_DETALHES = 'detalhes';  
  static const CAMPO_DIFERENCIAIS = 'diferenciais';  
  static const CAMPO_LATITUDE = 'latitude';  
  static const CAMPO_LONGITUDE = 'longitude';  

  int? id;
  String descricao;
  DateTime? data;
  DateTime? dataInclusao;
  String detalhes;
  String diferenciais;
  double latitude;
  double longitude;

  PontoTuristico(
    {
      required this.id, 
      required this.descricao, 
      this.data, 
      this.dataInclusao, 
      required this.detalhes, 
      required this.diferenciais,
      required this.latitude,
      required this.longitude,
    }
  );

  String get dataFormatada {
    if (data == null){
      return "";
    }
    return DateFormat('dd/MM/yyyy').format(data!);
  }

  String get dataInclusaoFormatada {
    if (dataInclusao == null){
      return "";
    }
    return DateFormat('dd/MM/yyyy').format(dataInclusao!);
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    CAMPO_ID: id,
    CAMPO_DESCRICAO: descricao,
    CAMPO_DATA: data == null ? null : DateFormat("dd/MM/yyyy").format(data!),
    CAMPO_DATA_INCLUSAO: dataInclusao == null ? DateFormat("dd/MM/yyyy").format(DateTime.now()) : DateFormat("dd/MM/yyyy").format(dataInclusao!),
    CAMPO_DETALHES: detalhes,
    CAMPO_DIFERENCIAIS: diferenciais,
    CAMPO_LATITUDE: latitude,
    CAMPO_LONGITUDE: longitude,
  };

  factory PontoTuristico.fromMap(Map<String, dynamic> map) => PontoTuristico(
    id: map[CAMPO_ID] is int ? map[CAMPO_ID] : null,
    descricao: map[CAMPO_DESCRICAO] is String ?  map[CAMPO_DESCRICAO] : '',
    data: map[CAMPO_DATA] == null ? null : DateFormat("dd/MM/yyyy").parse(map[CAMPO_DATA]),
    dataInclusao: map[CAMPO_DATA_INCLUSAO] == null ? null : DateFormat("dd/MM/yyyy").parse(map[CAMPO_DATA_INCLUSAO]),
    detalhes: map[CAMPO_DETALHES] is String ? map[CAMPO_DETALHES] : '',
    diferenciais: map[CAMPO_DIFERENCIAIS] is String ? map[CAMPO_DIFERENCIAIS] : '',
    latitude: map[CAMPO_LATITUDE] is double ? map[CAMPO_LATITUDE] : 0,
    longitude: map[CAMPO_LONGITUDE] is double ? map[CAMPO_LONGITUDE] : 0,
  );
}