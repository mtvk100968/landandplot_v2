import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/property_provider.dart';
import '../../../../utils/validators.dart';

class Step2PropertyDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const Step2PropertyDetails({Key? key, required this.formKey})
      : super(key: key);

  @override
  _Step2PropertyDetailsState createState() => _Step2PropertyDetailsState();
}

class _Step2PropertyDetailsState extends State<Step2PropertyDetails> {
  late TextEditingController _totalPriceController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PropertyProvider>(context, listen: false);
    _totalPriceController = TextEditingController(
      text:
          provider.totalPrice > 0 ? provider.totalPrice.toStringAsFixed(2) : '',
    );

    // Listen to changes in totalPrice and update the controller
    provider.addListener(_updateTotalPrice);
  }

  void _updateTotalPrice() {
    final provider = Provider.of<PropertyProvider>(context, listen: false);
    String newText =
        provider.totalPrice > 0 ? provider.totalPrice.toStringAsFixed(2) : '';
    if (_totalPriceController.text != newText) {
      _totalPriceController.text = newText;
    }
  }

  @override
  void dispose() {
    final provider = Provider.of<PropertyProvider>(context, listen: false);
    provider.removeListener(_updateTotalPrice);
    _totalPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final isAgri = propertyProvider.propertyType.toLowerCase() == 'agri land';

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
        ),
        child: Form(
          key: widget.formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Area Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: isAgri ? 'Area (in acres)' : 'Area (in sqyds)',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  initialValue: propertyProvider.area > 0
                      ? propertyProvider.area.toString()
                      : '',
                  validator: Validators.areaValidator,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      propertyProvider.setArea(0.0);
                    } else {
                      double? parsedValue = double.tryParse(value);
                      if (parsedValue != null) {
                        propertyProvider.setArea(parsedValue);
                      }
                    }
                  },
                ),
                SizedBox(height: 20),

                // Price per Unit Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: isAgri ? 'Price per acre' : 'Price per sqyd',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  initialValue: propertyProvider.pricePerUnit > 0
                      ? propertyProvider.pricePerUnit.toString()
                      : '',
                  validator: Validators.priceValidator,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      propertyProvider.setPricePerUnit(0.0);
                    } else {
                      double? parsedValue = double.tryParse(value);
                      if (parsedValue != null) {
                        propertyProvider.setPricePerUnit(parsedValue);
                      }
                    }
                  },
                ),
                SizedBox(height: 20),

                // Total Land Price Field (Auto-calculated)
                TextFormField(
                  controller: _totalPriceController,
                  decoration: InputDecoration(
                    labelText: 'Total Land Price (auto-calculated)',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  enabled: false, // Auto-calculated
                ),
                SizedBox(height: 20),

                // Survey Number Field
                TextFormField(
                  decoration: InputDecoration(labelText: 'Survey Number'),
                  initialValue: propertyProvider.surveyNumber,
                  validator: Validators.surveyNumberValidator,
                  onChanged: (value) => propertyProvider.setSurveyNumber(value),
                ),

                // Conditional Plot Numbers Field
                if (propertyProvider.propertyType.toLowerCase() == 'plot') ...[
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Plot Numbers'),
                    validator: Validators.plotNumberValidator,
                    onChanged: (value) => propertyProvider.addPlotNumber(value),
                  ),
                ],
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
