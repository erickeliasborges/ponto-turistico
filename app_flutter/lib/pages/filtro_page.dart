import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../model/ponto_turistico.dart';

class FiltroPage extends StatefulWidget {
  static const routeName = '/filtro';
  static const chaveCampoOrdenacao = 'campoOrdenacao';
  static const chaveUsarOrdemDecrescente = 'usarOrdemDecrescente';
  static const chaveFiltroDescricao = 'filtroDescricao';
  static const chaveFiltroDetalhes = 'filtroDetalhes';
  static const chaveDataInclusao = 'filtroDataInclusao';
  static const chaveDiferenciais = 'filtroDiferenciais';

  @override
  _FiltroPageState createState() => _FiltroPageState();
}

class _FiltroPageState extends State<FiltroPage> {
  final _dateFormat = DateFormat('dd/MM/yyy');
  final _camposParaOrdenacao = {
    PontoTuristico.CAMPO_ID: 'Código',
    PontoTuristico.CAMPO_DESCRICAO: 'Descrição',
    PontoTuristico.CAMPO_DATA: 'Data',
    PontoTuristico.CAMPO_DATA_INCLUSAO: 'Data de inclusão',
    PontoTuristico.CAMPO_DETALHES: 'Detalhes',
    PontoTuristico.CAMPO_DIFERENCIAIS: 'Diferenciais',
  };
  late final SharedPreferences _prefs;
  final _descricaoController = TextEditingController();
  final _detalhesController = TextEditingController();
  final _dataInclusaoController = TextEditingController();
  final _diferenciaisController = TextEditingController();
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
      _campoOrdenacao = _prefs.getString(FiltroPage.chaveCampoOrdenacao) ??
          PontoTuristico.CAMPO_ID;
      _usarOrdemDecrescente =
          _prefs.getBool(FiltroPage.chaveUsarOrdemDecrescente) == true;
      _descricaoController.text =
          _prefs.getString(FiltroPage.chaveFiltroDescricao) ?? '';
      _detalhesController.text =
          _prefs.getString(FiltroPage.chaveFiltroDetalhes) ?? '';
      _dataInclusaoController.text =
          _prefs.getString(FiltroPage.chaveDataInclusao) ?? '';
      _diferenciaisController.text =
          _prefs.getString(FiltroPage.chaveDiferenciais) ?? '';
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
            child: TextFormField(
              controller: _dataInclusaoController,
              decoration: InputDecoration(
                labelText: 'Data',
                prefixIcon: IconButton(
                  onPressed: _mostraCalendario,
                  icon: Icon(Icons.calendar_today),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    _dataInclusaoController.clear();
                    _prefs.setString(FiltroPage.chaveDataInclusao, '');
                    _alterouValores = true;
                  },
                  icon: Icon(Icons.close),
                ),
              ),
              readOnly: true,
              onChanged: _onDataInclusaoChanged,
            ),
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
                labelText: 'Detalhes começa com',
              ),
              controller: _detalhesController,
              onChanged: _onFiltroDetalhesChanged,
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Diferenciais começa com',
              ),
              controller: _diferenciaisController,
              onChanged: _onFiltroDiferenciaisChanged,
            ),
          ),
        ],
      );

  void _mostraCalendario() {
    final dataFormatada = _dataInclusaoController.text;
    var data = DateTime.now();
    if (dataFormatada.isNotEmpty) {
      data = _dateFormat.parse(dataFormatada);
    }
    showDatePicker(
      context: context,
      initialDate: data,
      firstDate: data.subtract(Duration(days: 365 * 5)),
      lastDate: data.add(Duration(days: 365 * 5)),
    ).then((DateTime? dataSelecionada) {
      if (dataSelecionada != null) {
        setState(() {
          _dataInclusaoController.text = _dateFormat.format(dataSelecionada);
          _prefs.setString(FiltroPage.chaveDataInclusao,
              _dateFormat.format(dataSelecionada) ?? '');
          _alterouValores = true;
        });
      }
    });
  }

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

  void _onFiltroDetalhesChanged(String? valor) {
    _prefs.setString(FiltroPage.chaveFiltroDetalhes, valor ?? '');
    _alterouValores = true;
  }

  void _onFiltroDiferenciaisChanged(String? valor) {
    _prefs.setString(FiltroPage.chaveDiferenciais, valor ?? '');
    _alterouValores = true;
  }

  void _onDataInclusaoChanged(String? valor) {
    _prefs.setString(FiltroPage.chaveDataInclusao, valor ?? '');
    _alterouValores = true;
  }

  Future<bool> _onVoltarClick() async {
    Navigator.of(context).pop(_alterouValores);
    return true;
  }
}
