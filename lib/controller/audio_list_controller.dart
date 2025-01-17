import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioListController extends AsyncNotifier<List<SongModel>> {

  final audioQuery = OnAudioQuery();
  var permissionStatus = Permission.storage.status;
  List<SongModel> audios = [];

  @override
  FutureOr<List<SongModel>> build(){
    checkPermission();

    return  audios;
  }
  
  void checkPermission() async{
    state = const AsyncValue.loading();
    var perm = await Permission.storage.status;
    if(perm.isGranted){
      await getAudios();
    }
    else{
      requestPermission();
    }
  }
  
  void requestPermission() async{
    var permissionStatus = await Permission.storage.request();
    if(permissionStatus.isGranted){
      await getAudios();
    }
      
  }
  
  Future<void> getAudios() async{
    final songs = await audioQuery.querySongs(
      ignoreCase: true,
      orderType: OrderType.ASC_OR_SMALLER,
      sortType: null,
      uriType: UriType.EXTERNAL,
    );

    List<SongModel> filteredSongs = songs.where((song) => (song.duration ?? 0) > 30000).toList();

    state = AsyncValue.data(filteredSongs);
  }
}

final audioListControllerProvider = AsyncNotifierProvider<AudioListController, List<SongModel>>(AudioListController.new); 
final audioListLengthProvider = Provider<int>((ref) => ref.watch(audioListControllerProvider).maybeWhen(
  data: (audios) => audios.length,
  orElse: () => 0,
));
