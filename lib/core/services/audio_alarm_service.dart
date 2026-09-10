import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/custom_logger.dart';

class SoundItem {
  final String title;
  final String subtitle;
  final String? assetPath;
  final IconData icon;

  const SoundItem({
    required this.title,
    required this.subtitle,
    this.assetPath,
    required this.icon,
  });
}

/// Service responsible for managing continuous alarm audio playback,
/// sound preview in settings/add-medicine dialogs, and periodic haptic vibrations.
class AudioAlarmService {
  final log = CustomLogger(className: '@AudioAlarmService');

  AudioPlayer? _player;
  AudioPlayer? _previewPlayer;
  Timer? _vibrationTimer;
  bool _isRinging = false;

  bool get isRinging => _isRinging;

  /// Dedicated sounds for general app notifications (configured in Settings)
  static const List<SoundItem> notificationSounds = [
    SoundItem(
      title: 'Clinical Chime',
      subtitle: 'Gentle and harmonic clinical notification tone',
      assetPath: 'sounds/notificatons/clinical_chime.wav',
      icon: Icons.music_note_rounded,
    ),
    SoundItem(
      title: 'Classic Alert',
      subtitle: 'Standard rhythmic app alert tone',
      assetPath: 'sounds/notificatons/classic_alarm.wav',
      icon: Icons.alarm_rounded,
    ),
    SoundItem(
      title: 'Gentle Beep',
      subtitle: 'Soft unobtrusive notification beep',
      assetPath: 'sounds/notificatons/gentle_beep.wav',
      icon: Icons.notifications_active_rounded,
    ),
    SoundItem(
      title: 'Vibrate Only',
      subtitle: 'Silent haptic vibration pattern',
      assetPath: null,
      icon: Icons.vibration_rounded,
    ),
  ];

  /// Dedicated sounds for medicine reminder alarms (configured in Add Medicine)
  static const List<SoundItem> medicineAlarmSounds = [
    SoundItem(
      title: 'Morning Clock Alarm',
      subtitle: 'Gentle rising morning alarm chime',
      assetPath: 'sounds/alarm/mixkit-morning-clock-alarm-1003.wav',
      icon: Icons.wb_sunny_rounded,
    ),
    SoundItem(
      title: 'Digital Alarm Buzzer',
      subtitle: 'Energetic digital clock beep pattern',
      assetPath: 'sounds/alarm/mixkit-digital-clock-digital-alarm-buzzer-992.wav',
      icon: Icons.alarm_rounded,
    ),
    SoundItem(
      title: 'Digital Clock Alert',
      subtitle: 'Standard electronic bedside clock tone',
      assetPath: 'sounds/alarm/universfield-digital-alarm-clock-151927.mp3',
      icon: Icons.access_alarm_rounded,
    ),
    SoundItem(
      title: 'Electronic Pulse',
      subtitle: 'High-clarity modern electronic alert',
      assetPath: 'sounds/alarm/u_inx5oo5fv3-alarm-327234.mp3',
      icon: Icons.notifications_active_rounded,
    ),
    SoundItem(
      title: 'Community Alert',
      subtitle: 'Crisp harmonic reminder alert',
      assetPath: 'sounds/alarm/freesound_community-alert-33762.mp3',
      icon: Icons.music_note_rounded,
    ),
    SoundItem(
      title: 'Hall Sound Alert',
      subtitle: 'Resonant reverberant alert tone',
      assetPath: 'sounds/alarm/mixkit-sound-alert-in-hall-1006.wav',
      icon: Icons.campaign_rounded,
    ),
    SoundItem(
      title: 'Vintage Telephone',
      subtitle: 'Classic nostalgic telephone bell',
      assetPath: 'sounds/alarm/mixkit-vintage-telephone-ringtone-1356.wav',
      icon: Icons.ring_volume_rounded,
    ),
    SoundItem(
      title: 'Old Telephone Ring',
      subtitle: 'Traditional rhythmic telephone bell',
      assetPath: 'sounds/alarm/mixkit-old-telephone-ring-1357.wav',
      icon: Icons.phone_in_talk_rounded,
    ),
    SoundItem(
      title: 'Vibrate Only',
      subtitle: 'Silent haptic vibration pattern',
      assetPath: null,
      icon: Icons.vibration_rounded,
    ),
  ];

  /// Returns the asset path for a given user-selected sound title.
  static String? getAssetForSound(String soundTitle) {
    final trimmed = soundTitle.trim();
    if (trimmed.toLowerCase().contains('vibrate')) return null;

    // Check direct matches in medicineAlarmSounds
    for (final item in medicineAlarmSounds) {
      if (item.title.toLowerCase() == trimmed.toLowerCase()) {
        return item.assetPath;
      }
    }

    // Check direct matches in notificationSounds
    for (final item in notificationSounds) {
      if (item.title.toLowerCase() == trimmed.toLowerCase()) {
        return item.assetPath;
      }
    }

    final lower = trimmed.toLowerCase();
    if (lower.contains('morning')) {
      return 'sounds/alarm/mixkit-morning-clock-alarm-1003.wav';
    } else if (lower.contains('buzzer')) {
      return 'sounds/alarm/mixkit-digital-clock-digital-alarm-buzzer-992.wav';
    } else if (lower.contains('digital clock')) {
      return 'sounds/alarm/universfield-digital-alarm-clock-151927.mp3';
    } else if (lower.contains('pulse') || lower.contains('electronic')) {
      return 'sounds/alarm/u_inx5oo5fv3-alarm-327234.mp3';
    } else if (lower.contains('community')) {
      return 'sounds/alarm/freesound_community-alert-33762.mp3';
    } else if (lower.contains('hall')) {
      return 'sounds/alarm/mixkit-sound-alert-in-hall-1006.wav';
    } else if (lower.contains('vintage')) {
      return 'sounds/alarm/mixkit-vintage-telephone-ringtone-1356.wav';
    } else if (lower.contains('telephone') || lower.contains('phone')) {
      return 'sounds/alarm/mixkit-old-telephone-ring-1357.wav';
    } else if (lower.contains('clinical')) {
      return 'sounds/notificatons/clinical_chime.wav';
    } else if (lower.contains('classic')) {
      return 'sounds/notificatons/classic_alarm.wav';
    } else if (lower.contains('gentle') || lower.contains('beep')) {
      return 'sounds/notificatons/gentle_beep.wav';
    }

    return 'sounds/alarm/mixkit-morning-clock-alarm-1003.wav';
  }

  /// Plays an immediate audio preview of a chosen sound (e.g. inside selection dialog).
  Future<void> playPreview(String soundName) async {
    try {
      log.i('@playPreview: Playing preview for sound "$soundName"');
      await stopPreview();

      final asset = getAssetForSound(soundName);
      if (asset != null) {
        _previewPlayer ??= AudioPlayer();
        await _previewPlayer!.stop();
        await _previewPlayer!.setVolume(1.0);
        await _previewPlayer!.setReleaseMode(ReleaseMode.stop);
        await _previewPlayer!.play(AssetSource(asset));
      } else {
        // Vibrate only preview
        try {
          await HapticFeedback.heavyImpact();
        } catch (_) {}
      }
    } catch (e) {
      log.w('@playPreview: Error playing sound preview ($e)');
    }
  }

  /// Stops any currently playing sound preview.
  Future<void> stopPreview() async {
    try {
      if (_previewPlayer != null) {
        await _previewPlayer!.stop();
      }
    } catch (_) {}
  }

  /// Starts the alarm sound in a continuous loop and periodic vibration pulses.
  Future<void> startAlarm({
    String? soundName,
    bool enableVibration = true,
  }) async {
    if (_isRinging) return;
    _isRinging = true;

    final selectedSound = soundName ?? 'Morning Clock Alarm';
    log.i('@startAlarm: Starting active medication alarm: sound="$selectedSound", vibration=$enableVibration');

    // 1. Periodic haptic vibration loop
    if (enableVibration) {
      try {
        await HapticFeedback.heavyImpact();
      } catch (_) {}

      _vibrationTimer?.cancel();
      _vibrationTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) async {
        if (!_isRinging) return;
        try {
          await HapticFeedback.heavyImpact();
        } catch (_) {}
      });
    }

    // 2. Continuous looping audio playback
    final asset = getAssetForSound(selectedSound);
    if (asset != null) {
      try {
        _player ??= AudioPlayer();
        await _player!.stop();
        await _player!.setVolume(1.0);
        await _player!.setReleaseMode(ReleaseMode.loop);
        await _player!.play(AssetSource(asset));
        log.i('@startAlarm: Playing looped alarm asset: $asset');
      } catch (e) {
        log.w('@startAlarm: Audio player playback note ($e)');
      }
    }
  }

  /// Stops audio playback and cancels haptic vibration pulses immediately.
  Future<void> stopAlarm() async {
    if (!_isRinging) return;
    _isRinging = false;

    log.i('@stopAlarm: Stopping active medication alarm audio and vibration');

    try {
      _vibrationTimer?.cancel();
      _vibrationTimer = null;
    } catch (_) {}

    try {
      if (_player != null) {
        await _player!.stop();
      }
    } catch (e) {
      log.w('@stopAlarm: Error stopping audio player ($e)');
    }
  }

  /// Disposes audio players and cancels any active timers.
  Future<void> dispose() async {
    await stopAlarm();
    await stopPreview();
    try {
      await _player?.dispose();
      _player = null;
    } catch (_) {}
    try {
      await _previewPlayer?.dispose();
      _previewPlayer = null;
    } catch (_) {}
  }
}
