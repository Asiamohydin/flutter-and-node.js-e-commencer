import 'package:flutter/material.dart';
import 'package:app/core/theme.dart';
import 'package:app/models/product.dart';
import 'package:app/services/api_service.dart';
import 'package:iconsax/iconsax.dart';

import 'package:image_picker/image_picker.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _imageCtrl;
  late TextEditingController _stockCtrl;
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _descCtrl = TextEditingController(text: widget.product?.description ?? '');
    _priceCtrl = TextEditingController(text: widget.product?.price.toString() ?? '');
    _imageCtrl = TextEditingController(text: widget.product?.imageUrl ?? '');
    _stockCtrl = TextEditingController(text: widget.product?.stock.toString() ?? '0');
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isUploading = true);
    
    final bytes = await image.readAsBytes();
    final result = await _apiService.uploadImage(bytes, image.name);
    
    setState(() => _isUploading = false);

    if (result['success'] == true) {
      setState(() {
        _imageCtrl.text = result['imageUrl'];
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image uploaded from computer!")),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Upload failed")),
      );
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    final productData = {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': double.parse(_priceCtrl.text),
      'image_url': _imageCtrl.text.trim(),
      'stock': int.parse(_stockCtrl.text),
    };

    dynamic result;
    if (widget.product != null) {
      result = await _apiService.updateProduct(int.parse(widget.product!.id), productData);
    } else {
      result = await _apiService.createProduct(productData);
    }

    setState(() => _isLoading = false);

    if (result != null && (result['id'] != null || result['success'] == true)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.product != null ? "Product updated" : "Product created")),
      );
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result?['message'] ?? "Error saving product")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.product != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Product" : "Add Product", style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField("Product Name", _nameCtrl, Iconsax.box, "Enter name"),
              const SizedBox(height: 20),
              _buildField("Description", _descCtrl, Iconsax.document_text, "Enter description", maxLines: 3),
              const SizedBox(height: 20),
              _buildField("Price", _priceCtrl, Iconsax.money_3, "Enter price", keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              
              const Text("Product Image", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildField("", _imageCtrl, Iconsax.image, "Image URL (autofilled on upload)"),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickAndUploadImage,
                      icon: _isUploading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Iconsax.document_upload),
                      label: const Text("Upload"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ],
              ),
              if (_imageCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 15),
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[200]!, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      _imageCtrl.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.image, color: Colors.grey[300], size: 40),
                              const SizedBox(height: 10),
                              const Text("Invalid Image URL", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              _buildField("Stock", _stockCtrl, Iconsax.archive, "Enter stock count", keyboardType: TextInputType.number),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEdit ? "Update Product" : "Create Product", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, String error, {TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            hintText: error,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
          validator: (value) => value == null || value.isEmpty ? error : null,
        ),
      ],
    );
  }
}
