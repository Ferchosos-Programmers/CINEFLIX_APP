import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoScreen extends StatefulWidget {
  final String videoUrl;

  const VideoScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);

    try {
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: true,
        looping: false,
        allowedScreenSleep: false,
        autoInitialize: true,
        allowFullScreen: true,
        allowMuting: true,
        additionalOptions: (context) {
          return <OptionItem>[
            OptionItem(
              onTap: () {
                _videoPlayerController.seekTo(
                    _videoPlayerController.value.position -
                        Duration(seconds: 10));
              },
              iconData: Icons.replay_10,
              title: 'Rewind 10 seconds',
            ),
            OptionItem(
              onTap: () {
                _videoPlayerController.seekTo(
                    _videoPlayerController.value.position +
                        Duration(seconds: 10));
              },
              iconData: Icons.forward_10,
              title: 'Forward 10 seconds',
            ),
          ];
        },
      );

      setState(() {});
    } catch (e) {
      print('Error initializing video player: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load video')),
      );
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
      ),
      body: _chewieController != null &&
              _chewieController!.videoPlayerController.value.isInitialized
          ? Chewie(
              controller: _chewieController!,
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
