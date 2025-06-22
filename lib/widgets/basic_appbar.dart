import 'package:flutter/material.dart';

class BasicAppbar extends StatelessWidget implements PreferredSizeWidget{
  final String title ;
  final List<Widget>? action;
  const BasicAppbar({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return AppBar(
    title: Text(title,style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 30,        
        color: Theme.of(context).colorScheme.primary
       ),),
       centerTitle: true,
       actions: action,
    );
  }
  
  @override

  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}