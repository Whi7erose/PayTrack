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

enum CalcMode { monthlyPayment, totalMonths }

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  final _amountController = TextEditingController();
  final _monthsController = TextEditingController();
  final _targetPaymentController = TextEditingController();
  final _feeController = TextEditingController();
  final _interestController = TextEditingController(); // Annual interest rate

  CalcMode _mode = CalcMode.monthlyPayment;

  double _totalAmount = 0.0;
  double _monthlyPayment = 0.0;
  double _totalInterest = 0.0;
  int _calculatedMonths = 0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_calculate);
    _monthsController.addListener(_calculate);
    _targetPaymentController.addListener(_calculate);
    _feeController.addListener(_calculate);
    _interestController.addListener(_calculate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _monthsController.dispose();
    _targetPaymentController.dispose();
    _feeController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  void _calculate() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final fee = double.tryParse(_feeController.text) ?? 0.0;
    final annualInterestRate = double.tryParse(_interestController.text) ?? 0.0;
    final monthlyInterestRate = (annualInterestRate / 100) / 12;

    if (amount <= 0) {
      setState(() {
        _totalAmount = 0;
        _monthlyPayment = 0;
        _totalInterest = 0;
        _calculatedMonths = 0;
      });
      return;
    }

    if (_mode == CalcMode.monthlyPayment) {
      final months = int.tryParse(_monthsController.text) ?? 0;
      if (months <= 0) {
        setState(() { _totalAmount = 0; _monthlyPayment = 0; _totalInterest = 0; });
        return;
      }
      _calculatedMonths = months;

      if (annualInterestRate > 0) {
        final factor = pow(1 + monthlyInterestRate, months);
        _monthlyPayment = (amount * monthlyInterestRate * factor) / (factor - 1);
        final totalPaid = (_monthlyPayment * months) + fee;
        _totalInterest = totalPaid - amount - fee;
        _totalAmount = totalPaid;
      } else {
        _monthlyPayment = amount / months;
        _totalAmount = amount + fee;
        _totalInterest = 0.0;
      }
    } else {
      // Calculate Months mode
      final targetPmt = double.tryParse(_targetPaymentController.text) ?? 0.0;
      if (targetPmt <= 0) {
        setState(() { _totalAmount = 0; _calculatedMonths = 0; _totalInterest = 0; });
        return;
      }
      _monthlyPayment = targetPmt;

      if (annualInterestRate > 0) {
        // Check if payment is too small to cover interest
        final interestPerMonth = amount * monthlyInterestRate;
        if (targetPmt <= interestPerMonth) {
          setState(() { _calculatedMonths = 999; _totalAmount = 0; _totalInterest = 0; }); // infinite
          return;
        }
        
        // n = -log(1 - (r * P) / PMT) / log(1 + r)
        final numerator = -log(1 - ((monthlyInterestRate * amount) / targetPmt));
        final denominator = log(1 + monthlyInterestRate);
        _calculatedMonths = (numerator / denominator).ceil();
        
        final totalPaid = (targetPmt * _calculatedMonths) + fee;
        _totalInterest = totalPaid - amount - fee;
        _totalAmount = totalPaid;
      } else {
        _calculatedMonths = (amount / targetPmt).ceil();
        _totalAmount = amount + fee;
        _totalInterest = 0.0;
      }
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
            SegmentedButton<CalcMode>(
              segments: const [
                ButtonSegment(
                  value: CalcMode.monthlyPayment,
                  label: Text('Calc Monthly'),
                  icon: Icon(Icons.calendar_month),
                ),
                ButtonSegment(
                  value: CalcMode.totalMonths,
                  label: Text('Calc Months'),
                  icon: Icon(Icons.functions),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (Set<CalcMode> newSelection) {
                setState(() {
                  _mode = newSelection.first;
                  _calculate();
                });
              },
            ),
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      _mode == CalcMode.monthlyPayment ? 'Monthly Payment' : 'Total Months to Pay Off',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _mode == CalcMode.monthlyPayment 
                          ? NumberFormat.currency(symbol: currencySymbol).format(_monthlyPayment)
                          : (_calculatedMonths == 999 ? '∞ (Increase Pmt)' : '$_calculatedMonths months'),
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
            if (_mode == CalcMode.monthlyPayment)
              TextField(
                controller: _monthsController,
                decoration: const InputDecoration(
                  labelText: 'Number of Months',
                  prefixIcon: Icon(Icons.date_range),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              )
            else
              TextField(
                controller: _targetPaymentController,
                decoration: InputDecoration(
                  labelText: 'Target Monthly Payment',
                  prefixIcon: Text(' $currencySymbol ', style: const TextStyle(fontSize: 16, height: 1.4)),
                  prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
