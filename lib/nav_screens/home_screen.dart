import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isActive = false;

  void isActiveCheck() {
    setState(() {
      isActive = !isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Привет, Рамиль',
          style: TextStyle(color: Colors.white),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/nix.png'),
            radius: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 600,
              height: 800,
              child: Stack(
                alignment: AlignmentDirectional.topStart,
                children: [
                  // Wrapping the object to the left of the container in a AnimatedPositioned widget.
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    left: isActive ? 10 : 0, // Object moves down or back up
                    top: isActive
                        ? 400
                        : 0, // Moves down when the container opens
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: Image.asset(
                        'assets/nix.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  // The container that will open/close and animate its size
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    left: isActive ? 10 : 200,
                    right: 10,
                    top: 10,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 350 : 200,
                      height: isActive ? 350 : 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color.fromARGB(255, 53, 250, 174),
                            Color.fromARGB(255, 53, 18, 77),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  isActiveCheck();
                                },
                                icon: Icon(Icons.refresh),
                              ),
                              IconButton(
                                onPressed: () {
                                  isActiveCheck();
                                },
                                icon: Icon(Icons.zoom_out_map_rounded),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16.0, 0, 16, 16),
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: false,
                                    drawHorizontalLine: true,
                                    horizontalInterval: 1.0,
                                    drawVerticalLine: true,
                                    verticalInterval: 1.0,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey,
                                        strokeWidth: 0.5,
                                      );
                                    },
                                    getDrawingVerticalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey,
                                        strokeWidth: 0.5,
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: isActive ? true : false,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                        reservedSize: 40,
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: isActive ? true : false,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                        reservedSize: 40,
                                      ),
                                    ),
                                    topTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(
                                    show: false,
                                    border: const Border(
                                      top: BorderSide.none,
                                      right: BorderSide.none,
                                      bottom: BorderSide(
                                          color: Colors.black, width: 3),
                                      left: BorderSide.none,
                                    ),
                                  ),
                                  minX: 0,
                                  maxX: 6,
                                  minY: 0,
                                  maxY: 6,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: const [
                                        FlSpot(0, 3),
                                        FlSpot(1, 1),
                                        FlSpot(2, 4),
                                        FlSpot(3, 1.5),
                                        FlSpot(4, 5),
                                        FlSpot(5, 2.5),
                                        FlSpot(6, 4),
                                      ],
                                      isCurved: true,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 62, 19, 252),
                                          Color.fromARGB(255, 15, 20, 41),
                                        ],
                                      ),
                                      barWidth: 4,
                                      isStrokeCapRound: true,
                                      belowBarData: BarAreaData(
                                        show: false,
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.withOpacity(0.3),
                                            Colors.lightBlueAccent
                                                .withOpacity(0.1),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      dotData: FlDotData(show: false),
                                    ),
                                    LineChartBarData(
                                      spots: const [
                                        FlSpot(0, 2),
                                        FlSpot(1, 1),
                                        FlSpot(2, 2),
                                        FlSpot(3, 1),
                                        FlSpot(4, 3),
                                        FlSpot(5, 2),
                                        FlSpot(6, 4.5),
                                      ],
                                      isCurved: true,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 41, 255, 148),
                                          Color.fromARGB(255, 8, 88, 12),
                                        ],
                                      ),
                                      barWidth: 4,
                                      isStrokeCapRound: true,
                                      belowBarData: BarAreaData(
                                        show: false,
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.withOpacity(0.3),
                                            Colors.lightBlueAccent
                                                .withOpacity(0.1),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      dotData: FlDotData(show: false),
                                    ),
                                    LineChartBarData(
                                      spots: const [
                                        FlSpot(0, 1),
                                        FlSpot(1, 3),
                                        FlSpot(2, 2),
                                        FlSpot(3, 2.5),
                                        FlSpot(4, 4),
                                        FlSpot(5, 5),
                                        FlSpot(6, 3),
                                      ],
                                      isCurved: true,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 234, 34, 252),
                                          Color.fromARGB(255, 114, 39, 253),
                                        ],
                                      ),
                                      barWidth: 4,
                                      isStrokeCapRound: true,
                                      belowBarData: BarAreaData(
                                        show: false,
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.withOpacity(0.3),
                                            Colors.lightBlueAccent
                                                .withOpacity(0.1),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      dotData: FlDotData(show: false),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
