import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../classes/Entry.dart';

class EntryForm extends StatefulWidget {
  @override
  _EntryFormState createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  Stream<QuerySnapshot> getEntryStream() {
    return _entryCollection.orderBy('date', descending: true).snapshots();
  }

  final _formKey = GlobalKey<FormState>();
  final List<Entry> _entries = [];
  late CollectionReference _entryCollection;

  late String _name;
  late String _category;
  late double _amount;
  late DateTime _date = DateTime.now();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _entryCollection = FirebaseFirestore.instance.collection('entries');
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Entry entry = Entry(
        name: _name,
        category: _category,
        amount: _amount,
        date: _date,
      );

      try {
        DocumentReference docRef = await _entryCollection.add({
          'name': entry.name,
          'category': entry.category,
          'amount': entry.amount,
          'date': entry.date,
        });

        entry.documentId = docRef.id; // Update the document ID of the entry

        setState(() {
          _entries.add(entry);
        });

        _formKey.currentState!.reset();
      } catch (e) {
        print('Error adding entry: $e');
      }
    }
  }

  void _editEntry(int index) {
    Entry entry = _entries[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String updatedName = entry.name;
        String updatedCategory = entry.category;
        double updatedAmount = entry.amount;
        DateTime updatedDate = entry.date;

        return AlertDialog(
          title: Text('Edit Entry'),
          backgroundColor: Colors.deepPurple,
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    initialValue: entry.name,
                    decoration: InputDecoration(labelText: 'Name'),
                    onChanged: (value) {
                      updatedName = value;
                    },
                  ),
                  TextFormField(
                    initialValue: entry.category,
                    decoration: InputDecoration(labelText: 'Category'),
                    onChanged: (value) {
                      updatedCategory = value;
                    },
                  ),
                  TextFormField(
                    initialValue: entry.amount.toString(),
                    decoration: InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      updatedAmount = double.parse(value);
                    },
                  ),
                  TextFormField(
                    initialValue: DateFormat('yyyy-MM').format(entry.date),
                    decoration: InputDecoration(labelText: 'Month'),
                    onChanged: (value) {
                      updatedDate = DateTime.parse(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                Entry updatedEntry = Entry(
                  documentId: entry.documentId,
                  name: updatedName,
                  category: updatedCategory,
                  amount: updatedAmount,
                  date: updatedDate,
                );

                await _entryCollection.doc(entry.documentId).update({
                  'name': updatedEntry.name,
                  'category': updatedEntry.category,
                  'amount': updatedEntry.amount,
                  'date': updatedEntry.date,
                });

                setState(() {
                  _entries[index] = updatedEntry;
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteEntry(int index) async {
    String? documentId = _entries[index].documentId;

    await _entryCollection.doc(documentId).delete();

    setState(() {
      _entries.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Income and Expenses Tracker'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _entryCollection.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                List<Entry> entries = [];

                snapshot.data!.docs.forEach((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  Entry entry = Entry(
                    documentId: doc.id,
                    name: data['name'],
                    category: data['category'],
                    amount: data['amount'],
                    date: data['date'].toDate(),
                  );
                  entries.add(entry);
                });

                _entries.clear();
                _entries.addAll(entries);

                return ListView.builder(
                  itemCount: _entries.length,
                  itemBuilder: (BuildContext context, int index) {
                    Entry entry = _entries[index];

                    return ListTile(
                      title: Text(entry.name),
                      subtitle: Text(entry.category),
                      trailing: Text('\$${entry.amount.toStringAsFixed(2)}'),
                      onTap: () {
                        _editEntry(index);
                      },
                      onLongPress: () {
                        _deleteEntry(index);
                      },
                    );
                  },
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Category'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a category';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _category = value!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _amount = double.parse(value!);
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: _selectDate,
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a date';
                      }
                      return null;
                    },
                    onTap: _selectDate,
                    controller: TextEditingController(
                      text: _date != null
                          ? DateFormat('yyyy-MM-dd').format(_date)
                          : '',
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 10.0),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.deepPurple)),
                    child: Text('Add Entry'),
                    onPressed: _submitForm,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
