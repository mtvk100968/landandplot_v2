import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late final PropertyProvider _provider;

  final indianFormat = NumberFormat.decimalPattern('en_IN');

  @override
  void initState() {
    super.initState();
    // 1) Grab the provider exactly once here:
    _provider = Provider.of<PropertyProvider>(context, listen: false);

    // 2) Register listener
    _provider.addListener(_updateFields);

    // 3) Initialize controllers from _provider
    _areaController = TextEditingController(
      text: _provider.area > 0 ? indianFormat.format(_provider.area) : '',
    );

    _pricePerUnitController = TextEditingController(
      text: _provider.pricePerUnit > 0
          ? indianFormat.format(_provider.pricePerUnit)
          : '',
    );

    _totalPriceController = TextEditingController(
      text: _provider.totalPrice > 0
          ? indianFormat.format(_provider.totalPrice)
          : '',
    );
  }

  void _updateFields() {
    // 4) Only call setState if we’re still mounted
    setState(() {
      _totalPriceController.text = _provider.totalPrice > 0
          ? indianFormat.format(_provider.totalPrice)
          : '';
    });
  }

  @override
  void dispose() {
    // 5) Remove listener on the same instance — no context lookup here!
    _provider.removeListener(_updateFields);
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

  /// Build a row of ChoiceChips for BHK selection
  Widget _buildBhkSelection() {
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final bhkOptions = ["1 BHK", "2 BHK", "3 BHK", "4 BHK", "5 BHK", "6 BHK"];

    return Wrap(
      spacing: 8.0,
      children: bhkOptions.map((option) {
        int bhkValue =
            int.parse(option.split(' ')[0]); // ✅ Extract integer value
        bool isSelected =
            propertyProvider.bedRooms == bhkValue; // ✅ Compare int values

        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              propertyProvider.setBedRooms(bhkValue); // ✅ Pass int correctly
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildBathSelection() {
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final bathOptions = ["1 Bath", "2 Bath", "3 Bath", "4 Bath", "5+ Bath"];

    return Wrap(
      spacing: 8.0,
      children: bathOptions.map((option) {
        int currentBathRooms =
            propertyProvider.bathRooms ?? 0; // ✅ Ensure it's an int

        bool isSelected = option == "5+ Bath"
            ? currentBathRooms >= 5 // ✅ Handle 4+ case correctly
            : currentBathRooms ==
                int.parse(option.split(' ')[0]); // ✅ Convert from String to int

        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              int newValue = option == "5+ Bath"
                  ? 4
                  : int.parse(
                      option.split(' ')[0]); // ✅ Convert from String to int
              propertyProvider
                  .setBathRooms(newValue); // ✅ Now passing an int correctly
            }
          },
        );
      }).toList(),
    );
  }

  /// Build a row of ChoiceChips for parkingSpots selection
  Widget _buildparkingSpotsSelection() {
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final pksOptions = ["1 PKS", "2 PKS", "3 PKS", "4 PKS"];

    return Wrap(
      spacing: 8.0,
      children: pksOptions.map((option) {
        int pksValue =
            int.parse(option.split(' ')[0]); // ✅ Extract integer value
        bool isSelected =
            propertyProvider.parkingSpots == pksValue; // ✅ Compare int values

        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              propertyProvider
                  .setparkingSpots(pksValue); // ✅ Pass int correctly
            }
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);
    // final isAgri = propertyProvider.propertyType.toLowerCase() == 'agri land';
    final type = propertyProvider.propertyType.toLowerCase();

    final isDevelopment =
        ['development', 'development_plot', 'development_land'].contains(type);
    final isDevelopmentLand = type == 'development_land';
    final isDevelopmentPlot = type == 'development_plot';
    final isAgri = type == 'agri land';

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
                if (isDevelopment) ...[
                  DropdownButtonFormField<String>(
                    value: ['development_plot', 'development_land']
                            .contains(propertyProvider.propertyType)
                        ? propertyProvider.propertyType
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Select Development Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'development_plot',
                          child: Text('Development Plot')),
                      DropdownMenuItem(
                          value: 'development_land',
                          child: Text('Development Land')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        propertyProvider.setPropertyType(value);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
                // TextFormField(
                //   controller: _areaController,
                //   decoration: InputDecoration(
                //     labelText: isDevelopmentLand || isAgri
                //         ? 'Area (in acres)'
                //         : 'Area (in sqyds)',
                //   ),
                //   keyboardType:
                //       const TextInputType.numberWithOptions(decimal: true),
                //   validator: Validators.areaValidator,
                //   onChanged: (value) {
                //     String formattedValue = _formatToIndianSystem(value);
                //     _areaController.value = TextEditingValue(
                //       text: formattedValue,
                //       selection: TextSelection.collapsed(
                //           offset: formattedValue.length),
                //     );
                //     double? parsedValue =
                //         double.tryParse(value.replaceAll(',', ''));
                //     propertyProvider.setArea(parsedValue ?? 0.0);
                //   },
                // ),

                TextFormField(
                  controller: _areaController,
                  decoration: InputDecoration(
                    labelText: isDevelopmentLand || isAgri
                        ? 'Area (in acres)'
                        : 'Area (in sqyds)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    // 1) allow only digits and at most one decimal point:
                    FilteringTextInputFormatter.allow(RegExp(r'\d+\.?\d*')),
                    // 2) cap the total length to 10 characters:
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: Validators.areaValidator,
                  onChanged: (value) {
                    // strip commas before parsing
                    final raw = value.replaceAll(',', '');
                    // re-format in Indian style
                    final formatted = _formatToIndianSystem(raw);
                    // update the field, keeping the cursor at the end
                    _areaController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                    // commit the numeric value to your provider
                    propertyProvider.setArea(double.tryParse(raw) ?? 0.0);
                  },
                ),

                const SizedBox(height: 20),
                if (isDevelopmentPlot || isDevelopmentLand) ...[
                  DropdownButtonFormField<String>(
                    value: propertyProvider.ownerBuilderShare,
                    decoration: const InputDecoration(
                      labelText: 'Select Owner Builder share split',
                      border: OutlineInputBorder(),
                    ),
                    items: ['50-50', '55-45', '60-40', '45-55', '40-60']
                        .map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        propertyProvider.setOwnerBuilderShare(value);
                      }
                    },
                    validator: Validators.requiredValidator,
                  ),
                  const SizedBox(height: 20),
                ],
                if (isDevelopmentLand) ...[
                  TextFormField(
                    controller: _totalPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Total Land Price (manual entry)',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      double? parsed =
                          double.tryParse(value.replaceAll(',', ''));
                      propertyProvider.setTotalPrice(parsed ?? 0);
                    },
                  ),

                  SizedBox(height: 20),

                  // Survey Number Field
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Survey Number'),
                    initialValue: propertyProvider.surveyNumber,
                    validator: Validators.surveyNumberValidator,
                    onChanged: (value) =>
                        propertyProvider.setSurveyNumber(value),
                  ),
                ] else ...[
                  // TextFormField(
                  //   controller: _pricePerUnitController,
                  //   decoration: InputDecoration(
                  //     labelText: isAgri ? 'Price per acre' : 'Price per sqyd',
                  //   ),
                  //   keyboardType:
                  //       TextInputType.numberWithOptions(decimal: true),
                  //   validator: Validators.priceValidator,
                  //   onChanged: (value) {
                  //     String formattedValue = _formatToIndianSystem(value);
                  //     _pricePerUnitController.value = TextEditingValue(
                  //       text: formattedValue,
                  //       selection: TextSelection.collapsed(
                  //         offset: formattedValue.length,
                  //       ),
                  //     );
                  //     double? parsedValue =
                  //         double.tryParse(value.replaceAll(',', ''));
                  //     propertyProvider.setPricePerUnit(parsedValue ?? 0.0);
                  //   },
                  // ),
                  TextFormField(
                    controller: _pricePerUnitController,
                    decoration: InputDecoration(
                      labelText: isAgri ? 'Price per acre' : 'Price per sqyd',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      // 1) only digits and an optional dot:
                      FilteringTextInputFormatter.allow(RegExp(r'\d+\.?\d*')),
                      // 2) no more than 10 characters total:
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: Validators.priceValidator,
                    onChanged: (value) {
                      // strip commas
                      final raw = value.replaceAll(',', '');
                      // format with Indian commas
                      final formatted = _formatToIndianSystem(raw);
                      // update the text field (and keep cursor at the end)
                      _pricePerUnitController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                      // parse the raw (un‐comma’d) number into your provider
                      propertyProvider.setPricePerUnit(double.tryParse(raw) ?? 0.0);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Total Land Price Field (Auto-calculated)
                  TextFormField(
                    controller: _totalPriceController,
                    decoration: InputDecoration(
                      labelText: 'Total Land Price (auto-calculated)',
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    enabled: false, // Auto-calculated
                  ),
                  SizedBox(height: 20),

                  // Survey Number Field
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Survey Number'),
                    initialValue: propertyProvider.surveyNumber,
                    validator: Validators.surveyNumberValidator,
                    onChanged: (value) =>
                        propertyProvider.setSurveyNumber(value),
                  ),

                  // Conditional Plot Numbers Field
                  if ([
                    'plot',
                    'farm land'
                  ].contains(propertyProvider.propertyType.toLowerCase())) ...[
                    // Plot Number
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Plot Number'),
                      validator: Validators.plotNumberValidator,
                      onChanged: (v) => propertyProvider.setPlotNumber(v),
                    ),

                    const SizedBox(height: 16),

                    // Venture Name
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Venture Name'),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Please enter venture name'
                          : null,
                      onChanged: (v) => propertyProvider.setVentureName(v),
                    ),

                    const SizedBox(height: 20),
                  ],

                  if (['agri land']
                      .contains(propertyProvider.propertyType.toLowerCase()))
                    ...[],

                  if ([
                    'house',
                    'villa',
                    'apartment'
                  ].contains(propertyProvider.propertyType.toLowerCase())) ...[
                    // House / Villa / Apartment Number
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'House/Villa/Apartment Number'),
                      validator: Validators.hvaNumberValidator,
                      onChanged: propertyProvider.setPlotNumber,
                    ),

                    const SizedBox(height: 16),

                    // Society Name
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Society Name'),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Please enter Society name'
                          : null,
                      onChanged: propertyProvider.setVentureName,
                    ),

                    const SizedBox(height: 16),

                    // 4) Bedrooms row
                    const Text("Bedrooms",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildBhkSelection(),
                    const SizedBox(height: 20),

                    // 5) Bathrooms row
                    const Text("Bathrooms",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildBathSelection(),
                    const SizedBox(height: 20),

                    // 4) parkingSpots row
                    const Text("parkingSpots",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildparkingSpotsSelection(),
                    const SizedBox(height: 20),

                    const SizedBox(height: 20),
                  ],

                  if ([
                    'commercial space'
                  ].contains(propertyProvider.propertyType.toLowerCase())) ...[
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Plot/Site Number'),
                      validator: Validators.plotNumberValidator,
                      onChanged: (v) => propertyProvider.setPlotNumber(v),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
