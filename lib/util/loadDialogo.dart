import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aevivienda/util/loader.dart';

class LoadDialogo {
  final BuildContext context;
  LoadDialogo(this.context);
  void mostrar() {
    showCupertinoDialog(
      context: this.context,
      builder: (_) => Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white.withOpacity(0.6),
        child: Loader(),
      ),
      //child: CupertinoActivityIndicator(
      //  radius: 15,
      //),
    );
  }

  void ocultar() {
    Navigator.pop(context);
  }
}
