import 'package:calling_system/firebase/Remark.dart';
import 'package:calling_system/firebase/create_user.dart';
import 'package:calling_system/model/user_session.dart';
import 'package:get_it/get_it.dart';

final sl =GetIt.instance;

Future<void> initializeDependency() async{
 sl.registerSingleton<CreateUser>(CreateUser());
 sl.registerSingleton<Remark>(Remark());
 sl.registerSingleton<UserSession>(UserSession());
}