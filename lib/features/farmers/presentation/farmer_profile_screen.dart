import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/farmer_provider.dart';
import '../../cart/providers/cart_provider.dart';


class FarmerProfileScreen extends ConsumerWidget {
  final int farmerId;
  const FarmerProfileScreen({super.key, required this.farmerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmerAsync = ref.watch(farmerDetailProvider(farmerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: farmerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (farmer) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green,
                  child: Text(
                    farmer.firstname[0] + farmer.lastname[0],
                    style: const TextStyle(fontSize: 28, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(farmer.fullName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              _infoTile('Identifier', farmer.identifier),
              _infoTile('Phone', farmer.phoneNumber),
              _infoTile('Email', farmer.email),
              const Divider(height: 32),
              _infoTile('Credit Limit', '${farmer.creditLimit.toStringAsFixed(0)} FCFA'),
              _infoTile('Total Debt', '${farmer.totalDebt.toStringAsFixed(0)} FCFA',
                  valueColor: farmer.totalDebt > 0 ? Colors.red : Colors.green),
              _infoTile('Available Credit', '${farmer.availableCredit.toStringAsFixed(0)} FCFA',
                  valueColor: Colors.green),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
  ref.read(cartProvider.notifier).setFarmer(farmer);
  context.go('/cart');
},
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Start Sale'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/debts/${farmer.id}'),
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('View Debts'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: valueColor)),
        ],
      ),
    );
  }
}
