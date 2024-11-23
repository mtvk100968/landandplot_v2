import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For number formatting
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
  late TextEditingController _areaController;
  late TextEditingController _pricePerUnitController;

  final indianFormat = NumberFormat.decimalPattern('en_IN');

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PropertyProvider>(context, listen: false);

    _areaController = TextEditingController(
      text: provider.area > 0 ? indianFormat.format(provider.area) : '',
    );

    _pricePerUnitController = TextEditingController(
      text: provider.pricePerUnit > 0
          ? indianFormat.format(provider.pricePerUnit)
          : '',
    );

    _totalPriceController = TextEditingController(
      text: provider.totalPrice > 0
          ? indianFormat.format(provider.totalPrice)
          : '',
    );

    provider.addListener(_updateFields);
  }

  void _updateFields() {
    final provider = Provider.of<PropertyProvider>(context, listen: false);

    setState(() {
      _totalPriceController.text = provider.totalPrice > 0
          ? indianFormat.format(provider.totalPrice)
          : '';
    });
  }

  @override
  void dispose() {
    final provider = Provider.of<PropertyProvider>(context, listen: false);
    provider.removeListener(_updateFields);
    _areaController.dispose();
    _pricePerUnitController.dispose();
    _totalPriceController.dispose();
    super.dispose();
  }

  String _formatToIndianSystem(String value) {
    if (value.isEmpty) return '';
    double? parsedValue = double.tryParse(value.replaceAll(',', ''));
    return parsedValue != null ? indianFormat.format(parsedValue) : value;
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
                  controller: _areaController,
                  decoration: InputDecoration(
                    labelText: isAgri ? 'Area (in acres)' : 'Area (in sqyds)',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: Validators.areaValidator,
                  onChanged: (value) {
                    String formattedValue = _formatToIndianSystem(value);
                    _areaController.value = TextEditingValue(
                      text: formattedValue,
                      selection: TextSelection.collapsed(
                        offset: formattedValue.length,
                      ),
                    );
                    double? parsedValue =
                        double.tryParse(value.replaceAll(',', ''));
                    propertyProvider.setArea(parsedValue ?? 0.0);
                  },
                ),
                SizedBox(height: 20),

                // Price per Unit Field
                TextFormField(
                  controller: _pricePerUnitController,
                  decoration: InputDecoration(
                    labelText: isAgri ? 'Price per acre' : 'Price per sqyd',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: Validators.priceValidator,
                  onChanged: (value) {
                    String formattedValue = _formatToIndianSystem(value);
                    _pricePerUnitController.value = TextEditingValue(
                      text: formattedValue,
                      selection: TextSelection.collapsed(
                        offset: formattedValue.length,
                      ),
                    );
                    double? parsedValue =
                        double.tryParse(value.replaceAll(',', ''));
                    propertyProvider.setPricePerUnit(parsedValue ?? 0.0);
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
                if (['plot', 'farm land']
                    .contains(propertyProvider.propertyType.toLowerCase())) ...[
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
