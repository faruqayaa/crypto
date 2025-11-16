import 'package:flutter/material.dart';
import '../models/crypto_model.dart';

class CryptoCard extends StatefulWidget {
  final CryptoModel coin;
  const CryptoCard({super.key, required this.coin});

  @override
  State<CryptoCard> createState() => _CryptoCardState();
}

class _CryptoCardState extends State<CryptoCard> {
  bool isRotated = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => isRotated = !isRotated);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: widget.coin.isUp ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.coin.isUp ? Colors.greenAccent : Colors.redAccent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedRotation(
              turns: isRotated ? 1 : 0,
              duration: const Duration(seconds: 1),
              child: Image.asset(
                widget.coin.icon,
                height: 48,
                width: 48,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.coin.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    widget.coin.symbol,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Text(
              "\$${widget.coin.price.toStringAsFixed(2)}",
              style: TextStyle(
                color: widget.coin.isUp ? Colors.greenAccent : Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )
          ],
        ),
      ),
    );
  }
}
