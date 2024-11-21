import 'package:flutter/material.dart';

class NotificacionBajoStock extends StatefulWidget {
  final bool mostrarNotificacion;
  final VoidCallback onClose;
  final int productos;

  const NotificacionBajoStock(
      {Key? key,
      required this.mostrarNotificacion,
      required this.onClose,
      required this.productos})
      : super(key: key);

  @override
  _NotificacionBajoStockState createState() => _NotificacionBajoStockState();
}

class _NotificacionBajoStockState extends State<NotificacionBajoStock> {
  @override
  Widget build(BuildContext context) {
    return widget.mostrarNotificacion
        ? Positioned(
            top: 20,
            right: 20,
            child: Card(
              color: Colors.red[400],
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      '¡${widget.productos} producto(s) bajo(s) en stock!',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),
            ),
          )
        : SizedBox.shrink();
  }
}
