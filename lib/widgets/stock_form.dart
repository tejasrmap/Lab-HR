import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/stock_item.dart';
import '../services/firestore_service.dart';

class StockForm extends StatefulWidget {
  final VoidCallback? onItemSaved;

  const StockForm({super.key, this.onItemSaved});

  @override
  State<StockForm> createState() => _StockFormState();
}

class _StockFormState extends State<StockForm> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  // Permitted categories per specification
  static const List<String> categories = [
    'Electronics',
    'Stationery',
    'Hardware',
    'Grocery',
  ];

  // Controllers
  final _skuController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _reorderLevelController = TextEditingController();

  String? _selectedCategory;
  bool _isSaving = false;

  @override
  void dispose() {
    _skuController.dispose();
    _itemNameController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _reorderLevelController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // 1. Validate Form (gating any Firestore write)
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors in the form before saving.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final newItem = StockItem(
        id: '',
        sku: _skuController.text.trim().toUpperCase(),
        itemName: _itemNameController.text.trim(),
        category: _selectedCategory!,
        quantity: int.parse(_quantityController.text.trim()),
        unitPrice: double.parse(_unitPriceController.text.trim()),
        reorderLevel: int.parse(_reorderLevelController.text.trim()),
      );

      // Save to Firebase Cloud Firestore
      await _firestoreService.addStockItem(newItem);

      if (!mounted) return;

      // 2. Success feedback acknowledged
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item "${newItem.sku} - ${newItem.itemName}" saved to Firestore successfully!'),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 3),
        ),
      );

      // Clear the form only upon successful save
      _skuController.clear();
      _itemNameController.clear();
      _quantityController.clear();
      _unitPriceController.clear();
      _reorderLevelController.clear();
      setState(() {
        _selectedCategory = null;
      });
      _formKey.currentState?.reset();

      if (widget.onItemSaved != null) {
        widget.onItemSaved!();
      }
    } catch (e) {
      if (!mounted) return;
      // Do NOT clear form inputs on failure, show clear error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save to Firestore: ${e.toString()}'),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossFadeState.showFirst == CrossFadeState.showFirst
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.add_box_rounded, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Add New Stock Item',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // 1. SKU Field
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(
                  labelText: 'SKU *',
                  hintText: 'e.g. STK-101',
                  prefixIcon: Icon(Icons.qr_code),
                  border: OutlineInputBorder(),
                  helperText: 'Format: STK- followed by 3 digits',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'SKU is required';
                  }
                  final skuRegex = RegExp(r'^STK-\d{3}$', caseSensitive: false);
                  if (!skuRegex.hasMatch(text)) {
                    return 'Invalid SKU. Format must be STK- followed by 3 digits (e.g. STK-101)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. Item Name Field
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name *',
                  hintText: 'e.g. USB C Cable',
                  prefixIcon: Icon(Icons.inventory_2),
                  border: OutlineInputBorder(),
                  helperText: 'Minimum 3 characters',
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Item name is required';
                  }
                  if (text.length < 3) {
                    return 'Item name must be at least 3 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 3. Category Selector
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select category'),
                items: categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                  });
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 4. Quantity Field & 5. Reorder Level Field (in a row)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Quantity *',
                        hintText: 'e.g. 10',
                        prefixIcon: Icon(Icons.format_list_numbered),
                        border: OutlineInputBorder(),
                        helperText: 'Integer >= 0',
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Quantity is required';
                        }
                        final intVal = int.tryParse(text);
                        if (intVal == null || intVal < 0) {
                          return 'Enter whole number >= 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _reorderLevelController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Reorder Level *',
                        hintText: 'e.g. 5',
                        prefixIcon: Icon(Icons.notification_important_outlined),
                        border: OutlineInputBorder(),
                        helperText: 'Integer >= 0',
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Reorder level required';
                        }
                        final intVal = int.tryParse(text);
                        if (intVal == null || intVal < 0) {
                          return 'Enter whole number >= 0';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 6. Unit Price Field (RM)
              TextFormField(
                controller: _unitPriceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Unit Price (RM) *',
                  hintText: 'e.g. 19.90',
                  prefixText: 'RM ',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  helperText: 'Must be greater than 0',
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Unit price is required';
                  }
                  final doubleVal = double.tryParse(text);
                  if (doubleVal == null || doubleVal <= 0) {
                    return 'Price must be a valid positive number (> 0)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Save Item Button with Progress Indicator
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submitForm,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving ? 'Saving to Firestore...' : 'Save Item',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
