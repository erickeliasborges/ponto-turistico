import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import '../model/ponto_turistico.dart';
import 'package:gerenciador_pontos_turisticos/pages/selecionar_localizacao_mapa_dialog.dart';

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
  double latitude = 0;
  double longitude = 0;

  @override
  void initState() {
    super.initState();
    if (widget.pontoTuristicoAtual != null) {
      descricaoController.text = widget.pontoTuristicoAtual!.descricao;
      detalhesController.text = widget.pontoTuristicoAtual!.detalhes;
      diferenciaisController.text = widget.pontoTuristicoAtual!.diferenciais;
      dataController.text = widget.pontoTuristicoAtual!.dataFormatada;
      latitude = widget.pontoTuristicoAtual!.latitude;
      longitude = widget.pontoTuristicoAtual!.longitude;
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
            ElevatedButton( 
                  onPressed: _abrirMapaParaSelecionarLocalizacao,
                  child: Icon(Icons.map),
              )
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
        // Ajustar para validar se já ta no banco, criar dataInclusaoController que nem o data, pois esse método é chamado quando altera também
        dataInclusao:
            _dateFormat.parse(DateFormat("dd/MM/yyyy").format(DateTime.now())),
        detalhes: detalhesController.text,
        diferenciais: diferenciaisController.text,
        latitude: latitude,
        longitude: longitude,
      );


  void _abrirMapaExterno(){
    // if(_localizacaoAtual == null){
    //   return;
    // }
    // MapsLauncher.launchCoordinates(_localizacaoAtual!.latitude, _localizacaoAtual!.longitude);
    double latitude = 1.0;
    double longitude = 1.0;
    MapsLauncher.launchCoordinates(latitude, longitude);
    print(latitude);   
  }    

  Future<void> _abrirMapaParaSelecionarLocalizacao() async {
    if (!await _validarPermissoes()) 
      return;    
    final position; 
    if ((latitude == 0) && (longitude == 0)) 
      position = await Geolocator.getCurrentPosition();
    else
      position = new LatLng(latitude, longitude);
    LatLng posicaoAtual = LatLng(position.latitude, position.longitude);
    final navigator = Navigator.of(context);
    navigator.pushNamed(SelecionarLocalizacaoMapaPage.routeName, arguments: {'latLng': posicaoAtual}).then((localizacaoSelecionada) {
        print(localizacaoSelecionada);
        if (localizacaoSelecionada == null)
          return;
        LatLng? latLng = localizacaoSelecionada as LatLng?;
        latitude = latLng!.latitude;
        longitude = latLng.longitude;                
    });
  }

  Future<bool> _validarPermissoes() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        _mostrarMensagem('Não será possível utilizar o recurso '
            'por falta de permissão');
      }
    }
    if (permissao == LocationPermission.deniedForever) {
      await _mostrarDialogMensagem(
          'Para utilizar esse recurso, você deverá acessar '
          'as configurações do app para permitir a utilização do serviço de localização');
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _mostrarDialogMensagem(String mensagem) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Atenção'),
        content: Text(mensagem),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(), child: Text('OK'))
        ],
      ),
    );
  }
    
}
