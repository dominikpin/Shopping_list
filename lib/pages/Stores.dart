// ignore_for_file: deprecated_member_use, unused_local_variable, use_key_in_widget_constructors, file_names

import 'dart:convert';
import 'dart:io';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/Store.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class Stores extends StatefulWidget {
  @override
  State<Stores> createState() => _Stores();
}

class _Stores extends State<Stores> {
  List<Store> storeList = [];
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStores();
  }

  loadStores() async {
    final prefs = await SharedPreferences.getInstance();
    final storeListJson = prefs.getString('Stores');
    if (storeListJson != null) {
      final decodedStoreList = jsonDecode(storeListJson);
      setState(() {
        storeList = decodedStoreList
            .map<Store>((item) => Store.fromJson(item))
            .toList();
      });
    }
  }

  saveShopList() async {
    final prefs = await SharedPreferences.getInstance();
    final storeListJson =
        jsonEncode(storeList.map((item) => item.toJson()).toList());
    await prefs.setString('Stores', storeListJson);
  }

  addShopToList(String storeName) async {
    bool isSame =
        storeList.any((el) => el.name.toLowerCase() == storeName.toLowerCase());
    if (storeName.isEmpty) {
      return;
    }
    if (!isSame) {
      setState(() {
        storeList.add(Store(name: storeName, imageLocation: '', itemList: []));
      });
      await saveShopList();
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Text('"$storeName" is already on your list!'),
          ),
        );
      },
    );
  }

  editStoreFromList(Store store, String name) async {
    setState(() {
      if (store.name.isNotEmpty) {
        store.name = name;
      }
    });
    await saveShopList();
  }

  removeStoreFromList(Store store) async {
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
                      'Are you sure you want to delete ${store.name}?',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() {
                      storeList.remove(store);
                      textController.clear();
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

  printStoreList() {
    for (var store in storeList) {
      {
        // ignore: avoid_print
        print(
            'Store name: ${store.name}, Store IMGpath: ${store.imageLocation} Store items: ${store.itemList.map((item) => item.text).join(', ')}');
      }
    }
  }

  getImage(Store store) async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final image = File(pickedFile.path);
      final imagePath = await saveImage(image, store);
      store.imageLocation = imagePath;
      setState(() {});
    }
  }

  Future<String> saveImage(File image, Store store) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/${store.name}Image.png';
    final File newImage = await image.copy(imagePath);
    return imagePath;
  }

  removeImage(Store store) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/${store.name}Image.png';
    File imageFile =
        File(imagePath); // imagePath is the path of the saved image
    if (await imageFile.exists()) {
      await imageFile.delete();
    }
    store.imageLocation = '';
    await saveShopList();
    setState(() {});
  }

  removeOrEditStoreFromList(Store store) async {
    showDialogSuper(
      context: context,
      onDismissed: (dynamic value) {
        textController.clear();
      },
      builder: (BuildContext context) {
        textController = TextEditingController(text: store.name);
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: Center(
                    child: TextField(
                      onSubmitted: (value) {
                        Navigator.pop(context);
                        editStoreFromList(store, value);
                        textController.clear();
                      },
                      autofocus: true,
                      controller: textController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Change ${store.name} name.',
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              setState(() {
                                editStoreFromList(store, textController.text);
                                textController.clear();
                              });
                              await saveShopList();
                            },
                            child: const Text('Change'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              removeStoreFromList(store);
                            },
                            child: const Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              setState(() {
                                getImage(store);
                                textController.clear();
                              });
                              await saveShopList();
                            },
                            child: const Text('Add Image'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              setState(() {
                                removeImage(store);
                                textController.clear();
                              });
                              await saveShopList();
                            },
                            child: const Text('Remove Image'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
        title: const Text('Store list'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        actions: [
          Visibility(
            visible: kDebugMode,
            child: IconButton(
              onPressed: () {
                printStoreList();
              },
              icon: const Icon(Icons.print),
            ),
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: storeList.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.grey[350],
              child: ListTile(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/ShoppingList',
                    arguments: {
                      'store': storeList[index],
                      'saveShopList': saveShopList,
                    },
                  );
                },
                onLongPress: () {
                  removeOrEditStoreFromList(storeList[index]);
                },
                title: Text(storeList[index].name),
                leading: storeList[index].imageLocation.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.all(3),
                        child: Image.file(File(storeList[index].imageLocation)))
                    : const Icon(Icons.shopping_cart_rounded),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addStore',
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
                          addShopToList(textController.text);
                          textController.clear();
                        },
                        autofocus: true,
                        controller: textController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Add new store to the list!',
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          addShopToList(textController.text);
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
    );
  }
}
