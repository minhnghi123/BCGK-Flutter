import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store/index.dart';

class QuantityControl extends StatelessWidget {
  final String foodId;
  final int quantity;

  const QuantityControl({
    super.key,
    required this.foodId,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ControlButton(
          icon: Icons.remove,
          onTap: () => provider.decrementQuantity(foodId),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '$quantity',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        _ControlButton(
          icon: Icons.add,
          onTap: () => provider.incrementQuantity(foodId),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
