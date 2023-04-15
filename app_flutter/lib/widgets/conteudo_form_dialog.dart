import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/ponto_turistico.dart';

class ConteudoFormDialog extends StatefulWidget {
  final PontoTuristico? pontoTuristicoAtual;

  ConteudoFormDialog({Key? key, this.pontoTuristicoAtual}) : super(key: key);

  @override
  ConteudoFormDialogState createState() => ConteudoFormDialogState();
}

class ConteudoFormDialogState extends State<ConteudoFormDialog> {
  final formKey = GlobalKey<FormState>();
  final descricaoController = TextEditingController();
  final detalhesController = TextEditingController();
  final diferenciaisController = TextEditingController();
  final dataController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyy');

  @override
  void initState() {
    super.initState();
    if (widget.pontoTuristicoAtual != null) {
      descricaoController.text = widget.pontoTuristicoAtual!.descricao;
      detalhesController.text = widget.pontoTuristicoAtual!.detalhes;
      diferenciaisController.text = widget.pontoTuristicoAtual!.diferenciais;
      dataController.text = widget.pontoTuristicoAtual!.dataFormatada;
    }
  }

  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
              validator: (String? valor) {
                if (valor == null || valor.isEmpty) {
                  return 'Informe a descrição';
                }
                return null;
              },
            ),
            TextFormField(
              controller: dataController,
              decoration: InputDecoration(
                labelText: 'Data',
                prefixIcon: IconButton(
                  onPressed: _mostraCalendario,
                  icon: Icon(Icons.calendar_today),
                ),
                suffixIcon: IconButton(
                  onPressed: () => dataController.clear(),
                  icon: Icon(Icons.close),
                ),
              ),
              readOnly: true,
            ),
            TextFormField(
              controller: detalhesController,
              decoration: InputDecoration(labelText: 'Detalhes'),
              validator: (String? valor) {
                if (valor == null || valor.isEmpty) {
                  return 'Informe as Detalhes';
                }
                return null;
              },
            ),
            TextFormField(
              controller: diferenciaisController,
              decoration: InputDecoration(labelText: 'Diferenciais'),
              validator: (String? valor) {
                if (valor == null || valor.isEmpty) {
                  return 'Informe os diferenciais';
                }
                return null;
              },
            ),
          ],
        ));
  }

  void _mostraCalendario() {
    final dataFormatada = dataController.text;
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
          dataController.text = _dateFormat.format(dataSelecionada);
        });
      }
    });
  }

  bool dadosValidados() => formKey.currentState!.validate() == true;

  PontoTuristico get novoPontoTuristico => PontoTuristico(
        id: widget.pontoTuristicoAtual?.id ?? 0,
        descricao: descricaoController.text,
        data: dataController.text.isEmpty
            ? null
            : _dateFormat.parse(dataController.text),
        dataInclusao:
            _dateFormat.parse(DateFormat("dd/MM/yyyy").format(DateTime.now())),
        detalhes: detalhesController.text,
        diferenciais: diferenciaisController.text,
      );
}
