import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shop_app/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/grocery_item.dart';
import '../data/categories.dart';

class NewItem extends StatefulWidget {
   const NewItem({super.key,});

   @override
  State<NewItem> createState()=> _NewItem();
}

class _NewItem extends State<NewItem>{
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  int _enteredQuantity = 0;
  Category _selectedCategory = categories[Categories.fruit]! ;
  bool _isLoading = false;

  void _saveItem()async{
    if(_formKey.currentState!.validate()){
      final url = Uri.https('flutter-test-7df69-default-rtdb.firebaseio.com','shopping-list.json');
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      final res= await http.post(url, headers: {
        'Content-Type' : 'application/json',
      }, body:
      json.encode({
        'name': _enteredName,
        'quantity' : _enteredQuantity,
        'category': _selectedCategory.title,
      }),
      );
      final Map<String, dynamic> resData = json.decode(res.body);
      if(res.statusCode == 200){
        Navigator.of(context).pop(
            GroceryItem(id: resData['name'],
                name: _enteredName,
                quantity: _enteredQuantity,
                category: _selectedCategory)
        );
      }


    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Item"),),
      body: Padding(padding: EdgeInsets.all(12),
        child: Form(
          key:_formKey,
          child: Column(
        children: [
          TextFormField(
            maxLength: 50,
            onSaved: (newValue) {
              setState(() {
                _enteredName = newValue!;
              });

            },
            decoration: InputDecoration(labelText: 'Name'),
            validator: (String? value){
              if( value==null || value.isEmpty || value.trim().length<=1 || value.trim().length> 50){
                return 'Must be between 1 and 50 characters';
              }
              return null;
            },
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: TextFormField(
                keyboardType: TextInputType.number,
                initialValue: '1',
                onSaved: (newValue) {

                    _enteredQuantity = int.parse(newValue!);


                },
                decoration: InputDecoration(labelText: 'Quantity'),
                validator: (String? value){
                  if( value==null || value.isEmpty || int.tryParse(value)==null|| int.tryParse(value)!<=0){
                    return 'Must be a valid, positive number';
                  }
                  return null;
                },
              ),),
              SizedBox(width: 6,),
              Expanded(child: DropdownButtonFormField(
                value: _selectedCategory,
                  items: [
                    for(final category in categories.entries)
                      DropdownMenuItem(
                        value: category.value,
                          child: Row(children: [
                        Container(height: 16,width: 16, color: category.value.color,),
                        SizedBox(width: 6,),
                        Text(category.value.title),
                      ],))
                  ],
                  onChanged: (Category? value){

                      _selectedCategory = value! ;


                  }))
            ],
          ),
          SizedBox(height: 16,),
          Row( mainAxisAlignment: MainAxisAlignment.end,
            children: [
            TextButton(onPressed:_isLoading? null: (){
              _formKey.currentState!.reset();
            }, child: Text("Reset")),
            ElevatedButton(onPressed:_isLoading? null:  _saveItem

              //make validation => "for"



            , child: _isLoading? SizedBox( height: 16,width: 16,child: CircularProgressIndicator(),): Text("Add Item"))
          ],)

        ],
      ),),),
    );
  }
}
