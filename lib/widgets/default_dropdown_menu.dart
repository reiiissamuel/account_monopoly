import 'package:flutter/material.dart';


class DefaultDropdownMenu<T> extends StatelessWidget {

  T value;
  final String hintText;
  List<T> items;
  Function(dynamic) onChange;

  DefaultDropdownMenu({super.key, required this.value, required this.hintText, required this.items, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Colors.lightBlueAccent,
                  Theme.of(context).primaryColor,
                  Colors.blueAccent
                  //add more colors
                ]), //background color of dropdown button
            border: Border.all(color: Colors.black38, width:3), //border of dropdown button
            borderRadius: BorderRadius.circular(50), //border raiuds of dropdown button
            boxShadow: const <BoxShadow>[ //apply shadow on Dropdown button
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                  blurRadius: 5) //blur radius of shadow
            ]
        ),
        child:Padding(
            padding: const EdgeInsets.only(left:30, right:30),
            child:DropdownButton(
              hint: Text(hintText, style: const TextStyle(color: Colors.white, fontSize: 12)),
              elevation: 2,
              value: value,
              items: items.map<DropdownMenuItem<T>>((T value) {
                return DropdownMenuItem<T>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              icon: const Padding( //Icon at tail, arrow bottom is default icon
                  padding: EdgeInsets.only(left:20),
                  child:Icon(Icons.arrow_circle_down_sharp)
              ),
              iconEnabledColor: Colors.white, //Icon color
              style: const TextStyle(  //te
                  color: Colors.white, //Font color
                  fontSize: 17 //font size on dropdown button
              ),
              dropdownColor: Theme.of(context).primaryColor, //dropdown background color
              underline: Container(), //remove underline
              isExpanded: true, //make true to make width 100%
              onChanged: onChange
            )
        )
    );
  }
}