import 'package:admin_panel_medlab/bloc/product-bloc/product_bloc.dart';
import 'package:admin_panel_medlab/bloc/product-bloc/product_events.dart';
import 'package:admin_panel_medlab/bloc/product-bloc/product_states.dart';
import 'package:flutter/material.dart';
import 'package:admin_panel_medlab/models/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Assuming your Product model is here

class CreateEditProductScreen extends StatefulWidget {
  final Product? productToEdit; // Null if creating, has value if editing

  const CreateEditProductScreen({super.key, this.productToEdit});

  @override
  State<CreateEditProductScreen> createState() =>
      _CreateEditProductScreenState();
}

class _CreateEditProductScreenState extends State<CreateEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Editing Controllers for each field
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _dosageFormController;
  late TextEditingController _strengthController;
  late TextEditingController _categoryController;
  // Ingredients might be handled differently (e.g., chip input, multi-select)
  // For simplicity, let's use a comma-separated string for now.
  late TextEditingController _ingredientsController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _manufacturerController;
  late TextEditingController _expiryDateController; // Consider a DatePicker
  late TextEditingController _instructionsController;

  bool _prescriptionRequired = false;
  bool _isLoading = false; // For a loading indicator when saving

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing product data if editing, or empty if creating
    final p = widget.productToEdit;
    _nameController = TextEditingController(text: p?.name ?? '1');
    _brandController = TextEditingController(text: p?.brand ?? '2');
    _descriptionController = TextEditingController(text: p?.description ?? '3');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '4');
    _dosageFormController = TextEditingController(text: p?.dosageForm ?? '5');
    _strengthController = TextEditingController(text: p?.strength ?? '6');
    _categoryController = TextEditingController(text: p?.category ?? '7');
    _ingredientsController = TextEditingController(
      text: p?.ingredients?.join(', ') ?? '8',
    ); // Join list to string
    _priceController = TextEditingController(text: p?.price.toString() ?? '9');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '10');
    _manufacturerController = TextEditingController(
      text: p?.manufacturer ?? '11',
    );
    _expiryDateController = TextEditingController(
      text: p?.expiryDate ?? '',
    ); // Could use a DatePicker later
    _instructionsController = TextEditingController(
      text: p?.instructions ?? '12',
    );
    _prescriptionRequired = p?.prescriptionRequired ?? false;
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _dosageFormController.dispose();
    _strengthController.dispose();
    _categoryController.dispose();
    _ingredientsController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _manufacturerController.dispose();
    _expiryDateController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Triggers onSaved for FormFields if used

      setState(() {
        _isLoading = true; // Show loading indicator
      });

      // Construct the Product object (or a DTO for API)
      // For now, just printing. Later, call BLoC event / Service method.
      final isEditing = widget.productToEdit != null;
      final productId = isEditing
          ? widget.productToEdit!.id
          : UniqueKey().toString(); // Generate new ID if creating

      final productData = Product(
        id: productId,
        name: _nameController.text.trim(),
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        dosageForm: _dosageFormController.text.trim().isEmpty
            ? null
            : _dosageFormController.text.trim(),
        strength: _strengthController.text.trim().isEmpty
            ? null
            : _strengthController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        ingredients: _ingredientsController.text.trim().isEmpty
            ? null
            : _ingredientsController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        stock: int.tryParse(_stockController.text) ?? 0,
        prescriptionRequired: _prescriptionRequired,
        manufacturer: _manufacturerController.text.trim().isEmpty
            ? null
            : _manufacturerController.text.trim(),
        expiryDate: _expiryDateController.text.trim().isEmpty
            ? null
            : _expiryDateController.text.trim(),
        instructions: _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
      );

      print('Saving Product: ${productData.name}');
      print('Is Editing: $isEditing');
      // In a real app:
      if (isEditing) {
        // context.read<ProductBloc>().add(UpdateProductEvent(productData));
      } else {
        context.read<ProductBloc>().add(
          CreateProductEvent(product: productData),
        ); // Might not need ID here
      }

      final result = await BlocProvider.of<ProductBloc>(context).stream
          .firstWhere(
            (state) => state is ProductsLoaded || state is ProductError,
          );

      if (!mounted) return;

      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      if (result is ProductError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (result is ProductsLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Product ${isEditing ? "updated" : "created"} successfully!',
            ),
          ),
        );
        Navigator.of(context).pop(); // Go back after saving
      }

      // // Simulate save and pop
      // Future.delayed(const Duration(seconds: 1), () {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text(
      //           'Product ${isEditing ? "updated" : "created"} successfully (simulated)!',
      //         ),
      //       ),
      //     );
      //     Navigator.of(context).pop(); // Go back after "saving"
      //   }
      // });
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productToEdit != null;
    final appBarTitle = isEditing ? 'Edit Product' : 'Create Product';

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
              onPressed: _saveProduct,
              tooltip: 'Save Product',
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
                controller: _nameController,
                labelText: 'Product Name',
                icon: Icons.medication,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter product name'
                    : null,
              ),
              _buildTextFormField(
                controller: _brandController,
                labelText: 'Brand',
                icon: Icons.branding_watermark,
              ),
              _buildTextFormField(
                controller: _descriptionController,
                labelText: 'Description',
                icon: Icons.description,
                maxLines: 3,
              ),
              _buildTextFormField(
                controller: _imageUrlController,
                labelText: 'Image URL',
                icon: Icons.image,
                keyboardType: TextInputType.url,
              ),
              _buildTextFormField(
                controller: _dosageFormController,
                labelText: 'Dosage Form (e.g., Tablet, Syrup)',
                icon: Icons.science,
              ),
              _buildTextFormField(
                controller: _strengthController,
                labelText: 'Strength (e.g., 500mg)',
                icon: Icons.fitness_center,
              ),
              _buildTextFormField(
                controller: _categoryController,
                labelText: 'Category',
                icon: Icons.category,
              ),
              _buildTextFormField(
                controller: _ingredientsController,
                labelText: 'Ingredients (comma-separated)',
                icon: Icons.eco,
              ),
              _buildTextFormField(
                controller: _priceController,
                labelText: 'Price',
                icon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _stockController,
                labelText: 'Stock Quantity',
                icon: Icons.inventory_2,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid integer';
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: const Text('Prescription Required'),
                secondary: const Icon(Icons.receipt_long),
                value: _prescriptionRequired,
                onChanged: (bool value) {
                  setState(() {
                    _prescriptionRequired = value;
                  });
                },
              ),
              _buildTextFormField(
                controller: _manufacturerController,
                labelText: 'Manufacturer',
                icon: Icons.factory,
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
              _buildTextFormField(
                controller: _instructionsController,
                labelText: 'Instructions',
                icon: Icons.integration_instructions,
                maxLines: 3,
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
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
                        isEditing ? 'Update Product' : 'Create Product',
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
