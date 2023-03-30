// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, library_private_types_in_public_api, file_names

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

import 'ListItem.dart';

class ListItemWidget extends StatefulWidget {
  late ListItem item;
  late TextEditingController textController;
  final Function removeFunction;
  final Function editItemFunction;

  ListItemWidget({
    required this.item,
    required this.textController,
    required this.removeFunction,
    required this.editItemFunction,
  });

  @override
  _ListItemWidget createState() => _ListItemWidget();
}

class _ListItemWidget extends State<ListItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform.scale(
          scale: 1.5,
          child: Checkbox(
              value: widget.item.isChecked,
              onChanged: (value) {
                setState(() {
                  widget.item.isChecked = value!;
                  widget.editItemFunction();
                });
              },
              fillColor:
                  MaterialStateColor.resolveWith((states) => Colors.grey[900]!),
              side: const BorderSide(
                width: 2.0,
                style: BorderStyle.solid,
                color: Colors.black,
              )),
        ),
        Text(
          widget.item.text,
          style: !widget.item.isChecked
              ? const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )
              : TextStyle(
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.lineThrough,
                  decorationThickness: 3.0,
                ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            showDialogSuper(
              context: context,
              onDismissed: (dynamic value) {
                widget.textController.clear();
              },
              builder: (BuildContext context) {
                widget.textController =
                    TextEditingController(text: widget.item.text);
                return Dialog(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextField(
                          onSubmitted: (value) {
                            Navigator.pop(context);
                            widget.item.text = widget.textController.text;
                            widget.editItemFunction();
                          },
                          autofocus: true,
                          controller: widget.textController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText:
                                'Change "${widget.item.text}" into whatever you like',
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.item.text = widget.textController.text;
                            widget.editItemFunction();
                          },
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          icon: Icon(
            Icons.edit,
            color: Colors.grey[200],
            size: 15.0,
          ),
        ),
        IconButton(
          onPressed: () {
            widget.removeFunction();
          },
          icon: Icon(
            Icons.close,
            color: Colors.grey[200],
            size: 20.0,
          ),
        ),
      ],
    );
  }
}
