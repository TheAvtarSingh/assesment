import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageBudget extends StatefulWidget {
  const ManageBudget({super.key});

  @override
  State<ManageBudget> createState() => _ManageBudgetState();
}

class _ManageBudgetState extends State<ManageBudget> {
  late CollectionReference _entryCollection;
  late CollectionReference _expensesCollection;

  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double _balance = 0.0;

  bool _isTotalBudget = true;

  @override
  void initState() {
    super.initState();
    _entryCollection = FirebaseFirestore.instance.collection('entries');
    _expensesCollection = FirebaseFirestore.instance.collection('expenses');
    fetchBudgetDetails();
  }

  void fetchBudgetDetails() async {
    QuerySnapshot querySnapshot = await _entryCollection.get();
    QuerySnapshot expensesSnapshot = await _expensesCollection.get();
    List<QueryDocumentSnapshot> docs = querySnapshot.docs;
    List<QueryDocumentSnapshot> docs1 = expensesSnapshot.docs;

    double totalIncome = 0.0;
    double totalExpenses = 0.0;

    for (var doc in docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      double amount = data['amount'];
      if (amount > 0) {
        totalIncome += amount;
      } else {
        totalExpenses += amount.abs();
      }
    }

    for (var doc in docs1) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      double amount = data['totalExpenses'];
      totalExpenses += amount;
    }
    double balance = totalExpenses - totalIncome;

    setState(() {
      _totalIncome = totalIncome;
      _totalExpenses = totalExpenses;
      _balance = balance;
      (_totalExpenses != 0) ? _isTotalBudget = true : _isTotalBudget = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Tracker'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Monthly Budget',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Total Expenses: \$$_totalIncome',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Total Income : \$$_totalExpenses',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Balance: \$$_balance',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          Padding(
              padding: EdgeInsets.all(12.0),
              child: _isTotalBudget
                  ? Text(" ")
                  : ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/addExpenses');
                      },
                      child: Text("Add Total Expenses"))),
        ],
      ),
    );
  }
}
