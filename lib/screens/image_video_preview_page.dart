import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ImageVideoPreviewPage extends StatelessWidget {
  final List<String> imageUrls; // List of image URLs
  final List<String> videoUrls; // List of video URLs

  const ImageVideoPreviewPage({
    Key? key,
    required this.imageUrls,
    required this.videoUrls,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Combine images and videos into one list with indicators
    final List<Widget> mediaItems = [
      ...imageUrls.map((url) => _buildImage(url)).toList(),
      ...videoUrls.map((url) => _buildVideo(url)).toList(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Viewer'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: mediaItems.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: mediaItems[index],
          );
        },
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, size: 50),
        ),
      ),
    );
  }

  Widget _buildVideo(String videoUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: VideoPlayerWidget(videoUrl: videoUrl),
    );
  }
}

// Video Player Widget
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play(); // Auto-play the video
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        : const Center(child: CircularProgressIndicator());
  }
}
