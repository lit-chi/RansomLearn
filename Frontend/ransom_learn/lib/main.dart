import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:ransom_learn/file_manager.dart';
import 'dart:convert';
import 'dart:io';
import 'delete_files.dart';


void main() {
  runApp(RansomLearnApp());
}

class RansomLearnApp extends StatelessWidget {
  const RansomLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _visible = true;
      });
    });
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: Duration(seconds: 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'RANSOMLEARN',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(height: 10),
              AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: Duration(seconds: 1),
                child: Text(
                  'Simulating Ransomware to Build Awareness and Backup Defenses',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  // Add controllers for input fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void navigateToEmailPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmailPage()),
    );
  }

  Future<void> _signupAndReturnToLogin() async {
    if (!isLogin && passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final url = Uri.parse('http://localhost:5000/${isLogin ? "login" : "signup"}');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": emailController.text, "password": passwordController.text}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"]), backgroundColor: Colors.green),
      );

      if (isLogin) {
        setupRansomLearnEnvironment();
        navigateToEmailPage(); // Move to the next screen after login
        
      } else {
        setState(() {
          isLogin = true; // Switch to login page after signup
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["error"]), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers to free memory
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/back1.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              width: 350,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLogin ? 'Login' : 'Signup',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  if (!isLogin)
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signupAndReturnToLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                    ),
                    child: Text(isLogin ? 'Login' : 'Signup'),
                  ),
                  TextButton(
                    onPressed: toggleForm,
                    child: Text(
                      isLogin
                          ? "Don't have an account? Sign up"
                          : "Already have an account? Log in",
                      style: TextStyle(color: Colors.blue.shade400),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
  


class EmailPage extends StatefulWidget {
  const EmailPage({super.key});

  @override
  _EmailPageState createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSending = false;
  bool _BackupEnabled = false;

  Future<void> sendPhishingEmail() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an email address')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    final url = Uri.parse('http://localhost:5000/send-email'); // Adjust if needed
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": _emailController.text}),
    );

    setState(() {
      _isSending = false;
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phishing email sent successfully!')),
      );
      // Navigate to RansomNotePage AFTER email is sent
      String ransomNotePath = "C:\\Users\\yohan\\OneDrive\\Desktop\\RansomLearn\\RansomNote.txt";

      Timer.periodic(Duration(seconds: 5), (timer) {
      String? desktopPath = getDesktopPath();
      if (desktopPath != null) {
        String ransomNotePath = "$desktopPath\\RansomLearn\\RansomNote.txt";
      }    
      if (File(ransomNotePath).existsSync()) {
          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RansomNotePage(BackupEnabled: _BackupEnabled),
          ),
        );

          timer.cancel(); // Stop checking after detecting the note
        }
      });
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send email')),
      );
    }
  }



@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Target Email',
        style: TextStyle(color: Colors.white),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: Color.fromARGB(255, 240, 74, 24),
      elevation: 0,
      toolbarHeight: 50,
    ),
    body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/back2.jpg', fit: BoxFit.cover),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    infoCard(
                      'Email Simulation Triggered',
                      'A phishing email is being sent to the address provided. This simulates how attackers initiate phishing attempts.',
                    ),
                    infoCard(
                      'Risk of Clicking Malicious Links',
                      'Clicking on malicious links may download ransomware, which can encrypt your files and lock access to your data.',
                    ),
                  ],
                ),
              ),
              Container(
                width: 350,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Your Email',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 20),

                    // 🔘 Enable Backup Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Enable Backup',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        Switch(
                          value: _BackupEnabled,
                          onChanged: (value) async {
                            setState(() {
                              _BackupEnabled = value;
                            });

                            if (_BackupEnabled) {
                              createBackupFiles(); // From file_manager.dart
                            } else {
                              await deleteBackupFiles(); // From file_manager.dart
                            }
                          },
                          activeColor: Colors.green,
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _isSending ? null : sendPhishingEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                      ),
                      child: _isSending
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Proceed'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    infoCard(
                      'Ransom Note Delivered',
                      'A ransom note appears, demanding payment to unlock your files. Paying the ransom is risky and doesn’t guarantee that your data will be restored.',
                    ),
                    infoCard(
                      'Potential Data Encryption',
                      'If ransomware is installed, it encrypts your data, demanding payment to restore access.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  Widget infoCard(String title, String content) {
    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.all(12),
      width: 300,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
            ),
          ),
          SizedBox(height: 5),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}


class RansomNotePage extends StatefulWidget {
  final bool BackupEnabled;

  const RansomNotePage({super.key, required this.BackupEnabled}); 

  @override
  _RansomNotePageState createState() => _RansomNotePageState();
}



class _RansomNotePageState extends State<RansomNotePage> {
  int _timeLeft = 60;
  final TextEditingController _passkeyController = TextEditingController();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    if (mounted) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          timer.cancel();
          _showDeletionDialog();
          deleteFiles();
        }
      });
    }
  });
  }

  void _checkPasskey() {
    String enteredPasskey = _passkeyController.text;
    if (enteredPasskey == 'Ransom@Learn') {
      _timer?.cancel();
      _runDecryptionExe();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passkey accepted. Files decrypting..')),
      );
    } else {
      _showWarningDialog();
    }
  }

  Future<void> _runDecryptionExe() async {
    try {
      // Adjust the path to the exe file
      String exePath = "${Directory.current.path}\\lib\\script_decrypt.exe";
      ProcessResult result = await Process.run(exePath, []);

      if (result.exitCode == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Decryption successful!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${result.stderr}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to execute script: $e")),
      );
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Warning'),
        content: Text('Incorrect passkey! Try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Files Deleted'),
        content: Text('Time is up! Your files have been permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _simulateBackup() {
    restoreBackup();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Backup Successful'),
        content: Text('Backup simulated successfully!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pass Key',
          style: TextStyle(color: Colors.white), // White text color
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white, // White back arrow
          ),
          onPressed: () {
            setupRansomLearnEnvironment();
            Navigator.pop(context); // This will take you back to the previous page
          },
        ),
        backgroundColor: Color.fromARGB(255, 4, 4, 4), 
        elevation: 0, // Remove shadow for a flat look
        toolbarHeight: 50, // Adjust height of the AppBar (default is 56)
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/back3.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: Container(
              width: 350,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 68, 67, 67).withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'YOUR FILES HAVE BEEN ENCRYPTED!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'To regain access, enter the passkey. Failure to enter the correct passkey within time limit will result in permanent file deletion.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Time Left: ${_timeLeft ~/ 60}:${(_timeLeft % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellowAccent,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passkeyController,
                    decoration: InputDecoration(
                      labelText: 'Enter Passkey',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _checkPasskey,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text('Submit Passkey'),
                  ),
                ],
              ),
            ),
          ),
    if (_timeLeft == 0 && widget.BackupEnabled)
    Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            restoreBackup(); // Calls restore function from file_manager.dart
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Backup restored successfully!")),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
          ),
          child: Text('Restore Backup'),
        ),
      ),
    )

        ],
      ),
    );
  }
}