import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/debt_provider.dart';

class FarmerDebtsScreen extends ConsumerWidget {
  final int farmerId;
  const FarmerDebtsScreen({super.key, required this.farmerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(farmerDebtsProvider(farmerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Debts'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: debtsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (debts) {
          if (debts.isEmpty) {
            return const Center(child: Text('No open debts'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: debts.length,
            itemBuilder: (context, index) {
              final debt = debts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Debt #${debt.id}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: debt.status == 'pending'
                                  ? Colors.red.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(debt.status,
                                style: TextStyle(
                                    color: debt.status == 'pending'
                                        ? Colors.red
                                        : Colors.orange)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Original:', style: TextStyle(color: Colors.grey)),
                          Text('${debt.originalAmountFcfa.toStringAsFixed(0)} FCFA'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Remaining:', style: TextStyle(color: Colors.grey)),
                          Text(
                            '${debt.remainingAmountFcfa.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRepaymentDialog(context, ref),
        icon: const Icon(Icons.payments),
        label: const Text('Record Repayment'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showRepaymentDialog(BuildContext context, WidgetRef ref) {
    final kgController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record Repayment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter commodity amount in kg:'),
            const SizedBox(height: 12),
            TextField(
              controller: kgController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (kg)',
                border: OutlineInputBorder(),
                suffixText: 'kg',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final kg = double.tryParse(kgController.text);
              if (kg == null || kg <= 0) return;
              Navigator.pop(ctx);
              try {
                final result = await ref.read(debtRepositoryProvider).recordRepayment(
                      farmerId: farmerId,
                      kgReceived: kg,
                    );
                ref.invalidate(farmerDebtsProvider(farmerId));
                if (context.mounted) {
                  final rate = result['commodity_rate'];
                  final fcfa = result['fcfa_value'];
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Repayment Recorded'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kg received: ${result['kg_received']} kg'),
                          Text('Rate used: $rate FCFA/kg'),
                          Text('FCFA credited: $fcfa FCFA'),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
