import 'package:cashflow/back/auth_service/user_service.dart';
import 'package:cashflow/back/transaction_collection/transaction_crud.dart';
import 'package:cashflow/nav_screens/purpose_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isActive = false;
  bool isSeccond = true;
  String? userId;
  String? username;
  double? globalMaxY;
  Map<String, double> weeklyData = {};
  Map<String, double> weeklyData2 = {};
  final AuthService _authService = AuthService();
  late Future<Map<int, Map<String, double>>> _monthlyDataFuture;
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final userData = await _authService.fetchUser();
      setState(() {
        username = userData?['username'];
      });

      // Загружаем данные только после получения username
      _loadWeeklyData();
      _loadTransactions();
      _monthlyDataFuture =
          TransactionCrud().getMonthlyTransactionData(username);
    }
  }

  void _loadWeeklyData() async {
    print('Fetching weekly data for username: $username');
    final data = await TransactionCrud().getWeeklyTransactionData(username, 1);
    final data2 = await TransactionCrud().getWeeklyTransactionData(username, 2);

    if (data != null && data.isNotEmpty && data2 != null && data2.isNotEmpty) {
      print('Weekly data loaded: $data');
      setState(() {
        weeklyData = data;
        weeklyData2 = data2;
        double maxExpense = weeklyData.values.isNotEmpty
            ? weeklyData.values.reduce((a, b) => a > b ? a : b)
            : 0.0;

        double maxIncome = weeklyData2.values.isNotEmpty
            ? weeklyData2.values.reduce((a, b) => a > b ? a : b)
            : 0.0;

        globalMaxY = (maxExpense > maxIncome ? maxExpense : maxIncome);
      });
    } else {
      print('No weekly data found.');
      setState(() {
        weeklyData = {};
        weeklyData2 = {};
      });
    }
  }

  double getIncomeForMonth(int monthIndex) {
    // Пример: возвращаем случайные данные для дохода
    return (monthIndex + 1) * 1000.0;
  }

  double getExpenseForMonth(int monthIndex) {
    // Пример: возвращаем случайные данные для затрат
    return (monthIndex + 1) * 800.0;
  }

  List<FlSpot> _generateSpots() {
    List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    List<FlSpot> spots = List.generate(daysOfWeek.length, (index) {
      final value = weeklyData[daysOfWeek[index]] ?? 0.0;
      print('Day: ${daysOfWeek[index]}, Value: $value');
      return FlSpot(index.toDouble(), value);
    });

    print('Generated spots: $spots');
    return spots;
  }

  List<FlSpot> _generateSpots2() {
    List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    List<FlSpot> spots = List.generate(daysOfWeek.length, (index) {
      final value = weeklyData2[daysOfWeek[index]] ?? 0.0;
      print('Day: ${daysOfWeek[index]}, Value: $value');
      return FlSpot(index.toDouble(), value);
    });

    print('Generated spots: $spots');
    return spots;
  }

  void isActiveCheck() {
    setState(() {
      isActive = !isActive;
    });
  }

  void isSeccondChart() {
    setState(() {
      isSeccond = !isSeccond;
    });
  }

  List<Map<String, dynamic>> transactions = [];
  Future<void> _loadTransactions() async {
    print(username);
    final data = await TransactionCrud().getTransactions(username);
    setState(() {
      transactions = data;
      //print(transactions);
    });
  }

  String enteredAmount = '';
  String selectedCategory = '';

  void _showBottomSheet(String type) {
    List<Map<String, String>> categories = [];

    if (type == 'Пополнения') {
      categories = [
        {'name': 'Зарплата', 'image': 'assets/zp.png'},
        {'name': 'Перевод', 'image': 'assets/perevod.png'},
        {'name': 'Бонусы', 'image': 'assets/bonus.png'},
        {'name': 'Другие', 'image': 'assets/other.png'},
      ];
    } else if (type == 'Траты') {
      categories = [
        {'name': 'Одежда', 'image': 'assets/shmotki.png'},
        {'name': 'Перевод', 'image': 'assets/perevod.png'},
        {'name': 'Техника', 'image': 'assets/technic.png'},
        {'name': 'Продукты', 'image': 'assets/havka.png'},
        {'name': 'Другие', 'image': 'assets/other.png'},
      ];
    } else if (type == 'Счета на оплату') {
      categories = [
        {'name': 'ЖКХ', 'image': 'assets/jkx.png'},
        {'name': 'Штрафы', 'image': 'assets/shtraf.png'},
        {'name': 'Подписки', 'image': 'assets/podpiska.png'},
        {'name': 'Другие', 'image': 'assets/other.png'},
      ];
    }

    showModalBottomSheet(
      sheetAnimationStyle:
          AnimationStyle(duration: Duration(milliseconds: 1000)),
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 85, 85, 85),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '$type',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width / 4,
                        child: Center(
                          child: TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: Colors.white, fontSize: 28),
                            onChanged: (value) {
                              setState(() {
                                enteredAmount = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '   0.00',
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 28),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Категории:',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category['name']!;
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(category['image']!),
                            backgroundColor:
                                selectedCategory == category['name']
                                    ? Colors.blue
                                    : Colors.grey[300],
                          ),
                          SizedBox(height: 5),
                          Text(
                            category['name']!,
                            style: TextStyle(
                              color: selectedCategory == category['name']
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: () async {
                    if (enteredAmount.isNotEmpty &&
                        selectedCategory.isNotEmpty) {
                      final transactionCrud = TransactionCrud();

                      // Определение типа транзакции
                      final transactionType = type == 'Пополнения'
                          ? 'income'
                          : type == 'Траты'
                              ? 'expense'
                              : 'bill';

                      // Вызов метода создания транзакции
                      await transactionCrud.createTransaction(username, {
                        'amount': double.parse(enteredAmount),
                        'category': selectedCategory,
                        'type': transactionType,
                        'timestamp': DateTime.now(),
                      });
                      await _loadTransactions();
                      // Закрытие модального окна
                      Navigator.pop(context);
                    }
                  },
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (username == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Привет, ${username}',
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
      body: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 600,
              height: isActive ? 430 : 170,
              child: Stack(
                alignment: AlignmentDirectional.topStart,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: isActive ? 10 : 0,
                    top: isActive ? 320 : 10,
                    child: Container(
                      width: 180,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color.fromARGB(255, 78, 78, 78),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Баланс',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/diamond.gif',
                                scale: 3,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '25 000.01',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: isActive ? 10 : 200,
                    right: 10,
                    top: 10,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: isActive ? 300 : 200,
                      height: isActive ? 300 : 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: isSeccond
                            ? LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color.fromARGB(255, 53, 250, 174),
                                  Color.fromARGB(255, 53, 18, 77),
                                ],
                              )
                            : LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color.fromARGB(255, 31, 31, 31),
                                  Color.fromARGB(255, 31, 31, 31),
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
                                  isSeccondChart();
                                },
                                icon: Icon(Icons.change_history_rounded),
                              ),
                              Text(
                                'Графики',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                onPressed: () {
                                  isActiveCheck();
                                },
                                icon: isActive
                                    ? Icon(Icons.zoom_in_map_rounded)
                                    : Icon(Icons.zoom_out_map_rounded),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16.0, 16, 16, 16),
                              child: weeklyData.isEmpty
                                  ? Center(child: CircularProgressIndicator())
                                  : isSeccond
                                      ? StatefulBuilder(
                                          builder: (context, setState) {
                                          return LineChart(
                                            LineChartData(
                                              gridData: FlGridData(
                                                show: false,
                                                drawHorizontalLine: true,
                                                horizontalInterval: 1.0,
                                                drawVerticalLine: true,
                                                verticalInterval: 1.0,
                                                getDrawingHorizontalLine:
                                                    (value) {
                                                  return FlLine(
                                                    color: Colors.grey,
                                                    strokeWidth: 0.5,
                                                  );
                                                },
                                                getDrawingVerticalLine:
                                                    (value) {
                                                  return FlLine(
                                                    color: Colors.grey,
                                                    strokeWidth: 0.5,
                                                  );
                                                },
                                              ),
                                              titlesData: FlTitlesData(
                                                leftTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles:
                                                        isActive ? true : false,
                                                    reservedSize: 40,
                                                  ),
                                                ),
                                                bottomTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles:
                                                        isActive ? true : false,
                                                    getTitlesWidget:
                                                        (value, meta) {
                                                      const days = [
                                                        'Пн',
                                                        'Вт',
                                                        'Ср',
                                                        'Чт',
                                                        'Пт',
                                                        'Сб',
                                                        'Вс'
                                                      ];

                                                      if (value.toInt() < 0 ||
                                                          value.toInt() >=
                                                              days.length) {
                                                        return SizedBox(); // Пустой виджет для значений вне диапазона
                                                      }

                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        child: Text(
                                                          days[value.toInt()],
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      );
                                                    },
                                                    reservedSize: 60,
                                                  ),
                                                ),
                                                topTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                        showTitles: false)),
                                                rightTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                        showTitles: false)),
                                              ),
                                              borderData: FlBorderData(
                                                show: false,
                                                border: const Border(
                                                  top: BorderSide.none,
                                                  right: BorderSide.none,
                                                  bottom: BorderSide.none,
                                                  left: BorderSide.none,
                                                ),
                                              ),
                                              minX: 0,
                                              maxX: 6,
                                              minY: 0,
                                              maxY: globalMaxY! > 0
                                                  ? globalMaxY! + 10
                                                  : 100,
                                              lineBarsData: [
                                                LineChartBarData(
                                                  spots: _generateSpots2(),
                                                  isCurved: true,
                                                  gradient:
                                                      const LinearGradient(
                                                    colors: [
                                                      Color.fromARGB(
                                                          255, 144, 255, 140),
                                                      Color.fromARGB(
                                                          255, 39, 253, 85),
                                                    ],
                                                  ),
                                                  barWidth: 5,
                                                  isStrokeCapRound: false,
                                                  belowBarData: BarAreaData(
                                                    show: false,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        const Color.fromARGB(
                                                                255,
                                                                136,
                                                                55,
                                                                241)
                                                            .withOpacity(0.3),
                                                        const Color.fromARGB(
                                                                255,
                                                                192,
                                                                158,
                                                                255)
                                                            .withOpacity(0.3),
                                                      ],
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                    ),
                                                  ),
                                                  dotData:
                                                      FlDotData(show: true),
                                                ),
                                                LineChartBarData(
                                                  spots: _generateSpots(),
                                                  isCurved: true,
                                                  gradient:
                                                      const LinearGradient(
                                                    colors: [
                                                      Color.fromARGB(
                                                          255, 234, 34, 252),
                                                      Color.fromARGB(
                                                          255, 114, 39, 253),
                                                    ],
                                                  ),
                                                  barWidth: 5,
                                                  isStrokeCapRound: false,
                                                  belowBarData: BarAreaData(
                                                    show: false,
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        const Color.fromARGB(
                                                                255,
                                                                136,
                                                                55,
                                                                241)
                                                            .withOpacity(0.3),
                                                        const Color.fromARGB(
                                                                255,
                                                                192,
                                                                158,
                                                                255)
                                                            .withOpacity(0.3),
                                                      ],
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                    ),
                                                  ),
                                                  dotData:
                                                      FlDotData(show: true),
                                                ),
                                              ],
                                            ),
                                          );
                                        })
                                      : FutureBuilder<
                                              Map<int, Map<String, double>>>(
                                          future: _monthlyDataFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }
                                            if (!snapshot.hasData ||
                                                snapshot.data!.isEmpty) {
                                              return Center(
                                                  child: Text(
                                                      'Нет данных для отображения'));
                                            }

                                            final monthlyData = snapshot.data!;
                                            return BarChart(
                                              BarChartData(
                                                borderData:
                                                    FlBorderData(show: false),
                                                titlesData: FlTitlesData(
                                                  show: isActive ? true : false,
                                                  bottomTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                      showTitles: true,
                                                      getTitlesWidget:
                                                          (double value,
                                                              TitleMeta meta) {
                                                        int monthIndex =
                                                            value.toInt() - 1;
                                                        const months = [
                                                          'Янв',
                                                          'Фев',
                                                          'Мар',
                                                          'Апр',
                                                          'Май',
                                                          'Июн',
                                                          'Июл',
                                                          'Авг',
                                                          'Сен',
                                                          'Окт',
                                                          'Ноя',
                                                          'Дек'
                                                        ];
                                                        return Text(
                                                          months[monthIndex],
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 8,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  rightTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                        showTitles: false),
                                                  ),
                                                  topTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                        showTitles: false),
                                                  ),
                                                ),
                                                barTouchData: BarTouchData(
                                                  enabled: true,
                                                  touchTooltipData:
                                                      BarTouchTooltipData(
                                                    getTooltipItem: (group,
                                                        groupIndex,
                                                        rod,
                                                        rodIndex) {
                                                      String type =
                                                          rodIndex == 0
                                                              ? 'Доход'
                                                              : 'Затраты';
                                                      return BarTooltipItem(
                                                        '$type: ${rod.toY.toStringAsFixed(2)}',
                                                        TextStyle(
                                                            color:
                                                                Colors.white),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                barGroups:
                                                    List.generate(12, (index) {
                                                  double income =
                                                      monthlyData[index + 1]
                                                              ?['income'] ??
                                                          0.0;
                                                  double expense =
                                                      monthlyData[index + 1]
                                                              ?['expense'] ??
                                                          0.0;

                                                  return BarChartGroupData(
                                                    x: index + 1,
                                                    barRods: [
                                                      BarChartRodData(
                                                        toY: income,
                                                        color: Colors.green,
                                                        width: 8,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(2),
                                                      ),
                                                      BarChartRodData(
                                                        toY: expense,
                                                        color: Colors.red,
                                                        width: 8,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(2),
                                                      ),
                                                    ],
                                                  );
                                                }),
                                              ),
                                              duration:
                                                  Duration(milliseconds: 150),
                                              curve: Curves.linear,
                                            );
                                          }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  _showBottomSheet('Пополнения');
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 30,
                      color: Color.fromARGB(255, 102, 102, 102),
                    ),
                    Text(
                      'Пополнения',
                      style: TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showBottomSheet('Траты');
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.payment_outlined,
                      size: 30,
                      color: Color.fromARGB(255, 102, 102, 102),
                    ),
                    Text(
                      'Траты',
                      style: TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showBottomSheet('Счета на оплату');
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.adjust_outlined,
                      size: 30,
                      color: Color.fromARGB(255, 102, 102, 102),
                    ),
                    Text(
                      'Счета на оплату',
                      style: TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .snapshots(),
              builder: (context, snapshot) {
                return Expanded(
                    flex: 3,
                    child: transactions.isEmpty
                        ? Center(
                            child: Text(
                              'Нет транзакций',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = transactions[index];
                              String category = transaction['category'] ??
                                  ''; // Получаем категорию

                              // Создаем маппинг категорий с соответствующими картинками
                              Map<String, String> categoryImages = {
                                'Зарплата': 'assets/zp.png',
                                'Перевод': 'assets/perevod.png',
                                'Бонусы': 'assets/bonus.png',
                                'Другие': 'assets/other.png',
                                'Одежда': 'assets/shmotki.png',
                                'Техника': 'assets/technic.png',
                                'Продукты': 'assets/havka.png',
                                'ЖКХ': 'assets/jkx.png',
                                'Штрафы': 'assets/shtraf.png',
                                'Подписки': 'assets/podpiska.png',
                                // Добавьте другие категории и их изображения
                              };

                              // Получаем путь к картинке для этой категории
                              String imagePath = categoryImages[category] ??
                                  'assets/other.png'; // Путь по умолчанию

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  backgroundImage: AssetImage(
                                      imagePath), // Загружаем картинку для категории
                                ),
                                title: Text(
                                  transaction['title']!,
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  transaction['date']!,
                                  style: TextStyle(color: Colors.grey),
                                ),
                                trailing: Text(
                                  transaction['type'] == 'income'
                                      ? '+${transaction['amount']}'
                                      : '-${transaction['amount']}',
                                  style: TextStyle(
                                      color: transaction['type'] == 'income'
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              );
                            },
                          ));
              }),
        ],
      ),
    );
  }
}
