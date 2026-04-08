import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/farmer_provider.dart';
import '../../../core/error_handler.dart';

class CreateFarmerScreen extends ConsumerStatefulWidget {
  const CreateFarmerScreen({super.key});

  @override
  ConsumerState<CreateFarmerScreen> createState() => _CreateFarmerScreenState();
}

class _CreateFarmerScreenState extends ConsumerState<CreateFarmerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _identifierController = TextEditingController();
  final _creditLimitController = TextEditingController();
  bool _loading = false;

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
  static final _phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _identifierController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(farmerRepositoryProvider).create(
            firstname: _firstnameController.text.trim(),
            lastname: _lastnameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            identifier: _identifierController.text.trim(),
            creditLimit: double.tryParse(_creditLimitController.text.trim()) ?? 0,
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ErrorHandler.show(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateRequired(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    if (!_phoneRegex.hasMatch(v.trim())) return 'Enter a valid phone number (8-15 digits)';
    return null;
  }

  String? _validateCreditLimit(String? v) {
    if (v == null || v.trim().isEmpty) return 'Credit limit is required';
    final amount = double.tryParse(v.trim());
    if (amount == null) return 'Enter a valid number';
    if (amount <= 0) return 'Credit limit must be greater than 0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Farmer'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_firstnameController, 'First Name',
                  validator: (v) => _validateRequired(v, 'First Name')),
              _field(_lastnameController, 'Last Name',
                  validator: (v) => _validateRequired(v, 'Last Name')),
              _field(_emailController, 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail),
              _field(_phoneController, 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone),
              _field(_identifierController, 'Identifier',
                  validator: (v) => _validateRequired(v, 'Identifier')),
              _field(_creditLimitController, 'Credit Limit (FCFA)',
                  keyboardType: TextInputType.number,
                  validator: _validateCreditLimit),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Farmer', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }
}
