import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? avatarPath;
  String? name;
  String? email;
  double balance = 0.0;

  final TextEditingController balanceController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        setState(() {
          avatarPath = data['avatarPath'] as String?;
          name = data['name'] as String?;
          email = user.email;
          balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
          balanceController.text = balance.toStringAsFixed(2);
          isLoading = false;
        });
      }
    }
  }

  Future<String?> _uploadAvatarToStorage(File image) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final storageRef =
          FirebaseStorage.instance.ref().child('users/${user.uid}/avatar.jpg');

      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Error uploading avatar: $e");
      return null;
    }
  }

  Future<void> _updateAvatar(File image) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final avatarUrl = await _uploadAvatarToStorage(image);
      if (avatarUrl != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'avatarPath': avatarUrl});
        setState(() {
          avatarPath = avatarUrl;
        });
      }
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final image = File(pickedFile.path);
      await _updateAvatar(image);
    }
  }

  Future<void> _updateBalance(double newBalance) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'balance': newBalance});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickAvatar,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      avatarPath != null ? NetworkImage(avatarPath!) : null,
                  child: avatarPath == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name ?? 'Имя не указано',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email ?? 'Почта не указана',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: balanceController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Баланс',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: () {
                      final newBalance =
                          double.tryParse(balanceController.text) ?? balance;
                      setState(() {
                        balance = newBalance;
                      });
                      _updateBalance(newBalance);
                    },
                    child: Icon(Icons.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
