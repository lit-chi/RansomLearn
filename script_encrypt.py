import os
import io
import zipfile
import base64
import pyperclip
from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes

FOLDER_PATH = "test"
KEY_FILE = "encryption_key.key"

def generate_key():
    """Generate and save a 32-byte AES key."""
    key = get_random_bytes(32)
    with open(KEY_FILE, "wb") as keyfile:
        keyfile.write(key)
    return key

def load_key():
    """Load AES key from file."""
    if not os.path.exists(KEY_FILE):
        return generate_key()
    with open(KEY_FILE, "rb") as keyfile:
        return keyfile.read()

def compress_folder():
    """Compress the folder into an in-memory ZIP file."""
    zip_buffer = io.BytesIO()
    with zipfile.ZipFile(zip_buffer, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, _, files in os.walk(FOLDER_PATH):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, FOLDER_PATH)
                zipf.write(file_path, arcname)
    return zip_buffer.getvalue()

def encrypt_data(data, key):
    """Encrypt data using AES-256-CBC."""
    iv = get_random_bytes(16)
    cipher = AES.new(key, AES.MODE_CBC, iv)
    pad_length = 16 - (len(data) % 16)
    data += bytes([pad_length]) * pad_length  # PKCS7 padding
    encrypted = cipher.encrypt(data)
    return iv + encrypted  # Store IV with encrypted data

def store_in_clipboard(data):
    """Encode data as Base64 and store in clipboard."""
    encoded = base64.b64encode(data).decode()
    pyperclip.copy(encoded)
    print("✅ Encrypted data stored in clipboard!")

def encrypt():
    print("meow meow meow meowwwwwww")
    if not os.path.exists(FOLDER_PATH):
        print("Folder not found!")
        return
    
    key = load_key()    
    zip_data = compress_folder()
    encrypted_data = encrypt_data(zip_data, key)
    store_in_clipboard(encrypted_data)
    
    print(f"✅ {FOLDER_PATH} encrypted and stored in clipboard!")
    
encrypt()
