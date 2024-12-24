import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class PurposeScreen extends StatefulWidget {
  const PurposeScreen({super.key});

  @override
  State<PurposeScreen> createState() => _PurposeScreenState();
}

class _PurposeScreenState extends State<PurposeScreen> {
  double currentAmount = 20000; // Текущая сумма
  double targetAmount = 40000; // Целевая сумма

  void _addAmount(double amount) {
    setState(() {
      currentAmount = (currentAmount + amount).clamp(0, targetAmount);
    });
  }

  void _subtractAmount(double amount) {
    setState(() {
      currentAmount = (currentAmount - amount).clamp(0, targetAmount);
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = currentAmount / targetAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Цели'),
      ),
      body: Column(
        children: [
          // Закругленный контейнер с подробностями цели
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Моя цель',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Сумма для достижения: $targetAmount ₽',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Текущая сумма: $currentAmount ₽',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () => _addAmount(1000),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Icon(Icons.add),
                    ),
                    ElevatedButton(
                      onPressed: () => _subtractAmount(1000),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Icon(Icons.remove),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Нижняя половина экрана с круговой диаграммой
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
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${currentAmount.toStringAsFixed(0)} / ${targetAmount.toStringAsFixed(0)} ₽',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                progressColor: Colors.green,
                backgroundColor: Colors.grey[300]!,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
