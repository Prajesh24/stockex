// lib/features/portfolio/presentation/widgets/sell_stock_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/portfolio_entity.dart';

class SellStockDialog extends StatefulWidget {
  final PortfolioEntity stock;
  final Function(Map<String, String>) onSell;

  const SellStockDialog({super.key, required this.stock, required this.onSell});

  @override
  State<SellStockDialog> createState() => _SellStockDialogState();
}

class _SellStockDialogState extends State<SellStockDialog> {
  final _unitsController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime _sellDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _priceController.text = widget.stock.ltp.toString();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sellDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _sellDate = picked);
    }
  }

  void _submit() {
    if (_unitsController.text.isEmpty || _priceController.text.isEmpty) return;

    final units = int.parse(_unitsController.text);
    if (units > widget.stock.remainingUnits) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot sell more than ${widget.stock.remainingUnits} units',
          ),
        ),
      );
      return;
    }

    widget.onSell({
      'units': _unitsController.text,
      'sellPrice': _priceController.text,
      'sellDate': _sellDate.toIso8601String().split('T')[0],
    });

    Navigator.pop(context);
  }

  double get _estimatedPL {
    final units = double.tryParse(_unitsController.text) ?? 0;
    final sellPrice = double.tryParse(_priceController.text) ?? 0;
    final revenue = units * sellPrice;
    final fees = revenue * 0.004365 + 25;
    final cost = units * widget.stock.wacc;
    return revenue - fees - cost;
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'en_NP', symbol: 'NPR ');
    final isProfit = _estimatedPL >= 0;

    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.attach_money,
                    color: Colors.green,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sell Stock',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Enter sell details',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Symbol:', widget.stock.symbol),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Available:',
                    '${widget.stock.remainingUnits} units',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Your WACC:', format.format(widget.stock.wacc)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _unitsController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Units to Sell'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Sell Price'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: _inputDecoration('Sell Date'),
                child: Text(
                  _sellDate.toIso8601String().split('T')[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_unitsController.text.isNotEmpty &&
                _priceController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isProfit
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isProfit
                        ? Colors.green.withOpacity(0.3)
                        : Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Estimated Realized P/L:',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${isProfit ? '+' : ''}${format.format(_estimatedPL)}',
                      style: TextStyle(
                        color: isProfit ? Colors.green : Colors.red,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Confirm Sell'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400])),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
