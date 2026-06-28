import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/payment_plan.dart';
import '../providers/payment_plan_provider.dart';
import '../services/installment_generator_service.dart';
import 'customize_installments_screen.dart';
import 'package:intl/intl.dart';

class AddPaymentPlanScreen extends ConsumerStatefulWidget {
  const AddPaymentPlanScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddPaymentPlanScreen> createState() => _AddPaymentPlanScreenState();
}

class _AddPaymentPlanScreenState extends ConsumerState<AddPaymentPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _periodsController = TextEditingController();
  final _amountController = TextEditingController();
  final _notifyDaysController = TextEditingController(text: '1');
  
  String _frequency = 'monthly';
  DateTime _startDate = DateTime.now();
  bool _customizeInstallments = false;
  int _selectedColorValue = 0xFFBBDEFB; // Default light blue

  final List<int> _availableColors = [
    0xFFBBDEFB, // Light Blue
    0xFFE1BEE7, // Light Purple
    0xFFC8E6C9, // Light Green
    0xFFFFCC80, // Light Orange/Yellow
    0xFFFFCDD2, // Light Red
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _periodsController.dispose();
    _amountController.dispose();
    _notifyDaysController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _savePlan() async {
    if (_formKey.currentState!.validate()) {
      final plan = PaymentPlan(
        id: Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        startDate: _startDate,
        frequency: _frequency,
        totalPeriods: int.tryParse(_periodsController.text) ?? 1,
        defaultAmount: double.tryParse(_amountController.text) ?? 0.0,
        notifyDaysBefore: int.tryParse(_notifyDaysController.text) ?? 3,
        createdAt: DateTime.now(),
        colorValue: _selectedColorValue,
      );

      final installments = await InstallmentGeneratorService.generateInstallments(plan);

      if (_customizeInstallments) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CustomizeInstallmentsScreen(
              plan: plan,
              initialInstallments: installments,
            ),
          ),
        );
      } else {
        await ref.read(paymentPlanProvider.notifier).addPlan(plan, installments);
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment plan saved successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _savePlan,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text('Card Color', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: _availableColors.map((colorValue) {
                final isSelected = _selectedColorValue == colorValue;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorValue = colorValue),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(colorValue),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: isSelected
                        ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Plan Title',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'annually', child: Text('Annually')),
              ],
              onChanged: (v) => setState(() => _frequency = v!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _periodsController,
                    decoration: const InputDecoration(
                      labelText: 'Total Periods',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (int.tryParse(v) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Default Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid amount';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start Date'),
              subtitle: Text(DateFormat.yMMMd().format(_startDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectStartDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notifyDaysController,
              decoration: const InputDecoration(
                labelText: 'Notify me X days before due date',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (int.tryParse(v) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Customize individual period amounts'),
              subtitle: const Text('Set specific amounts or extra fees for each period'),
              value: _customizeInstallments,
              onChanged: (v) => setState(() => _customizeInstallments = v),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _savePlan,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Plan'),
            ),
          ],
        ),
      ),
    );
  }
}
