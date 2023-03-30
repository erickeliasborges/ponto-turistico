import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/ponto_turistico.dart';

class FiltroPage extends StatefulWidget {
  static const routeName = '/filtro';
  static const chaveCampoOrdenacao = 'campoOrdenacao';
  static const chaveUsarOrdemDecrescente = 'usarOrdemDecrescente';
  static const chaveFiltroDescricao = 'filtroDescricao';
  static const chaveFiltroCaracteristica = 'filtroCaracteristica';

  @override
  _FiltroPageState createState() => _FiltroPageState();
}

class _FiltroPageState extends State<FiltroPage> {
  final _camposParaOrdenacao = {
    PontoTuristico.CAMPO_ID: 'Código',
    PontoTuristico.CAMPO_DESCRICAO: 'Descrição',
    PontoTuristico.CAMPO_DATA: 'Data',
    PontoTuristico.CAMPO_CARACTERISTICAS: 'Características',
  };
  late final SharedPreferences _prefs;
  final _descricaoController = TextEditingController();
  final _caracteristicasController = TextEditingController();
  String _campoOrdenacao = PontoTuristico.CAMPO_ID;
  bool _usarOrdemDecrescente = false;
  bool _alterouValores = false;

  @override
  void initState() {
    super.initState();
    _carregarSharedPreferences();
  }

  void _carregarSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _campoOrdenacao =
          _prefs.getString(FiltroPage.chaveCampoOrdenacao) ?? PontoTuristico.CAMPO_ID;
      _usarOrdemDecrescente =
          _prefs.getBool(FiltroPage.chaveUsarOrdemDecrescente) == true;
      _descricaoController.text =
          _prefs.getString(FiltroPage.chaveFiltroDescricao) ?? '';
      _caracteristicasController.text =
          _prefs.getString(FiltroPage.chaveFiltroCaracteristica) ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Filtro e Ordenação'),
        ),
        body: _criarBody(),
      ),
      onWillPop: _onVoltarClick,
    );
  }

  Widget _criarBody() => ListView(
    children: [
      Padding(
        padding: EdgeInsets.only(left: 10, top: 10),
        child: Text('Campo para ordenação'),
      ),
      for (final campo in _camposParaOrdenacao.keys)
        Row(
          children: [
            Radio(
              value: campo,
              groupValue: _campoOrdenacao,
              onChanged: _onCampoOrdenacaoChanged,
            ),
            Text(_camposParaOrdenacao[campo]!),
          ],
        ),
      Divider(),
      Row(
        children: [
          Checkbox(
            value: _usarOrdemDecrescente,
            onChanged: _onUsarOrdemDecrescenteChanged,
          ),
          Text('Usar ordem decrescente'),
        ],
      ),
      Divider(),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          decoration: InputDecoration(
            labelText: 'Descrição começa com',
          ),
          controller: _descricaoController,
          onChanged: _onFiltroDescricaoChanged,
        ),
      ),
      Divider(),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          decoration: InputDecoration(
            labelText: 'Características começa com',
          ),
          controller: _caracteristicasController,
          onChanged: _onFiltroCaracteristicasChanged,
        ),
      ),
    ],
  );

  void _onCampoOrdenacaoChanged(String? valor) {
    _prefs.setString(FiltroPage.chaveCampoOrdenacao, valor!);
    _alterouValores = true;
    setState(() {
      _campoOrdenacao = valor;
    });
  }

  void _onUsarOrdemDecrescenteChanged(bool? valor) {
    _prefs.setBool(FiltroPage.chaveUsarOrdemDecrescente, valor!);
    _alterouValores = true;
    setState(() {
      _usarOrdemDecrescente = valor;
    });
  }

  void _onFiltroDescricaoChanged(String? valor) {
    _prefs.setString(FiltroPage.chaveFiltroDescricao, valor ?? '');
    _alterouValores = true;
  }

  void _onFiltroCaracteristicasChanged(String? valor) {
    _prefs.setString(FiltroPage.chaveFiltroCaracteristica, valor ?? '');
    _alterouValores = true;
  }

  Future<bool> _onVoltarClick() async {
    Navigator.of(context).pop(_alterouValores);
    return true;
  }
}