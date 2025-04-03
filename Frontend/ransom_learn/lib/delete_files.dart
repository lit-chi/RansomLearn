import 'dart:io';
import 'package:ransom_learn/file_manager.dart'; // Import getDesktopPath

void deleteFiles() {
  String? desktopPath = getDesktopPath();
  if (desktopPath == null) {
    print("Error: Could not determine desktop path.");
    return;
  }

  String filesFolder = '$desktopPath/RansomLearn/Files';
  Directory dir = Directory(filesFolder);

  if (dir.existsSync()) {
    dir.listSync().forEach((file) {
      try {
        file.deleteSync();
        print("Deleted: ${file.path}");
      } catch (e) {
        print("Failed to delete ${file.path}: $e");
      }
    });
  } else {
    print("Files folder does not exist.");
  }
}
