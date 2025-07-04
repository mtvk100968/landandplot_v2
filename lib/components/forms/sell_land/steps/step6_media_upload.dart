import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../providers/property_provider.dart';

class Step6MediaUpload extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const Step6MediaUpload({super.key, required this.formKey});

  @override
  _Step6MediaUploadState createState() => _Step6MediaUploadState();
}

class _Step6MediaUploadState extends State<Step6MediaUpload> {
  final Map<String, VideoPlayerController> _videoControllers = {};
  final ImagePicker _picker = ImagePicker();
  final Map<String, Future<String?>> _videoThumbnails = {};

  @override
  void initState() {
    super.initState();

    // Safely access provider once without listening to it
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);

    for (var file in propertyProvider.videoFiles) {
      _generateVideoThumbnail(file.path);
    }
  }

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

  Future<void> _pickImages(
      BuildContext context, PropertyProvider propertyProvider) async {
    final ImageSource? source = await _showImageSourceActionSheet(context);
    if (source == null) return;

    const maxImageSizeMB = 20;
    const maxImageCount = 20;
    const maxCombinedSizeMB = 250;

    double currentTotalSize =
        propertyProvider.imageFiles.fold(0.0, (sum, f) => sum + f.lengthSync()) +
            propertyProvider.videoFiles.fold(0.0, (sum, f) => sum + f.lengthSync()) +
            propertyProvider.documentFiles.fold(0.0, (sum, f) => sum + f.lengthSync());

    currentTotalSize /= (1024 * 1024); // Convert to MB

    if (source == ImageSource.camera) {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (photo != null) {
        final file = File(photo.path);
        final fileSizeInMB = file.lengthSync() / (1024 * 1024);

        if (fileSizeInMB > maxImageSizeMB) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image is over $maxImageSizeMB MB and was skipped.')),
          );
          return;
        }

        if (propertyProvider.imageFiles.length >= maxImageCount) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can upload a maximum of 20 images.')),
          );
          return;
        }

        if (currentTotalSize + fileSizeInMB > maxCombinedSizeMB) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Adding this file exceeds total size limit (250 MB).')),
          );
          return;
        }

        if (propertyProvider.imageFiles.any((f) => f.path == file.path)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This image is already added.')),
          );
          return;
        }

        propertyProvider.addImageFile(file);
        setState(() {});
      }
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );

      if (result != null) {
        if (propertyProvider.imageFiles.length + result.files.length > maxImageCount) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can upload a maximum of 20 images.')),
          );
          return;
        }

        for (var file in result.files) {
          if (file.path != null) {
            final fileObj = File(file.path!);
            final fileSizeInMB = fileObj.lengthSync() / (1024 * 1024);

            if (fileSizeInMB > maxImageSizeMB) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${file.name} is over $maxImageSizeMB MB and was skipped.')),
              );
              continue;
            }

            if (currentTotalSize + fileSizeInMB > maxCombinedSizeMB) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${file.name} exceeds total upload limit (250 MB). Skipped.')),
              );
              continue;
            }

            if (propertyProvider.imageFiles.any((f) => f.path == file.path)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${file.name} is already added. Skipped.')),
              );
              continue;
            }

            propertyProvider.addImageFile(fileObj);
            currentTotalSize += fileSizeInMB;
          }
        }

        setState(() {});
      }
    }
  }

  Future<void> _pickVideos(
      BuildContext context, PropertyProvider propertyProvider) async {
    final ImageSource? source = await _showVideoSourceActionSheet(context);
    if (source == null) return;

    if (source == ImageSource.camera) {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 10),
      );
      if (video != null) {
        final file = File(video.path);
        final fileSizeInMB = file.lengthSync() / (1024 * 1024);

        if (fileSizeInMB > 75) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Captured video is over 50 MB and was skipped.')),
          );
          return;
        }

        if (propertyProvider.videoFiles.length >= 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can upload a maximum of 5 videos.')),
          );
          return;
        }

        propertyProvider.addVideoFile(file);
        _generateVideoThumbnail(file.path);
        setState(() {});
      }
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.video,
      );

      if (result != null) {
        // Check for max file count before processing
        if (propertyProvider.videoFiles.length + result.files.length > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can upload a maximum of 5 videos.')),
          );
          return;
        }

        for (var file in result.files) {
          if (file.path != null) {
            final fileObj = File(file.path!);
            final fileSizeInMB = fileObj.lengthSync() / (1024 * 1024);

            if (fileSizeInMB > 75) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${file.name} is over 50 MB and was skipped.')),
              );
              continue;
            }

            propertyProvider.addVideoFile(fileObj);
            _generateVideoThumbnail(file.path!);
          }
        }

        setState(() {});
      }
    }
  }

  /// Method to pick documents from the device
  Future<void> _pickDocuments(
      BuildContext context, PropertyProvider propertyProvider) async {
    const maxFileSizeMB = 50;
    const maxTotalDocs = 10;
    const maxCombinedSizeMB = 500;

    // Calculate current total size (images + videos + docs)
    double currentTotalSize =
        propertyProvider.imageFiles.fold(0.0, (sum, f) => sum + f.lengthSync()) +
            propertyProvider.videoFiles.fold(0.0, (sum, f) => sum + f.lengthSync()) +
            propertyProvider.documentFiles.fold(0.0, (sum, f) => sum + f.lengthSync());
    currentTotalSize /= (1024 * 1024); // Convert to MB

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
    );

    if (result != null) {
      // Check document count limit
      if (propertyProvider.documentFiles.length + result.files.length > maxTotalDocs) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can upload a maximum of 10 documents.')),
        );
        return;
      }

      for (var file in result.files) {
        if (file.path != null) {
          final fileObj = File(file.path!);
          final fileSizeMB = fileObj.lengthSync() / (1024 * 1024);

          // Skip if single file > 50 MB
          if (fileSizeMB > maxFileSizeMB) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${file.name} is over $maxFileSizeMB MB. Skipped.')),
            );
            continue;
          }

          // Skip if file already added
          if (propertyProvider.documentFiles.any((f) => f.path == file.path)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${file.name} is already added. Skipped.')),
            );
            continue;
          }

          // Skip if total combined size exceeds 250 MB
          if (currentTotalSize + fileSizeMB > maxCombinedSizeMB) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${file.name} exceeds total 250 MB limit. Skipped.')),
            );
            continue;
          }

          propertyProvider.addDocumentFile(fileObj);
          currentTotalSize += fileSizeMB;
        }
      }

      setState(() {}); // Refresh UI
    }
  }

  /// Generate a thumbnail for the video
  Future<void> _generateVideoThumbnail(String videoPath, {bool force = false}) async {
    if (!force && _videoThumbnails.containsKey(videoPath)) return;

    final Directory tempDir = await getTemporaryDirectory();
    final String thumbPath = '${tempDir.path}/${videoPath.hashCode}.png';

    final String? thumbnail = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: thumbPath,
      imageFormat: ImageFormat.PNG,
      maxWidth: 128,
      quality: 25,
    );

    if (thumbnail != null && !_videoThumbnails.containsKey(videoPath)) {
      _videoThumbnails[videoPath] = Future.value(thumbnail);
    }
  }

  /// Widget to build image thumbnails
  Widget _buildImageThumbnail(File file) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => FullScreenImageViewer(imagePath: file.path),
        ));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.file(
          file,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// Widget to build video thumbnails
  Widget _buildVideoThumbnail(File file) {
    String url = file.path;
    return FutureBuilder<String?>(
      future: _videoThumbnails[url],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 100,
            height: 100,
            color: Colors.black12,
            child: Center(child: Icon(Icons.videocam, size: 30, color: Colors.grey)),
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
            propertyProvider.imageFiles.isNotEmpty
                ? Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: propertyProvider.imageFiles.map((file) {
                      return Stack(
                        children: [
                          _buildImageThumbnail(file),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                propertyProvider.removeImageFile(file);
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
            propertyProvider.videoFiles.isNotEmpty
                ? Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: propertyProvider.videoFiles.map((file) {
                      return Stack(
                        children: [
                          _buildVideoThumbnail(file),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                propertyProvider.removeVideoFile(file);
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
            propertyProvider.documentFiles.isNotEmpty
                ? Column(
                    children: propertyProvider.documentFiles.map((file) {
                      return ListTile(
                        leading: Icon(Icons.insert_drive_file),
                        title: Text(file.path.split('/').last),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            propertyProvider.removeDocumentFile(file);
                            setState(() {}); // Refresh UI after removal
                          },
                        ),
                        onTap: () async {
                          final result = await OpenFile.open(file.path);
                          if (result.type != ResultType.done) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not open file: ${result.message}')),
                            );
                          }
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
                      aspectRatio: _controller.value.isInitialized
                          ? _controller.value.aspectRatio
                          : 16 / 9, // Default aspect ratio if not initialized
                      child: VideoPlayer(_controller),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error loading video');
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              )
            : Text('Unable to load video'), // Message if future is null
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
