import 'package:calling_system/firebase/create_user.dart';
import 'package:calling_system/pages/admin_page.dart';
import 'package:calling_system/service_locator.dart';
import 'package:calling_system/widgets/basic_appbar.dart';
import 'package:flutter/material.dart';

class AssignUser extends StatefulWidget {
  const AssignUser({super.key});

  @override
  State<AssignUser> createState() => _AssignUserState();
}

class _AssignUserState extends State<AssignUser> {
  final TextEditingController _searchBarController = TextEditingController();
  String _searchQuery = '';
  String msg = '';
  Map<String, dynamic>? _employeeSelected;
  String? _schoolSelected;

  final numOfStudentsToAssignController = TextEditingController();
  List<Map<String, dynamic>> peopleList = [];
  List<Map<String, dynamic>> employeeList = [];
  List<String> schoolNameList = [];
  List<Map<String, dynamic>> filteredUserList = [];
  @override
  void initState() {
    getPeopleList();
    getEmployeeList();
    getSchoolList();
    super.initState();
  }

  Future<void> getPeopleList() async {
    peopleList = await sl<CreateUser>().getUnAssignUser();
    _filterUser(_searchQuery);
    setState(() {});
  }

  Future<void> getEmployeeList() async {
    employeeList =
        await sl<CreateUser>().getEmpList();
    setState(() {});
  }

  Future<void> getSchoolList() async {
    schoolNameList = await sl<CreateUser>().getSchoolNameList();
    schoolNameList.add('All');
    print(schoolNameList);
    setState(() {});
  }

  void _filterUser(String query) {
    setState(() {
      if (query.isEmpty) {
        setState(() {
          filteredUserList = peopleList;
        });
      } else {
        filteredUserList = peopleList.where((user) {
          final name = user['name'].toString().toLowerCase();
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
      _filterUser(_searchQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(width: 1, style: BorderStyle.solid),
    );

    return Scaffold(
      //backgroundColor: Color(0xffDAE0E2),
      appBar: BasicAppbar(
        title: 'Assign User',
        action: [
          SizedBox(
              width: 400,
              height: 40,
              child: SearchBar(
                controller: _searchBarController,
                hintText: 'search user',
                onChanged: _updateSearchQuery,
                trailing: [
                  IconButton(
                      onPressed: () => _stopSearch(),
                      iconSize: 20,
                      icon: Icon(Icons.close))
                ],
              ))
        ],
      ),
      drawer: MyNavigationDrawer(),

      body: filteredUserList.isEmpty
          ? const Center(child: Text('No User Found'))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Prevents Row from taking full width
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.22,
                          child: DropdownButtonFormField(
                            items: schoolNameList.map((label) {
                              return DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              );
                            }).toList(),
                            onChanged: (value) async {
                              _schoolSelected = value;
                              filteredUserList = await sl<CreateUser>()
                                  .getSchoolFilterStd(_schoolSelected!);
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              labelText: 'School Name',
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.w500),
                              border: border,
                              enabledBorder: border,
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                            onPressed: () async {
                              if (employeeList.isEmpty) {
                                await getEmployeeList();
                                setState(() {});
                              }
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Assign Users',
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.22,
                                          child: DropdownButtonFormField(
                                            //value: (_employeeSelected!='')?_employeeSelected: employeeList[0]['name'].toString(),
                                            items: employeeList
                                                .map((emp) => DropdownMenuItem(
                                                    value: emp,
                                                    child: Text(emp['name']
                                                        .toString())))
                                                .toList(),
                                            onChanged: (val) => setState(
                                                () => _employeeSelected = val!),
                                            decoration: InputDecoration(
                                              labelText: 'Employee',
                                              labelStyle: TextStyle(
                                                  fontWeight: FontWeight.w500),
                                              border: border,
                                              enabledBorder: border,
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.22,
                                          child: DropdownButtonFormField(
                                            items: schoolNameList.map((label) {
                                              return DropdownMenuItem(
                                                value: label,
                                                child: Text(label),
                                              );
                                            }).toList(),
                                            onChanged: (value) 
                                             async {
                                                _schoolSelected = value;
                                                filteredUserList =
                                                    await sl<CreateUser>()
                                                        .getSchoolFilterStd(
                                                            _schoolSelected!);
                                                setState(() {});
                                             
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'School Name',
                                              labelStyle: TextStyle(
                                                  fontWeight: FontWeight.w500),
                                              border: border,
                                              enabledBorder: border,
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.22,
                                          child: TextField(
                                            keyboardType: TextInputType.number,
                                            controller:
                                                numOfStudentsToAssignController,
                                            decoration: InputDecoration(
                                                border: border,
                                                enabledBorder: border,
                                                focusedBorder: border,
                                                isDense: true,
                                                label: Text(
                                                  'No of Students',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                )),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        ElevatedButton(
                                            onPressed: assign,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.all(10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              fixedSize: Size(100, 40),
                                              side: BorderSide(
                                                  color: Colors.white,
                                                  width: 1),
                                            ),
                                            child: Text('Assign')),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          msg,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              fixedSize: Size(150, 40),
                              side: BorderSide(color: Colors.white, width: 1),
                            ),
                            child: Text('Assign Users ')),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: filteredUserList.length,
                        itemBuilder: (context, index) {
                          final people = filteredUserList[index];
                          return Card(
                            child: ListTile(
                                title: Text(
                                  people['name'].toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20),
                                ),
                                subtitle: Text(
                                    '${people['phno']}\n${people['schoolName'] ?? ''}'),
                                trailing: IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Delete User',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              content: Text(
                                                  'Are you sure? you want to delete'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('No',
                                                        style: TextStyle(
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 231, 3, 3),
                                                        ))),
                                                TextButton(
                                                    onPressed: () async {
                                                    
                                                      await sl<CreateUser>()
                                                          .deleteUser(
                                                             true,
                                                              people,);
                                                      Navigator.pop(context);
                                                      await getPeopleList();
                                                    },
                                                    child: Text('Yes')),
                                              ],
                                            );
                                          });
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ))),
                          );
                        }),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> assign() async {
    if (_employeeSelected == null ||
        numOfStudentsToAssignController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all the fields',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      int numOfStudent = int.parse(numOfStudentsToAssignController.text);
      await sl<CreateUser>()
          .assignUsers(filteredUserList, _employeeSelected!, numOfStudent);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Users assigned successfully',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      numOfStudentsToAssignController.clear();
      await getPeopleList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
