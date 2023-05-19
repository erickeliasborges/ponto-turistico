import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gerenciador_pontos_turisticos/services/localizacao.dart';

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
  String filtro = '';
  late Localizacao localizacao;

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

    return _criarBody();
  }

  Widget _criarBody() => Scaffold(
        appBar: AppBar(
          title: Text('Selecione a localização'),
        ),
        body: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  filtro = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Filtro',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            TextButton(
                onPressed: () =>
                    localizacao.filtrarLocalizacoes(filtro).then((value) {
                      if (value.isEmpty) return;

                      final filteredLocations = value;
                      localizacaoSelecionada = new LatLng(
                          filteredLocations.first.latitude,
                          filteredLocations.first.longitude);
                      ;
                      posicaoCameraMapa = localizacaoSelecionada;
                      atualizarPosicaoCameraMapa(posicaoCameraMapa);
                    }),
                child: Text('Pesquisar')),
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
                },
                markers: Set<Marker>.from([
                  if (localizacaoSelecionada != null)
                    Marker(
                      markerId: MarkerId('Localização selecionada'),
                      position: localizacaoSelecionada,
                    ),
                ]),
                initialCameraPosition: CameraPosition(
                  target: posicaoCameraMapa,
                  zoom: 12.0,
                ),
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
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
      );

  void atualizarPosicaoCameraMapa(LatLng targetPosition) async {
    if (googleMapController != null) {
      final novaPosicao = CameraPosition(target: targetPosition, zoom: 12.0);
      await googleMapController!
          .animateCamera(CameraUpdate.newCameraPosition(novaPosicao));
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
}
