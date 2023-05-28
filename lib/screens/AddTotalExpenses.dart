import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddExpensesPage extends StatelessWidget {
  final TextEditingController _totalExpensesController =
      TextEditingController();

  void _addExpenses(double totalExpenses) {
    CollectionReference expensesCollection =
        FirebaseFirestore.instance.collection('expenses');

    expensesCollection.add({'totalExpenses': totalExpenses});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expenses'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Expenses',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _totalExpensesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Total Expenses',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                double totalExpenses =
                    double.parse(_totalExpensesController.text);
                _addExpenses(totalExpenses);
                Navigator.of(context).pop();
              },
              child: Text('Add Expenses'),
            ),
          ],
        ),
      ),
    );
  }
}
