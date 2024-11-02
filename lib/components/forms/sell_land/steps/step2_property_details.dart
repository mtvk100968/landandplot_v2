import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/property_provider.dart';
import '../../../../utils/validators.dart';

class Step2PropertyDetails extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const Step2PropertyDetails({Key? key, required this.formKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final isAgri = propertyProvider.propertyType == 'agri land';

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
        ),
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: isAgri ? 'Area (in acres)' : 'Area (in sqyds)',
                  ),
                  keyboardType: TextInputType.number,
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
                TextFormField(
                  decoration: InputDecoration(
                    labelText: isAgri ? 'Price per acre' : 'Price per sqyd',
                  ),
                  keyboardType: TextInputType.number,
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
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Total Land Price (auto-calculated)'),
                  keyboardType: TextInputType.number,
                  initialValue: propertyProvider.totalPrice > 0
                      ? propertyProvider.totalPrice.toString()
                      : '',
                  enabled: false, // Auto-calculated
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Survey Number'),
                  initialValue: propertyProvider.surveyNumber,
                  validator: Validators.surveyNumberValidator,
                  onChanged: (value) => propertyProvider.setSurveyNumber(value),
                ),
                if (propertyProvider.propertyType == 'plot') ...[
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
