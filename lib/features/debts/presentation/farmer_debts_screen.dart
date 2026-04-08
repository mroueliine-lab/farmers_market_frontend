import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/debt_provider.dart';
import '../../../core/providers.dart';
import '../../../core/error_handler.dart';

class FarmerDebtsScreen extends ConsumerStatefulWidget {
  final int farmerId;
  const FarmerDebtsScreen({super.key, required this.farmerId});

  @override
  ConsumerState<FarmerDebtsScreen> createState() => _FarmerDebtsScreenState();
}

class _FarmerDebtsScreenState extends ConsumerState<FarmerDebtsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.invalidate(farmerDebtsProvider(widget.farmerId)));
  }

  @override
  Widget build(BuildContext context) {
    final debtsAsync = ref.watch(farmerDebtsProvider(widget.farmerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Debts'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: debtsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(ErrorHandler.getMessage(e))),
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
        onPressed: () => _showRepaymentDialog(context),
        icon: const Icon(Icons.payments),
        label: const Text('Record Repayment'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showRepaymentDialog(BuildContext context) {
    final kgController = TextEditingController();
    final settings = ref.read(settingsProvider).value;
    final rate = double.tryParse(settings?['commodity_rate']?.toString() ?? '0') ?? 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record Repayment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current rate: $rate FCFA/kg',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: kgController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
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
            onPressed: () {
              final kg = double.tryParse(kgController.text);
              if (kg == null || kg <= 0) return;
              final fcfaPreview = kg * rate;
              Navigator.pop(ctx);
              // Step 2: Confirmation dialog
              showDialog(
                context: context,
                builder: (ctx2) => AlertDialog(
                  title: const Text('Confirm Repayment'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _confirmRow('Kg received', '$kg kg'),
                      _confirmRow('Rate', '$rate FCFA/kg'),
                      const Divider(),
                      _confirmRow('FCFA credited',
                          '${fcfaPreview.toStringAsFixed(0)} FCFA',
                          bold: true),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx2),
                      child: const Text('Back'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx2);
                        try {
                          final result = await ref
                              .read(debtRepositoryProvider)
                              .recordRepayment(
                                farmerId: widget.farmerId,
                                kgReceived: kg,
                              );
                          ref.invalidate(farmerDebtsProvider(widget.farmerId));
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Row(children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Repayment Recorded'),
                                ]),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _confirmRow('Kg received',
                                        '${result['kg_received']} kg'),
                                    _confirmRow('Rate used',
                                        '${result['commodity_rate']} FCFA/kg'),
                                    _confirmRow('FCFA credited',
                                        '${result['fcfa_value']} FCFA',
                                        bold: true),
                                  ],
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Done'),
                                  ),
                                ],
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ErrorHandler.show(context, e);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Preview'),
          ),
        ],
      ),
    );
  }

  Widget _confirmRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
