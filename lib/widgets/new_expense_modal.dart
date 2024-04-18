import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();

class NewExpenseModal extends StatefulWidget {
  NewExpenseModal(this.addNewExpense, {super.key});

  void Function(Expense newExpense) addNewExpense;

  @override
  State<NewExpenseModal> createState() => _NewExpenseModalState();
}

class _NewExpenseModalState extends State<NewExpenseModal> {
  final _titleController =
      TextEditingController(); // Flutter's special Built-in method to handle Input Management
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category? _selectedCategory;

  void _selectCategory(Category? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _presentDatePicker() {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: now,
    ).then((pickedDate) => {
          if (pickedDate != null)
            {
              setState(() {
                _selectedDate = pickedDate;
              })
            }
        });
  }

  bool _validateExpenseInputs() {
    final parsedAmount = double.tryParse(_amountController.text);
    if (_titleController.text.trim().isEmpty ||
        parsedAmount == null ||
        _selectedCategory == null ||
        _selectedDate == null) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Invalid input'),
          content: const Text('Please, make sure valid values were entered.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Okay'),
            )
          ],
        ),
      );
      return false;
    }
    return true;
  }

  void _saveExpense() {
    if (_validateExpenseInputs()) {
      widget.addNewExpense(
        Expense(
          title: _titleController.text.trim(),
          amount: double.parse(_amountController.text),
          category: _selectedCategory!,
          date: _selectedDate!,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _cancelExpanse() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            maxLength: 50,
            // keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              label: Text('Title'),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  maxLength: 12,
                  maxLengthEnforcement: MaxLengthEnforcement.none,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixText: 'R\$ ',
                    label: Text('Amount'),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'No selected Date'
                          : formatter.format(_selectedDate!),
                    ),
                    IconButton(
                      onPressed: _presentDatePicker,
                      icon: const Icon(Icons.calendar_month_rounded),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              DropdownButton(
                items: categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                value: _selectedCategory,
                onChanged: (selectedCategory) {
                  _selectCategory(selectedCategory as Category?);
                },
              ),
              const Spacer(),
              TextButton(
                onPressed: _cancelExpanse,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _saveExpense,
                child: const Text('Save Expense'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
