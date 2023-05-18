import 'package:flutter/material.dart';
import 'package:gerenciador_pontos_turisticos/pages/filtro_page.dart';
import 'package:gerenciador_pontos_turisticos/pages/lista_ponto_turistico_page.dart';
import 'package:gerenciador_pontos_turisticos/pages/selecionar_localizacao_mapa_dialog.dart';

void main() {
  runApp(const CadastroApp());
}

class CadastroApp extends StatelessWidget {
  const CadastroApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ponto turístico',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: ListaPontoTuristicoPage(),    
      routes: {
        FiltroPage.routeName: (BuildContext context) => FiltroPage(),
        SelecionarLocalizacaoMapaPage.routeName: (BuildContext context) => SelecionarLocalizacaoMapaPage(),
      },
    );
  }
}