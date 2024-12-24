import 'package:cashflow/back/auth_service/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  Future<UserModel?> signUp(
      String username, String email, String password) async {
    try {
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        UserCredential userCredential = await _firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password);
        User user = userCredential.user!;
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
        });
        return UserModel.fromFirebase(user);
      } else if (userSnapshot.docs.isNotEmpty) {
        UserCredential userCredential = await _firebaseAuth
            .signInWithEmailAndPassword(email: email, password: password);
        User user = userCredential.user!;
        print('asdasdasd');
        return UserModel.fromFirebase(user);
      }
    } catch (e) {
      print("Ошибка регистрации: $e");
      return null;
    }
  }

  // Вход с использованием имени пользователя и пароля
  // Future<UserModel?> signIn(String username, String password) async {
  //   try {
  //     // Поиск email по имени пользователя
  //     QuerySnapshot userSnapshot = await _firestore
  //         .collection('users')
  //         .where('username', isEqualTo: username)
  //         .limit(1)
  //         .get();

  //     if (userSnapshot.docs.isEmpty) {
  //       throw Exception("Пользователь с таким именем не найден");
  //     }

  //     // Получаем email пользователя
  //     String email = userSnapshot.docs[0]['email'];

  //     // Выполняем вход с использованием email и пароля
  //     UserCredential userCredential = await _firebaseAuth
  //         .signInWithEmailAndPassword(email: email, password: password);
  //     User user = userCredential.user!;

  //     return UserModel.fromFirebase(user);
  //   } catch (e) {
  //     print("Ошибка входа: $e");
  //     return null;
  //   }
  // }

  // Выход из аккаунта
  Future logOut() async {
    try {
      await _firebaseAuth.signOut();
      print('вышел');
    } catch (e) {
      return null;
    }
  }

  Future<DocumentSnapshot?> fetchUser() async {
    if (userId != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userDoc;
    }
    return null;
  }

  // Текущий пользователь
  Stream<UserModel?> get currentUser {
    return _firebaseAuth
        .authStateChanges()
        .map((user) => user != null ? UserModel.fromFirebase(user) : null);
  }
}
