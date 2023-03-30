// ignore_for_file: use_key_in_widget_constructors, file_names

import 'package:flutter/material.dart';
import '../classes/ListItem.dart';
import '../classes/ListItemWidget.dart';
import '../classes/Store.dart';

class ShoppingList extends StatefulWidget {
  @override
  State<ShoppingList> createState() => _ShoppingList();
}

class _ShoppingList extends State<ShoppingList> {
  late Store store;
  late List<ListItem> itemList;
  late int editingIndex;
  late TextEditingController textController = TextEditingController();
  late Function saveShopList;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Map args = ModalRoute.of(context)!.settings.arguments as Map;
    store = args['store'] as Store;
    saveShopList = args['saveShopList'] as Function;
    itemList = store.itemList;
  }

  sortListAlphabetically() async {
    itemList
        .sort((a, b) => a.text.toLowerCase().compareTo(b.text.toLowerCase()));
    return;
  }

  sortListSlovenian() async {
    const slovenianAlphabet =
        'a,b,c,č,d,e,f,g,h,i,j,k,l,m,n,o,p,r,s,š,t,u,v,z,ž';
    final List<String> slovenianOrder = slovenianAlphabet.split(',');
    itemList.sort((a, b) {
      int minLen =
          a.text.length < b.text.length ? a.text.length : b.text.length;
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

  addItemToList(String itemText) async {
    bool isSame =
        itemList.any((el) => el.text.toLowerCase() == itemText.toLowerCase());
    if (itemText.isEmpty) {
      return;
    }
    if (!isSame) {
      setState(() {
        itemList.add(ListItem(text: itemText, isChecked: false));
      });
      await sortListSlovenian();
      await saveShopList();
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

  checkIfAllTrue() {
    if (itemList.isEmpty) {
      return;
    }
    for (ListItem item in itemList) {
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

  editItemFromList(ListItem item, int itemIndex) async {
    setState(() {
      if (item.text.isNotEmpty) {
        itemList[itemIndex].text = item.text;
      }
      itemList[itemIndex].isChecked = item.isChecked;
    });
    checkIfAllTrue();
    await sortListSlovenian();
    await saveShopList();
  }

  removeItemFromList(ListItem item) async {
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
                SizedBox(
                  child: Center(
                    child: Text(
                      'Are you sure you want to delete ${item.text}?',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() {
                      itemList.remove(item);
                    });
                    checkIfAllTrue();
                    await saveShopList();
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

  removeEveryItemFromList() {
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
                const SizedBox(
                  child: Center(
                    child: Text(
                      'Are you sure you want to delete everything from your shopping list?',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() {
                      itemList.clear();
                    });
                    await saveShopList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(store.name),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Column(
                  children: itemList
                      .map((item) => ListItemWidget(
                            item: item,
                            textController: textController,
                            removeFunction: () => removeItemFromList(item),
                            editItemFunction: () =>
                                editItemFromList(item, itemList.indexOf(item)),
                          ))
                      .toList()),
            ],
          ),
          const SizedBox(height: 150),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 20.0,
            left: 50.0,
            child: Visibility(
              visible: itemList.isNotEmpty,
              child: FloatingActionButton(
                heroTag: 'remove',
                onPressed: () {
                  removeEveryItemFromList();
                },
                child: Icon(
                  Icons.close,
                  color: Colors.grey[200],
                  size: 20.0,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: FloatingActionButton(
              heroTag: 'add',
              child: const Icon(Icons.add),
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
                              textAlign: TextAlign.center,
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
            ),
          ),
        ],
      ),
    );
  }
}
