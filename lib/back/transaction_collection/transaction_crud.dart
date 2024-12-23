import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Для форматирования даты и времени

class TransactionCrud {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> createTransaction(
      String? username, Map<String, dynamic> transactionData) async {
    try {
      QuerySnapshot currentUserName = await _firebaseFirestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      var filter = currentUserName.docs.first.id;
      await _firebaseFirestore
          .collection('users')
          .doc(filter)
          .collection('transaction')
          .add(transactionData);
    } catch (e) {
      print('Error creating transaction: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTransactions(String? username) async {
    List<Map<String, dynamic>> transactions = [];

    try {
      QuerySnapshot currentUserName = await _firebaseFirestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      var filter = currentUserName.docs.first.id;

      QuerySnapshot transactionSnapshot = await _firebaseFirestore
          .collection('users')
          .doc(filter)
          .collection('transaction')
          .orderBy('timestamp', descending: true)
          .get();

      for (var doc in transactionSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        transactions.add({
          'title': data['category'], // Категория как заголовок
          'date': DateFormat('dd.MM.yyyy').format(
            (data['timestamp'] as Timestamp).toDate(),
          ),
          'amount': data['amount'].toString(),
          'type': data['type'], // Тип транзакции: доход/расход
        });
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    }

    print(transactions);
    return transactions;
  }

  Future<Map<String, double>> getWeeklyTransactionData(String? username) async {
    if (username == null) return {};
    QuerySnapshot currentUserName = await _firebaseFirestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    var filter = currentUserName.docs.first.id;

    final transactionSnapshot = await _firebaseFirestore
        .collection('users')
        .doc(filter)
        .collection('transaction')
        .get();

    Map<String, double> weeklyData = {
      'Monday': 0.0,
      'Tuesday': 0.0,
      'Wednesday': 0.0,
      'Thursday': 0.0,
      'Friday': 0.0,
      'Saturday': 0.0,
      'Sunday': 0.0,
    };

    for (var doc in transactionSnapshot.docs) {
      final data = doc.data();
      DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
      String dayOfWeek = _getDayOfWeek(timestamp);

      if (data['type'] == 'expense') {
        weeklyData[dayOfWeek] = (weeklyData[dayOfWeek] ?? 0.0) + data['amount'];
      }
    }

    return weeklyData;
  }

  String _getDayOfWeek(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }
}
