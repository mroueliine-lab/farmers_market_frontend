import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/farmer_provider.dart';
import 'package:go_router/go_router.dart';

class FarmerSearchScreen extends ConsumerStatefulWidget {
  const FarmerSearchScreen({super.key});

  @override
  ConsumerState<FarmerSearchScreen> createState() => _FarmerSearchScreenState();
}

class _FarmerSearchScreenState extends ConsumerState<FarmerSearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResult = ref.watch(farmerSearchProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Farmer'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by phone number or ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _query.isEmpty
                  ? const Center(child: Text('Enter a phone number or identifier'))
                  : searchResult.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (farmer) {
                        if (farmer == null) {
                          return const Center(child: Text('No farmer found'));
                        }
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(farmer.fullName),
                          subtitle: Text(farmer.identifier),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/farmers/${farmer.id}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/farmers/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Farmer'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }
}
