import 'dart:io';

// ===== Global Paths Setup =====
final String? desktopPath = getDesktopPath();
final String ransomwareFolder = '$desktopPath\\RansomLearn';
final String filesPath = '$ransomwareFolder\\Files';
final String backupPath = '$ransomwareFolder\\Backup';
final String keyPath = '$ransomwareFolder\\Key';

// ===== Desktop Path Utility =====
String? getDesktopPath() {
  if (Platform.isWindows) {
    String userProfile = Platform.environment['USERPROFILE'] ?? "";
    String oneDriveDesktop = "$userProfile\\OneDrive\\Desktop";
    String defaultDesktop = "$userProfile\\Desktop";

    if (Directory(oneDriveDesktop).existsSync()) {
      return oneDriveDesktop;
    } else {
      return defaultDesktop;
    }
  } else if (Platform.isLinux || Platform.isMacOS) {
    return "${Platform.environment['HOME']}/Desktop";
  }
  return null;
}

// ===== File Generators & Setup =====
void createRandomTextFiles(String folderPath, int count) {
  for (int i = 1; i <= count; i++) {
    File file = File('$folderPath\\file$i.txt');
    file.writeAsStringSync("This is sample data for file $i.");
  }
}

void setupRansomLearnEnvironment() {
  if (desktopPath == null) {
    print("Error: Could not find desktop path.");
    return;
  }

  Directory mainDir = Directory(ransomwareFolder);

  if (mainDir.existsSync()) {
    mainDir.deleteSync(recursive: true);
    print('Existing RansomLearn folder deleted.');
  }
  mainDir.createSync();
  print('Created new RansomLearn folder.');

  for (String subfolder in ['Files', 'Backup', 'Key']) {
    Directory('$ransomwareFolder\\$subfolder').createSync();
  }

  createRandomTextFiles(filesPath, 5);
  print('Random text files created.');
}

// ===== Backup Handlers =====
void createBackupFiles() {
  if (desktopPath == null) {
    print("Error: Could not find desktop path.");
    return;
  }

  Directory filesDir = Directory(filesPath);
  Directory backupDir = Directory(backupPath);

  if (!filesDir.existsSync()) {
    print("Error: Files folder not found.");
    return;
  }

  if (!backupDir.existsSync()) {
    backupDir.createSync();
  }

  // Clear old backup
  backupDir.listSync().forEach((file) {
    if (file is File) {
      file.deleteSync();
    }
  });

  filesDir.listSync().forEach((file) {
    if (file is File) {
      file.copySync('$backupPath\\${file.uri.pathSegments.last}');
    }
  });

  print("✅ Backup files created.");
}

Future<void> deleteBackupFiles() async {
  if (desktopPath == null) {
    print("Error: Could not find desktop path.");
    return;
  }

  final backupDir = Directory(backupPath);

  if (await backupDir.exists()) {
    final files = backupDir.listSync();
    for (final file in files) {
      try {
        if (file is File) {
          await file.delete();
        } else if (file is Directory) {
          await file.delete(recursive: true);
        }
      } catch (e) {
        print("❌ Error deleting backup file: $e");
      }
    }
    print("🗑️ Backup files deleted.");
  }
}

void restoreBackup() {
  if (desktopPath == null) {
    print("Error: Could not find desktop path.");
    return;
  }

  Directory backupDir = Directory(backupPath);
  Directory filesDir = Directory(filesPath);

  if (!backupDir.existsSync()) {
    print("Error: Backup folder does not exist!");
    return;
  }

  if (!filesDir.existsSync()) {
    print("Error: Files folder does not exist! Creating it now...");
    filesDir.createSync();
  }

  filesDir.listSync().forEach((file) {
    if (file is File) {
      file.deleteSync();
    }
  });

  backupDir.listSync().forEach((file) {
    if (file is File) {
      file.copySync('$filesPath\\${file.uri.pathSegments.last}');
    }
  });

  print("✅ Backup successfully restored!");
}
