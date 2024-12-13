import 'package:flutter/material.dart';
import 'package:xiaomi_weather_clone/app/extensions/context_extension.dart';

class SelectionItem {
  SelectionItem({required this.title, required this.value});

  final String title;
  final String value;
}

class SelectionButton extends StatefulWidget {
  final String title;
  final List<SelectionItem> list;
  final String initialValue;
  final Function(String) onSelected;

  const SelectionButton(
      {super.key,
      required this.title,
      required this.list,
      required this.initialValue,
      required this.onSelected});

  @override
  State<SelectionButton> createState() => _SelectionButtonState();
}

class _SelectionButtonState extends State<SelectionButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        _showPopupMenu(context, details.globalPosition);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Text(widget.title,
                    style: context.theme.textTheme.bodyMedium!
                        .copyWith(fontWeight: FontWeight.w500))),
            Expanded(
                child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    widget.list
                        .firstWhere((e) => e.value == widget.initialValue)
                        .title,
                    style: context.theme.textTheme.bodyMedium!
                        .copyWith(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 5),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.keyboard_arrow_up_sharp, size: 15.0),
                    Icon(Icons.keyboard_arrow_down_sharp, size: 15.0),
                  ],
                )
              ],
            ))
          ],
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context, Offset position) async {
    final selectedValue = await showMenu<String>(
      context: context,
      color: Colors.white,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      menuPadding: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      items: () {
        final children = <PopupMenuEntry<String>>[];

        for (int i = 0; i < widget.list.length; i++) {
          final item = widget.list[i];
          final child = Container(
              color: item.value != widget.initialValue
                  ? null
                  : Colors.blue.shade100,
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.title),
                  const SizedBox(width: 10),
                  if (item.value == widget.initialValue)
                    const Icon(Icons.check, color: Colors.green)
                ],
              ));
          children.add(PopupMenuItem(
              value: item.value,
              padding: EdgeInsets.zero,
              child: i == 0
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      child: child)
                  : i == widget.list.length - 1
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20)),
                          child: child)
                      : child));
        }
        return children;
      }(),
      elevation: 8.0,
    );
    if (selectedValue == null) return;
    widget.onSelected(selectedValue);
  }
}
