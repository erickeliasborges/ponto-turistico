import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gerenciador_pontos_turisticos/pages/filtro_page.dart';
import '../model/ponto_turistico.dart';
import '../widgets/conteudo_form_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
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
                    Text(pontoTuristico.data == null
                        ? 'Sem data definida'
                        : 'Data: ${pontoTuristico.dataFormatada}')
                  ]),
                  Row(
                    children: [
                      Text('Características: ${pontoTuristico.caracteristicas}')
                    ],
                  )
                ],
              )),
          itemBuilder: (BuildContext context) => criarItensMenuPopup(),
          onSelected: (String valorSelecionado) {
            if (valorSelecionado == ACAO_EDITAR) {
              _abrirForm(pontoTuristicoAtual: pontoTuristico, indice: index);
            } else {
              _excluir(index);
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
        ////
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
                child: Text('Editar'),
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

  void _abrirForm({PontoTuristico? pontoTuristicoAtual, int? indice}) {
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
                onPressed: () {
                  if (key.currentState != null &&
                      key.currentState!.dadosValidados()) {
                    setState(() {
                      final novoPontoTuristico =
                          key.currentState!.novoPontoTuristico;
                      if (indice == null) {
                        novoPontoTuristico.id = ++_ultimoId;
                      } else {
                        pontosTuristicos[indice] = novoPontoTuristico;
                      }
                      pontosTuristicos.add(novoPontoTuristico);
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Salvar'),
              )
            ],
          );
        });
  }

  void _excluir(int indice) {
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
                    setState(() {
                      pontosTuristicos.removeAt(indice);
                    });
                  },
                  child: Text('OK'))
            ],
          );
        });
  }
}
