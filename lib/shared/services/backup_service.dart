import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/workout_log.dart';
import '../models/set_log.dart';
import '../models/check_in.dart';
import '../models/user_profile.dart';
import '../models/challenge.dart';
import '../models/custom_split.dart';
import 'hive_service.dart';

class BackupService {
  static Future<Map<String, dynamic>> getBackupData() async {
    final data = <String, dynamic>{};

    // User profile
    final profile = HiveService.profile.get('profile');
    if (profile != null) {
      data['user_profile'] = profile.toJson();
    }

    // Workout logs
    data['workout_logs'] =
        HiveService.workoutLogs.values.map((w) => w.toJson()).toList();

    // Set logs
    data['set_logs'] =
        HiveService.setLogs.values.map((s) => s.toJson()).toList();

    // Check-ins
    data['check_ins'] =
        HiveService.checkIns.values.map((c) => c.toJson()).toList();

    // Personal records
    data['personal_records'] = HiveService.prRecords.values
        .map((r) => Map<String, dynamic>.from(r))
        .toList();

    // Challenges
    data['challenges'] =
        HiveService.challenges.values.map((c) => c.toJson()).toList();

    // Custom splits
    data['custom_splits'] =
        HiveService.customSplits.values.map((s) => s.toJson()).toList();

    return data;
  }

  static Future<String> exportToJson() async {
    final data = await getBackupData();
    final jsonString = jsonEncode(data);

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    final file = File('${directory.path}/forja_backup_$timestamp.json');
    await file.writeAsString(jsonString);

    return file.path;
  }

  static Future<void> shareBackup() async {
    final filePath = await exportToJson();
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath)],
        text: 'FORJA Backup Data',
      ),
    );
  }

  static Future<bool> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate backup format
      if (!data.containsKey('version')) {
        data['version'] = '1.0';
      }

      // Clear existing data
      await HiveService.clearAll();

      // Restore user profile
      if (data.containsKey('user_profile') && data['user_profile'] != null) {
        final profile = UserProfile.fromJson(data['user_profile']);
        await HiveService.profile.put('profile', profile);
      }

      // Restore workout logs
      if (data.containsKey('workout_logs')) {
        final logs = (data['workout_logs'] as List)
            .map((w) => WorkoutLog.fromJson(w))
            .toList();
        for (final log in logs) {
          await HiveService.workoutLogs.put(log.id, log);
        }
      }

      // Restore set logs
      if (data.containsKey('set_logs')) {
        final sets =
            (data['set_logs'] as List).map((s) => SetLog.fromJson(s)).toList();
        for (final set in sets) {
          await HiveService.setLogs.put(set.id, set);
        }
      }

      // Restore check-ins
      if (data.containsKey('check_ins')) {
        final checkIns = (data['check_ins'] as List)
            .map((c) => CheckIn.fromJson(c))
            .toList();
        for (final checkIn in checkIns) {
          await HiveService.checkIns.put(checkIn.id, checkIn);
        }
      }

      // Restore personal records
      if (data.containsKey('personal_records')) {
        final prs = data['personal_records'] as List;
        for (final pr in prs) {
          final key =
              pr['exercise_id'].toString() + '_' + pr['achieved_at'].toString();
          await HiveService.prRecords.put(key, Map<String, dynamic>.from(pr));
        }
      }

      // Restore challenges
      if (data.containsKey('challenges')) {
        final challenges = (data['challenges'] as List)
            .map((c) => Challenge.fromJson(c))
            .toList();
        for (final challenge in challenges) {
          await HiveService.challenges.put(challenge.id, challenge);
        }
      }

      // Restore custom splits
      if (data.containsKey('custom_splits')) {
        final splits = (data['custom_splits'] as List)
            .map((s) => CustomSplit.fromJson(s))
            .toList();
        for (final split in splits) {
          await HiveService.customSplits.put(split.id, split);
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> restoreFromFilePicker() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();
      return await importFromJson(jsonString);
    } catch (e) {
      return false;
    }
  }

  static Future<String?> validateBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Basic validation - check for expected keys
      final hasAnyData = data.containsKey('user_profile') ||
          data.containsKey('workout_logs') ||
          data.containsKey('set_logs') ||
          data.containsKey('check_ins');

      if (!hasAnyData) {
        return 'Invalid backup file format';
      }

      return null;
    } catch (e) {
      return 'Could not read backup file';
    }
  }
}
