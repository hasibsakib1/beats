import 'package:beats/widgets/marquee_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../constants.dart';
import '../controller/audio_list_controller.dart';
import '../controller/audio_player_controller.dart';
import 'player_screen.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final audioList = ref.watch(audioListControllerProvider);
    final nowPlayingSong = ref.watch(nowPlayingSongProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgDarkColor,
        title: const Text('Beats', style: titleStyle),
      ),
      body: audioList.when(
        data: (audios) {
          return audios.isNotEmpty
              ? ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: audios.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      width: MediaQuery.of(context).size.width,
                      child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tileColor: bgColor,
                          title: SizedBox(
                            height: 30,
                            child: audios[index].title.length > 20
                                ? MarqueeWidget(
                                    text: audios[index].title,
                                    style: titleStyle,
                                  )
                                : Text(
                                    audios[index].title,
                                    style: titleStyle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                          subtitle: Text(audios[index].artist ?? '',
                              style: subTitleStyle),
                          leading: QueryArtworkWidget(
                            size: 50,
                            id: audios[index].id,
                            type: ArtworkType.AUDIO,
                            nullArtworkWidget:
                                const Icon(Icons.music_note, size: 50),
                          ),
                          trailing:
                              const Icon(Icons.play_arrow, color: whiteColor),
                          onTap: () {
                            AudioPlayerController()
                                .play(url: audios[index].uri);
                            ref.read(nowPlayingSongProvider.notifier).state =
                                audios[index];
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PlayerScreen(audios[index])));
                          }),
                    );
                  },
                )
              : const Center(
                  child: Text('No songs found', style: titleStyle),
                );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      // bottomNavigationBar: nowPlayingSong != null
      //     ? GestureDetector(
      //         onTap: () {
      //           Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                   builder: (context) => PlayerScreen(nowPlayingSong)));
      //         },
      //         child: Container(
      //           height: 100,
      //           clipBehavior: Clip.antiAliasWithSaveLayer,
      //           decoration: const BoxDecoration(
      //             color: bgColor,
      //             borderRadius: const BorderRadius.only(
      //               topLeft: Radius.circular(20),
      //               topRight: Radius.circular(20),
      //             ),
      //           ),
      //           child: Row(
      //             children: [
      //               QueryArtworkWidget(
      //                 size: 50,
      //                 id: nowPlayingSong.id,
      //                 type: ArtworkType.AUDIO,
      //                 nullArtworkWidget: const Icon(Icons.music_note, size: 50),
      //               ),
      //               Expanded(
      //                 child: Column(
      //                   children: [
      //                     nowPlayingSong.title.length > 20
      //                         ? SizedBox(
      //                           width: MediaQuery.of(context).size.width * 0.5,
      //                           child: MarqueeWidget(
      //                               text: nowPlayingSong.title, style: titleStyle),
      //                         )
      //                         : Text(nowPlayingSong.title, style: titleStyle),
      //                     Text(nowPlayingSong.artist ?? '', style: subTitleStyle),
      //                   ],
      //                 ),
      //               ),
      //               _buildControlPanel(),
      //             ],
      //           ),
      //         ),
      //       )
      //     : null,
    );
  }

  _buildControlPanel() {
    return StreamBuilder(
        stream: AudioPlayerController().playbackState,
        builder: (context, snapshot) {
          final playerState = snapshot.data;
          if (playerState?.playing ?? false) {
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
}
