// ignore_for_file: file_names

import 'ListItem.dart';

class Store {
  String name;
  String imageLocation;
  List<ListItem> itemList;

  Store(
      {required this.name,
      required this.imageLocation,
      required this.itemList});

  factory Store.fromJson(Map<String, dynamic> json) {
    var itemList = List<ListItem>.from(
      json['itemList'].map(
        (itemJson) => ListItem.fromJson(itemJson),
      ),
    );

    return Store(
      name: json['name'],
      imageLocation: json['imageLocation'],
      itemList: itemList,
    );
  }

  Map<String, dynamic> toJson() {
    var itemListJson = itemList.map((item) => item.toJson()).toList();

    return {
      'name': name,
      'imageLocation': imageLocation,
      'itemList': itemListJson,
    };
  }
}
