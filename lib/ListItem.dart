class ListItem {

  String text;
  bool isChecked;

  ListItem({ required this.text, required this.isChecked });

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      text: json['text'],
      isChecked: json['isChecked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isChecked': isChecked,
    };
  }
}