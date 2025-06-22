import 'package:calling_system/firebase/Remark.dart';
import 'package:calling_system/firebase/create_user.dart';
import 'package:calling_system/service_locator.dart';
import 'package:flutter/material.dart';

class UserDetail extends StatefulWidget {
  final String query;
  final List<Map<String,dynamic>>? user ;
  const UserDetail({super.key, required this.query,  this.user});

  @override
  State<UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
  List<Map<String, dynamic>> userList = [];
  List<Map<String, dynamic>> filteredUserList = [];
  List<Map<String, dynamic>> remarkList = [];
  final List<bool> _buttonDisable = [];
  final List<List<TextEditingController>> _remarkControllers = [];
  bool isloading = true;
    String? _schoolSelected;
  List<String> schoolNameList = [];

  List<Map<String, dynamic>>  users = [];
  final List<String> _currentStatus = [];
  bool isInterestedUser =false;
  List status =  [ 'Pending','Interested', 'Not Interested','Other'  ];
  @override
  void initState() {
    super.initState();
    setList();
    getSchoolList();
  }

  void setList() async {
    try {

      if(widget.user ==null){
       users =
          await sl<CreateUser>().getStdList();
          print(users);
      }else{
       users =  List<Map<String, dynamic>>.from(widget.user!);
       setState(() => isInterestedUser=true);
      }
      final remarks = await sl<Remark>().getFeedback();
      Map<String, Map<String, dynamic>> remarkMap = {
        for (var remark in remarks) remark['username']: remark
      };
      setState(() {
        userList = users;
        _filterUser(widget.query);
        remarkList = remarks;
        isloading = false;
        _remarkControllers.clear();
        _buttonDisable.clear();
        _currentStatus.clear();
        for (var user in users) {
          String userName =  isInterestedUser?user['username']: user['name'];
          Map<String, dynamic>? remark = remarkMap[userName];
          _currentStatus.add(remark?['status']?.toString()??'Pending');
          bool isSave = remark?['isSave'] ?? false;
          _buttonDisable.add(isSave);
          _remarkControllers.add([
            TextEditingController(text: remark?['remark1']?.toString() ?? ''),
            TextEditingController(text: remark?['remark2']?.toString() ?? ''),
            TextEditingController(text: remark?['remark3']?.toString() ?? ''),
          ]);
        }
      });
    } catch (e) {
      // Handle error
    }
  }
  Future<void> getSchoolList() async {
    schoolNameList = await sl<CreateUser>().getSchoolNameList();
    schoolNameList.add('All');
    print(schoolNameList);
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant UserDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _filterUser(widget.query);
    }
  }

  void _filterUser(String query) {
    setState(() {
      if (query.isEmpty) {
        setState(() {
          filteredUserList = userList;
        });
      } else {
        filteredUserList = userList.where((user) {
          final name = isInterestedUser?user['username'].toString().toLowerCase(): user['name'].toString().toLowerCase();
          final phone =  user['phno'].toString();
          return name.contains(query.toLowerCase()) || phone.contains(query);
        }).toList();
      }
    });
  }

  void isButtonDisable(int index) {
    setState(() {
      _buttonDisable[index] = !_buttonDisable[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(width: 1, style: BorderStyle.solid),
    );

    return isloading
        ? const Center(child: CircularProgressIndicator())
            : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: SizedBox(
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
                                  filteredUserList = isInterestedUser? await sl<Remark>().getInterestedSchoolUser(_schoolSelected!):await sl<CreateUser>()
                                      .getSchoolFilterAllStd(_schoolSelected!);
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
                  ),
         filteredUserList.isEmpty
            ? Expanded(child: const Center(child: Text('No User Found'))):
                  SizedBox(height: 20,),
                  Expanded(
                    child: ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        itemCount: filteredUserList.length,
                        itemBuilder: (context, index) {
                          final user = filteredUserList[index];
                    
                          return Card(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.white24, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.15,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isInterestedUser?user['username'].toString(): user['name'].toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            user['phno'].toString(),
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                    
                                    // Dropdown
                                    SizedBox(
                                     width: MediaQuery.of(context).size.width * 0.25,
                                      child: DropdownButtonFormField(
                                        value: _currentStatus[index],
                                        items:status
                                            .map((label) => DropdownMenuItem(
                                                value: label, child: Text(label)))
                                            .toList(),
                                        onChanged:
                                            !_buttonDisable[index] ? (val) {
                                              setState(() {
                                                _currentStatus[index]=val.toString();
                                              });
                                            } : null,
                                        decoration: InputDecoration(
                                          labelText: 'Status',
                                          border: border,
                                          enabledBorder: border,
                                          isDense: true,
                                        ),
                                        selectedItemBuilder: (context) {
                                          return status.map((label){
                                              Color textColor ; 
                                                if (label == 'Pending') {
                                                textColor = Colors.red;
                                              } else if (label == 'Interested') {
                                                textColor = Theme.of(context).colorScheme.primary;
                                              } else {
                                                textColor = Colors.black;
                                              }
                                              return Text(label,style:TextStyle(color: textColor),);
                                          }).toList();
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                    
                                    // Remark
                                    SizedBox(
                                       width: MediaQuery.of(context).size.width * 0.30,
                                      child: TextField(
                                        controller: _remarkControllers[index][0],
                                        maxLines: null,
                                        minLines: 1,
                                        enabled: !_buttonDisable[index],
                                        decoration: InputDecoration(
                                          labelText: 'Remark',
                                          isDense: true,
                                          border: border,
                                          enabledBorder: border,
                                        ),
                                      ),
                                    ),
                                     SizedBox(
                                      width: MediaQuery.of(context).size.width*0.10,
                                    
                                     ),
                    
                                    // Save Button
                                    ElevatedButton(
                                      onPressed: () {
                                        isButtonDisable(index);
                                        if (_buttonDisable[index]) {
                                          sl<Remark>().saveFeedback(
                                            user['std_id'],
                                            user,
                                            isInterestedUser,
                                            _remarkControllers[index][0].text,
                                            '',
                                            '',
                                            true,
                                            _currentStatus[index]
                                          );
                                        } else {
                                          sl<Remark>().saveFeedback(
                                            user['std_id'],
                                            user,
                                            isInterestedUser,
                                            '',
                                            '',
                                            '', 
                                            false,
                                            _currentStatus[index]
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: Size(150, 20),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        side: const BorderSide(
                                            color: Colors.white, width: 1),
                                      ),
                                      child: Text(
                                          _buttonDisable[index] ? 'Unsaved' : 'Save'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ),
                ],
              ),
            );
  }
}
