import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../providers/settings_provider.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  final _amountController = TextEditingController();
  final _monthsController = TextEditingController();
  final _feeController = TextEditingController();
  final _interestController = TextEditingController(); // Annual interest rate

  double _totalAmount = 0.0;
  double _monthlyPayment = 0.0;
  double _totalInterest = 0.0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_calculate);
    _monthsController.addListener(_calculate);
    _feeController.addListener(_calculate);
    _interestController.addListener(_calculate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _monthsController.dispose();
    _feeController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  void _calculate() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final months = int.tryParse(_monthsController.text) ?? 0;
    final fee = double.tryParse(_feeController.text) ?? 0.0;
    final annualInterestRate = double.tryParse(_interestController.text) ?? 0.0;

    if (amount <= 0 || months <= 0) {
      setState(() {
        _totalAmount = 0;
        _monthlyPayment = 0;
        _totalInterest = 0;
      });
      return;
    }

    if (annualInterestRate > 0) {
      // Standard amortized loan calculation
      final monthlyInterestRate = (annualInterestRate / 100) / 12;
      final factor = pow(1 + monthlyInterestRate, months);
      _monthlyPayment = (amount * monthlyInterestRate * factor) / (factor - 1);
      
      // The one-time fee is usually paid upfront, but we can distribute it or just add it to total.
      // Let's just add it to the total loan amount needed to be paid.
      // If fee is added to monthly payment:
      final feePerMonth = fee / months;
      _monthlyPayment += feePerMonth;

      final totalPaid = _monthlyPayment * months;
      _totalInterest = totalPaid - amount - fee;
      _totalAmount = totalPaid;
    } else {
      // Simple 0% interest calculation
      _totalAmount = amount + fee;
      _monthlyPayment = _totalAmount / months;
      _totalInterest = 0.0;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = ref.watch(currencyProvider);
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Monthly Payment',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat.currency(symbol: currencySymbol).format(_monthlyPayment),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Repayment'),
                            Text(
                              NumberFormat.currency(symbol: currencySymbol).format(_totalAmount),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Total Interest'),
                            Text(
                              NumberFormat.currency(symbol: currencySymbol).format(_totalInterest),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Loan Amount',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _monthsController,
              decoration: const InputDecoration(
                labelText: 'Number of Months',
                prefixIcon: Icon(Icons.date_range),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _feeController,
                    decoration: const InputDecoration(
                      labelText: 'One-time Fee',
                      prefixIcon: Icon(Icons.receipt),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _interestController,
                    decoration: const InputDecoration(
                      labelText: 'Annual Interest (%)',
                      prefixIcon: Icon(Icons.percent),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }
}
