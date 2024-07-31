import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:waterbottle/data/logs.dart';
import 'package:waterbottle/services/notification_service.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:waterbottle/data/db.dart';

SimpleLogger logger = SimpleLogger();
ProfileData profileData = ProfileData();

void initBackgroundFetch() {
  BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15, // check every x minutes
        stopOnTerminate: false,
        enableHeadless: true,
      ), (String taskId) async {
    await checkLogsAndTriggerFunction();
    BackgroundFetch.finish(taskId);
  }).then((int status) {
    logger.info('BackgroundFetch configure success: $status');
  }).catchError((e) {
    logger.info('BackgroundFetch configure error: $e');
  });

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  await checkLogsAndTriggerFunction();
  BackgroundFetch.finish(taskId);
}

Future<void> checkLogsAndTriggerFunction() async {
  final logs = await Logs.loadLogs();
  profileData = await ProfileData.readProfileData() ?? ProfileData();

  if (logs != null && logs.entries.isNotEmpty) {
    final latestLog = logs.entries.last;
    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

    if (now.difference(latestLog.dateTime).inHours >= profileData.drinkEvery &&
        !_isWithinMutePeriod(
            currentTime, profileData.muteStart, profileData.muteEnd)) {
      triggerFunction(true);
      logger.info(
          'Sending reminder; drinkEvery: ${profileData.drinkEvery} hours');
    } else {
      triggerFunction(false);
      logger.info('Remove notification');
    }
  } else {
    triggerFunction(true);
    logger.info('No logs data');
  }
}

bool _isWithinMutePeriod(
    TimeOfDay currentTime, TimeOfDay muteStart, TimeOfDay muteEnd) {
  if (muteStart.hour < muteEnd.hour ||
      (muteStart.hour == muteEnd.hour && muteStart.minute <= muteEnd.minute)) {
    return currentTime.hour > muteStart.hour ||
        (currentTime.hour == muteStart.hour &&
                currentTime.minute >= muteStart.minute) &&
            (currentTime.hour < muteEnd.hour ||
                (currentTime.hour == muteEnd.hour &&
                    currentTime.minute <= muteEnd.minute));
  } else {
    // Mute period crosses midnight
    return (currentTime.hour > muteStart.hour ||
            (currentTime.hour == muteStart.hour &&
                currentTime.minute >= muteStart.minute)) ||
        (currentTime.hour < muteEnd.hour ||
            (currentTime.hour == muteEnd.hour &&
                currentTime.minute <= muteEnd.minute));
  }
}

void triggerFunction(bool option) {
  option
      ? NotificationService().showNotification(2, 'Drink water',
          'It\'s been over ${profileData.drinkEvery} hours since you last drank water')
      : NotificationService().removeNotification(2);
}
