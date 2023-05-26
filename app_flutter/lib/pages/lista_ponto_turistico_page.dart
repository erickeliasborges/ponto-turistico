import 'package:flutter/material.dart';
import 'package:gerenciador_pontos_turisticos/dao/ponto_turistico_dao.dart';
import 'package:gerenciador_pontos_turisticos/pages/filtro_page.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/ponto_turistico.dart';
import '../widgets/conteudo_form_dialog.dart';
import 'package:gerenciador_pontos_turisticos/services/localizacao.dart';

class ListaPontoTuristicoPage extends StatefulWidget {
  @override
  _ListaPontoTuristicoPageState createState() =>
      _ListaPontoTuristicoPageState();
}

class _ListaPontoTuristicoPageState extends State<ListaPontoTuristicoPage> {
  static const ACAO_EDITAR = 'editar';
  static const ACAO_EXCLUIR = 'excluir';

  final pontosTuristicos = <PontoTuristico>[];
  int _ultimoId = 0;
  final _dao = PontoTuristicoDao();
  var _carregando = false;
  late Localizacao localizacao;

  @override
  void initState() {
    super.initState();
    _atualizarLista();
  }

  @override
  Widget build(BuildContext context) {
    localizacao = Localizacao(context);
    return Scaffold(
      appBar: _criarAppBar(),
      body: _criarBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirForm,
        tooltip: 'Novo ponto turístico',
        child: Icon(Icons.add),
      ),
    );
  }

  AppBar _criarAppBar() {
    return AppBar(
      title: Text('Ponto turístico'),
      actions: [
        IconButton(
            onPressed: _abrirPaginaFiltro, icon: Icon(Icons.filter_list)),
      ],
    );
  }

  Widget _criarBody() {
    if (pontosTuristicos.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum ponto turístico cadastrado',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        final pontoTuristico = pontosTuristicos[index];
        return PopupMenuButton<String>(
          child: ListTile(
              title: Text('${pontoTuristico.id} - ${pontoTuristico.descricao}'),
              subtitle: Column(
                children: [
                  Row(children: [
                    Text(
                        'Data de inclusão: ${pontoTuristico.dataInclusaoFormatada}')
                  ]),
                  Row(children: [
                    Text(pontoTuristico.data == null
                        ? 'Sem data do registro definida'
                        : 'Data do registro: ${pontoTuristico.dataFormatada}')
                  ]),
                  Row(
                    children: [
                      Flexible(
                          child: Text('Detalhes: ${pontoTuristico.detalhes}'))
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: Text(
                              'Diferenciais: ${pontoTuristico.diferenciais}'))
                    ],
                  ),
                  // FutureBuilder serve para retornar um Widget que usa uma função async,
                  // no qual passa no future a funcção e utiliza o snaphot para pegar o retorno
                  FutureBuilder(
                    future: localizacao.getDescricaoLocalizacao(
                        pontoTuristico.latitude, pontoTuristico.longitude),
                    builder: (context, snapshot) => Row(
                      children: [
                        Flexible(
                            child: Text('Localização: ${snapshot.data ?? ''}'))
                      ],
                    ),
                  ),
                  FutureBuilder(
                    future: localizacao.getDescricaoDistanciaPontoAteLocalAtual(
                        pontoTuristico.latitude, pontoTuristico.longitude),
                    builder: (context, snapshot) => Row(
                      children: [
                        Flexible(
                            child: Text(
                                'Distância até o seu local: ${snapshot.data ?? ''}'))
                      ],
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        MapsLauncher.launchCoordinates(
                            pontoTuristico.latitude, pontoTuristico.longitude);
                      },
                      child: Text('Visualizar no mapa'))
                ],
              )),
          itemBuilder: (BuildContext context) => criarItensMenuPopup(),
          onSelected: (String valorSelecionado) {
            if (valorSelecionado == ACAO_EDITAR) {
              _abrirForm(pontoTuristicoAtual: pontoTuristico);
            } else {
              _excluir(pontoTuristico);
            }
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemCount: pontosTuristicos.length,
    );
  }

  void _abrirPaginaFiltro() {
    final navigator = Navigator.of(context);
    navigator.pushNamed(FiltroPage.routeName).then((alterouValores) {
      if (alterouValores == true) {
        _atualizarLista();
      }
    });
  }

  List<PopupMenuEntry<String>> criarItensMenuPopup() {
    return [
      PopupMenuItem<String>(
          value: ACAO_EDITAR,
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.black),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Editar ou visualizar'),
              )
            ],
          )),
      PopupMenuItem<String>(
          value: ACAO_EXCLUIR,
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Excluir'),
              )
            ],
          ))
    ];
  }

  void _abrirForm({PontoTuristico? pontoTuristicoAtual}) {
    final key = GlobalKey<ConteudoFormDialogState>();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(pontoTuristicoAtual == null
                ? 'Novo ponto turístico'
                : ' Alterar o ponto turístico ${pontoTuristicoAtual.id}'),
            content: ConteudoFormDialog(
                key: key, pontoTuristicoAtual: pontoTuristicoAtual),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar'),
              ),
              TextButton(
                child: Text('Salvar'),
                onPressed: () async {
                  if (key.currentState?.dadosValidados() != true) {
                    return;
                  }
                  await key.currentState?.confirmarLocalizacaoAtual();
                  Navigator.of(context).pop();
                  final novaTarefa = key.currentState!.novoPontoTuristico;
                  _dao.salvar(novaTarefa).then((success) {
                    if (success) {
                      _atualizarLista();
                    }
                  });
                  _atualizarLista();
                },
              )
            ],
          );
        });
  }

  void _excluir(PontoTuristico pontoTuristico) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.red,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('ATENÇÃO'),
                ),
              ],
            ),
            content: Text('Esse registro será deletado definitivamente'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (pontoTuristico.id == null) {
                      return;
                    }
                    _dao.remover(pontoTuristico.id!).then((sucess) {
                      if (sucess) _atualizarLista();
                    });
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  void _atualizarLista() async {
    setState(() {
      _carregando = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final campoOrdenacao = prefs.getString(FiltroPage.chaveCampoOrdenacao) ??
        PontoTuristico.CAMPO_ID;
    final usarOrdemDecrescente =
        prefs.getBool(FiltroPage.chaveUsarOrdemDecrescente) == true;
    final filtroDescricao =
        prefs.getString(FiltroPage.chaveFiltroDescricao) ?? '';
    final filtroDetalhes =
        prefs.getString(FiltroPage.chaveFiltroDetalhes) ?? '';
    final filtroDataInclusao =
        prefs.getString(FiltroPage.chaveDataInclusao) ?? '';
    final filtroDiferenciais =
        prefs.getString(FiltroPage.chaveDiferenciais) ?? '';
    final listaPontosTuristicos = await _dao.listar(
      filtroDescricao: filtroDescricao,
      filtroDetalhes: filtroDetalhes,
      filtroDataInclusao: filtroDataInclusao,
      filtroDiferenciais: filtroDiferenciais,
      campoOrdenacao: campoOrdenacao,
      usarOrdemDecrescente: usarOrdemDecrescente,
    );
    setState(() {
      pontosTuristicos.clear();
      if (listaPontosTuristicos.isNotEmpty) {
        pontosTuristicos.addAll(listaPontosTuristicos);
      }
    });
    setState(() {
      _carregando = false;
    });
  }
}
