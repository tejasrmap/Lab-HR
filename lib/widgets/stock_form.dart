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

  static const List<String> categories = [
    'Electronics',
    'Stationery',
    'Hardware',
    'Grocery',
  ];

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
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Please fix the form errors before saving.'),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

      await _firestoreService.addStockItem(newItem);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Item "${newItem.sku} - ${newItem.itemName}" saved to Firestore!'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save to Firestore: ${e.toString()}'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_shopping_cart_rounded, color: Color(0xFF1E40AF), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add New Stock Item',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'All fields required',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Layout: Responsive 2-column grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 580;

                  return Column(
                    children: [
                      // Row 1: SKU & Item Name
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildSkuField()),
                            const SizedBox(width: 14),
                            Expanded(flex: 3, child: _buildNameField()),
                          ],
                        )
                      else ...[
                        _buildSkuField(),
                        const SizedBox(height: 14),
                        _buildNameField(),
                      ],
                      const SizedBox(height: 14),

                      // Row 2: Category & Unit Price
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildCategoryField()),
                            const SizedBox(width: 14),
                            Expanded(child: _buildPriceField()),
                          ],
                        )
                      else ...[
                        _buildCategoryField(),
                        const SizedBox(height: 14),
                        _buildPriceField(),
                      ],
                      const SizedBox(height: 14),

                      // Row 3: Quantity & Reorder Level
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildQuantityField()),
                          const SizedBox(width: 14),
                          Expanded(child: _buildReorderField()),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Save Item Button
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
                      : const Icon(Icons.cloud_upload_rounded, size: 20),
                  label: Text(
                    _isSaving ? 'Writing to Firestore...' : 'Save Stock Item',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E40AF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkuField() {
    return TextFormField(
      controller: _skuController,
      decoration: const InputDecoration(
        labelText: 'SKU *',
        hintText: 'e.g. STK-101',
        prefixIcon: Icon(Icons.tag_rounded, size: 20),
        helperText: 'STK- followed by 3 digits',
      ),
      textCapitalization: TextCapitalization.characters,
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return 'SKU is required';
        if (!RegExp(r'^STK-\d{3}$', caseSensitive: false).hasMatch(text)) {
          return 'Must be format STK-### (e.g. STK-101)';
        }
        return null;
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _itemNameController,
      decoration: const InputDecoration(
        labelText: 'Item Name *',
        hintText: 'e.g. USB C Cable',
        prefixIcon: Icon(Icons.inventory_2_outlined, size: 20),
        helperText: 'Minimum 3 characters',
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return 'Item name is required';
        if (text.length < 3) return 'Must be at least 3 characters';
        return null;
      },
    );
  }

  Widget _buildCategoryField() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category *',
        prefixIcon: Icon(Icons.category_outlined, size: 20),
      ),
      hint: const Text('Select category'),
      items: categories.map((cat) {
        return DropdownMenuItem<String>(value: cat, child: Text(cat));
      }).toList(),
      onChanged: (val) => setState(() => _selectedCategory = val),
      validator: (val) => (val == null || val.isEmpty) ? 'Category is required' : null,
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _unitPriceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Unit Price (RM) *',
        hintText: 'e.g. 19.90',
        prefixText: 'RM ',
        prefixIcon: Icon(Icons.payments_outlined, size: 20),
        helperText: 'Amount > 0',
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return 'Price required';
        final val = double.tryParse(text);
        if (val == null || val <= 0) return 'Must be positive number (> 0)';
        return null;
      },
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantityController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: 'Quantity *',
        hintText: 'e.g. 4',
        prefixIcon: Icon(Icons.numbers_rounded, size: 20),
        helperText: 'Integer >= 0',
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return 'Quantity required';
        final val = int.tryParse(text);
        if (val == null || val < 0) return 'Must be whole number >= 0';
        return null;
      },
    );
  }

  Widget _buildReorderField() {
    return TextFormField(
      controller: _reorderLevelController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: 'Reorder Level *',
        hintText: 'e.g. 5',
        prefixIcon: Icon(Icons.flag_outlined, size: 20),
        helperText: 'Integer >= 0',
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return 'Reorder level required';
        final val = int.tryParse(text);
        if (val == null || val < 0) return 'Must be whole number >= 0';
        return null;
      },
    );
  }
}
