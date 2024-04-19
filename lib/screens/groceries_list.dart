import 'dart:convert';

import "package:http/http.dart" as http;

import 'package:flutter/material.dart';
import 'package:shop_list/data/categories.dart';
import 'package:shop_list/models/grocery_item.dart';
import 'package:shop_list/screens/new_items.dart';
import 'package:shop_list/widgets/grocery_record.dart';

class GroceriesListSreen extends StatefulWidget {
  const GroceriesListSreen({super.key});

  @override
  State<GroceriesListSreen> createState() => _GroceriesListSreenState();
}

class _GroceriesListSreenState extends State<GroceriesListSreen> {
  List<GroceryItem> _groceryItems = [];

  var _isLoading = true;

  String? _error;

  @override
  void initState() {
    super.initState();

    _getItems();
  }

  void _getItems() async {
    try {
      final url = Uri.https("flutter-app-d34ee-default-rtdb.firebaseio.com",
          "shopping-list.json");

      final res = await http.get(url);

      if (res.statusCode >= 400) {
        setState(() {
          _error = "Failed to fetch resource, please try again";
        });
      }

      if (res.body == "null") {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(res.body);

      final List<GroceryItem> loadedItems = [];

      for (final item in listData.entries) {
        final category = categories.entries.firstWhere(
            (catItem) => catItem.value.title == item.value["category"]);
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value["name"],
            quantity: item.value["quantity"],
            category: category.value,
          ),
        );
      }

      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to fetch resource, please try again";
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const NewItemScreen(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _deleteItem(int index) async {
    final victimItem = _groceryItems[index];

    var msg = "Item Removed Sucussfully";

    setState(() {
      _groceryItems.removeAt(index);
    });

    final url = Uri.https("flutter-app-d34ee-default-rtdb.firebaseio.com",
        "shopping-list/${victimItem.id}.json");

    final res = await http.delete(url);

    if (res.statusCode >= 400) {
      msg = "Error Deleting Item, Please try again";

      setState(() {
        _groceryItems.insert(index, victimItem);
      });
    }

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(msg),
      action: SnackBarAction(
        label: "Undo",
        onPressed: () {
          setState(() {
            _groceryItems.insert(index, victimItem);
          });
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _error != null
                ? Text(_error!)
                : _groceryItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("No Items to Display"),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton.icon(
                                onPressed: _addItem,
                                icon: const Icon(Icons.add),
                                label: const Text("Add New Item"))
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _groceryItems.length,
                        itemBuilder: (ctx, index) => Dismissible(
                              key: ValueKey(_groceryItems[index].id),
                              background: Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .errorContainer,
                                margin: const EdgeInsets.all(12),
                              ),
                              onDismissed: (direction) {
                                _deleteItem(index);
                              },
                              child: GroceryRecord(
                                groceryItem: _groceryItems[index],
                              ),
                            )),
      ),
    );
  }
}
