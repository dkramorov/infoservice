import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app_asset_lib.dart';
import '../../../../themes.dart';
import '../../../../format_ends.dart';
import '../../../../../widgets/modal.dart';
import '../side_page/chat_page.dart';
import 'modal_items.dart';

class SwipeItem extends StatefulWidget {
  const SwipeItem({
    super.key,
    required this.name,
    required this.data,
    required this.onDel,
  });
  final String name;
  final dynamic data;
  final Function onDel;

  @override
  State<SwipeItem> createState() => _SwipeItemState();
}

class _SwipeItemState extends State<SwipeItem> {
  double offsetX = 0.0;
  double initialX = 0.0;
  bool isSwiping = false;
  bool opened = false;
  double borderRadiusValue = 7.0;
  double detailsdeltadx = 0.0;

  @override
  void initState() {
    super.initState();
    isSwiping = false;
    opened = false;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      color: widget.data["new_mgs_count"] != 0 ? surfacePrimary : white,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Theme.of(context).colorScheme.primaryContainer,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => ChatPage(
                  userPhone: widget.name,
                ),
              ),
            );
          },
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Positioned(
                right: isSwiping ? -offsetX - 106 : offsetX - 106,
                child: ClipRect(
                  child: GestureDetector(
                    onTap: () {
                      showModal(
                        context,
                        size.height * 0.3,
                        const DeleteItem(),
                      );
                    },
                    child: Container(
                      width: 90,
                      height: 76,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                          // color: widget.data["new_mgs_count"] != 0
                          //     ? surfacePrimary
                          //     : white,
                          ),
                      child: Container(
                        width: 90,
                        height: 76,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(251, 232, 231, 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(AssetLib.trash),
                            const SizedBox(height: 4),
                            Text(
                              "Удалить",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: w500,
                                color: red,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onHorizontalDragStart: (details) {
                  initialX = details.localPosition.dx;
                },
                onHorizontalDragUpdate: (details) {
                  final currentX = details.localPosition.dx;
                  final deltaX = currentX - initialX;
                  // print(deltaX);
                  if (deltaX < 106 && deltaX > -106) {
                    // print(details.delta.dx);
                    offsetX += details.delta.dx;
                    isSwiping = true;

                    if (!opened && offsetX > 0) {
                      offsetX = 0;
                    }
                    if (opened && offsetX < -106) {
                      offsetX = -106;
                    }

                    borderRadiusValue = 7 *
                        ((details.delta.dx < 0)
                            ? -details.delta.dx
                            : details.delta.dx) /
                        106;
                    detailsdeltadx = details.delta.dx;
                    setState(() {});
                  }
                },
                onHorizontalDragEnd: (details) {
                  if (offsetX < -20.0 && offsetX > -106.0) {
                    //widget.onDel();
                    opened = true;
                    offsetX = -106;
                  } else {
                    opened = false;
                  }

                  setState(() {
                    if (!opened) {
                      offsetX = 0.0;
                      isSwiping = false;
                    }

                    borderRadiusValue = 7.0;
                  });
                },
                // onHorizontalDragEnd: (details) {
                //   if (offsetX < -30.0 && offsetX > -60.0) {
                //     // действие при свайпе
                //   }

                //   if (!isSwiping) {
                //     setState(() {
                //       offsetX = 0.0;
                //       borderRadiusValue = 7.0;
                //     });
                //   }
                //   isSwiping = false;
                // },
                child: Transform.translate(
                  offset: Offset(offsetX, 0.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: size.width,
                    height: 76,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        // color: widget.data["new_mgs_count"] != 0
                        //     ? surfacePrimary
                        //     : white,
                        ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: white,
                            shape: widget.data["type"] == "chat"
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                            borderRadius: widget.data["type"] == "chat"
                                ? null
                                : BorderRadius.circular(6),
                            image: widget.data["type"] == "chat"
                                ? DecorationImage(
                                    image: NetworkImage(widget.data["img"]),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: widget.data["type"] != "chat"
                              ? Image.network(
                                  widget.data["img"],
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: size.width * 0.7,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: size.width * 0.5,
                                    child: Text(
                                      extractPhoneNumberFromJid(widget.name),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: black,
                                        fontWeight: w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    widget.data["date"],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: w400,
                                      color: gray100,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              width: size.width * 0.7,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: size.width * 0.6,
                                    child: Text(
                                      widget.data["last_msg"],
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: w400,
                                        color: gray100,
                                      ),
                                    ),
                                  ),
                                  if (widget.data["new_mgs_count"] != 0)
                                    Container(
                                      padding: const EdgeInsets.only(
                                        top: 1,
                                        left: 5,
                                        right: 5,
                                        bottom: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        widget.data["new_mgs_count"].toString(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: w600,
                                          color: white,
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
