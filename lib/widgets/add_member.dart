
//import 'package:calling_system/user.dart';
import 'package:calling_system/firebase/create_user.dart';
import 'package:calling_system/model/employee.dart';
import 'package:calling_system/model/user.dart';
import 'package:calling_system/service_locator.dart';
import 'package:calling_system/widgets/basic_appbar.dart';
//import 'package:firebase/firestore.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMember extends StatefulWidget {
  final String usertype;
   final Function(Map<String, dynamic>)  onUserAdded ;
  const AddMember({super.key, required this.usertype, required this.onUserAdded});

  @override
  State<AddMember> createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  late bool isvalid;
  final usernameController = TextEditingController();
  final  phnoController = TextEditingController();
  final schoolNameController =TextEditingController();
   String msg ='';
  @override
  Widget build(BuildContext context) {
     final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(width: 1,style: BorderStyle.solid)
    );
    final focusBorder =  OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(width: 1,color:Theme.of(context).colorScheme.primary,style:  BorderStyle.solid),
      
                  );
    return  Scaffold(
      appBar: BasicAppbar(title: ''),
      //backgroundColor:  const Color.fromARGB(179, 248, 240, 240),
      body: Center(
        
        child: Container(
          
          height: 400,
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white70,
            border: Border.all(width: 1,color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(5),
          ),
        
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Text('Add Details',style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryFixed
                ),),
                SizedBox(height: 50,),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                  border: border,
                  enabledBorder: border,
                  focusedBorder: focusBorder,
                  label: Text('Name',style: TextStyle(fontWeight: FontWeight.w500),)

                ),),
                SizedBox(height: 20,),
                if(widget.usertype == 'User')
                  TextField(
                    controller: schoolNameController,
                    decoration: InputDecoration(
                    border: border,
                    enabledBorder: border,
                    focusedBorder: focusBorder,
                    label: Text('School Name ',style: TextStyle(fontWeight: FontWeight.w500),)

                  ),),
                  SizedBox(height: 20,),
                TextField(
                 
                  keyboardType: TextInputType.phone,
                  
                  controller: phnoController,
                
                  decoration: InputDecoration(
                  border: border,
                  enabledBorder: border,
                  focusedBorder: focusBorder,
                  label: Text('Phone Number',style: TextStyle(fontWeight: FontWeight.w500),)
                ),),
                SizedBox(height: 20,),
                if(widget.usertype != 'User')
                  SizedBox(height: 20,),
                ElevatedButton(onPressed: ()async {
                   setState(() => msg = '');
                  if(widget.usertype =='User'){   
                    if(usernameController.text.isEmpty || phnoController.text.isEmpty||schoolNameController.text.isEmpty){
                        setState(() => msg='Please enter all the fields');    
                    }else{
                    isvalid =  validatePhno(phnoController.text);
                    } 
                    if(isvalid){
                    var result = await sl<CreateUser>().addStudent(Student(
                      name: usernameController.text.toString(), 
                      schoolName: schoolNameController.text.toString(),
                      phno: int.parse(phnoController.text.toString())));  
                      await sl<CreateUser>().setSchoolName(schoolNameController.text.toString());
                      result.fold((l){
                      setState(() => msg = l);
                      clearMsg();
                      clearField();
                      },(r){
                       Map<String,dynamic> newUser = { 'name': usernameController.text.toString(), 
                      'schoolName': schoolNameController.text.toString(),
                      'phno': int.parse(phnoController.text.toString())};
                        widget.onUserAdded((newUser));
                      setState(() => msg = r);
                      clearMsg();
                      clearField();
                      });   
                    }      
                  }else{
                    if(usernameController.text.isEmpty || phnoController.text.isEmpty){
                        setState(() => msg='Please enter all the fields');    
                    }else{
                    isvalid =  validatePhno(phnoController.text);
                    } 
                    if(isvalid){
                    
                    var result = await sl<CreateUser>().addEmployee(Employee(
                     name:  usernameController.text,
                     password: '${usernameController.text}@1234',
                     phno:  int.parse(phnoController.text)
                    ));
                    result.fold((l){
                     setState(() => msg = l);
                     clearMsg();
                     clearField();
                    },(r){
                    Map<String,dynamic> newUser = {'name':usernameController.text,
                     'password': '${usernameController.text}@1234',
                     'phno':  int.parse(phnoController.text)};
                    widget.onUserAdded((newUser));
                     setState(() => msg = r);
                     clearMsg();
                     clearField();
                    });
                  }
                  }
                },style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),),
                  fixedSize:Size(100,40),
                  side:BorderSide(color: Colors.white,width: 1),

                ), child: Text('Add')),
                SizedBox(height: 10,),
                Text(msg,style: TextStyle(fontWeight: FontWeight.w500,color: Colors.red),)
              ],
            ),
          ),
        ),
      ),
    );
  }


  

 void clearField(){
 usernameController.text ='';
 phnoController.text = '';
 if(widget.usertype =='User'){
 schoolNameController.text ='';
 }

 }
  

void clearMsg(){
  Future.delayed(Duration(seconds: 2),(){
        setState(() =>  msg = '');
        });
}

bool validatePhno(phno){
  if (phno == null || phno.isEmpty) {
    setState(()=> msg="Phone number is required");
  }
  
  RegExp regExp = RegExp(r'^\d{10}$'); 
  if (!regExp.hasMatch(phno)) {
     setState(() => msg="Invalid phone number");
     return false;
    
  }
  return true;
  
  
}
}