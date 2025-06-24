import 'package:hive/hive.dart';

part 'item_model.g.dart';

@HiveType(typeId: 0)
class ItemModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double price;

  @HiveField(2)
  String icon;

  ItemModel({required this.name, required this.price, required this.icon});
}