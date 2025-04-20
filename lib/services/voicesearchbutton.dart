import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:fuzzy/fuzzy.dart';

class VoiceSearchButton extends StatefulWidget {
  final Function(String) onResult;
  final List<Map<String, dynamic>> productos;
  final Function(List<Map<String, dynamic>>) onFiltrar;
  final Function(Map<String, dynamic>) onAgregar;

  const VoiceSearchButton({
    Key? key,
    required this.onResult,
    required this.productos,
    required this.onFiltrar,
    required this.onAgregar,
  }) : super(key: key);

  @override
  _VoiceSearchButtonState createState() => _VoiceSearchButtonState();
}

class _VoiceSearchButtonState extends State<VoiceSearchButton> {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _listen() async {
    if (!_isListening) {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
        if (!status.isGranted) {
          return;
        }
      }

      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (val.finalResult) {
              _procesarComando(val.recognizedWords);
              setState(() => _isListening = false);
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _procesarComando(String comando) {
  final texto = comando.toLowerCase();
  widget.onResult(texto);

  final nombres = widget.productos.map((p) => p['nombre'].toString()).toList();
  final fuseProductos = Fuzzy(nombres);

  final categorias = {
    'computadoras': 2,
    'teléfonos': 1,
    'telefono': 1,
    'accesorios': 3,
    'dispositivos': 4,
  };
  final fuseCategorias = Fuzzy(categorias.keys.toList());

  if (texto.contains('añadir') || texto.contains('agregar')) {
    final resultado = fuseProductos.search(texto);
    if (resultado.isNotEmpty) {
      final nombreEncontrado = resultado.first.item;
      final producto = widget.productos.firstWhere(
        (p) => p['nombre'].toString().toLowerCase() == nombreEncontrado.toLowerCase(),
        orElse: () => {},
      );
      if (producto.isNotEmpty) {
        widget.onAgregar(producto);
      }
    }
  } else if (texto.contains('listar') || texto.contains('mostrar') || texto.contains('filtrar')) {
    final resultadoCategoria = fuseCategorias.search(texto);
    final resultadoProducto = fuseProductos.search(texto);

    if (resultadoCategoria.isNotEmpty) {
      final categoriaNombre = resultadoCategoria.first.item;
      final categoriaId = categorias[categoriaNombre];

      final filtrados = widget.productos
          .where((p) => p['categoria'] == categoriaId)
          .toList();
      widget.onFiltrar(filtrados);
    } else if (resultadoProducto.isNotEmpty) {
      final coincidencias = resultadoProducto.map((r) => r.item).toList();
      final filtrados = widget.productos.where((p) =>
          coincidencias.contains(p['nombre'].toString())).toList();
      widget.onFiltrar(filtrados);
    }
  }
}



  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
      onPressed: _listen,
    );
  }
}
