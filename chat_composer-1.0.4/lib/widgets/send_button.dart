import 'dart:developer';

import '../consts/consts.dart';
import '../cubit/recordaudio_cubit.dart';
import '../utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum DragAxis { horizontal, vertical }

class SendButton extends StatefulWidget {
  final Function(String?) onReceiveText;
  final Function()? onPanCancel;
  final double composerHeight;

  const SendButton(
      {Key? key,
      required this.composerHeight,
      required this.onReceiveText,
      this.onPanCancel})
      : super(key: key);

  @override
  State<SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<SendButton> with TickerProviderStateMixin {
  final Stopwatch stopwatch = Stopwatch();
  late Animation<double> sizeAnimation,
      posAnimation1,
      posAnimation2,
      rotateAnimation;
  late AnimationController recordAnimation,
      cancelAnimation1,
      cancelAnimation2,
      rotationAnimation;
  ValueNotifier<double> sizeListener = ValueNotifier(1);
  ValueNotifier<double> micPosListener = ValueNotifier(0);
  ValueNotifier<double> deletePosListener = ValueNotifier(30);
  ValueNotifier<bool> dragLocked = ValueNotifier(false);
  ValueNotifier<List<double>> posValueListener = ValueNotifier([1, 0]);
  double _horizontalPos = 1, _verticalPos = 0, lockPos = -25, cancelPos = 0.6;
  bool dragCanceled = false;

  @override
  void initState() {
    super.initState();
    recordAnimation = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    rotationAnimation = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    cancelAnimation1 = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    cancelAnimation2 = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);

    sizeAnimation = Tween<double>(begin: 1, end: 1.7).animate(
        CurvedAnimation(parent: recordAnimation, curve: Curves.fastOutSlowIn))
      ..addListener(() {
        sizeListener.value = sizeAnimation.value;
      });
    posAnimation1 = Tween<double>(begin: 0, end: -14).animate(
        CurvedAnimation(parent: cancelAnimation1, curve: Curves.fastOutSlowIn))
      ..addListener(() {
        micPosListener.value = posAnimation1.value;
      });
    posAnimation2 = Tween<double>(begin: 30, end: -1).animate(
        CurvedAnimation(parent: cancelAnimation2, curve: Curves.fastOutSlowIn))
      ..addListener(() {
        deletePosListener.value = posAnimation2.value;
      });
    rotateAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: rotationAnimation, curve: Curves.fastOutSlowIn));

    context.read<RecordAudioCubit>().stream.listen((event) {
      if (event is RecordAudioStarted) {
        recordAnimation.forward();
      } else if (event is RecordAudioReady) {
        dragLocked.value = false;
        dragCanceled = true;
        recordAnimation.reverse();
        _verticalPos = 0;
        _horizontalPos = 1;
        posValueListener.value = [_horizontalPos, _verticalPos];
      }
    });
  }

  DragAxis? getAxis(DragUpdateDetails details) {
    DragAxis axis;
    _verticalPos =
        (_verticalPos + details.delta.dy / (context.size!.height * 0.06));
    _horizontalPos =
        (_horizontalPos + details.delta.dx / (context.size!.width));
    if (((_verticalPos * -1)) < (1 - _horizontalPos)) {
      axis = DragAxis.horizontal;
    } else {
      axis = DragAxis.vertical;
    }
    if (_horizontalPos < 0.96) axis = DragAxis.horizontal;
    if (axis == DragAxis.horizontal && _horizontalPos > 1) return null;
    return axis;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (_) {
        final GestureDetector handle = GestureDetector(
          onPanDown: (_) {
            dragCanceled = false;
            if (dragLocked.value &&
                (context.read<RecordAudioCubit>().state
                    is RecordAudioStarted)) {
              context.read<RecordAudioCubit>().stopRecord();
              dragLocked.value = false;

              return;
            }
            stopwatch.stop();
            stopwatch.reset();
            stopwatch.start();
            dragLocked.value = false;
            context.read<RecordAudioCubit>().startRecord();
          },
          onPanUpdate: (d) {
            if (dragCanceled || dragLocked.value) return;
            DragAxis? axis = getAxis(d);

            if (axis == DragAxis.vertical) {
              posValueListener.value = [1, _verticalPos];
              if (_verticalPos <= lockPos) {
                dragLocked.value = true;
                _verticalPos = 0;
                _horizontalPos = 1;
                posValueListener.value = [_horizontalPos, _verticalPos];
              }
            } else if (axis == DragAxis.horizontal) {
              posValueListener.value = [_horizontalPos, 0];
              if (_horizontalPos <= cancelPos) {
                if (!dragCanceled) {
                  dragCanceled = true;
                  recordAnimation.reverse();
                  _verticalPos = 0;
                  _horizontalPos = 1;
                  posValueListener.value = [_horizontalPos, _verticalPos];
                  cancelRecord();
                }
              }
            } else {
              posValueListener.value = [1, 0];
            }
          },
          onPanEnd: (d) {
            if (dragLocked.value || dragCanceled) return;

            context.read<RecordAudioCubit>().stopRecord();
            _verticalPos = 0;
            _horizontalPos = 1;
            posValueListener.value = [_horizontalPos, _verticalPos];
          },
          onPanCancel: () {
            if (!dragCanceled) {
              if (stopwatch.elapsed.inMilliseconds > 300) {
                context.read<RecordAudioCubit>().stopRecord();
              } else {
                dragCanceled = true;
                if (widget.onPanCancel != null) {
                  widget.onPanCancel!();
                } else {
                  Fluttertoast.cancel();
                  Fluttertoast.showToast(
                      msg: "Hold to record",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.grey.withOpacity(0.8),
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
                context.read<RecordAudioCubit>().cancelRecord();
              }
              stopwatch.stop();
              stopwatch.reset();
            }
          },
          child: ValueListenableBuilder<double>(
              valueListenable: sizeListener,
              builder: (_, value, __) {
                return Transform.scale(
                  scale: value,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: ValueListenableBuilder<bool>(
                        valueListenable: dragLocked,
                        builder: (_, locked, __) {
                          return SendType(
                            icon: locked ? localSendIcon : localRecordIcon,
                            height: widget.composerHeight,
                          );
                        }),
                  ),
                );
              }),
        );

        return SizedBox(
          height: widget.composerHeight,
          child: ValueListenableBuilder<List<double>>(
            valueListenable: posValueListener,
            builder: (_, List<double> value, __) {
              return BlocBuilder<RecordAudioCubit, RecordaudioState>(
                builder: (_, RecordaudioState state) {
                  return Stack(
                    children: [
                      if (state is RecordAudioStarted)
                        Container(
                          margin:
                              EdgeInsets.only(right: widget.composerHeight + 8),
                          decoration: BoxDecoration(
                              color: localComposerColor,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(18))),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (!dragLocked.value)
                                Align(
                                  alignment:
                                      Alignment((value[0] * 0.7) * 2 - 1, 0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.arrow_back_ios,
                                        size: 20,
                                        color: localTextColor,
                                      ),
                                      Text(
                                        'Slide to cancel',
                                        style: TextStyle(
                                            color: localTextColor,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: widget.composerHeight - 8,
                                          width: widget.composerHeight - 8,
                                          child: Stack(
                                            children: [
                                              ValueListenableBuilder<double>(
                                                valueListenable: micPosListener,
                                                builder: (_, value, __) {
                                                  return Align(
                                                    alignment:
                                                        Alignment(0, value),
                                                    child: RotationTransition(
                                                      turns: rotateAnimation,
                                                      child: Icon(
                                                        Icons.mic_rounded,
                                                        color:
                                                            localRecordIconColor,
                                                        size: 28,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              ValueListenableBuilder<double>(
                                                valueListenable:
                                                    deletePosListener,
                                                builder: (_, value, __) {
                                                  return Align(
                                                    alignment:
                                                        Alignment(0, value),
                                                    child: Image.asset(
                                                      'packages/chat_composer/images/delete_icon.png',
                                                      width: 40,
                                                      height: 40,
                                                      color: Colors.grey,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        ValueListenableBuilder<Duration?>(
                                          valueListenable: context
                                              .read<RecordAudioCubit>()
                                              .currentDuration,
                                          builder: (_, value, __) {
                                            return Container(
                                              color: localComposerColor,
                                              child: Text(
                                                printDuration(value),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: localTextColor),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (dragLocked.value)
                                    CupertinoButton(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Icon(
                                        Icons.delete_rounded,
                                        color: localDeleteButtonColor,
                                        size: 28,
                                      ),
                                      onPressed: () {
                                        dragLocked.value = false;
                                        recordAnimation.reverse();
                                        cancelRecord();
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      Align(
                        alignment: Alignment(1, lockPos),
                        child: SizedBox(
                          height: widget.composerHeight - 8,
                          width: widget.composerHeight - 8,
                          child: ValueListenableBuilder<double>(
                              valueListenable: sizeListener,
                              builder: (_, value, __) {
                                return Transform.scale(
                                  scale: dragLocked.value
                                      ? 0
                                      : value == 1
                                          ? 0
                                          : ((value / 2)),
                                  child: Card(
                                    shape: const CircleBorder(),
                                    color: localLockBackgroundColor,
                                    child: Icon(
                                      Icons.lock_outline,
                                      color: localLockColor,
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
                      if (state is RecordAudioClosed)
                        Align(
                          alignment: const Alignment(1, 0),
                          child: SendType(
                            icon: localSendIcon,
                            height: widget.composerHeight,
                            onTap: () {
                              String msg = localController.text.trim();
                              if (msg.isNotEmpty) {
                                log('[chat_composer] 🟢 text "$msg"');
                                widget.onReceiveText(msg);
                              } else {
                                log('[chat_composer] 🔴 Text Empty');
                              }
                            },
                          ),
                        )
                      else
                        Align(
                          alignment:
                              Alignment(value[0] * 2 - 1, value[1] * 2 - 1),
                          child: handle,
                        ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void cancelRecord() {
    rotationAnimation.forward(from: 0);
    cancelAnimation1.forward().then((value) {
      cancelAnimation2.forward().then((value) {
        cancelAnimation1.reverse().then((value) {
          context.read<RecordAudioCubit>().cancelRecord();
          cancelAnimation2.reverse();
        });
      });
    });
  }

  @override
  void dispose() {
    recordAnimation.dispose();
    cancelAnimation1.dispose();
    cancelAnimation2.dispose();
    rotationAnimation.dispose();
    sizeAnimation.removeListener(() {});
    posAnimation1.removeListener(() {});
    posAnimation2.removeListener(() {});
    super.dispose();
  }
}

class SendType extends StatelessWidget {
  final double height;
  final Function()? onTap;
  final IconData? icon;

  const SendType(
      {Key? key, required this.height, this.onTap, @required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        width: height - 8,
        height: height - 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: localSendButtonBackgroundColor,
        ),
        child: Icon(
          icon,
          color: localSendButtonColor,
          size: 28,
        ),
      ),
    );
  }
}
