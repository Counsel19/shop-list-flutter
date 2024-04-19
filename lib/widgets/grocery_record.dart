import 'package:flutter/material.dart';
import 'package:shop_list/models/grocery_item.dart';

class GroceryRecord extends StatelessWidget {
  const GroceryRecord({super.key, required this.groceryItem});

  final GroceryItem groceryItem;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Container(
          color: groceryItem.category.color,
          width: 20,
          height: 20,
        ),
        title: Text(groceryItem.name),
        trailing: Text("${groceryItem.quantity}"));
  }
}
