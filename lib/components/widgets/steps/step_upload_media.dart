// lib/components/forms/steps/step_upload_media.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class StepUploadMedia extends StatelessWidget {
  final List<File> images;
  final List<File> videos;
  final Function() onPickImages;
  final Function() onPickVideos;
  final Function(int) onRemoveImage;
  final Function(int) onRemoveVideo;

  const StepUploadMedia({
    super.key,
    required this.images,
    required this.videos,
    required this.onPickImages,
    required this.onPickVideos,
    required this.onRemoveImage,
    required this.onRemoveVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Upload Images Section
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Upload Images',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        images.isEmpty
            ? const Text('No images selected.')
            : SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: Image.file(
                            images[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            semanticLabel: 'Selected image ${index + 1}',
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => onRemoveImage(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                                semanticLabel: 'Remove image',
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: onPickImages,
          icon: const Icon(Icons.upload),
          label: const Text('Select Images'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Upload Videos Section
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Upload Videos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        videos.isEmpty
            ? const Text('No videos selected.')
            : SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.videocam,
                            size: 50,
                            color: Colors.black54,
                            semanticLabel: 'Selected video',
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => onRemoveVideo(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                                semanticLabel: 'Remove video',
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: onPickVideos,
          icon: const Icon(Icons.video_library),
          label: const Text('Select Videos'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
