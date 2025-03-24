import sys
import os
from PyQt6.QtWidgets import QApplication, QWidget, QPushButton, QFileDialog, QLabel, QVBoxLayout
from Crypto.Cipher import AES

# AES Key (must be 16, 24, or 32 bytes)
KEY = b'ThisIsASecretKey'

# Padding function
def pad(data):
    return data + b"\0" * (16 - len(data) % 16)

# Encrypt function
def encrypt_file(file_path):
    with open(file_path, "rb") as f:
        data = f.read()
    cipher = AES.new(KEY, AES.MODE_ECB)
    encrypted_data = cipher.encrypt(pad(data))
    with open(file_path, "wb") as f:
        f.write(encrypted_data)

# Decrypt function
def decrypt_file(file_path):
    with open(file_path, "rb") as f:
        encrypted_data = f.read()
    cipher = AES.new(KEY, AES.MODE_ECB)
    decrypted_data = cipher.decrypt(encrypted_data).rstrip(b"\0")
    with open(file_path, "wb") as f:
        f.write(decrypted_data)

# PyQt GUI Class
class EncryptorApp(QWidget):
    def __init__(self):
        super().__init__()
        self.initUI()

    def initUI(self):
        self.setWindowTitle("File Encryptor")
        self.setGeometry(100, 100, 400, 250)

        layout = QVBoxLayout()

        self.label = QLabel("Select a folder to encrypt/decrypt", self)
        layout.addWidget(self.label)

        self.encrypt_btn = QPushButton("🔒 Encrypt Folder", self)
        self.encrypt_btn.clicked.connect(self.encrypt_folder)
        layout.addWidget(self.encrypt_btn)

        self.decrypt_btn = QPushButton("🔓 Decrypt Folder", self)
        self.decrypt_btn.clicked.connect(self.decrypt_folder)
        layout.addWidget(self.decrypt_btn)

        self.setLayout(layout)

    def encrypt_folder(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Folder")
        if not folder:
            return
        for filename in os.listdir(folder):
            file_path = os.path.join(folder, filename)
            if os.path.isfile(file_path):
                encrypt_file(file_path)
        self.label.setText("✅ Files Encrypted!")

    def decrypt_folder(self):
        folder = QFileDialog.getExistingDirectory(self, "Select Folder")
        if not folder:
            return
        for filename in os.listdir(folder):
            file_path = os.path.join(folder, filename)
            if os.path.isfile(file_path):
                decrypt_file(file_path)
        self.label.setText("🔓 Files Decrypted!")

# Run the app
if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = EncryptorApp()
    window.show()
    sys.exit(app.exec())
