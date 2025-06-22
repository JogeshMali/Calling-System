import 'package:calling_system/firebase/Remark.dart';
import 'package:calling_system/model/user_session.dart';
import 'package:calling_system/pages/signin_page.dart';
import 'package:calling_system/service_locator.dart';
import 'package:calling_system/widgets/profile_info.dart';
import 'package:calling_system/widgets/user_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = '';
  bool isLoading = false;
  List<Map<String,dynamic>> userList = [];
    List<Map<String,dynamic>> filteredUserList = [];

  String _searchQuery = '';
  final TextEditingController _searchBarController = TextEditingController();
  @override
  void initState() {
    super.initState();
    setUsername();
    getUserList();
 
  }

  Future<void> setUsername() async {
    String? uname = await sl<UserSession>().getUsername();
    setState(() {
      username = uname;
    });
  }

  Future<void> getUserList()async{
   List<Map<String,dynamic>> users = await sl<Remark>().getEmployeeAssignedUserWithRemark();
   setState(() {
     userList=users ;
     isLoading=true;
     });
    
     print(userList);
  }
  
    

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'User Details',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 26,
        
          ),
        ),
        centerTitle: true,
        elevation: 4,
        actions: [
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
        ],
  
      ),
      drawer: _buildDrawer(context),
      body:userList.isNotEmpty? UserDetail(query:_searchQuery,user: userList,):Center(child: CircularProgressIndicator(),),
    );
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
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white70,
              child: Icon(
                CupertinoIcons.person_fill,
                size: 45,
                color: Colors.black87,
              ),
            ),
            accountName: Text(
              username,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            accountEmail: Text(''),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileInfo(User: 'Employee')),
              );
            },
          ),
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SigninPage()),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
