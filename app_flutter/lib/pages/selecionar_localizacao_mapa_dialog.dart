import 'package:flutter/material.dart';
import 'package:gerenciador_pontos_turisticos/model/cep.dart';
import 'package:gerenciador_pontos_turisticos/services/cep_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gerenciador_pontos_turisticos/services/localizacao.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class SelecionarLocalizacaoMapaPage extends StatefulWidget {
  static const routeName = '/selecionar-localizacao-mapa';
  @override
  _SelecionarLocalizacaoMapaPageState createState() =>
      _SelecionarLocalizacaoMapaPageState();
}

class _SelecionarLocalizacaoMapaPageState
    extends State<SelecionarLocalizacaoMapaPage> {
  LatLng localizacaoSelecionada = const LatLng(0, 0);
  LatLng posicaoCameraMapa = const LatLng(0, 0);
  GoogleMapController? googleMapController;
  Set<Marker> markers = {};
  final filtroController = TextEditingController();
  late Localizacao localizacao;

  final cepService = CepService();
  final cepController = TextEditingController();
  final cepKey = GlobalKey<FormState>();
  final cepFormater = MaskTextInputFormatter(
      mask: '#####-###', filter: {'#': RegExp(r'[0-9]')});
  var loading = false;
  Cep? cep;

  @override
  Widget build(BuildContext context) {
    localizacao = Localizacao(context);
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    LatLng latLngPassadaPorParametro = arguments['latLng'];
    // Adicionado validação da latitude e longitude igual a 0 pois toda vez que clica no mapa passa por aqui
    if (latLngPassadaPorParametro != null &&
        localizacaoSelecionada.latitude == 0 &&
        localizacaoSelecionada.longitude == 0) {
      localizacaoSelecionada = latLngPassadaPorParametro;
      posicaoCameraMapa = latLngPassadaPorParametro;
    }

    updateMarker();
    return _criarBody();
  }

  void updateMarker() {
    if (localizacaoSelecionada == null) return;

    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: MarkerId('Localização selecionada'),
          position: localizacaoSelecionada,
        ),
      );
    });
  }

  Widget _criarBody() => Scaffold(
      appBar: AppBar(
        title: Text('Selecione a localização'),
      ),
      body: Column(
        children: [
          Form(
            key: cepKey,
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: cepController,
              decoration: InputDecoration(
                labelText: 'CEP',
                hintText: 'Informe o CEP',
                suffixIcon: loading
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => cepController.text = '',
                            icon: const Icon(Icons.clear),
                          ),
                          IconButton(
                            onPressed: () {
                              _findCep().then((value) {
                                if (cep != null) {
                                  filtroController.text =
                                      '${cep!.localidade!}, ${cep!.bairro!}, ${cep!.logradouro!}';
                                  filtrarLocalizacaoMapa();
                                }
                              });
                            },
                            icon: const Icon(Icons.search),
                          ),
                        ],
                      ),
              ),
              inputFormatters: [cepFormater],
              validator: (String? value) {
                if (value == null || value.isEmpty || !cepFormater.isFill()) {
                  return 'Informe um CEP válido.';
                }
                return null;
              },
            ),
          ),
          TextField(
            controller: filtroController,
            decoration: InputDecoration(
                labelText: 'Endereço',
                hintText: 'Informe o endereço',
                suffixIcon: loading
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => filtroController.text = '',
                            icon: const Icon(Icons.clear),
                          ),
                          IconButton(
                            onPressed: filtrarLocalizacaoMapa,
                            icon: const Icon(Icons.search),
                          ),
                        ],
                      )),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                googleMapController = controller;
                atualizarPosicaoCameraMapa(posicaoCameraMapa);
              },
              onTap: (LatLng latLng) {
                setState(() {
                  localizacaoSelecionada = latLng;
                });
                updateMarker();
              },
              markers: markers,
              initialCameraPosition: CameraPosition(
                target: posicaoCameraMapa,
                zoom: 12.0,
              ),
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: 'Marcar localização atual no mapa.',
            onPressed: () {
              setPosicaoAtual();
            },
            child: Icon(Icons.my_location),
          ),
          SizedBox(width: 5.0),
          FloatingActionButton(
            tooltip: 'Selecionar localização.',
            onPressed: () {
              if (localizacaoSelecionada != null) {
                print(
                    'Localização selecionada: ${localizacaoSelecionada.latitude}, ${localizacaoSelecionada.longitude}');
              } else {
                print('Nenhuma localização selecionada');
              }
              _onVoltarClick();
            },
            child: Icon(Icons.check),
          ),
          SizedBox(width: 40.0),
        ],
      ));

  void atualizarPosicaoCameraMapa(LatLng targetPosition) async {
    if (googleMapController != null) {
      final novaPosicao = CameraPosition(target: targetPosition, zoom: 12.0);
      await googleMapController!
          .animateCamera(CameraUpdate.newCameraPosition(novaPosicao));
      updateMarker();
    }
  }

  Future<void> setPosicaoAtual() async {
    LatLng posicaoAtual = await localizacao.getLocalizacaoAtual();
    localizacaoSelecionada = posicaoAtual;
    posicaoCameraMapa = posicaoAtual;
    atualizarPosicaoCameraMapa(posicaoCameraMapa);
  }

  Future<bool> _onVoltarClick() async {
    Navigator.pop(context, localizacaoSelecionada);
    return true;
  }

  void filtrarLocalizacaoMapa() {
    if (filtroController.text.isEmpty) return;

    localizacao.filtrarLocalizacoes(filtroController.text).then((value) {
      if (value.isEmpty) return;

      final filteredLocations = value;
      localizacaoSelecionada = new LatLng(
          filteredLocations.first.latitude, filteredLocations.first.longitude);
      posicaoCameraMapa = localizacaoSelecionada;
      atualizarPosicaoCameraMapa(posicaoCameraMapa);
    });
  }

  Future<void> _findCep() async {
    if (cepKey.currentState == null || !cepKey.currentState!.validate()) {
      return;
    }
    setState(() {
      loading = true;
    });
    try {
      cep = await cepService.findCepAsObject(cepFormater.getUnmaskedText());
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ocorreu um erro, tente noavamente! \n'
              'ERRO: ${e.toString()}')));
    }
    setState(() {
      loading = false;
    });
  }
}
