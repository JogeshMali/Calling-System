import 'package:calling_system/pages/admin_page.dart';
import 'package:calling_system/widgets/basic_appbar.dart';
import 'package:calling_system/widgets/user_detail.dart';
import 'package:flutter/material.dart';

class ShowUser extends StatefulWidget {
  const ShowUser({super.key});

  @override
  State<ShowUser> createState() => _ShowUserState();
}

class _ShowUserState extends State<ShowUser> {

  String _searchQuery = '';
  final TextEditingController _searchBarController = TextEditingController();
void _stopSearch() {
    setState(() {
  
      _searchBarController.clear();
      _searchQuery = '';
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(title: 'User ',
       action: [
          SizedBox(
            width: 400,
            height:40 ,
            child: SearchBar(
              controller: _searchBarController,
              hintText: 'search user',
              onChanged: _updateSearchQuery,
              trailing: [
               
                 IconButton(onPressed: ()=>_stopSearch(), iconSize:20,icon:  Icon(Icons.close))
                
              ],
            

                
            )
            )
        ],),
      drawer: MyNavigationDrawer(),
      body: UserDetail(query: _searchQuery),
    );
  }
}