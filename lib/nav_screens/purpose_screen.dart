import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PurposeScreen extends StatefulWidget {
  const PurposeScreen({super.key});

  @override
  State<PurposeScreen> createState() => _PurposeScreenState();
}

class _PurposeScreenState extends State<PurposeScreen> {
  double currentAmount = 0;
  double targetAmount = 0;
  bool isLoading = true;
  bool hasData = false;
  File? selectedImage;
  bool isExpanded = false;

  // Данные из Firestore
  String? goalName;
  String? goalDescription;
  String? goalImagePath;

  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPurposeData();
  }

  Future<void> _checkPurposeData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('purpose')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          currentAmount = data['currentAmount']?.toDouble() ?? 0;
          targetAmount = data['targetAmount']?.toDouble() ?? 0;
          goalName = data['name'] as String?;
          goalDescription = data['description'] as String?;
          goalImagePath = data['imagePath'] as String?;
          hasData = true;
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _updateAmountInFirestore(double amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('purpose')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final docRef = snapshot.docs.first.reference;
        await docRef.update({
          'currentAmount': amount,
        });
      }
    }
  }

  Future<String?> _uploadImageToStorage(File image) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final storageRef = FirebaseStorage.instance.ref().child(
          'users/${user.uid}/images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = await storageRef.putFile(image);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _addGoal(
      String name, double amount, String? description, File? image) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? imageUrl;
      if (image != null) {
        imageUrl = await _uploadImageToStorage(image);
      }

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('purpose')
          .doc();

      Map<String, dynamic> goalData = {
        'name': name,
        'targetAmount': amount,
        'currentAmount': 0,
        'description': description,
        'imagePath': imageUrl,
      };

      await docRef.set(goalData);
      _checkPurposeData();
    }
  }

  Future<void> _showAddGoalDialog() async {
    String goalName = "";
    double goalAmount = 0;
    String? goalDescription;
    File? pickedImage;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Добавить цель"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Название",
                  ),
                  onChanged: (value) => goalName = value,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Сумма",
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      goalAmount = double.tryParse(value) ?? 0,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Описание (необязательно)",
                  ),
                  onChanged: (value) => goalDescription = value,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        pickedImage = File(pickedFile.path);
                      });
                    }
                  },
                  child: const Text("Выбрать картинку"),
                ),
                if (pickedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.file(
                      pickedImage!,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Отмена"),
            ),
            ElevatedButton(
              onPressed: () {
                if (goalName.isNotEmpty && goalAmount > 0) {
                  _addGoal(goalName, goalAmount, goalDescription, pickedImage);
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Сохранить"),
            ),
          ],
        );
      },
    );
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

    if (!hasData) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: FloatingActionButton(
            onPressed: _showAddGoalDialog,
            child: const Icon(Icons.add),
            backgroundColor: Colors.white,
          ),
        ),
      );
    }

    double progress = currentAmount / targetAmount;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Основное содержимое страницы
          Column(
            children: [
              const SizedBox(height: 180),
              Expanded(
                child: Center(
                  child: CircularPercentIndicator(
                    radius: 120.0,
                    lineWidth: 15.0,
                    percent: progress,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${currentAmount.toStringAsFixed(0)} / ${targetAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                    linearGradient: const LinearGradient(
                      colors: [Colors.pink, Color.fromARGB(255, 93, 196, 255)],
                    ),
                    backgroundColor: Colors.grey[300]!,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                ),
              ),
            ],
          ),
          // Анимируемый контейнер
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            top: 10,
            left: isExpanded ? 0 : 20,
            height: isExpanded
                ? MediaQuery.of(context).size.height * 0.3
                : MediaQuery.of(context).size.height * 0.1,
            width: isExpanded
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.width * 0.4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 96, 173, 236),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: isExpanded
                    ? SingleChildScrollView(
                        scrollDirection:
                            Axis.vertical, // Прокрутка по вертикали
                        child: SingleChildScrollView(
                          scrollDirection:
                              Axis.horizontal, // Прокрутка по горизонтали
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        goalName ?? 'Цель',
                                        softWrap: true,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8.0, 20, 8, 20),
                                        child: Text(
                                          goalDescription ?? '',
                                          softWrap: true,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              double amountToDecrease =
                                                  double.tryParse(
                                                          amountController
                                                              .text) ??
                                                      0;
                                              double newAmount =
                                                  (currentAmount -
                                                          amountToDecrease)
                                                      .clamp(0, targetAmount);
                                              setState(() {
                                                currentAmount = newAmount;
                                              });
                                              _updateAmountInFirestore(
                                                  newAmount); // Обновляем данные в Firestore
                                            },
                                            icon: const Icon(Icons.remove,
                                                color: Colors.white),
                                          ),
                                          SizedBox(
                                            width:
                                                100, // Устанавливаем фиксированную ширину для поля ввода
                                            child: TextField(
                                              controller: amountController,
                                              decoration: InputDecoration(
                                                labelText: "Сумма",
                                                labelStyle: TextStyle(
                                                    color: Colors.black),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black,
                                                      width: 3),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black,
                                                      width: 3),
                                                ),
                                              ),
                                              style: TextStyle(
                                                  color: Colors.white),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              double amountToIncrease =
                                                  double.tryParse(
                                                          amountController
                                                              .text) ??
                                                      0;
                                              double newAmount =
                                                  (currentAmount +
                                                          amountToIncrease)
                                                      .clamp(0, targetAmount);
                                              setState(() {
                                                currentAmount = newAmount;
                                              });
                                              _updateAmountInFirestore(
                                                  newAmount); // Обновляем данные в Firestore
                                            },
                                            icon: const Icon(Icons.add,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (goalImagePath != null)
                                    SizedBox(
                                      width:
                                          200, // Устанавливаем фиксированную ширину для изображения
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Image.network(
                                          goalImagePath!,
                                          height: 200,
                                          width: 200,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : Center(
                        // Используем Center для текста
                        child: Text(
                          goalName ?? 'Цель',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
