import 'package:beats/controller/audio_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../constants.dart';

class PlayerScreen extends ConsumerWidget {
  final SongModel song;
  const PlayerScreen(this.song, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgDarkColor,
        foregroundColor: whiteColor,
        title: const Text('Now Playing', style: titleStyle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                decoration:
                    const BoxDecoration(shape: BoxShape.circle, color: bgColor),
                child: QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: const Icon(
                    Icons.music_note,
                    size: 100,
                    color: whiteColor,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    song.title,
                    style: titleStyle,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    song.artist ?? '',
                    style: subTitleStyle,
                  ),
                  const SizedBox(height: 20),
                  // Row(
                  //   children: [
                  //     Text(_formatDuration(AudioPlayerController().duration), style: subTitleStyle),
                  //     Expanded(
                  //       child: Slider(
                  //         value: 0.5,
                  //         onChanged: (double value) {},
                  //       ),
                  //     ),
                  //     const Text('3:00', style: subTitleStyle),
                  //   ],
                  // ),
                  _buildPositionSlider(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 50,
                        onPressed: () {},
                      ),
                      // IconButton(
                      //   icon: const Icon(Icons.play_arrow),
                      //   iconSize: 50,
                      //   onPressed: () {},
                      // ),
                      _buildControlPanel(),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        iconSize: 50,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildControlPanel() {
    return StreamBuilder(stream: AudioPlayerController().playbackState, builder: (context, snapshot) {
      final playerState = snapshot.data;    
      if(playerState?.playing ?? false){
        return IconButton(
          icon: const Icon(Icons.pause),
          iconSize: 50,
          color: whiteColor,
          onPressed: () {
            AudioPlayerController().pause();
          },
        );
      }
      else{
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          iconSize: 50,
          color: whiteColor,
          onPressed: () {
            AudioPlayerController().play();
          },
        );
      }
    });
  }

  _buildPositionSlider(){
    return StreamBuilder(stream: AudioPlayerController().position, builder: (context, snapshot) {
      final position = snapshot.data;
      final duration = AudioPlayerController().duration;
      return Row(
        children: [
          Text(_formatDuration(position), style: subTitleStyle),
          Expanded(
            child: Slider(
              value: position!.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble()),
              onChanged: (double value) {
                AudioPlayerController().seek(Duration(milliseconds: value.toInt()));
              },
              min: 0.0,
              max: AudioPlayerController().duration.inMilliseconds.toDouble(),
            ),
          ),
          Text(_formatDuration(duration), style: subTitleStyle),
        ],
      );
    });
  }

  String _formatDuration(Duration? duration) {
  if (duration == null) {
    return '0:00';
  }
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return '$minutes:$seconds';
}
}
