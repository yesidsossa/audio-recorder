import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';

class AudioItemWidget extends StatefulWidget {
  final String name;
  final String url;

  const AudioItemWidget({super.key, required this.name, required this.url});

  @override
  _AudioItemWidgetState createState() => _AudioItemWidgetState();
}

class _AudioItemWidgetState extends State<AudioItemWidget> {
  FlutterSoundPlayer? _player;
  bool _isPlaying = false;
  bool _isPaused = false;
  double _progress = 0.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  StreamSubscription? _progressSubscription;

  @override
  void initState() {
    super.initState();
    _player = FlutterSoundPlayer();
    _player!.openPlayer();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _player!.pausePlayer();
      setState(() {
        _isPlaying = false;
        _isPaused = true;
      });
    } else if (_isPaused) {
      await _player!.resumePlayer();
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
    } else {
      await _player!.stopPlayer();
      _progressSubscription?.cancel();

      setState(() {
        _progress = 0.0;
        _position = Duration.zero;
        _duration = Duration.zero;
      });

      await _player!.setSubscriptionDuration(const Duration(milliseconds: 500));

      _progressSubscription = _player!.onProgress!.listen((event) {
        if (mounted) {
          setState(() {
            _position = event.position;
            _duration = event.duration;
            _progress = (_duration.inMilliseconds > 0)
                ? _position.inMilliseconds / _duration.inMilliseconds
                : 0.0;
          });
        }
      });

      await _player!.startPlayer(
        fromURI: widget.url,
        whenFinished: () {
          _progressSubscription?.cancel();
          if (mounted) {
            setState(() {
              _isPlaying = false;
              _progress = 0.0;
              _position = Duration.zero;
            });
          }
        },
      );

      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
    }
  }

  @override
  void dispose() {
    _player!.closePlayer();
    _progressSubscription?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.toString().padLeft(2, '0');
    String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(widget.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(_formatDuration(_position)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Slider(
                      value: _progress,
                      min: 0,
                      max: 1,
                      onChanged: (_) {},
                    ),
                  ),
                  Text(_formatDuration(_duration)),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _togglePlayPause,
          ),
        ),
        const Divider(),
      ],
    );
  }
}
