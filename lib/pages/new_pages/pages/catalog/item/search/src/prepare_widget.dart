import 'package:flutter/material.dart';

import 'helper_classes.dart';

Widget? prepareWidget(dynamic object,
    {dynamic parameter = const NotGiven(),
    Function? updateParent,
    BuildContext? context,
    Function? stringToWidgetFunction}) {
  // Проверка, если объект равен null, возвращается null
  if (object == null) {
    return (null);
  }
  // Если объект является виджетом, возвращается сам объект
  if (object is Widget) {
    return (object);
  }
  // Если объект является строкой, создается виджет Text с этой строкой
  // или используется пользовательская функция stringToWidgetFunction
  if (object is String) {
    if (stringToWidgetFunction == null) {
      return (Text(
        object,
      ));
    } else {
      return (stringToWidgetFunction(object));
    }
  }

  // Если объект является функцией, производится множество проверок и вызовов
  if (object is Function) {
    // Логика для вызова функции с различными комбинациями аргументов
    // и обработка исключений NoSuchMethodError
    // Результат функции преобразуется в виджет с рекурсивным вызовом prepareWidget

    dynamic objectResult = const NotGiven();
    if (parameter is! NotGiven && context != null && updateParent != null) {
      try {
        objectResult = object(parameter, context, updateParent);
      } on NoSuchMethodError {
        objectResult = const NotGiven();
      }
    }
    if (objectResult is NotGiven && parameter is! NotGiven && context != null) {
      try {
        objectResult = object(parameter, context);
      } on NoSuchMethodError {
        objectResult = const NotGiven();
      }
    }
    if (objectResult is NotGiven &&
        parameter is! NotGiven &&
        updateParent != null) {
      try {
        objectResult = object(parameter, updateParent);
      } on NoSuchMethodError {
        objectResult = const NotGiven();
      }
    }
    if (objectResult is NotGiven && context != null && updateParent != null) {
      try {
        objectResult = object(context, updateParent);
      } on NoSuchMethodError {
        objectResult = const NotGiven();
      }
    }
    if (objectResult is NotGiven && parameter is! NotGiven) {
      try {
        objectResult = object(parameter);
      } on NoSuchMethodError {
        objectResult = const NotGiven();
      }
    }
    if (objectResult is NotGiven && context != null) {
      try {
        objectResult = object(context);
      } on NoSuchMethodError {
        objectResult = const NotGiven();
      }
    }
    if (objectResult is NotGiven && updateParent != null) {
      try {
        objectResult = object(updateParent);
      } on NoSuchMethodError {
        objectResult = const NotGiven();
      }
    }
    if (objectResult is NotGiven) {
      try {
        objectResult = object();
      } on NoSuchMethodError {
        objectResult = const Text(
          "Call failed",
          style: TextStyle(color: Colors.red),
        );
      }
    }
    return (prepareWidget(objectResult,
        stringToWidgetFunction: stringToWidgetFunction));
  }
  // Если тип объекта не распознан, возвращается виджет Text с сообщением об ошибке

  return (Text(
    "Unknown type: ${object.runtimeType.toString()}",
    style: const TextStyle(color: Colors.red),
  ));
}
