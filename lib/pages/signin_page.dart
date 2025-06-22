import 'package:calling_system/model/user_session.dart';
import 'package:calling_system/pages/admin_page.dart';
import 'package:calling_system/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:calling_system/service_locator.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final usernameController =  TextEditingController();
  final passwordController = TextEditingController();
  late String msg;
  @override
  void initState() {
    
    super.initState();
    msg ='';
  }
  void checkLogin(){
   final username = usernameController.text;
   final password = passwordController.text;
   if(username.isEmpty || password.isEmpty){
    setState(() =>msg  = 'Please fill all the Fields');
    return;
   }
   checkAdmin();
  }
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
    return Scaffold(
      //backgroundColor:  const Color.fromARGB(179, 248, 240, 240),
      body: Center(
        
        child: Container(
          
          height: 350,
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white70,
            border: Border.all(width: 1,color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(5),
          ),
        
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('Login',style: TextStyle(
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
                  label: Text('Username',style: TextStyle(fontWeight: FontWeight.w500),)

                ),),
                SizedBox(height: 20,),
                TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                  border: border,
                  enabledBorder: border,
                  focusedBorder: focusBorder,
                  label: Text('Password',style: TextStyle(fontWeight: FontWeight.w500),)
                ),),
                SizedBox(height: 35,),
                ElevatedButton(onPressed: checkLogin,style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),),
                  fixedSize: Size(100, 40),
                  side:BorderSide(color: Colors.white,width: 1),

                ), child: Text('Login')),
                SizedBox(height: 10,),
                Text(msg,style: TextStyle(fontWeight: FontWeight.w500,color: Colors.red),)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void>checkEmployee()async{
  final CollectionReference employeeCollection = FirebaseFirestore.instance.collection('User').doc('user_employee').collection('Employee');
  QuerySnapshot querySnapshot = await  employeeCollection
  .where('name',isEqualTo: usernameController.text.toString())
  .where('password',isEqualTo: passwordController.text.toString())
  .get();
   
  if(querySnapshot.docs.isEmpty){
     setState(() =>msg='Invalid Credential');
  }else{
     await sl<UserSession>().setUsername(usernameController.text.toString());
     await sl<UserSession>().setPassword(passwordController.text.toString());
     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> HomePage()));
  }
  }

   Future<void>checkAdmin()async{
  final CollectionReference adminCollection = FirebaseFirestore.instance.collection('User').doc('user_admin').collection('Admin');
  QuerySnapshot querySnapshot = await  adminCollection
  .where('name',isEqualTo: usernameController.text.toString())
  .where('password',isEqualTo: passwordController.text.toString())
  .get();
   
  if(querySnapshot.docs.isEmpty){
     checkEmployee();
  }else{
     await sl<UserSession>().setUsername(usernameController.text.toString());
     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> AdminPage()));
  }
  }
}