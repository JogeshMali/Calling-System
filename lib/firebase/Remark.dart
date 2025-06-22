import 'package:calling_system/firebase/create_user.dart';
import 'package:calling_system/service_locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Remark {
  Future<void> saveFeedback(
      String docId,
      Map<String, dynamic> user,
      bool isInterestedUser,
      String remark1,
      String remark2,
      String remark3,
      bool isSave,
      String status) async {
    final CollectionReference remarkCollection =
        FirebaseFirestore.instance.collection('Remark');

    await remarkCollection.doc(docId).set({
      'username': isInterestedUser ? user['username'] : user['name'].toString(),
      'phno': user['phno'],
      'schoolName': user['schoolName'].toString(),
      'remark 1': remark1,
      // 'remark 2':remark2,
      // 'remark 3':remark3,
      'isSave': isSave,
      'status': status
    });
  }

  Future<List<Map<String, dynamic>>> getFeedback() async {
    List<Map<String, dynamic>> remarkList = [];
    var remarkData =
        await FirebaseFirestore.instance.collection('Remark').get();
    for (var data in remarkData.docs) {
      remarkList.add({
        'username': data.data().containsKey('username') ? data['username'] : '',
        'remark1': data.data().containsKey('remark 1') ? data['remark 1'] : '',
        'remark2': data.data().containsKey('remark 2') ? data['remark 2'] : '',
        'remark3': data.data().containsKey('remark 3') ? data['remark 3'] : '',
        'isSave': data.data().containsKey('isSave') ? data['isSave'] : false,
        'status':
            data.data().containsKey('status') ? data['status'] : 'Pending',
      });
    }
    return remarkList;
  }

  Future<List<Map<String, dynamic>>> getInterestedUser() async {
    final CollectionReference userCollection =
        FirebaseFirestore.instance.collection('Remark');

    try {
      QuerySnapshot querySnapshot =
          await userCollection.where('status', isEqualTo: 'Interested').get();

      return querySnapshot.docs
          .map((doc) {
           Map<String, dynamic> data = doc.data() as Map<String, dynamic>; 
           data['std_id'] = doc.id;
           return data;
           })
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getInterestedSchoolUser(String schoolName) async {
    final CollectionReference userCollection =
        FirebaseFirestore.instance.collection('Remark');

    try {
      if (schoolName == 'All') {
        return await getInterestedUser();
      } else {
      QuerySnapshot querySnapshot =
          await userCollection
          .where('status', isEqualTo: 'Interested',)
          .get();

      return querySnapshot.docs
          .map((doc) {
           Map<String, dynamic> data = doc.data() as Map<String, dynamic>; 
           data['std_id'] = doc.id;
           return data;
           }).where((data){
             return data['schoolName'].toString().toLowerCase() == schoolName.toLowerCase();
           })
          .toList();
      }
    } catch (e) {
      return [];
    }
    
  }






  Future<List<Map<String,dynamic>>> getEmployeeAssignedUserWithRemark()async{
    List<Map<String,dynamic>> assignUsers = await sl<CreateUser>().getEmployeeAssignedUser();
    print('assignlist $assignUsers');
    List<Map<String,dynamic>> userList = [];
    final CollectionReference remarkCollection = FirebaseFirestore.instance.collection('Remark');

    try {
      for (var i = 0; i < assignUsers.length; i++) {
        //  final empId =  assignUsers[i]['emp_id'];
        //  final name =  assignUsers[i]['name'];
         final stdId = assignUsers[i]['std_id'];
        //  QuerySnapshot querySnapshot = await  remarkCollection
        //                                 .where('emp_id',isEqualTo: empId)
        //                                 .where('username',isEqualTo: name)
        //                                 .limit(1)
        //                                 .get();

        DocumentSnapshot documentSnapshot = await remarkCollection.doc(stdId).get();
        if(documentSnapshot.exists){
          Map<String,dynamic> remarkList = documentSnapshot.data() as Map<String,dynamic>;
          remarkList['std_id']=stdId;
          userList.add(remarkList);
        }else{
           Map<String, dynamic> defaultRemark = {
          'status': 'Pending',  // Default status
          'remark 1': '',       // Default remark
          'isSave': false,      // Default save status
          'std_id': stdId,      // Add the std_id to the remark
          'username': assignUsers[i]['name'], // Add username for reference
          'phno': assignUsers[i]['phno'],     // Add phone number
          'schoolName': assignUsers[i]['schoolName'], // Add school name
        };
        userList.add(defaultRemark);
        }
      }
      return userList;
    } catch (e) {
      return [];
    }
    
  }
}
