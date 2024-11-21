import 'package:beats/controller/audio_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../constants.dart';
import '../controller/audio_list_controller.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowPlayingSong = ref.watch(nowPlayingSongProvider);
    final nowPlayingIndex = ref.watch(nowPlayingIndexProvider);
    final audioListLength = ref.watch(audioListLengthProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgDarkColor,
        foregroundColor: whiteColor,
        title: const Text('Now Playing', style: titleStyle),
      ),
      body: nowPlayingSong != null
          ? Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: bgColor),
                      child: QueryArtworkWidget(
                        id: nowPlayingSong.id,
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
                          nowPlayingSong.title,
                          style: titleStyle,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          nowPlayingSong.artist ?? '',
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
                              color: whiteColor,
                              onPressed: () {
                                if (nowPlayingIndex > 0) {
                                  ref.read(nowPlayingIndexProvider.notifier).state = nowPlayingIndex - 1;
                                  ref.read(nowPlayingSongProvider.notifier).state = ref.read(audioListControllerProvider).maybeWhen(
                                            data: (audios) {
                                              AudioPlayerController().play(url: audios[nowPlayingIndex - 1].uri);
                                              return audios[nowPlayingIndex - 1];
                                            },
                                            orElse: () => null,
                                          );
                                }
                              },
                            ),
                            _buildPlayPauseButton(),
                            IconButton(
                              icon: const Icon(Icons.skip_next),
                              iconSize: 50,
                              color: whiteColor,
                              onPressed: () {
                                if (nowPlayingIndex < audioListLength - 1) {
                                  ref.read(nowPlayingIndexProvider.notifier).state = nowPlayingIndex + 1;
                                  ref.read(nowPlayingSongProvider.notifier).state = ref.read(audioListControllerProvider).maybeWhen(
                                            data: (audios) {
                                              AudioPlayerController().play(url: audios[nowPlayingIndex + 1].uri);
                                              return audios[nowPlayingIndex + 1];
                                            },
                                            orElse: () => null,
                                          );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: Text('No song selected')),
    );
  }

  _buildPlayPauseButton() {
    return StreamBuilder(
        stream: AudioPlayerController().playbackState,
        builder: (context, snapshot) {
          final playerState = snapshot.data;
          print(playerState?.processingState.toString());
          if (playerState?.processingState == ProcessingState.completed) {
            print('completed..................................');
            return IconButton(
              icon: const Icon(Icons.play_arrow),
              iconSize: 50,
              color: whiteColor,
              onPressed: () {
                AudioPlayerController().seek(Duration.zero);
                AudioPlayerController().play();
              },
            );
          } else if (playerState?.playing ?? false) {
            print('playing..................................');
            return IconButton(
              icon: const Icon(Icons.pause),
              iconSize: 50,
              color: whiteColor,
              onPressed: () {
                AudioPlayerController().pause();
              },
            );
          } else {
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

  _buildPositionSlider() {
    return StreamBuilder(
        stream: AudioPlayerController().position,
        builder: (context, snapshot) {
          final position = snapshot.data ?? Duration.zero;
          final duration = AudioPlayerController().duration;
          return Row(
            children: [
              Text(_formatDuration(position), style: subTitleStyle),
              Expanded(
                child: Slider(
                  value: position.inMilliseconds
                      .floorToDouble()
                      .clamp(0.0, duration.inMilliseconds.floorToDouble()),
                  onChanged: (double value) {
                    AudioPlayerController()
                        .seek(Duration(milliseconds: value.toInt()));
                  },
                  min: 0.0,
                  max: AudioPlayerController()
                      .duration
                      .inMilliseconds
                      .floorToDouble(),
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
