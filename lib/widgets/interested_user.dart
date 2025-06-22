import 'package:calling_system/firebase/Remark.dart';
import 'package:calling_system/pages/admin_page.dart';
import 'package:calling_system/service_locator.dart';
import 'package:calling_system/widgets/basic_appbar.dart';
import 'package:calling_system/widgets/user_detail.dart';
import 'package:flutter/material.dart';

class InterestedUser extends StatefulWidget {
  const InterestedUser({super.key});

  @override
  State<InterestedUser> createState() => _InterestedUserState();
}

class _InterestedUserState extends State<InterestedUser> {
final TextEditingController _searchBarController = TextEditingController();
  String _searchQuery = '';
  
   List<Map<String,dynamic>> peopleList=[];
   List<Map<String,dynamic>> filteredUserList=[];
@override
  void initState() {
    getPeopleList();
    //_filterUser(_searchQuery); 
    super.initState();
  }
  void getPeopleList()async{
    
    peopleList =await sl<Remark>().getInterestedUser();
    print('peoplelist $peopleList');
    _filterUser(_searchQuery); 
    setState(() {
     
    });
  }

  void _filterUser(String query) {
    setState(() {
      if(query.isEmpty){
        setState(() {
          filteredUserList = peopleList;
        });
      }else{
      filteredUserList = peopleList.where((user) {
        final name = user['username'].toString().toLowerCase();
        final phone = user['phno'].toString();
        return name.contains(query.toLowerCase()) || phone.contains(query);
      }).toList();
      }
      
    });
  }
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
     appBar: BasicAppbar(title: 'Interested User', action: [
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
     
      body:filteredUserList.isNotEmpty? UserDetail(query: _searchQuery,user: filteredUserList,):Center(child: CircularProgressIndicator(),)
    );
  }
}