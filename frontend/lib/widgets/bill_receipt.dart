import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store/index.dart';

class BillReceipt extends StatelessWidget {
  const BillReceipt({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Card(
          margin: const EdgeInsets.all(12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bill Receipt',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _BillRow(
                  label: 'Items Total',
                  value: '₹${provider.itemsTotal.toStringAsFixed(2)}',
                ),
                _BillRow(
                  label: 'Offer Discount (1.7%)',
                  value: '-₹${provider.discount.toStringAsFixed(2)}',
                  valueColor: Colors.green,
                ),
                _BillRow(
                  label: 'Taxes (8%)',
                  value: '₹${provider.taxes.toStringAsFixed(2)}',
                ),
                _BillRow(
                  label: 'Delivery Charges',
                  value: '₹${provider.deliveryCharges.toStringAsFixed(0)}',
                ),
                const Divider(height: 24),
                _BillRow(
                  label: 'Total Pay',
                  value: '₹${provider.totalPay.toStringAsFixed(2)}',
                  bold: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _BillRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: bold ? 15 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            value,
            style: style.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
