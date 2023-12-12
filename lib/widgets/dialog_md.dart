import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:infoservice/settings.dart';
import 'package:infoservice/widgets/rounded_button_widget.dart';

class DialogMDWidget extends StatelessWidget {
  final double radius;
  final String mdFileName;
  final Function? callback;
  DialogMDWidget({Key? key, this.radius = 8, this.callback,
    required this.mdFileName}) : assert(mdFileName.endsWith('.md'),
  'File must endswith .md'), super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: Future.delayed(
                const Duration(milliseconds: 100)).then((value) {
                return rootBundle.loadString('assets/$mdFileName');
              }),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Markdown(
                    data: snapshot.data.toString(),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          SIZED_BOX_H12,
          RoundedButtonWidget(
            text: const Text('Закрыть'),
            onPressed: () {
              if (callback != null) {
                callback!();
              }
              Navigator.of(context).pop();
            }
          ),
          SIZED_BOX_H12,
        ],
      ),
    );
  }
}
