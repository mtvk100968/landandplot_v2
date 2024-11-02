import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../providers/property_provider.dart';

class Step5MediaUpload extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const Step5MediaUpload({Key? key, required this.formKey}) : super(key: key);

  @override
  _Step5MediaUploadState createState() => _Step5MediaUploadState();
}

class _Step5MediaUploadState extends State<Step5MediaUpload> {
  final Map<String, VideoPlayerController> _videoControllers = {};
  final ImagePicker _picker = ImagePicker();
  final Map<String, Future<String?>> _videoThumbnails = {};

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Helper method to show source selection for images
  Future<ImageSource?> _showImageSourceActionSheet(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Helper method to show source selection for videos
  Future<ImageSource?> _showVideoSourceActionSheet(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.video_library),
                title: Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(Icons.videocam),
                title: Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Method to pick images either from gallery or camera
  Future<void> _pickImages(
      BuildContext context, PropertyProvider propertyProvider) async {
    final ImageSource? source = await _showImageSourceActionSheet(context);
    if (source == null) return;

    if (source == ImageSource.camera) {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100, // Ensures high quality
      );
      if (photo != null) {
        propertyProvider.addImageUrl(photo.path);
        setState(() {});
      }
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );

      if (result != null) {
        for (var file in result.files) {
          if (file.path != null) {
            propertyProvider.addImageUrl(file.path!);
          }
        }
        setState(() {}); // Refresh UI after adding images
      }
    }
  }

  /// Method to pick videos either from gallery or camera
  Future<void> _pickVideos(
      BuildContext context, PropertyProvider propertyProvider) async {
    final ImageSource? source = await _showVideoSourceActionSheet(context);
    if (source == null) return;

    if (source == ImageSource.camera) {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: Duration(minutes: 10), // Adjust as needed
      );
      if (video != null) {
        propertyProvider.addVideoUrl(video.path);
        _generateVideoThumbnail(video.path);
        setState(() {});
      }
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.video,
      );

      if (result != null) {
        for (var file in result.files) {
          if (file.path != null) {
            propertyProvider.addVideoUrl(file.path!);
            _generateVideoThumbnail(file.path!);
          }
        }
        setState(() {}); // Refresh UI after adding videos
      }
    }
  }

  /// Method to pick documents from the device
  Future<void> _pickDocuments(
      BuildContext context, PropertyProvider propertyProvider) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      for (var file in result.files) {
        if (file.path != null) {
          propertyProvider.addDocumentUrl(file.path!);
        }
      }
      setState(() {}); // Refresh UI after adding documents
    }
  }

  /// Generate a thumbnail for the video
  Future<void> _generateVideoThumbnail(String videoPath) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String? thumbnail = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: tempDir.path,
      imageFormat: ImageFormat.PNG,
      maxWidth:
          128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    if (thumbnail != null) {
      _videoThumbnails[videoPath] = Future.value(thumbnail);
    }
  }

  /// Widget to build image thumbnails
  Widget _buildImageThumbnail(String url) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => FullScreenImageViewer(imagePath: url),
        ));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.file(
          File(url),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// Widget to build video thumbnails
  Widget _buildVideoThumbnail(String url) {
    return FutureBuilder<String?>(
      future: _videoThumbnails[url],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 100,
            height: 100,
            color: Colors.black12,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => FullScreenVideoPlayer(videoPath: url),
              ));
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    File(snapshot.data!),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Icon(Icons.play_circle_fill, color: Colors.white70, size: 30),
              ],
            ),
          );
        } else {
          // If thumbnail generation failed
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => FullScreenVideoPlayer(videoPath: url),
              ));
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.black12,
                  child: Icon(Icons.videocam, color: Colors.grey),
                ),
                Icon(Icons.play_circle_fill, color: Colors.white70, size: 30),
              ],
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImages(context, propertyProvider),
                  icon: Icon(Icons.photo_library),
                  label: Text('Add Images'),
                ),
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () => _pickImages(context, propertyProvider),
                  tooltip: 'Capture Image',
                ),
              ],
            ),
            SizedBox(height: 10),

            // Display selected images
            propertyProvider.imageUrls.isNotEmpty
                ? Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: propertyProvider.imageUrls.map((url) {
                      return Stack(
                        children: [
                          _buildImageThumbnail(url),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                propertyProvider.removeImageUrl(url);
                                setState(() {}); // Refresh UI after removal
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  )
                : Text('No images selected.'),

            SizedBox(height: 20),

            // Videos Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickVideos(context, propertyProvider),
                  icon: Icon(Icons.video_library),
                  label: Text('Add Videos'),
                ),
                IconButton(
                  icon: Icon(Icons.videocam),
                  onPressed: () => _pickVideos(context, propertyProvider),
                  tooltip: 'Capture Video',
                ),
              ],
            ),
            SizedBox(height: 10),

            // Display selected videos
            propertyProvider.videoUrls.isNotEmpty
                ? Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: propertyProvider.videoUrls.map((url) {
                      return Stack(
                        children: [
                          _buildVideoThumbnail(url),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                propertyProvider.removeVideoUrl(url);
                                setState(() {}); // Refresh UI after removal
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  )
                : Text('No videos selected.'),

            SizedBox(height: 20),

            // Documents Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickDocuments(context, propertyProvider),
                  icon: Icon(Icons.upload_file),
                  label: Text('Upload Documents'),
                ),
                // Optionally, add a button to clear all documents
              ],
            ),
            SizedBox(height: 10),

            // Display selected documents
            propertyProvider.documentUrls.isNotEmpty
                ? Column(
                    children: propertyProvider.documentUrls.map((url) {
                      return ListTile(
                        leading: Icon(Icons.insert_drive_file),
                        title: Text(url.split('/').last),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            propertyProvider.removeDocumentUrl(url);
                            setState(() {}); // Refresh UI after removal
                          },
                        ),
                        onTap: () {
                          // Optionally, implement document preview or opening
                        },
                      );
                    }).toList(),
                  )
                : Text('No documents uploaded.'),
          ],
        ),
      ),
    );
  }
}

/// Full-screen Image Viewer
class FullScreenImageViewer extends StatelessWidget {
  final String imagePath;

  const FullScreenImageViewer({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PhotoView(
        imageProvider: FileImage(File(imagePath)),
      ),
    );
  }
}

/// Full-screen Video Player
class FullScreenVideoPlayer extends StatefulWidget {
  final String videoPath;

  const FullScreenVideoPlayer({Key? key, required this.videoPath})
      : super(key: key);

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath));
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
    });
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: _initializeVideoPlayerFuture != null
            ? FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              )
            : CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child:
            Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}
