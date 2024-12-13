import 'package:flutter/material.dart';
import 'package:xiaomi_weather_clone/app/extensions/context_extension.dart';

class ItemList {
  int index;
  bool isSelected;
  BoxDecoration? decoration;
  ItemList({required this.index, this.isSelected = false, this.decoration});
}

class DataLocation {
  final String id;
  final String name;
  final double currentTemp;
  final int aqi;
  final double minTemp;
  final double maxTemp;
  const DataLocation(
      {required this.id,
      required this.name,
      required this.currentTemp,
      required this.aqi,
      required this.minTemp,
      required this.maxTemp});
}

class DataLocationItem extends ItemList {
  final DataLocation dataLocation;
  DataLocationItem(
      {required this.dataLocation,
      required super.index,
      super.isSelected,
      super.decoration});
}

class SelectableList extends StatefulWidget {
  final Function(int index) onSelectionMode;
  final List<DataLocationItem> items;
  final Function(int index) onTap;
  final bool selectionMode;
  const SelectableList(
      {super.key,
      required this.onSelectionMode,
      required this.selectionMode,
      required this.onTap,
      required this.items});

  @override
  State<SelectableList> createState() => _SelectableListState();
}

class _SelectableListState extends State<SelectableList> {
  void updateItems(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) newIndex -= 1;
      final item = widget.items.removeAt(oldIndex);
      widget.items.insert(newIndex, item);

      for (int i = 0; i < widget.items.length; i++) {
        widget.items[i].index = i;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverReorderableList(
        itemCount: widget.items.length,
        onReorder: updateItems,
        itemBuilder: (BuildContext context, int index) {
          return _SelectableWidget(
            dataLocationItem: widget.items[index],
            selectionMode: widget.selectionMode,
            onLongPress: widget.onSelectionMode,
            onTap: widget.onTap,
          );
        });
  }
}

class _SelectableWidget extends StatelessWidget {
  final Function(int index) onTap;
  final bool selectionMode;
  final DataLocationItem dataLocationItem;
  final Function(int index) onLongPress;

  _SelectableWidget({
    required this.dataLocationItem,
    required this.selectionMode,
    required this.onLongPress,
    required this.onTap,
  }) : super(key: Key(dataLocationItem.dataLocation.id));

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: dataLocationItem.index,
      enabled: selectionMode,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Material(
          child: GestureDetector(
            onTap: () async => await onTap(dataLocationItem.index),
            onLongPress: () async {
              if (selectionMode) return;
              dataLocationItem.isSelected = !dataLocationItem.isSelected;
              await onLongPress(dataLocationItem.index);
            },
            child: Container(
                height: 80,
                decoration: dataLocationItem.decoration,
                child: ListTile(
                  leading: !selectionMode
                      ? null
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu,
                              color: Colors.white,
                            ),
                          ],
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${dataLocationItem.dataLocation.currentTemp.round()}º',
                        style:
                            context.theme.textTheme.displaySmall!.copyWith(color: Colors.white),
                      ),
                      !selectionMode
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: dataLocationItem.isSelected
                                        ? Colors.blue
                                        : Colors.black38,
                                    border: dataLocationItem.isSelected
                                        ? null
                                        : Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(17.5),
                                  ),
                                  child: !dataLocationItem.isSelected
                                      ? null
                                      : const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 15,
                                        )),
                            ),
                    ],
                  ),
                  title: Text(
                    dataLocationItem.dataLocation.name,
                    style: context.theme.textTheme.titleMedium!.copyWith(color: Colors.white),
                  ),
                  subtitle: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${context.localizations.aqi} ${dataLocationItem.dataLocation.aqi}',
                        style: context.theme.textTheme.titleSmall!.copyWith(color: Colors.white70) 
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${dataLocationItem.dataLocation.maxTemp.round()}º / ${dataLocationItem.dataLocation.minTemp.round()}º',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
