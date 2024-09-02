import 'package:flutter/material.dart';

class SellLandForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController areaController;
  final TextEditingController priceController;
  final TextEditingController pricePerSqYardController;
  final VoidCallback onSubmit;

  const SellLandForm({super.key, 
    required this.formKey,
    required this.areaController,
    required this.priceController,
    required this.pricePerSqYardController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: areaController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Land Area (sq. yards)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Please enter land area' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Land Price',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Please enter land price' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: pricePerSqYardController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Price Per Sq. Yard',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Please enter price per sq. yard' : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}