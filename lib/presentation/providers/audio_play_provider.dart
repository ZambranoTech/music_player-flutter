// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>((ref) {
  return AudioNotifier();
});

class AudioNotifier extends StateNotifier<AudioState> {
  AudioNotifier(): super(AudioState());


  toggleIsPlaying() {
    state = state.copyWith(
      isPlaying: !state.isPlaying
    );
  }

  setController(AnimationController controller) {
    state = state.copyWith(
      animationController: controller
    );
  }

  setCurrent(Duration current) {
    state = state.copyWith(
      current: current
    );
  }

  setSongDuration(Duration songDuration) {
    state = state.copyWith(
      songDuration: songDuration
    );
  }

  setPercentaje() {
    (state.songDuration.inSeconds > 0) 
    ? state = state.copyWith(
      percentage: state.current.inSeconds / state.songDuration.inSeconds
    ) 
    : 0.0;
  }

}

class AudioState {
  final bool isPlaying;
  final AnimationController? animationController;
  final Duration songDuration;
  final Duration current;
  final double percentage;

  AudioState({
    this.isPlaying = false, 
    this.animationController,
    this.songDuration = const Duration(seconds: 0), 
    this.current = const Duration(seconds: 0),
    this.percentage = 0,
  });


  AudioState copyWith({
    bool? isPlaying,
    AnimationController? animationController,
    Duration? songDuration,
    Duration? current,
    double? percentage,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      animationController: animationController ?? this.animationController,
      songDuration: songDuration ?? this.songDuration,
      current: current ?? this.current,
      percentage: percentage ?? this.percentage,
    );
  }
}
