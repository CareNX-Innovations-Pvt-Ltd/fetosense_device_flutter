import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';

class MyAudioTrack16Bit {
  static final MyAudioTrack16Bit _instance = MyAudioTrack16Bit._internal();

  factory MyAudioTrack16Bit() => _instance;

  MyAudioTrack16Bit._internal() {

    //_audioPlayer = FlutterSoundPlayer();

    FlutterPcmSound.setLogLevel(LogLevel.verbose);
    FlutterPcmSound.setup(sampleRate: 4000, channelCount: 1);
    FlutterPcmSound.setFeedThreshold(4000 ~/ 10);
    //FlutterPcmSound.setFeedCallback(playPCM);
    //prepareAudioTrack();
    initialized = true;

  }

  static const int USHORT_MASK = (1 << 16) - 1;

  //FlutterSoundPlayer? _audioPlayer;
  bool firstStart = false;
  int packageWriteCount = 0;
  int packageReadCount = 0;
  int packageWriteIndex = 0;
  int packageReadIndex = 0;
  int packageCountCallback = 0;

  static const int MAX_BUF_PER200_SZIE = 40;
  static const int MAX_BUF_PER320_SZIE = 25;

  List<int> bufSaveForRealTime = List.filled(8000, 0);
  List<int> bufForRealBudian = List.filled(320, 0);
  int lastData = 0;
  bool dataNessary = false;
  int byteAvaliableToRead = 0;
  bool initialized = false;

  /*Future<void> prepareAudioTrack() async {
    await _audioPlayer!.openPlayer();
    await _audioPlayer!.startPlayerFromStream(
      codec: Codec.pcm16,
      sampleRate: 4000, // Adjust based on your PCM format
      numChannels: 1, // 1 for mono, 2 for stereo
    );
    initialized = true;
    print("is initialised? $initialized");

  }*/

  Future<void> playPCM(List<int> pcmData) async {
    if (!initialized) {
      print("audio is playing? $pcmData");
    } else {
      // print("is initialised? $initialized");
    }

    // Write PCM data to the stream
    //_audioPlayer!.feedInt16FromStream([pcmData]);

    await FlutterPcmSound.feed(PcmArrayInt16.fromList(pcmData));
  }

  Future<void> releaseAudioTrack() async {
    //await _audioPlayer?.closePlayer()
    FlutterPcmSound.release();
  }
  /*void writeAudioTrack(List<int> buffer, int start, int len, bool amplify) {
    if (amplify) {
      normalizeVolume(buffer, 0, buffer.length);
    }
    if (initialized) {
      Uint8List audioData = shortToByteTwiddleMethod(buffer);
      _audioPlayer?.startPlayer(fromDataBuffer: audioData);
      print("audio is playing? $audioData");
    } else {
      print("is initialised? $initialized");
    }
  }*/



  /*Uint8List shortToByteTwiddleMethod(List<int> input) {
    final buffer = Uint8List(input.length * 2);
    for (int i = 0; i < input.length; i++) {
      buffer[i * 2] = input[i] & 0x00FF;
      buffer[i * 2 + 1] = (input[i] & 0xFF00) >> 8;
    }
    return buffer;
  }

  static const int N_SHORTS = 0xffff;
  static final List<int> VOLUME_NORM_LUT = List.filled(N_SHORTS, 0);
  static const int MAX_NEGATIVE_AMPLITUDE = 0x8000;

  static void normalizeVolume(List<int> audioSamples, int start, int len) {
    for (int i = start; i < start + len; i++) {
      int res = audioSamples[i];
      res = VOLUME_NORM_LUT[(res + MAX_NEGATIVE_AMPLITUDE).clamp(0, N_SHORTS - 1)];
      audioSamples[i] = res;
    }
  }

  static void precomputeVolumeNormLUT() {
    for (int s = 0; s < N_SHORTS; s++) {
      double v = (s - MAX_NEGATIVE_AMPLITUDE) as double;
      double sign = v.sign;
      VOLUME_NORM_LUT[s] = (sign * (1.240769e-22 - (-4.66022 / 0.0001408133) *
          (1 - exp(-0.0001408133 * v * sign)))).toInt();
    }
  }

  Future<void> stopPlayer() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.stopPlayer();
      _audioPlayer = null;
    }
  }*/
}
