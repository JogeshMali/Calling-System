import 'package:calling_system/model/employee.dart';
import 'package:calling_system/model/user.dart';
import 'package:calling_system/model/user_session.dart';
import 'package:calling_system/service_locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

class CreateUser {
  Future<Either> addStudent(Student student) async {
    final CollectionReference studentCollection = FirebaseFirestore.instance
        .collection('User')
        .doc('user_students')
        .collection('Students')
        .doc('School')
        .collection(student.schoolName.toLowerCase());

    try {
      DocumentReference docRef = studentCollection.doc();
      String stdId = docRef.id;

      await docRef.set({
        'std_id': stdId,
        'name': student.name,
        'phno': student.phno,
        'schoolName': student.schoolName,
      });
      return Right('Student added successfully');
    } catch (e) {
      return left('Error adding student: $e');
    }
  }

  Future<Either> addEmployee(Employee employee) async {
    final CollectionReference employeeCollection = FirebaseFirestore.instance
        .collection('User')
        .doc('user_employee')
        .collection('Employee');

    try {
      DocumentReference empDoc = employeeCollection.doc();
      String empId = empDoc.id;
      await empDoc.set({
        'emp_id': empId,
        'name': employee.name,
        'phno': employee.phno,
        'password': employee.password,
      });
      return Right('Employee added successfully');
    } catch (e) {
      return left('Error adding employee: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getEmpList() async {
    List<Map<String, dynamic>> userList = [];
    final CollectionReference userCollection = FirebaseFirestore.instance
        .collection('User')
        .doc('user_employee')
        .collection('Employee');
    try {
      QuerySnapshot querySnapshot = await userCollection.get();
      userList = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      //  print('Error fetching users: $e');
    }
    return userList;
  }

  Future<List<Map<String, dynamic>>> getStdList() async {
    List<Map<String, dynamic>> userList = [];
    final DocumentReference userCollection = FirebaseFirestore.instance
        .collection('User')
        .doc('user_students')
        .collection('Students')
        .doc('School');
    try {
      final schoolList = await getSchoolNameList();
      List<Future<void>> queries = schoolList.map((school) async {
        final CollectionReference schoolNameCollection =
            userCollection.collection(school.toLowerCase());
        QuerySnapshot querySnapshot = await schoolNameCollection.get();
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> std = doc.data() as Map<String, dynamic>;

          userList.add(std);
        }
      }).toList();
      await Future.wait(queries);
      return userList;
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteUser(bool isUser, Map<String, dynamic> user) async {
    final CollectionReference userCollection;
    try {
      if (isUser) {
        userCollection = FirebaseFirestore.instance
            .collection('User')
            .doc('user_students')
            .collection('Students')
            .doc('School')
            .collection(user['schoolName'].toLowerCase());

        QuerySnapshot<Object?> querySnapshot = await userCollection
            .where('std_id', isEqualTo: user['std_id'].toString())
            .get();
        await querySnapshot.docs.first.reference.delete();
      } else {
        userCollection = FirebaseFirestore.instance
            .collection('User')
            .doc('user_employee')
            .collection('Employee');

        QuerySnapshot<Object?> querySnapshot = await userCollection
            .where('emp_id', isEqualTo: user['emp_id'].toString())
            .get();
        await querySnapshot.docs.first.reference.delete();
      }
    } catch (e) {
      SnackBar(
        content: Text('Unable to delete'),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getUnAssignUser() async {
    List<Map<String, dynamic>> userList = [];
    final DocumentReference userCollection = FirebaseFirestore.instance
        .collection('User')
        .doc('user_students')
        .collection('Students')
        .doc('School');
    try {
      final schoolList = await getSchoolNameList();
      List<Future<void>> queries = schoolList.map((school) async {
        final CollectionReference schoolNameCollection =
            userCollection.collection(school.toLowerCase());
        QuerySnapshot querySnapshot = await schoolNameCollection.get();
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> std = doc.data() as Map<String, dynamic>;
          if (!std.containsKey('emp_id') || std['emp_id'] == null) {
            userList.add(std);
          }
        }
      }).toList();
      await Future.wait(queries);
      return userList;
    } catch (e) {
      return [];
    }
  }

  Future<void> assignUsers(List<Map<String, dynamic>> unAssignList,
      Map<String, dynamic> employee, int numOfStudent) async {
    final CollectionReference userCollection = FirebaseFirestore.instance
        .collection('User')
        .doc('user_students')
        .collection('Students');
    try {
      final int count = numOfStudent.clamp(0, unAssignList.length);

      for (var i = 0; i < count; i++) {
        final student = unAssignList[i];
        final studentId = student['std_id'];
        final schoolName = student['schoolName'].toString().toLowerCase();

        if (studentId != null) {
          await userCollection.doc('School').collection(schoolName).doc(studentId).update({
            'emp_id': employee['emp_id'],
          });
        } else {
          print('Skipping student with missing std_id at index $i');
        }
      }
    } catch (e) {
      //
    }
  }

  Future<List<Map<String, dynamic>>> getEmployeeAssignedUser() async {
    String name = await sl<UserSession>().getUsername();
    String password = await sl<UserSession>().getPassword();
    final CollectionReference employeeCollection = FirebaseFirestore.instance
        .collection('User')
        .doc('user_employee')
        .collection('Employee');
    List<Map<String, dynamic>> stdList = await getStdList();
    List<Map<String, dynamic>> empAssignList = [];
    try {
      QuerySnapshot querySnapshot = await employeeCollection
          .where('name', isEqualTo: name)
          .where('password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String empId = querySnapshot.docs.first.id.toString();
        print('empId: $empId');

        for (var std in stdList) {
          if (std.containsKey('emp_id') && std['emp_id'] == empId) {
            empAssignList.add(std);
          }
        }
        return empAssignList;
      } else {
        print('No matching employee found');
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> setSchoolName(String name) async {
    final CollectionReference schoolNameCollection =
        FirebaseFirestore.instance.collection('Schools');

    try {
      List<String> schoolNameList = await getSchoolNameList();
      final lowerCaseList = schoolNameList.map((e) => e.toLowerCase()).toList();
      final newName = name.toLowerCase();

      if (!lowerCaseList.contains(newName)) {
        await schoolNameCollection.add({'name': name});
      }
    } catch (e) {
      print('setSchoolName :: ,$e');
    }
  }

  Future<List<String>> getSchoolNameList() async {
    final CollectionReference schoolNameCollection =
        FirebaseFirestore.instance.collection('Schools');

    try {
      QuerySnapshot querySnapshot = await schoolNameCollection.get();
      return querySnapshot.docs.map((doc) {
        final school = doc.data() as Map<String, dynamic>;
        return school['name'].toString();
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSchoolFilterStd(
      String schoolName) async {
    List<Map<String, dynamic>> stdList = await getUnAssignUser();
    List<Map<String, dynamic>> filterStdList = [];
    try {
      if (schoolName == 'All') {
        return stdList;
      } else {
        String name = schoolName.toLowerCase();
        for (var std in stdList) {
          if (std['schoolName'].toString().toLowerCase() == name) {
            filterStdList.add(std);
          }
        }
        return filterStdList;
      }
    } catch (e) {
      return [];
    }
  }

   Future<List<Map<String, dynamic>>> getSchoolFilterAllStd(
      String schoolName) async {
    List<Map<String, dynamic>> stdList = await getStdList();
    List<Map<String, dynamic>> filterStdList = [];
    try {
      if (schoolName == 'All') {
        return stdList;
      } else {
        String name = schoolName.toLowerCase();
        for (var std in stdList) {
          if (std['schoolName'].toString().toLowerCase() == name) {
            filterStdList.add(std);
          }
        }
        return filterStdList;
      }
    } catch (e) {
      return [];
    }
  }
}
