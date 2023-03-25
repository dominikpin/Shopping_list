import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ListItem.dart';

void main() {
  runApp(MaterialApp(
    home: ShoppingList(),
  ));
}

class ShoppingList extends StatefulWidget {
  @override
  State<ShoppingList> createState() => _ShoppingList();
}

class _ShoppingList extends State<ShoppingList> {
  List<ListItem> itemList = [];
  late int _editingIndex;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItemList();
  }

  _loadItemList() async {
    final prefs = await SharedPreferences.getInstance();
    final itemListJson = prefs.getString('itemList');
    if (itemListJson != null) {
      final decodedItemList = jsonDecode(itemListJson);
      setState(() {
        itemList = decodedItemList
            .map<ListItem>((item) => ListItem.fromJson(item))
            .toList();
      });
    }
  }

  _saveItemList() async {
    final prefs = await SharedPreferences.getInstance();
    final itemListJson =
        jsonEncode(itemList.map((item) => item.toJson()).toList());
    await prefs.setString('itemList', itemListJson);
  }

  _addItemToList(String itemText) async {
    bool isSame = itemList.any((el) => el.text.toLowerCase() == itemText.toLowerCase());
    if (itemText.isEmpty) {
      return;
    }
    if (!isSame) {
      setState(() {
        itemList.add(ListItem(text: itemText, isChecked: false));
      });
      await _saveItemList();
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              child: Text('Item "${itemText}" is already on your list'),
            ),
          );
        },
      );
    }
  }

  _editItemFromList(String itemText) async {
    if (itemText.isNotEmpty) {
      setState(() {
        itemList[_editingIndex].text = itemText;
      });
      await _saveItemList();
    }
  }

  _removeItemFromList(String itemText) async {
    setState(() {
      itemList.removeWhere((remove) => itemText == remove.text);
    });
    await _saveItemList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Shopping list"),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Column(
                children: itemList
                    .map((item) => Row(
                          key: Key(item.text),
                          children: [
                            Checkbox(
                              value: item.isChecked,
                              onChanged: (value) {
                                setState(() {
                                  item.isChecked = value!;
                                });
                                _saveItemList();
                              },
                            ),
                            Text(
                              item.text,
                              style: !item.isChecked
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
                            Spacer(),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _editingIndex = itemList.indexWhere(
                                      (element) => item.text == element.text);
                                });
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    final TextEditingController
                                        _textController = TextEditingController(
                                      text: itemList[_editingIndex].text,
                                    );
                                    return Dialog(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            TextField(
                                              controller: _textController,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText:
                                                    'Enter a new item to add to the list!',
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _editItemFromList(
                                                    _textController.text);
                                              },
                                              child: const Text('Done'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () {
                                _removeItemFromList(item.text);
                              },
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ))
                    .toList(),
              ),
            ],
          ),
          SizedBox(height: 200),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter a new item to add to the list!',
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _addItemToList(_textController.text);
                      _textController.clear();
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
