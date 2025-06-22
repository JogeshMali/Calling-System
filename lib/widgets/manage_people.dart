import 'dart:io';

import 'package:calling_system/firebase/create_user.dart';
import 'package:calling_system/model/employee.dart';
import 'package:calling_system/model/user.dart';
import 'package:calling_system/pages/admin_page.dart';
import 'package:calling_system/widgets/add_member.dart';
import 'package:calling_system/widgets/basic_appbar.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../service_locator.dart';

class ManagePeople extends StatefulWidget {
  final List<Map<String, dynamic>> peopleList;
  final String title;
  const ManagePeople(
      {super.key, required this.peopleList, required this.title});

  @override
  State<ManagePeople> createState() => _ManagePeopleState();
}

class _ManagePeopleState extends State<ManagePeople> {
  String _searchQuery = '';
  final TextEditingController _searchBarController = TextEditingController();
  String? _schoolSelected;
  List<String> schoolNameList = [];
  List<Map<String, dynamic>> peopleList = [];
  List<Map<String, dynamic>> filteredUserList = [];
  @override
  void initState() {
    peopleList = List.from(widget.peopleList);
    getSchoolList();
    _filterUser(_searchQuery);
    super.initState();
  }

  Future<void> getPeopleList() async {
    if (widget.title == 'User') {
      peopleList = await sl<CreateUser>().getStdList();
    } else {
      peopleList = await sl<CreateUser>().getEmpList();
    }
    print('people ::$peopleList');
    _filterUser(_searchQuery);
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
      _filterUser(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(width: 1));
    return Scaffold(
      appBar: BasicAppbar(
        title: 'Manage ${widget.title}',
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            
              Align(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if( widget.title == 'User')
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
                              .getSchoolFilterAllStd(_schoolSelected!);
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: 'School Name',
                          labelStyle: TextStyle(fontWeight: FontWeight.w500),
                          border: border,
                          enabledBorder: border,
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    "Add Member",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: Text(
                                    'choose any one mode to add member ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () async {
                                          await addMemberFromFile();
                                          await getPeopleList();
                                          Navigator.pop(context);
                                        },
                                        child: Text('Upload File')),
                                    ElevatedButton(
                                        onPressed: () async =>
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddMember(
                                                            usertype:
                                                                widget.title,
                                                            onUserAdded:
                                                                (newUser) {
                                                              setState(() =>
                                                                  peopleList.add(
                                                                      newUser));
                                                            }))),
                                        child: Text('Add manually')),
                                  ],
                                );
                              });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          fixedSize: Size(100, 40),
                          side: BorderSide(color: Colors.white, width: 1),
                        ),
                        child: Text('Add ')),
                  ],
                ),
              ),
            SizedBox(
              height: 20,
            ),
            filteredUserList.isEmpty
                ? Expanded(child: const Center(child: Text('No User Found')))
                : Expanded(
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
                                subtitle: Text(widget.title == 'User'
                                    ? '${people['phno']}\n${people['schoolName'] ?? ''}'
                                    : people['phno'].toString()),
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
                                                      if (widget.title ==
                                                          'User') {
                                                        await sl<CreateUser>()
                                                            .deleteUser(
                                                                true, people);
                                                      } else {
                                                        await sl<CreateUser>()
                                                            .deleteUser(
                                                                false, people);
                                                      }
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

  Future<void> addMemberFromFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'], // Allow xlsx, xls, and csv files
    );

    if (result != null) {
      String filePath = result.files.single.path!;

      try {
        // Step 2: Read the file based on its extension
        if (filePath.endsWith('.xlsx') || filePath.endsWith('.xls')) {
          var bytes = File(filePath).readAsBytesSync();
          var excel = Excel.decodeBytes(bytes);

          var sheet = excel.tables?.values.first;

          if (sheet != null) {
            for (int i = 1; i < sheet.rows.length; i++) {
              var row = sheet.rows[i];

              if (row.isNotEmpty) {
                Map<String, dynamic> data = {};

                if (widget.title != 'User') {
                  // Employee
                  if (row.length >= 2) {
                    String name =
                        _cleanCellData(row[0]?.value?.toString() ?? '');
                    num phno = _parsePhoneNumber(
                        _cleanCellData(row[1]?.value?.toString() ?? ''));
                    data['name'] = name;
                    data['phno'] = phno;
                    data['password'] = '${name}@123';
                  }

                  await sl<CreateUser>().addEmployee(Employee(
                      name: data['name'],
                      password: data['password'],
                      phno: data['phno']));
                } else {
                  if (row.length >= 3) {
                    String name = _cleanCellData(
                        row[0]?.value?.toString() ?? ''); // Student Name
                    num phno = _parsePhoneNumber(_cleanCellData(
                        row[1]?.value?.toString() ??
                            '')); // Student Phone Number
                    String schoolName = _cleanCellData(
                        row[2]?.value?.toString() ?? ''); // School Name

                    data = {
                      'name': name,
                      'phno': phno,
                      'schoolName': schoolName,
                    };

                    await sl<CreateUser>().addStudent(Student(
                        name: data['name'],
                        schoolName: data['schoolName'],
                        phno: data['phno']));
                    await sl<CreateUser>().setSchoolName(data['schoolName']);
                  }
                }
              }
            }
          } else {
            print("No data found in the sheet.");
          }
        } else if (filePath.endsWith('.csv')) {
          print("CSV files are not supported by the 'excel' package.");
        } else {
          print("Unsupported file type selected.");
        }
      } catch (e) {
        print("Error processing file: $e");
      }
    } else {
      print("No file selected.");
    }
  }

  num _parsePhoneNumber(String phoneNumberStr) {
    String cleanPhno = phoneNumberStr.replaceAll(RegExp(r'\D'), '');
    return cleanPhno.isNotEmpty ? num.parse(cleanPhno) : 0;
  }

  String _cleanCellData(String cellData) {
    RegExp regExp = RegExp(r'(?<=\().*(?=\))');
    Match? match = regExp.firstMatch(cellData);

    if (match != null) {
      return match.group(0)?.trim() ?? '';
    } else {
      return cellData.trim();
    }
  }
}
