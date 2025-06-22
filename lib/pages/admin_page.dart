import 'package:calling_system/firebase/create_user.dart';
import 'package:calling_system/model/user_session.dart';
import 'package:calling_system/pages/signin_page.dart';
import 'package:calling_system/service_locator.dart';
import 'package:calling_system/widgets/assign_user.dart';
import 'package:calling_system/widgets/interested_user.dart';
import 'package:calling_system/widgets/profile_info.dart';
import 'package:calling_system/widgets/manage_people.dart';
import 'package:calling_system/widgets/show_user.dart';
import 'package:calling_system/widgets/user_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
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
      appBar: AppBar(
        title: const Text(
          'Admin Panel',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
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
        centerTitle: true,
        elevation: 4,
      ),
      drawer: const MyNavigationDrawer(),
      body: UserDetail(query: _searchQuery,),
    );
  }
  
}

class MyNavigationDrawer extends StatefulWidget {
  const MyNavigationDrawer({super.key});

  @override
  State<MyNavigationDrawer> createState() => _MyNavigationDrawerState();
}

class _MyNavigationDrawerState extends State<MyNavigationDrawer> {
  String username = '';

  @override
  void initState() {
    super.initState();
    setUsername();
  }

  Future<void> setUsername() async {
    String? uname = await sl<UserSession>().getUsername();
    setState(() {
      username = uname;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                size: 50,
                color: Colors.black87,
              ),
            ),
            accountName: Text(
              username,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            accountEmail: const Text(""),
          ),
          _buildDrawerItem(
            icon: Icons.people,
            text: 'User Management',
            onTap: () => _navigateTo(context, const ShowUser()),
          ),
          _buildDrawerItem(
            icon: Icons.work,
            text: 'Manage Employees',
            onTap: () async {
              final employeeList = await sl<CreateUser>()
                  .getEmpList();
              _navigateTo(
                context,
                ManagePeople(peopleList: employeeList, title: 'Employee'),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.group,
            text: 'Manage Users',
            onTap: () async {
              final studentList = await sl<CreateUser>()
                  .getStdList();
              _navigateTo(
                context,
                ManagePeople(peopleList: studentList, title: 'User'),
              );
            },
          ),
           _buildDrawerItem(
            icon: Icons.group,
            text: 'Assign Users',
            onTap: ()  {         
              _navigateTo(
                context,
                AssignUser(),
              );
            },
          ),
          
           _buildDrawerItem(
            icon: Icons.group,
            text: 'Interested Users',
            onTap: ()  { 
              _navigateTo(
                context,
                InterestedUser(),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.person,
            text: 'Profile',
            onTap: ()  {
              _navigateTo(
                context,
                ProfileInfo(User: 'Admin',),
              );
            },
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout,
            text: 'Logout',
            color: Colors.redAccent,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    Color color = Colors.black,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
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
