
import 'package:flutter/material.dart';

import 'models/expense.dart';
import 'widgets/summary_card.dart';
import 'widgets/expense_tile.dart';

void main() {
  runApp(const BudgetCalculatorApp());
}

// ROOT APPLICATION
class BudgetCalculatorApp extends StatelessWidget {
  const BudgetCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Budget Calculator',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF2F7F6),
      ),
      home: const BudgetHomePage(),
    );
  }
}

// MAIN STATEFUL SCREEN
class BudgetHomePage extends StatefulWidget {
  const BudgetHomePage({super.key});

  @override
  State<BudgetHomePage> createState() => _BudgetHomePageState();
}

class _BudgetHomePageState extends State<BudgetHomePage> {

  // TEXT CONTROLLERS
  final TextEditingController incomeController =
      TextEditingController();

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController amountController =
      TextEditingController();

  // APPLICATION STATE
  double income = 0.0;

  String selectedCategory = 'Food';

  final List<String> categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Other',
  ];

  // EXPENSE LIST
  final List<Expense> expenses = [];

  // CALCULATE TOTAL EXPENSES
  double get totalExpenses {
    return expenses.fold<double>(
      0.0,
      (total, expense) => total + expense.amount,
    );
  }

  // CALCULATE REMAINING BALANCE
  double get remainingBalance {
    return income - totalExpenses;
  }

  // CALCULATE EXPENSE PERCENTAGE
  double get expensePercentage {
    if (income <= 0) return 0.0;

    return (totalExpenses / income)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  // FINANCIAL STATUS
  String get financialStatus {
    if (remainingBalance > 0) {
      return 'Good! You have savings.';
    } else if (remainingBalance == 0) {
      return 'Your budget is balanced.';
    } else {
      return 'Warning! You are overspending.';
    }
  }

  // STATUS COLOR
  Color get statusColor {
    if (remainingBalance > 0) {
      return Colors.green;
    } else if (remainingBalance == 0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // UPDATE INCOME
  void updateIncome(String value) {
    final parsedValue = double.tryParse(value.trim());

    setState(() {
      income = parsedValue != null && parsedValue >= 0
          ? parsedValue
          : 0.0;
    });
  }

  // ADD EXPENSE
  void addExpense() {
    final title = titleController.text.trim();

    final amount = double.tryParse(
      amountController.text.trim(),
    );

    if (title.isEmpty || amount == null ||
        !amount.isFinite || amount <= 0) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid expense name and positive amount!',
          ),
        ),
      );

      return;
    }

    setState(() {
      expenses.add(
        Expense(
          title: title,
          category: selectedCategory,
          amount: amount,
        ),
      );

      titleController.clear();
      amountController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense added successfully!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // DELETE EXPENSE
  void deleteExpense(int index) {
    setState(() {
      expenses.removeAt(index);
    });
  }

  // RESET BUDGET
  void resetBudget() {
    setState(() {
      income = 0.0;
      expenses.clear();

      incomeController.clear();
      titleController.clear();
      amountController.clear();

      selectedCategory = 'Food';
    });
  }

  // RELEASE CONTROLLERS
  @override
  void dispose() {
    incomeController.dispose();
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F6),

      // APP BAR
      appBar: AppBar(
        title: const Text(
          'Personal Budget Calculator',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
        actions: [
          IconButton(
            onPressed: resetBudget,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            tooltip: 'Reset budget',
          ),
        ],
      ),

      // RESPONSIVE MAIN BODY
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1000,
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [

              // WELCOME BANNER
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF00796B),
                      Color(0xFF4DB6AC),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 40,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Manage Your Money Smartly!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Track your income, expenses and savings.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // MONTHLY INCOME
              const Text(
                'Monthly Income',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: incomeController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: updateIncome,
                decoration: InputDecoration(
                  hintText: 'Enter your monthly income',
                  prefixIcon: const Icon(
                    Icons.currency_rupee,
                    color: Colors.green,
                  ),
                  suffixText: 'INR',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // FINANCIAL SUMMARY
              const Text(
                'Financial Summary',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isSmall = constraints.maxWidth < 450;

                  if (isSmall) {
                    return Column(
                      children: [
                        SummaryCard(
                          title: 'Income',
                          amount: income,
                          color: Colors.green,
                          icon: Icons.trending_up,
                        ),
                        SummaryCard(
                          title: 'Expenses',
                          amount: totalExpenses,
                          color: Colors.red,
                          icon: Icons.trending_down,
                        ),
                        SummaryCard(
                          title: 'Balance',
                          amount: remainingBalance,
                          color: remainingBalance < 0
                              ? Colors.red
                              : Colors.teal,
                          icon: Icons.account_balance_wallet,
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Income',
                          amount: income,
                          color: Colors.green,
                          icon: Icons.trending_up,
                        ),
                      ),
                      Expanded(
                        child: SummaryCard(
                          title: 'Expenses',
                          amount: totalExpenses,
                          color: Colors.red,
                          icon: Icons.trending_down,
                        ),
                      ),
                      Expanded(
                        child: SummaryCard(
                          title: 'Balance',
                          amount: remainingBalance,
                          color: remainingBalance < 0
                              ? Colors.red
                              : Colors.teal,
                          icon: Icons.account_balance_wallet,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // EXPENSE USAGE
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expense Usage',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      LinearProgressIndicator(
                        value: expensePercentage,
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(10),
                        backgroundColor: Colors.grey.shade200,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(
                          totalExpenses > income
                              ? Colors.red
                              : Colors.teal,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '${(income > 0 ? totalExpenses / income * 100 : 0).toStringAsFixed(1)}% of income spent',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // FINANCIAL STATUS
              Card(
                color: statusColor.withValues(alpha: 0.10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        remainingBalance >= 0
                            ? Icons.check_circle
                            : Icons.warning,
                        color: statusColor,
                        size: 32,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Financial Status',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              financialStatus,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ADD EXPENSE SECTION
              const Text(
                'Add New Expense',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [

                      // EXPENSE NAME
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Expense Name',
                          hintText: 'Example: Grocery',
                          prefixIcon: Icon(Icons.edit),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // EXPENSE AMOUNT
                      TextField(
                        controller: amountController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Expense Amount',
                          hintText: 'Enter amount',
                          prefixIcon: Icon(
                            Icons.currency_rupee,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // CATEGORY DROPDOWN
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Expense Category',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 18),

                      // ADD EXPENSE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: addExpense,
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Add Expense',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // EXPENSE HISTORY
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Expense History',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${expenses.length} expenses',
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // DISPLAY EXPENSES
              if (expenses.isEmpty)
                const Card(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(25),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 45,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No expenses added yet.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...List.generate(
                  expenses.length,
                  (index) {
                    final expense = expenses[index];

                    return ExpenseTile(
                      key: ObjectKey(expense),
                      expense: expense,
                      onDelete: () => deleteExpense(index),
                    );
                  },
                ),

              const SizedBox(height: 20),

              // RESET BUTTON
              OutlinedButton.icon(
                onPressed: resetBudget,
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Reset Entire Budget'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.all(14),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
