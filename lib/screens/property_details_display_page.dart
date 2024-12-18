import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/property_model.dart';
import 'image_video_preview_page.dart';

class PropertyDetailsDisplayPage extends StatefulWidget {
  final Property property;

  const PropertyDetailsDisplayPage({Key? key, required this.property})
      : super(key: key);

  @override
  State<PropertyDetailsDisplayPage> createState() =>
      _PropertyDetailsDisplayPageState();
}

class _PropertyDetailsDisplayPageState
    extends State<PropertyDetailsDisplayPage> {
  bool isFavorite = false; // State for heart icon toggle

  // Share property details
  void _shareProperty() {
    final String shareText =
        'Check out this property: ${widget.property.address}\n'
        'Price: ₹ ${widget.property.totalPrice}\n'
        'Location: ${widget.property.city}, ${widget.property.state}\n\n'
        'View more details in our app!';

    Share.share(shareText, subject: 'Property Details');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
        actions: [
          // Share Icon
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareProperty,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Property Images Section
              _buildImageCarousel(context), // Pass context here

        // Property Details Section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property Title and Type
              _buildTitleSection(),
              const Divider(height: 30),
              _buildDetailTile('Owner Name', widget.property.propertyOwner),
              _buildDetailTile('Mobile Number', widget.property.mobileNumber),
              _buildDetailTile('Property Type', widget.property.propertyType),
              _buildDetailTile('User Type', widget.property.userType),
              _buildDetailTile('Venture Name', widget.property.ventureName ?? 'N/A'),
              const Divider(height: 30),
              _buildDetailTile('Land Area', '${widget.property.landArea} Sq Yards'),
              _buildDetailTile('Price Per Unit', '₹ ${widget.property.pricePerUnit}'),
              _buildDetailTile('Total Price', '₹ ${widget.property.totalPrice}'),
              _buildDetailTile('Survey Number', widget.property.surveyNumber),
              _buildDetailTile('Plot Numbers', widget.property.plotNumbers.isNotEmpty ? widget.property.plotNumbers.join(', ') : 'N/A'),
              const Divider(height: 30),
              _buildDetailTile('District', widget.property.district ?? 'N/A'),
              _buildDetailTile('Mandal', widget.property.mandal ?? 'N/A'),
              _buildDetailTile('Village', widget.property.village ?? 'N/A'),
              _buildDetailTile('City', widget.property.city ?? 'N/A'),
              _buildDetailTile('Pincode', widget.property.pincode),
              _buildDetailTile('State', widget.property.state ?? 'N/A'),
              const Divider(height: 30),
              _buildDetailTile('Road Access', widget.property.roadAccess),
              _buildDetailTile('Road Type', widget.property.roadType),
              _buildDetailTile('Road Width', '${widget.property.roadWidth} meters'),
              _buildDetailTile('Land Facing', widget.property.landFacing),
              const SizedBox(height: 20),
              _buildMapLocation(context),
            ],
          ),
        ),
            ],
        ),
      ),
    );
  }

  // Image Carousel Section with Tap Action
  Widget _buildImageCarousel(BuildContext context) {
    return SizedBox(
      height: 400, // Fixed height for the image carousel
      width: double.infinity, // Full width
      child: GestureDetector(
        onTap: () {
          // Navigate to full-screen preview page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageVideoPreviewPage(
                imageUrls: widget.property.images,
                videoUrls: widget.property.videos,
              ),
            ),
          );
        },
        child: CarouselSlider(
          options: CarouselOptions(
            height: 400,
            viewportFraction: 1.0,
            autoPlay: false,
            enableInfiniteScroll: false,
          ),
          items: widget.property.images.isNotEmpty
              ? widget.property.images.map((imageUrl) {
            return ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  );
                },
              ),
            );
          }).toList()
              : [
            Image.asset(
              'assets/images/no_image_available.png',
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }

  // Section for Title
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.property.address ?? 'Property Details',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.property.propertyType,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  // Reusable Widget for Detail Tile
  Widget _buildDetailTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Map Location Display Section
  Widget _buildMapLocation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Map Location',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 400,
          width: double.infinity,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://maps.googleapis.com/maps/api/staticmap?center=${widget.property.latitude},${widget.property.longitude}&zoom=16&size=600x300&markers=color:red%7C${widget.property.latitude},${widget.property.longitude}&key=YOUR_GOOGLE_MAPS_API_KEY',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text('Map Preview Not Available'),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
