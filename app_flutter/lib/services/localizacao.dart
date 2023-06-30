import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gerenciador_pontos_turisticos/services/mensagem.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class Localizacao {
  final BuildContext context;
  late final Mensagem mensagem;

  Localizacao(this.context) {
    mensagem = Mensagem(context);
  }

  Future<LatLng> getLocalizacaoAtual() async {
    if (!await validarPermissoes()) return LatLng(0, 0);
    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  Future<bool> validarPermissoes() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        mensagem.mostrarMensagem('Não será possível utilizar o recurso '
            'por falta de permissão');
      }
    }
    if (permissao == LocationPermission.deniedForever) {
      await mensagem.mostrarDialogMensagem(
          'Para utilizar esse recurso, você deverá acessar '
          'as configurações do app para permitir a utilização do serviço de localização',
          TextButton(
              onPressed: () => Navigator.of(context).pop(), child: Text('OK')));
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  Future<String> getDescricaoLocalizacao(
      double latitude, double longitude) async {
    if ((latitude == 0) || (longitude == 0)) return 'Não informado';

    List<Placemark> placeMarkList =
        await placemarkFromCoordinates(latitude, longitude);

    if (placeMarkList.isEmpty) return 'Não informado';

    return '${placeMarkList[0].street}, ${placeMarkList[0].country}' ?? '';
  }

  Future<String> getDescricaoDistanciaPontoAteLocalAtual(
      double latitude, double longitude) async {
    if ((latitude == 0) || (longitude == 0)) return '';

    LatLng latLngAtual = await getLocalizacaoAtual();    
    double distanciaMetros =
        calcularDistanciaLocalizacoes(LatLng(latitude, longitude), latLngAtual);
    return formatarDistancia(distanciaMetros);
  }

  double calcularDistanciaLocalizacoes(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
        start.latitude, start.longitude, end.latitude, end.longitude);
  }

  String formatarDistancia(double distanciaEmMetros) {
    NumberFormat numberFormat = NumberFormat.decimalPattern('pt_BR');
    String distanciaFormatada;

    if (distanciaEmMetros < 1000) {
      distanciaFormatada = '${numberFormat.format(distanciaEmMetros)} m';
    } else {
      double distanceInKilometers = distanciaEmMetros / 1000;
      distanciaFormatada = '${numberFormat.format(distanceInKilometers)} km';
    }

    return distanciaFormatada;
  }

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
}
