import os
import io
import zipfile
import base64
import pyperclip
from Crypto.Cipher import AES

FOLDER_PATH = "test"
KEY_FILE = "encryption_key.key"

def load_key():
    """Load the encryption key from file."""
    if not os.path.exists(KEY_FILE):
        print("❌ Encryption key not found!")
        return None
    with open(KEY_FILE, "rb") as keyfile:
        return keyfile.read()

def decrypt_data(data, key):
    """Decrypt data using AES-256-CBC."""
    iv = data[:16]
    encrypted = data[16:]
    cipher = AES.new(key, AES.MODE_CBC, iv)
    decrypted = cipher.decrypt(encrypted)
    pad_length = decrypted[-1]
    return decrypted[:-pad_length]  # Remove padding

def retrieve_from_clipboard():
    """Retrieve Base64 encoded data from clipboard."""
    encoded = pyperclip.paste()
    return base64.b64decode(encoded)

def extract_zip(data):
    """Extract ZIP contents from memory."""
    zip_buffer = io.BytesIO(data)
    with zipfile.ZipFile(zip_buffer, 'r') as zipf:
        zipf.extractall(FOLDER_PATH)
    print(f"✅ {FOLDER_PATH} restored!")

def decrypt():
    key = load_key()
    if not key:
        return
    
    encrypted_data = retrieve_from_clipboard()
    zip_data = decrypt_data(encrypted_data, key)
    extract_zip(zip_data)

decrypt()
