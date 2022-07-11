import 'package:flutter/material.dart';

import '../../settings.dart';

class CatalogueInUpdate extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          SIZED_BOX_H45,
          ListTile(
            leading: Icon(Icons.disc_full),
            title: Text(
              'Каталог обновляется',
              style: TextStyle(fontSize: 20),
            ),
            subtitle: Text('Пожалуйста, подождите...'),
          ),
        ],
      ),
    );
  }
}
