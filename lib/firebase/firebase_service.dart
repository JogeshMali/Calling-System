import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static Future<void> initialize() async {
    
   


   await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBN83TnXJ8W9gHrV0zvDj0I9lkVo-6-8qc",  
        authDomain: "calling-system-ca920.firebaseapp.com",
        projectId: "calling-system-ca920",
        storageBucket: "calling-system-ca920.firebasestorage.app",
        messagingSenderId: "1051162113789",
        appId: "1:1051162113789:web:22ab5773c1b23255947094",
      ),
    );
  }
}
