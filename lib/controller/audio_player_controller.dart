import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

class AudioPlayerController extends Notifier {

  static final AudioPlayerController _instance = AudioPlayerController._internal();

  factory AudioPlayerController() {
    return _instance;
  }

  AudioPlayerController._internal();

  @override
  build() {
    throw UnimplementedError();
  }

  final _audioPlayer = AudioPlayer();

  Stream<PlayerState> get playbackState => _audioPlayer.playerStateStream;

  Stream<Duration> get position => _audioPlayer.positionStream;
  Duration get duration => _audioPlayer.duration ?? Duration.zero;

  void play({String? url}) {
    print('Playing audio...');
    if (url != null) {
      _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
    }
    _audioPlayer.play();
  }

  void pause() {
    print('Pausing audio...');
    _audioPlayer.pause();
  }

  void seek(Duration position) {
    print('Seeking audio...');
    _audioPlayer.seek(position);
  }

  void stop() {
    print('Stopping audio...');
    _audioPlayer.stop();
  }
  
  
}

final nowPlayingSongProvider = StateProvider<SongModel?>((ref) => null);  
