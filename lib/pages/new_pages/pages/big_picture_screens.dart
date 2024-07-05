import 'package:flutter/material.dart';

import '../../app_asset_lib.dart';
import '../common/widgets/big_picture_widget.dart';
import '../common/widgets/control_button.dart';

class BigPictureScreensTestPage extends StatelessWidget {
  const BigPictureScreensTestPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        // appBar: GenericAppBar(
        //   hasBackButton: true,
        // ),
        body: PageView(
          children: [
            const BigPictureWidget(
              asset: AssetLib.noResults,
              title: "Ничего не найдено",
              description:
                  "Попробуйте изменить поисковой запрос или воспользуйтесь каталогом",
            ),
            BigPictureWidget(
              asset: AssetLib.allowMic,
              title: "Нужен доступ к микрофону",
              description:
                  "Чтобы использовать голосовой поиск, предоставьте приложению доступ к микрофону в настройках",
              controls: ActionControlButton(
                onPressed: () {},
                title: 'К настройкам',
              ),
            ),
            const BigPictureWidget(
              asset: AssetLib.noMicAllowed,
              title: "Голосовой поиск недоступен",
              description:
                  "На вашем устройстве отсутствует возможность воспользоваться голосовым поиском",
            ),
            BigPictureWidget(
              title: "История пуста",
              description: "Начните звонить и общаться, чтобы она появилась",
              controls: ActionControlButton(
                onPressed: () {},
                title: 'В каталог',
              ),
            ),
            BigPictureWidget(
              asset: AssetLib.updateRequired,
              title: "Необходимо обновление",
              description:
                  "Для нормальной работы необходимо обновить приложение",
              controls: ActionControlButton(
                onPressed: () {},
                title: 'Обновить',
              ),
            ),
            BigPictureWidget(
              asset: AssetLib.noNetwork,
              title: "Нет подключения к сети",
              description:
                  "Проверьте мобильное соединение или подключение Wi-Fi",
              controls: ActionControlButton(
                onPressed: () {},
                title: 'Обновить',
              ),
            ),
            BigPictureWidget(
              asset: AssetLib.unknownError,
              title: "Что-то пошло не так",
              description:
                  "Попробуйте обновить страницу или зайти в приложение заново",
              controls: ActionControlButton(
                onPressed: () {},
                title: 'Обновить',
              ),
            ),
          ],
        ),
      );
}
