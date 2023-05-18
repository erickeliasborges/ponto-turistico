import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
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
                onPressed: () => filtrarLocalizacoes(filtro).then((value) {
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

  Future<List<Location>> filtrarLocalizacoes(String filtro) async {
    if (filtro.isEmpty) {
      return [];
    }

    try {
      final locations = await locationFromAddress(filtro);
      return locations;
    } catch (exception) {
      print('Erro ao filtrar localizações: $exception');
      return [];
    }
  }

  void atualizarPosicaoCameraMapa(LatLng targetPosition) async {
    if (googleMapController != null) {
      final novaPosicao = CameraPosition(target: targetPosition, zoom: 12.0);
      await googleMapController!
          .animateCamera(CameraUpdate.newCameraPosition(novaPosicao));
    }
  }

  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
        start.latitude, start.longitude, end.latitude, end.longitude);
  }

  Future<void> setPosicaoAtual() async {
    if (!await _validarPermissoes()) return;
    final position = await Geolocator.getCurrentPosition();
    LatLng posicaoAtual = LatLng(position.latitude, position.longitude);
    localizacaoSelecionada = posicaoAtual;
    posicaoCameraMapa = posicaoAtual;
    atualizarPosicaoCameraMapa(posicaoCameraMapa);
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

  Future<bool> _onVoltarClick() async {
    Navigator.pop(context, localizacaoSelecionada);
    return true;
  }
}
