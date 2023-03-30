import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/ponto_turistico.dart';

class ConteudoFormDialog extends StatefulWidget{
  final PontoTuristico? pontoTuristicoAtual;

  ConteudoFormDialog({Key? key, this.pontoTuristicoAtual}) : super(key: key);

  @override
  ConteudoFormDialogState createState() => ConteudoFormDialogState();
}

class ConteudoFormDialogState extends State<ConteudoFormDialog>{
    final formKey = GlobalKey<FormState>();
    final descricaoController = TextEditingController();
    final caracteristicasController = TextEditingController();
    final dataController = TextEditingController();
    final _dateFormat = DateFormat('dd/MM/yyy');

    @override
    void initState(){
      super.initState();
      if ( widget.pontoTuristicoAtual != null){
        descricaoController.text = widget.pontoTuristicoAtual!.descricao;
        caracteristicasController.text = widget.pontoTuristicoAtual!.caracteristicas;
        dataController.text = widget.pontoTuristicoAtual!.dataFormatada;
      }
    }

    Widget build(BuildContext context){
      return Form(
        key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: descricaoController,
                decoration: InputDecoration(labelText: 'Descrição'),
                validator: (String? valor){
                  if(valor == null || valor.isEmpty){
                    return 'Informe a descrição';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: dataController,
                decoration: InputDecoration(labelText: 'Data',
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
                controller: caracteristicasController,
                decoration: InputDecoration(labelText: 'Características'),
                validator: (String? valor){
                  if(valor == null || valor.isEmpty){
                    return 'Informe as características';
                  }
                  return null;
                },
              ),
            ],
          )
      );
    }
    void _mostraCalendario(){
      final dataFormatada = dataController.text;
      var data = DateTime.now();
      if (dataFormatada.isNotEmpty){
        data = _dateFormat.parse(dataFormatada);
      }
      showDatePicker(
          context: context,
          initialDate: data,
          firstDate: data.subtract(Duration(days: 365 * 5)),
          lastDate: data.add(Duration(days: 365 * 5)),
      ).then((DateTime? dataSelecionada){
        if (dataSelecionada != null){
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
        caracteristicas: caracteristicasController.text,
        data: dataController.text.isEmpty ? null : _dateFormat.parse(dataController.text),
    );
}