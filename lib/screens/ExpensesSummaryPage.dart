import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Entry {
  final String category;
  final double amount;

  Entry({
    required this.category,
    required this.amount,
  });
}

class ExpensesSummaryPage extends StatefulWidget {
  const ExpensesSummaryPage({super.key});

  @override
  State<ExpensesSummaryPage> createState() => _ExpensesSummaryPageState();
}

class _ExpensesSummaryPageState extends State<ExpensesSummaryPage> {
  final String currentMonth = DateTime.now().toString().substring(0, 7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Summary of : $currentMonth'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('entries')
            .where('date', isEqualTo: currentMonth)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text('No Expenses added for the current month');
          }

          Map<String, double> categoryMap = {};

          for (var doc in snapshot.data!.docs) {
            String category = doc['category'];
            double amount = doc['amount'];
            Entry entry = Entry(category: category, amount: amount);
            if (categoryMap.containsKey(category)) {
              categoryMap[category] = categoryMap[category]! + amount;
            } else {
              categoryMap[category] = amount;
            }
          }

          List<Widget> categoryWidgets = [];
          categoryMap.forEach((category, amount) {
            categoryWidgets.add(
              ListTile(
                title: Text(category),
                trailing: Text('\$${amount.toStringAsFixed(2)}'),
              ),
            );
          });

          return ListView(
            children: categoryWidgets,
          );
        },
      ),
    );
  }
}
