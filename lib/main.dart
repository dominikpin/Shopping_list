import 'dart:convert';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
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
  late int editingIndex;
  late TextEditingController textController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    loadItemList();
  }

  loadItemList() async {
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

  sortListAlphabetically() async {
    itemList.sort((a, b) => a.text.toLowerCase().compareTo(b.text.toLowerCase()));
    return;
  }

  sortListSlovenian() async {
    const slovenianAlphabet = 'a,b,c,č,d,e,f,g,h,i,j,k,l,m,n,o,p,r,s,š,t,u,v,z,ž';
    final List<String> slovenianOrder = slovenianAlphabet.split(',');
    itemList.sort((a, b) {
      int minLen = a.text.length < b.text.length ? a.text.length : b.text.length;
      for (int i = 0; i < minLen; i++) {
        String aChar = a.text[i].toLowerCase();
        String bChar = b.text[i].toLowerCase();
        int aIndex = slovenianOrder.indexOf(aChar);
        int bIndex = slovenianOrder.indexOf(bChar);
        if (aIndex != bIndex) {
          return aIndex - bIndex;
        }
      }
      return a.text.length - b.text.length;
    });
  }

   saveItemList() async {
    final prefs = await SharedPreferences.getInstance();
    final itemListJson =
        jsonEncode(itemList.map((item) => item.toJson()).toList());
    await prefs.setString('itemList', itemListJson);
  }

  addItemToList(String itemText) async {
    bool isSame = itemList.any((el) => el.text.toLowerCase() == itemText.toLowerCase());
    if (itemText.isEmpty) {
      return;
    }
    if (!isSame) {
      setState(() {
        itemList.add(ListItem(text: itemText, isChecked: false));
      });
      await sortListSlovenian();
      await saveItemList();
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Text('"$itemText" is already on your list!'),
          ),
        );
      },
    );
  }

  editItemFromList(String itemText) async {
    if (itemText.isNotEmpty) {
      setState(() {
        itemList[editingIndex].text = itemText;
      });
      await sortListSlovenian();
      await saveItemList();
    }
  }

  removeItemFromList(String itemText) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Are you sure you want to delete $itemText'),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() {
                      itemList.removeWhere((remove) => itemText == remove.text);
                    });
                    checkIfAllTrue();
                    await saveItemList();
                  },
                  child: const Text('Yes'),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  checkIfAllTrue() {
    if (itemList.isEmpty) {
      return;
    }
    for(ListItem item in itemList) {
      if (!item.isChecked) {
        return;
      }
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: const Text('Shopping completed!'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Shopping list'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
      ),
      body: ListView(
        children: [
          Column(
            children: [
              buildItemList(context),
            ],
          ),
          const SizedBox(height: 150),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
          context: context,
          builder: (BuildContext context) {
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
                        addItemToList(textController.text);
                        textController.clear();
                      },
                      autofocus: true,
                      controller: textController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Add new item to the shopping list!',
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        addItemToList(textController.text);
                        textController.clear();
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            );
          },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Column buildItemList(BuildContext context) {
    return Column(
      children: itemList.map((item) => Row(
        key: Key(item.text),
        children: [
          Transform.scale(
            scale: 1.5,
            child: Checkbox(
              value: item.isChecked,
              onChanged: (value) {
                setState(() {
                  item.isChecked = value!;
                  checkIfAllTrue();
                });
                saveItemList();
              },
              fillColor: MaterialStateColor.resolveWith((states) => Colors.grey[900]!),
              side: const BorderSide(
                width: 2.0,
                style: BorderStyle.solid,
                color: Colors.black,
              )
            ),
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
          const Spacer(),
          IconButton(
            onPressed: () {
              setState(() {
                editingIndex = itemList.indexWhere((element) => item.text == element.text);
              });
              showDialogSuper(
                context: context,
                onDismissed: (dynamic value) { textController.clear(); },
                builder: (BuildContext context) {
                  textController = TextEditingController(text: itemList[editingIndex].text);
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
                              editItemFromList(textController.text);
                            },
                            autofocus: true,
                            controller: textController,
                            decoration:  InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText:
                                  'Change "${itemList[editingIndex].text}" into whatever you like',
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              editItemFromList(textController.text);
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
              removeItemFromList(item.text);
            },
            icon: Icon(
              Icons.close,
              color: Colors.grey[200],
              size: 20.0,
            ),
          ),
        ],
      ))
      .toList(),
    );
  }
}
