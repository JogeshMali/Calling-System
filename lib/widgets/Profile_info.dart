import 'package:calling_system/model/user_session.dart';
import 'package:calling_system/service_locator.dart';
import 'package:calling_system/widgets/basic_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileInfo extends StatefulWidget {
  final String User;
  const ProfileInfo({super.key, required this.User});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
    String Username ='';
    String msg = '';
    final TextEditingController oldpassController = TextEditingController();
    final TextEditingController newpassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setUsername();
  }
  Future<void> setUsername()async{
    String ?uname =await  sl<UserSession>().getUsername();
    
    setState(() {
      Username =uname ;
    });
    
  }
  @override
  Widget build(BuildContext context) {
     final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(width: 1,style: BorderStyle.solid)
    );
    final focusBorder =  OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(width: 1,color:Theme.of(context).colorScheme.primary,style:  BorderStyle.solid));
    return Scaffold(
      appBar: BasicAppbar(title: '',),
      body:  Center(
        child: Container(
          height: 350,
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white70,
            border: Border.all(width: 1,color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(5),
          ),
          child:Padding(
            padding: const EdgeInsets.all(16),
            child: Column(

                    mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                    Text('Change Password',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary),),
                    SizedBox(height: 25,),
                     TextField(
                      controller: oldpassController,
                      decoration: InputDecoration(
                      border: border,
                      enabledBorder: border,
                      focusedBorder: focusBorder,
                      hintText: 'Old Password'
                     ),),
                     SizedBox(height: 15,),
                     TextField( 
                      controller: newpassController,
                      decoration: InputDecoration(
                      border: border,
                      enabledBorder: border,
                      focusedBorder: focusBorder,
                      hintText: 'New Password')),
                     SizedBox(height: 25,),
                     ElevatedButton(onPressed: changePassword,style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),),
                  fixedSize: Size(100, 40),
                  side:BorderSide(color: Colors.white,width: 1),

                ), child: Text('Change')),
                SizedBox(height: 10,),
                Text(msg,style: TextStyle(fontWeight: FontWeight.w500,color: Colors.red),)
                   ],
                  ),
          ),
        ),
      ),
    );
  }
  void changePassword()async{
    print(Username);
    String docID,subCollectionName;
    if(widget.User == 'Admin'){
      docID = 'user_admin';
      subCollectionName='Admin';
    }else{
      docID = 'user_employee';
      subCollectionName='Employee';
    }
    if(oldpassController.text.toString()  == newpassController.text.toString()){
      oldpassController.clear();
      newpassController.clear();
      return setState(() =>msg='Same password');
    }
    final CollectionReference employeeCollection = FirebaseFirestore.instance.collection('User').doc(docID).collection(subCollectionName);
      QuerySnapshot querySnapshot = await  employeeCollection
      .where('name',isEqualTo: Username)
      .where('password',isEqualTo: oldpassController.text.toString())
      .get();
   
  if(querySnapshot.docs.isEmpty){
     setState(() =>msg='Invalid password');
  }else{
    String docId = querySnapshot.docs.first.id;
    await employeeCollection.doc(docId).update({
      'password': newpassController.text.trim(),
    }).then((_) {
      setState(() => msg = 'Password updated successfully');
    }).catchError((error) {
      setState(() => msg = 'Error updating password');
    });
     
  }
  oldpassController.clear();
  newpassController.clear();
}
}