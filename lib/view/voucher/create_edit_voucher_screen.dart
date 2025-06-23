import 'dart:math';

import 'package:admin_panel_medlab/bloc/voucher-bloc/voucher_bloc.dart';
import 'package:admin_panel_medlab/bloc/voucher-bloc/voucher_events.dart';
import 'package:admin_panel_medlab/bloc/voucher-bloc/voucher_states.dart';
import 'package:flutter/material.dart';
import 'package:admin_panel_medlab/models/voucher_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Assuming your Voucher model is here

class CreateEditVoucherScreen extends StatefulWidget {
  final Voucher? voucherToEdit; // Null if creating, has value if editing

  const CreateEditVoucherScreen({super.key, this.voucherToEdit});

  @override
  State<CreateEditVoucherScreen> createState() =>
      _CreateEditVoucherScreenState();
}

class _CreateEditVoucherScreenState extends State<CreateEditVoucherScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Editing Controllers for each field
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _codeController;
  late TextEditingController _discountController;
  late TextEditingController _expiryDateController;

  bool _isVisibleToUsers = true;
  bool _isLoading = false; // For a loading indicator when saving

  @override
  void initState() {
    super.initState();
    final p = widget.voucherToEdit;

    // Initialize controllers with existing values if editing
    _titleController = TextEditingController(text: p?.title ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _codeController = TextEditingController(text: p?.code ?? '');
    _discountController = TextEditingController(
      text: p?.discount.toString() ?? '',
    );
    _expiryDateController = TextEditingController(text: p?.expiryDate ?? '');

    _isVisibleToUsers = p?.isVisibleToUsers ?? true; // Default to true if null
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    _discountController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  void _saveVoucher() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Triggers onSaved for FormFields if used

      setState(() {
        _isLoading = true; // Show loading indicator
      });

      // Construct the Voucher object (or a DTO for API)
      // For now, just printing. Later, call BLoC event / Service method.
      final isEditing = widget.voucherToEdit != null;

      final voucherData = Voucher(
        id: isEditing ? widget.voucherToEdit!.id : "temp",
        title: _titleController.text,
        description: _descriptionController.text,
        code: _codeController.text,
        discount: double.tryParse(_discountController.text) ?? 0.0,
        expiryDate: _expiryDateController.text,
        isVisibleToUsers: _isVisibleToUsers,
      );

      print('Saving Voucher: ${voucherData.title}');
      print('Is Editing: $isEditing');
      // In a real app:
      if (isEditing) {
        context.read<VoucherBloc>().add(
          UpdateVoucherEvent(voucher: voucherData),
        );
      } else {
        context.read<VoucherBloc>().add(
          CreateVoucherEvent(voucher: voucherData),
        ); // Might not need ID here
      }

      final result = await BlocProvider.of<VoucherBloc>(context).stream
          .firstWhere(
            (state) => state is VouchersLoaded || state is VoucherError,
          );

      if (!mounted) return;

      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      if (result is VoucherError) {
        print('Error: ${result.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (result is VouchersLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Voucher ${isEditing ? "updated" : "created"} successfully!',
            ),
          ),
        );
        Navigator.of(context).pop(); // Go back after saving
      }
    }
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.tryParse(_expiryDateController.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null &&
        picked != DateTime.tryParse(_expiryDateController.text)) {
      setState(() {
        // Format the date as needed (e.g., YYYY-MM-DD)
        _expiryDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  String generateVoucherCode({int length = 12}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.voucherToEdit != null;
    final appBarTitle = isEditing ? 'Edit Voucher' : 'Create Voucher';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveVoucher,
              tooltip: 'Save Voucher',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            // Use ListView for scrollability if form is long
            children: <Widget>[
              _buildTextFormField(
                controller: _titleController = TextEditingController(
                  text: widget.voucherToEdit?.title ?? '',
                ),
                labelText: 'Title',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _descriptionController = TextEditingController(
                  text: widget.voucherToEdit?.description ?? '',
                ),
                labelText: 'Description',
                icon: Icons.description,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _codeController = TextEditingController(
                        text: widget.voucherToEdit?.code ?? '',
                      ),
                      labelText: 'Code',
                      icon: Icons.code,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a code';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Generate a random code when button is pressed
                      final newCode = generateVoucherCode();
                      _codeController.text = newCode;
                    },
                    child: const Text('Generate Code'),
                  ),
                ],
              ),
              _buildTextFormField(
                controller: _discountController = TextEditingController(
                  text: widget.voucherToEdit?.discount.toString() ?? '',
                ),
                labelText: 'Discount (%)',
                icon: Icons.percent,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a discount';
                  }
                  final discount = double.tryParse(value);
                  if (discount == null || discount < 0) {
                    return 'Please enter a valid discount';
                  }
                  return null;
                },
              ),
              InkWell(
                // Make the expiry date field tappable to show date picker
                onTap: () => _selectExpiryDate(context),
                child: IgnorePointer(
                  // Makes the TextField itself not focusable
                  child: _buildTextFormField(
                    controller: _expiryDateController,
                    labelText: 'Expiry Date (YYYY-MM-DD)',
                    icon: Icons.calendar_today,
                    readOnly: true, // Prevent keyboard from showing
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isVisibleToUsers,
                      onChanged: (value) {
                        setState(() {
                          _isVisibleToUsers = value ?? true;
                        });
                      },
                    ),
                    const Text('Visible to Users'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveVoucher,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    60,
                  ), // Make button wide
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        isEditing ? 'Update Voucher' : 'Create Voucher',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build TextFormFields consistently
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
        ),
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: readOnly
            ? () => _selectExpiryDate(context)
            : null, // Trigger date picker if readOnly is for date
      ),
    );
  }
}
