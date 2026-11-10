import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ExpenseApp());
}

const Color purple = Color(0xFF7657F6);
const Color darkPurple = Color(0xFF4932B8);
const Color background = Color(0xFFF4F1FF);
const Color navy = Color(0xFF201B45);

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(seedColor: purple),
      ),
      home: const ExpenseScreen(),
    );
  }
}

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String selectedCategory = 'Food';
  DateTime selectedDate = DateTime.now();
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final List<String> categories = [
    'Food',
    'Travel',
    'Shopping',
    'Education',
    'Entertainment',
    'Bills',
    'Health',
    'Others',
  ];

  final List<Map<String, dynamic>> expenses = [];

  final List<int> years = List.generate(
    10,
    (index) => DateTime.now().year - index,
  );

  double get totalExpense {
    return expenses.fold(
      0.0,
      (sum, item) => sum + (item['amount'] as double),
    );
  }

  double get monthlyExpense {
    return expenses
        .where((item) =>
            item['date'].month == selectedMonth &&
            item['date'].year == selectedYear)
        .fold(0.0, (sum, item) => sum + item['amount']);
  }

  double get yearlyExpense {
    return expenses
        .where((item) => item['date'].year == selectedYear)
        .fold(0.0, (sum, item) => sum + item['amount']);
  }

  IconData categoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Travel':
        return Icons.directions_car_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Education':
        return Icons.school_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Health':
        return Icons.favorite_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color categoryColor(String category) {
    switch (category) {
      case 'Food':
        return const Color(0xFFFF9F43);
      case 'Travel':
        return const Color(0xFF36B8D9);
      case 'Shopping':
        return const Color(0xFFED70A6);
      case 'Education':
        return const Color(0xFF7966E8);
      case 'Entertainment':
        return const Color(0xFFEF7777);
      case 'Bills':
        return const Color(0xFF4C9BE8);
      case 'Health':
        return const Color(0xFF35B98A);
      default:
        return const Color(0xFF9295A8);
    }
  }

  String formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: purple,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  void addExpense() {
    if (!formKey.currentState!.validate()) return;

    final amount = double.parse(amountController.text.trim());

    setState(() {
      expenses.insert(0, {
        'id': DateTime.now().microsecondsSinceEpoch,
        'category': selectedCategory,
        'amount': amount,
        'description': descriptionController.text.trim(),
        'date': selectedDate,
      });

      amountController.clear();
      descriptionController.clear();
      selectedCategory = 'Food';
      selectedDate = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense added successfully!'),
        backgroundColor: Color(0xFF35B98A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void deleteExpense(int id) {
    setState(() {
      expenses.removeWhere((item) => item['id'] == id);
    });
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: purple),
      filled: true,
      fillColor: const Color(0xFFF7F5FF),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE9E4FF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: purple, width: 1.5),
      ),
    );
  }

  Widget sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: navy,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF85819C),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget summaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required List<Color> colors,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.22),
              blurRadius: 15,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '₹${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8DEFF),
              Color(0xFFF6F2FF),
              Color(0xFFE4F0FF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [purple, darkPurple],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MY FINANCES',
                            style: TextStyle(
                              color: purple,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            'Expense Tracker',
                            style: TextStyle(
                              color: navy,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: navy,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // TOTAL EXPENSE CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF8065FF),
                        Color(0xFF5536C8),
                        Color(0xFF38258F),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: purple.withOpacity(0.30),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -35,
                        child: Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.wallet_rounded,
                                color: Colors.white70,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'TOTAL EXPENSES',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            '₹${totalExpense.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Keep track of where your money goes.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              '${expenses.length} transactions recorded',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 27),

                sectionTitle(
                  'Your Overview',
                  'A quick look at your spending',
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    summaryCard(
                      title: 'Monthly',
                      amount: monthlyExpense,
                      icon: Icons.calendar_month_rounded,
                      colors: const [
                        Color(0xFFFF8B73),
                        Color(0xFFE84D82),
                      ],
                    ),
                    const SizedBox(width: 13),
                    summaryCard(
                      title: 'Yearly',
                      amount: yearlyExpense,
                      icon: Icons.bar_chart_rounded,
                      colors: const [
                        Color(0xFF43C6D9),
                        Color(0xFF3979D8),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // FILTERS
                Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: purple.withOpacity(0.07),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle(
                        'Spending Filters',
                        'Choose a month and year',
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: selectedMonth,
                              isExpanded: true,
                              decoration: inputDecoration(
                                'Month',
                                Icons.calendar_month_rounded,
                              ),
                              items: List.generate(
                                12,
                                (index) => DropdownMenuItem(
                                  value: index + 1,
                                  child: Text(
                                    monthName(index + 1),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => selectedMonth = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: selectedYear,
                              isExpanded: true,
                              decoration: inputDecoration(
                                'Year',
                                Icons.event_rounded,
                              ),
                              items: years.map((year) {
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text('$year'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => selectedYear = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 27),

                // ADD EXPENSE FORM
                sectionTitle(
                  'Add New Expense',
                  'Enter your spending details below',
                ),

                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: purple.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          decoration: inputDecoration(
                            'Expense Category',
                            Icons.category_rounded,
                          ),
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedCategory = value);
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          decoration: inputDecoration(
                            'Amount (₹)',
                            Icons.currency_rupee_rounded,
                          ),
                          validator: (value) {
                            final amount = double.tryParse(value ?? '');
                            if (amount == null || amount <= 0) {
                              return 'Enter a valid amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: descriptionController,
                          maxLength: 100,
                          decoration: inputDecoration(
                            'Description',
                            Icons.edit_note_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: pickDate,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 17,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F5FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE9E4FF),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  color: purple,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    formatDate(selectedDate),
                                    style: const TextStyle(
                                      color: navy,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: purple,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [purple, darkPurple],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: purple.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: addExpense,
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                              ),
                              label: const Text(
                                'ADD EXPENSE',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 27),

                // TRANSACTION HISTORY
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: sectionTitle(
                        'Recent Transactions',
                        'Your spending history',
                      ),
                    ),
                    Text(
                      '${expenses.length} items',
                      style: const TextStyle(
                        color: purple,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                if (expenses.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 48,
                          color: Color(0xFFBDB3EA),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No expenses yet!',
                          style: TextStyle(
                            color: navy,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Add your first expense to get started.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF9691AA),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...expenses.map((expense) {
                    final category = expense['category'] as String;
                    final color = categoryColor(category);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: purple.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.13),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              categoryIcon(category),
                              color: color,
                              size: 23,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  expense['description'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: navy,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '$category • ${formatDate(expense['date'])}',
                                  style: const TextStyle(
                                    color: Color(0xFF9691AA),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '-₹${(expense['amount'] as double).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFE65B76),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              IconButton(
                                onPressed: () => deleteExpense(expense['id']),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFFAAA4BC),
                                  size: 19,
                                ),
                                visualDensity: VisualDensity.compact,
                                tooltip: 'Delete expense',
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 15),

                Center(
                  child: Text(
                    'Made with ♥  •  Expense Tracker',
                    style: TextStyle(
                      color: navy.withOpacity(0.45),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
