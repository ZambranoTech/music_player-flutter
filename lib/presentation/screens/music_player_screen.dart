import 'package:animate_do/animate_do.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/presentation/config/helpers/helpers.dart';
import 'package:music_player/presentation/providers/audio_play_provider.dart';
import 'package:music_player/presentation/widgets/custom_appbar.dart';

class MusicPlayerScreen extends StatelessWidget {
  const MusicPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {


    return const Scaffold(
      body: Stack(
        children: [
          _Background(),
          Column(
            children: [
              CustomAppBar(),
              ImagenDiscoDuracion(),
              Expanded(child: _Lyrics())
            ],
          ),
        ],
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background({super.key});

  @override
  Widget build(BuildContext context) {

   Color scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

   final size = MediaQuery.of(context).size;

    return Container(
        width: double.infinity,
        height: size.height * 0.8,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 44, 43, 46),
              scaffoldBackgroundColor,
            ],
          ),
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(80)),
        ),
      );
  }
}

class ImagenDiscoDuracion extends StatelessWidget {
  const ImagenDiscoDuracion({super.key});

  @override
  Widget build(BuildContext context) {
    

    return   const Column(
      children: [
        Row(
          children: [
            _DiskImage(),
            SizedBox(
              width: 60,
            ),
          _ProgressBar()
          ]
        ),

        TituloPlay(),
      ],
    );
  }
}

class _Lyrics extends StatelessWidget {
  const _Lyrics({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final lyrics = getLyrics();

    return ListWheelScrollView(
            physics: const BouncingScrollPhysics(),
            itemExtent: 42, 
            diameterRatio: 1.5,
            children: lyrics.map(
              (linea) => Text(linea, style: TextStyle(fontSize: 20, color: Colors.white.withOpacity(0.6)),))
              .toList()
          );
  }
}




class TituloPlay extends ConsumerStatefulWidget  {
  const TituloPlay({
    super.key,
  });

  @override
  TituloPlayState createState() => TituloPlayState();
}

class TituloPlayState extends ConsumerState<TituloPlay> with SingleTickerProviderStateMixin {


  late AnimationController animationController;
  bool isFirstTime = true;
  final assetsAudioPlayer = AssetsAudioPlayer();


  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 200)
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void open() {

    assetsAudioPlayer.open(
      Audio('assets/songs/Breaking-Benjamin-Far-Away.mp3'),
      autoStart: true,
      showNotification: true
    );

    assetsAudioPlayer.currentPosition.listen((event) {
      ref.read(audioProvider.notifier).setCurrent(event);
      ref.read(audioProvider.notifier).setPercentaje();
      print(ref.watch(audioProvider).percentage);
    });

    assetsAudioPlayer.current.listen((event) {
      ref.read(audioProvider.notifier).setSongDuration(event?.audio.duration ?? const Duration(seconds: 0));
    });


  }


  @override
  Widget build(BuildContext context) {

    final audio = ref.watch(audioProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          const SizedBox(width: 45,),
          Column(
            children: [
              const Text('Far Away', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
              Text('-Breaking Benjamin-', style: TextStyle(color: Colors.white.withOpacity(0.4)),),
            ],
          ),
          const Spacer(),
          FloatingActionButton(
            backgroundColor: Colors.grey.shade800,
            onPressed: () {
              print('${audio.current.inSeconds} - ${audio.songDuration.inSeconds}');

              if (audio.isPlaying) {
                animationController.reverse(); 
                audio.animationController!.stop();
              } else {
                animationController.forward();
                audio.animationController!.repeat();
              }
              ref.read(audioProvider.notifier).toggleIsPlaying();

              if (isFirstTime) {
                open();
                isFirstTime = false;
              } else {
                assetsAudioPlayer.playOrPause();
              }

            }, 
            child: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: animationController,
            )
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends ConsumerWidget {
  
  const _ProgressBar();

  String printDuration(Duration duration) {
  
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    // return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context, ref) {

    final colorBlanco = Colors.white.withOpacity(0.4);

    final porcentaje = ref.watch(audioProvider).percentage;
    final current = ref.watch(audioProvider).current;
    final songDuration = ref.watch(audioProvider).songDuration;

    return Column(
      children: [
        Text(
          printDuration(songDuration),
          style: TextStyle(color: colorBlanco),
        ),
        Stack(
          children: [
            Container(
              width: 5,
              height: 230,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle, color: Colors.grey.shade700),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: 5,
                height: 230 * porcentaje,
                decoration: const BoxDecoration(
                    shape: BoxShape.rectangle, 
                    color: Colors.white
                ),
              ),
            ),

          ],
        ),
        Text(
          printDuration(current),
          style: TextStyle(color: colorBlanco),
        ),
      ],
    );
  }
}

class _DiskImage extends ConsumerWidget {
  const _DiskImage({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {

    return SpinPerfect(
      manualTrigger: true,
      duration: const Duration(seconds: 10),
      controller: (controller) { 
        Future.microtask(() => 
        ref.read(audioProvider.notifier).setController(controller)
        );
      },

      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 70, horizontal: 40),
        width: 250,
        height: 250,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              colors: [Colors.grey.shade700, Colors.grey.shade900],
            )),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(200),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/aurora.jpg',
                  fit: BoxFit.cover,
                ),
                Container(
                  width: 25,
                  height: 25,
                  decoration: const BoxDecoration(
                      color: Colors.black38, shape: BoxShape.circle),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                      color: Colors.black54, shape: BoxShape.circle),
                ),
              ],
            )),
      ),
    );
  }
}
