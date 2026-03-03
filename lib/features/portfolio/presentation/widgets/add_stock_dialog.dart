// lib/features/portfolio/presentation/widgets/add_stock_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockex/features/portfolio/data/service/nepse_fee_service.dart';

class AddStockDialog extends StatefulWidget {
  final Function(Map<String, String?>) onAdd;

  const AddStockDialog({super.key, required this.onAdd});

  @override
  State<AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<AddStockDialog> {
  final _searchController = TextEditingController();
  final _unitsController = TextEditingController();
  final _priceController = TextEditingController();

  String? _selectedSymbol;
  String? _selectedName;
  String? _selectedSector;
  double? _selectedLTP; // ✅ store LTP of selected stock
  String _transactionType = 'secondary';
  DateTime _buyDate = DateTime.now();

  NepseFeeResult? _feePreview;

  final _currencyFormat = NumberFormat.currency(
    locale: 'en_NP',
    symbol: 'NPR ',
    decimalDigits: 2,
  );

  // Dummy stocks — replace with real NEPSE API later
  final List<Map<String, dynamic>> _allStocks = [
    {'symbol': 'UPPER', 'name': 'Upper Tamakoshi Hydropower Ltd.', 'ltp': 225.3, 'sector': 'HydroPower'},
    {'symbol': 'HBL',   'name': 'Himalayan Bank Ltd.',             'ltp': 321.8, 'sector': 'Commercial Banks'},
    {'symbol': 'NABIL', 'name': 'Nabil Bank Ltd.',                 'ltp': 452.5, 'sector': 'Commercial Banks'},
    {'symbol': 'NICA',  'name': 'NIC Asia Bank Ltd.',              'ltp': 389.0, 'sector': 'Commercial Banks'},
    {'symbol': 'CHCL',  'name': 'Chilime Hydropower Co. Ltd.',     'ltp': 512.0, 'sector': 'HydroPower'},
    {'symbol': 'NLIC',  'name': 'Nepal Life Insurance Co. Ltd.',   'ltp': 1120.0,'sector': 'Life Insurance'},
    {'symbol': 'SBCF',  'name': 'Siddhartha Bank Capital Fund',    'ltp': 10.5,  'sector': 'Microfinance'},
  ];

  List<Map<String, dynamic>> _filteredStocks = [];

  @override
  void initState() {
    super.initState();
    _unitsController.addListener(_recalculate);
    _priceController.addListener(_recalculate);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _unitsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _recalculate() {
    final units = int.tryParse(_unitsController.text);
    final price = double.tryParse(_priceController.text);

    if (units != null && units > 0 && price != null && price > 0) {
      setState(() {
        _feePreview = NepseFeeService.calculateWACC(
          units: units,
          buyPrice: price,
          transactionType: _transactionType,
        );
      });
    } else {
      setState(() => _feePreview = null);
    }
  }

  void _filterStocks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStocks = [];
        return;
      }
      _filteredStocks = _allStocks.where((s) {
        final symbol = s['symbol'].toString().toLowerCase();
        final name = s['name'].toString().toLowerCase();
        final q = query.toLowerCase();
        return symbol.contains(q) || name.contains(q);
      }).toList();
    });
  }

  void _selectStock(Map<String, dynamic> stock) {
    setState(() {
      _selectedSymbol = stock['symbol'];
      _selectedName = stock['name'];
      _selectedSector = stock['sector'];
      _selectedLTP = (stock['ltp'] as num).toDouble(); // ✅ capture LTP
      _searchController.text = '${stock['symbol']} - ${stock['name']}';
      _filteredStocks = [];
    });
    _recalculate();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _buyDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _buyDate = picked);
  }

  void _submit() {
    if (_selectedSymbol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a stock')),
      );
      return;
    }
    if (_transactionType != 'bonus' &&
        (_unitsController.text.isEmpty || _priceController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter units and buy price')),
      );
      return;
    }
    if (_transactionType == 'bonus' && _unitsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter number of bonus units')),
      );
      return;
    }

    widget.onAdd({
      'symbol': _selectedSymbol,
      'name': _selectedName,
      'sector': _selectedSector,
      'transactionType': _transactionType,
      'units': _unitsController.text,
      'buyPrice': _transactionType == 'bonus' ? '0' : _priceController.text,
      'buyDate': _buyDate.toIso8601String().split('T')[0],
      // ✅ Pass the stock's market LTP so backend stores correct LTP
      // instead of defaulting to buyPrice
      'ltp': _selectedLTP?.toString() ?? _priceController.text,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Stock',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Stock Search ─────────────────────────────────────
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Search Stock (symbol or name)'),
                onChanged: _filterStocks,
              ),
              if (_filteredStocks.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredStocks.length,
                    itemBuilder: (_, index) {
                      final s = _filteredStocks[index];
                      return ListTile(
                        title: Text(s['symbol'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(s['name'],
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 12)),
                        trailing: Text(
                          'LTP: ${s['ltp']}',
                          style: const TextStyle(
                              color: Colors.greenAccent, fontSize: 12),
                        ),
                        onTap: () => _selectStock(s),
                      );
                    },
                  ),
                ),

              // ── Show selected stock LTP ──────────────────────────
              if (_selectedSymbol != null && _selectedLTP != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.show_chart, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Market LTP: ${_currencyFormat.format(_selectedLTP)}',
                        style: const TextStyle(color: Colors.green, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // ── Transaction Type ──────────────────────────────────
              DropdownButtonFormField<String>(
                value: _transactionType,
                dropdownColor: Colors.grey[800],
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Transaction Type'),
                items: const [
                  DropdownMenuItem(value: 'secondary', child: Text('Secondary Market')),
                  DropdownMenuItem(value: 'ipo',       child: Text('IPO')),
                  DropdownMenuItem(value: 'fpo',       child: Text('FPO')),
                  DropdownMenuItem(value: 'right',     child: Text('Right Share')),
                  DropdownMenuItem(value: 'bonus',     child: Text('Bonus Share')),
                ],
                onChanged: (v) {
                  setState(() => _transactionType = v!);
                  _recalculate();
                },
              ),
              const SizedBox(height: 12),

              // ── Buy Date ──────────────────────────────────────────
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: _inputDecoration('Buy Date'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _buyDate.toIso8601String().split('T')[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Icon(Icons.calendar_today,
                          color: Colors.grey, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Units & Buy Price ─────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _unitsController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Units'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration(
                        _transactionType == 'bonus'
                            ? 'Price (N/A)'
                            : 'Buy Price (NPR)',
                      ),
                      enabled: _transactionType != 'bonus',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── WACC Preview ──────────────────────────────────────
              if (_feePreview != null) _buildWaccPreview(_feePreview!),
              if (_transactionType == 'bonus')
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bonus shares are free. WACC = NPR 0.',
                          style:
                              TextStyle(color: Colors.blue[300], fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // ── Submit ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add to Portfolio',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaccPreview(NepseFeeResult fee) {
    final units = int.tryParse(_unitsController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final investment = units * price;
    final isBonusOrFree = fee.totalCost == 0;

    // ✅ Show P/L preview if LTP is available
    final ltpPL = _selectedLTP != null && fee.costPerShare > 0
        ? (_selectedLTP! - fee.costPerShare) * units
        : null;
    final ltpPLPositive = ltpPL != null && ltpPL >= 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_outlined,
                  color: Colors.greenAccent, size: 16),
              const SizedBox(width: 6),
              Text(
                'WACC Preview — ${NepseFeeService.transactionLabel(_transactionType)}',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!isBonusOrFree) ...[
            _feeRow('Investment', _currencyFormat.format(investment)),
            if (fee.brokerCommission > 0)
              _feeRow(
                'Broker Commission (${(fee.brokerRate * 100).toStringAsFixed(2)}%)',
                _currencyFormat.format(fee.brokerCommission),
              ),
            if (fee.nepseCommission > 0)
              _feeRow('NEPSE Commission (20%)',
                  _currencyFormat.format(fee.nepseCommission)),
            _feeRow('SEBON Fee (0.015%)',
                _currencyFormat.format(fee.sebonFee)),
            _feeRow('DP Charge', _currencyFormat.format(fee.dpCharge)),
            const Divider(color: Colors.grey),
            _feeRow('Total Fees', _currencyFormat.format(fee.totalFees),
                highlight: true),
            _feeRow('Total Cost', _currencyFormat.format(fee.totalCost),
                highlight: true),
          ],
          const SizedBox(height: 4),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your WACC',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text(
                  isBonusOrFree
                      ? 'NPR 0.00'
                      : _currencyFormat.format(fee.costPerShare),
                  style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ],
            ),
          ),

          // ✅ Instant P/L preview based on current LTP vs WACC
          if (ltpPL != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ltpPLPositive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ltpPLPositive
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'P/L at current LTP',
                    style: TextStyle(
                      color: ltpPLPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${ltpPLPositive ? '+' : ''}${_currencyFormat.format(ltpPL)}',
                    style: TextStyle(
                      color: ltpPLPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _feeRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                color: highlight ? Colors.white : Colors.grey[400],
                fontSize: 12,
                fontWeight:
                    highlight ? FontWeight.bold : FontWeight.normal,
              )),
          Text(value,
              style: TextStyle(
                color: highlight ? Colors.white : Colors.grey[300],
                fontSize: 12,
                fontWeight:
                    highlight ? FontWeight.bold : FontWeight.normal,
              )),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}