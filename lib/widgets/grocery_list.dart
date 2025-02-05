import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shop_app/data/categories.dart';
import 'package:shop_app/models/category.dart';
import 'package:shop_app/models/grocery_item.dart';
import 'package:shop_app/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;

  // This widget is the root of your application.

  void _loadData() async{
    final url = Uri.https('flutter-test-7df69-default-rtdb.firebaseio.com','shopping-list.json');
    final http.Response res= await http.get(url);

    if(res.body == 'null'){
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final Map<String, dynamic> loadedData = json.decode(res.body);

    final List<GroceryItem> _loadedItems = [];

    for(var item in loadedData.entries) {
      final Category category = categories.entries
          .firstWhere((element) =>
      element.value.title == item.value['category'],)
          .value;
      _loadedItems.add(
        GroceryItem(id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );

      setState(() {
        _groceryItems = _loadedItems;
        _isLoading = false;
      });
    }

  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  @override
  Widget build(BuildContext context) {

     Widget content = const Center(child: Text("No Item Added Yet"),);

    if(_isLoading ){
      content = const Center(child: CircularProgressIndicator(),);
     }

     if(_groceryItems.isNotEmpty){
       content = ListView.builder(
         itemCount: _groceryItems.length,

         //dismissible to delete the item

         itemBuilder: (ctx, index)=>Dismissible(
           key: ValueKey(_groceryItems[index].id),
           onDismissed: (_){
             _removeItem(_groceryItems[index]);

           },
           child: ListTile(
             title: Text(_groceryItems[index].name,),
             leading: Container(
               height: 24,
               width: 24,
               color: _groceryItems[index].category.color,),
             trailing: Text(_groceryItems[index].quantity.toString(),),
           ),
         ),
       );
     }
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: _addItem,
              icon: Icon(Icons.add))
        ],
        title: Text('Grocery List'),
      ),
     body: content,
    );
  }

  void _removeItem(GroceryItem item) async{
  final index =  _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https('flutter-test-7df69-default-rtdb.firebaseio.com','shopping-list/${item.id}.json');
  final res =  await http.delete(url);
  if(res.statusCode>= 400){
    setState(() {
      _groceryItems.insert(index, item);
    });
  }

  }
  _addItem() async{
   final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx)=> NewItem(),
        ),
    );
   if(newItem == null){
     return;
   }
   setState(() {
     _groceryItems.add(newItem);
   });



  }
}