import 'package:flutter/material.dart';

abstract class ChangeDetectingStatefulWidget extends StatefulWidget {
  const ChangeDetectingStatefulWidget({super.key});

  String value();
}

abstract class UpdatingScreenState<T extends ChangeDetectingStatefulWidget>
    extends State<T> {
  @override
  void initState() {
    super.initState();
    initOrUpdateWidgetParams();
  }

  void initOrUpdateWidgetParams();

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value() != widget.value()) {
      initOrUpdateWidgetParams();
    }
  }
}
