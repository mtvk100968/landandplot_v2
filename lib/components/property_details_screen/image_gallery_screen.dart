import 'package:flutter/material.dart';

class ImageGalleryScreen extends StatefulWidget {
  final List<String> images;

  const ImageGalleryScreen({
    Key? key,
    required this.images,
  }) : super(key: key);

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  bool isGridView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
            child: Text(
              isGridView ? 'List' : 'Grid',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      body: widget.images.isEmpty
          ? const Center(
              child: Text(
                "No images available",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : isGridView
              ? _buildGridView(widget.images)
              : _buildListView(widget.images),
    );
  }

  Widget _buildListView(List<String> images) {
    return ListView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Image.network(
            images[index],
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text("Image not available"),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<String> images) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Image.network(
          images[index],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text("Image not available"),
            );
          },
        );
      },
    );
  }
}
