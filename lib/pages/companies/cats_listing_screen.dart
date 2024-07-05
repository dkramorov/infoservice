
import 'package:flutter/material.dart';

import '../../models/companies/catalogue.dart';
import '../../helpers/log.dart';
import '../../services/jabber_manager.dart';
import '../../services/sip_ua_manager.dart';
import '../../settings.dart';
import '../../widgets/companies/cat_row.dart';
import '../../widgets/companies/catalogue_in_update.dart';
import '../../widgets/companies/floating_search_widget.dart';

class CatsListingScreen extends StatefulWidget {
  static const String id = '/cats_listing_screen/';

  final SIPUAManager? _sipHelper;
  final JabberManager? _xmppHelper;
  final Object? _arguments;

  const CatsListingScreen(this._sipHelper, this._xmppHelper, this._arguments, {Key? key})
      : super(key: key);

  @override
  _CatsListingScreenState createState() => _CatsListingScreenState();
}

class _CatsListingScreenState extends State<CatsListingScreen> {
  static const TAG = 'CatsListingScreen';

  SIPUAManager? get sipHelper => widget._sipHelper;
  JabberManager? get xmppHelper => widget._xmppHelper;

  late Catalogue? rubric;
  List<Catalogue> rubrics = [];
  String title = 'Каталог компаний';

  @override
  void initState() {
    super.initState();
    List args = (widget._arguments as Set).toList();
    for (Object? arg in args) {
      if (arg is Catalogue) {
        rubric = arg;
        Log.d(TAG, '---> rubric is ${rubric.toString()}');
        title = rubric!.name ?? title;
        loadRubrics();
        break;
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadRubrics() {
    String parents = '';
    if (rubric != null) {
      parents = '${rubric!.parents}_${rubric!.id}';
    }
    Catalogue().getFullCatalogue(parents: parents).then((result) {
      setState(() {
        rubrics = result;
      });
    });
  }

  // Обновление состояния
  void setStateCallback(Map<String, dynamic> state) {
    setState(() {
      if (state['title'] != null) {
        title = state['title'];
      }
    });
  }

  Widget buildFloatingSearch() {
    return Stack(
      children: [
        CompaniesFloatingSearchWidget(xmppHelper),
      ],
    );
  }

  /* Страничка листинга компаний */
  Widget buildCatalogue() {
    return rubrics.isEmpty
        ? Column(children: [
      SIZED_BOX_H30,
      CatalogueInUpdate(),
    ])
        : Column(
      children: [
        buildPanelForSearch(),
        Expanded(
          child: ListView.builder(
            itemCount: rubrics.length,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              vertical: 5,
            ),
            itemBuilder: (context, index) {
                final item = rubrics[index];
                return CatRow(sipHelper, xmppHelper, item);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
        ),
        backgroundColor: tealColor,
      ),
      body: Stack(
        children: [
          buildCatalogue(),
          buildFloatingSearch(),
        ],
      ),
    );
  }
}
