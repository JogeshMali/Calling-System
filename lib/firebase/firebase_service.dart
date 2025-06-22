import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static Future<void> initialize() async {
    
   


   await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "Your API KEY",  
        authDomain: "Your APP AuthDomain",
        projectId: "Your ProjectID",
        storageBucket: "Your App storageBucket",
        messagingSenderId: "Your App messagingSenderId",
        appId: "Your AppId",
      ),
    );
  }
}
