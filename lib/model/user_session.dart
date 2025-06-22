import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
 
 Future<SharedPreferences> getPrefsInstance ()async{
  return await SharedPreferences.getInstance();
 }

 Future<void> setUsername(String username)async{
   final prefs = await getPrefsInstance();
   await prefs.setString('Username', username);
 }
 Future<void> setPassword(String password)async{
   final prefs = await getPrefsInstance();
   await prefs.setString('Password', password);
 }

 Future<String> getUsername()async{
   final prefs = await getPrefsInstance();
    String ? uname=prefs.getString('Username');
    return uname!;
 }

 Future<String> getPassword()async{
   final prefs = await getPrefsInstance();
    String ? pass=prefs.getString('Password');
    return pass!;
 }
}
