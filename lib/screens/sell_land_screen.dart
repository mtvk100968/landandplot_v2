// lib/screens/sell_land_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/forms/sell_land_form.dart';
import '../models/property_model.dart';
import '../models/sell_land_form_data.dart';
import '../services/property_service.dart';
import '../utils/keys.dart';

class SellLandScreen extends StatelessWidget {
  const SellLandScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SellLandForm(
      onSubmit: (SellLandFormData data) async {
        // Retrieve the current user
        final user = FirebaseAuth.instance.currentUser;

        // Validate user authentication and selected location
        if (user != null && data.selectedLocation != null) {
          // Ensure at least one image is uploaded
          if (data.images.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please upload at least one image')),
            );
            return;
          }

          // Process Plot Numbers: Convert comma-separated string to List<String>
          List<String>? plotNumbersList;
          if (data.plotNumbers != null && data.plotNumbers!.isNotEmpty) {
            plotNumbersList = data.plotNumbers!
                .split(',')
                .map((e) => e.trim())
                .where((element) => element.isNotEmpty)
                .toList();
          }

          // Create a Property instance with the collected data
          Property newProperty = Property(
            id: '', // Will be set by Firestore
            userId: user.uid,
            name: data.name,
            mobileNumber: data.mobileNumber,
            propertyType: data.propertyType,
            landArea: data.landArea,
            pricePerUnit: data.pricePerUnit,
            totalPrice: data.totalPrice,
            surveyNumber: data.surveyNumber,
            plotNumbers: plotNumbersList,
            latitude: data.selectedLocation.latitude,
            longitude: data.selectedLocation.longitude,
            pincode: data.pincode,
            village: data.village,
            mandal: data.mandal,
            town: data.town,
            district: data.district,
            state: data.state,
            roadAccess: data.roadAccess,
            roadType: data.roadType,
            roadWidth: data.roadWidth,
            landFacing: data.landFacing,
            images: [], // To be populated after uploading
            videos: [], // To be populated after uploading
            documents: [], // To be populated after uploading
            propertyOwner: data.propertyOwner,
            propertyRegisteredBy: data.propertyRegisteredBy,
          );

          try {
            // Use PropertyService to add the property along with media
            PropertyService propertyService = PropertyService();

            String propertyId = await propertyService.addProperty(
                newProperty, data.images,
                videos: data.videos, documents: data.documents);

            if (propertyId.isNotEmpty) {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Property added successfully!')),
              );

              // Navigate to the Buy Land tab using the global bottomNavBarKey
              bottomNavBarKey.currentState?.switchTab(0);
            } else {
              // Show failure message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to add property.')),
              );
            }
          } catch (e) {
            // Handle any errors during the submission process
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add property: $e')),
            );
          }
        } else {
          // Inform the user to select a location if not done
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please select a location on the map')),
          );
        }
      },
    );
  }
}
