import 'dart:io';

// Function to get the desktop path based on OS
String? getDesktopPath() {
  if (Platform.isWindows) {
    String userProfile = Platform.environment['USERPROFILE'] ?? "";
    String oneDriveDesktop = "$userProfile\\OneDrive\\Desktop";
    String defaultDesktop = "$userProfile\\Desktop";

    if (Directory(oneDriveDesktop).existsSync()) {
      return oneDriveDesktop; // Use OneDrive if available
    } else {
      return defaultDesktop; // Use regular desktop if OneDrive is not found
    }
  } else if (Platform.isLinux || Platform.isMacOS) {
    return "${Platform.environment['HOME']}/Desktop";
  }
  return null;
}


// Function to create random text files
void createRandomTextFiles(String folderPath, int count) {
  for (int i = 1; i <= count; i++) {
    File file = File('$folderPath\\file$i.txt');
    file.writeAsStringSync("This is sample data for file $i.");
  }
}

// Function to set up the RansomLearn environment (Always replaces existing files)
void setupRansomLearnEnvironment() {
  String? desktopPath = getDesktopPath();
  if (desktopPath == null) {
    print("Error: Could not find desktop path.");
    return;
  }

  String ransomwareFolder = '$desktopPath\\RansomLearn';
  List<String> subfolders = ['Files', 'Backup', 'Key'];

  Directory mainDir = Directory(ransomwareFolder);

  // Delete existing folder and recreate it
  if (mainDir.existsSync()) {
    mainDir.deleteSync(recursive: true);
    print('Existing RansomLearn folder deleted.');
  }
  mainDir.createSync();
  print('Created new RansomLearn folder.');

  for (String subfolder in subfolders) {
    Directory('${mainDir.path}\\$subfolder').createSync();
  }
  print('Subfolders created successfully.');

  // Create random text files in the Files folder
  String filesPath = '$ransomwareFolder\\Files';
  createRandomTextFiles(filesPath, 5); // Create 5 random text files
  print('Random text files created.');

  // Copy text files to Backup folder
  String backupPath = '$ransomwareFolder\\Backup';
  Directory(filesPath).listSync().forEach((file) {
    if (file is File) {
      file.copySync('$backupPath\\${file.uri.pathSegments.last}');
    }
  });
  print('Backup files created.');
}

// Function to restore files from Backup to Files (overwrite existing files)
void restoreBackup() {
  String? desktopPath = getDesktopPath();
  if (desktopPath == null) {
    print("Error: Could not find desktop path.");
    return;
  }

  String ransomwareFolder = '$desktopPath\\RansomLearn';
  String backupPath = '$ransomwareFolder\\Backup';
  String filesPath = '$ransomwareFolder\\Files';

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

  // Delete all existing files in Files folder
  filesDir.listSync().forEach((file) {
    if (file is File) {
      file.deleteSync();
    }
  });

  // Copy backup files to Files folder (overwrite)
  backupDir.listSync().forEach((file) {
    if (file is File) {
      file.copySync('$filesPath\\${file.uri.pathSegments.last}');
    }
  });

  print("Backup successfully restored!");
}
