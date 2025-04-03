import os
import glob
from cryptography.fernet import Fernet

# Get desktop path (Handles OneDrive case)
def get_desktop_path():
    user_profile = os.environ["USERPROFILE"]
    onedrive_desktop = os.path.join(user_profile, "OneDrive", "Desktop")
    default_desktop = os.path.join(user_profile, "Desktop")

    return onedrive_desktop if os.path.exists(onedrive_desktop) else default_desktop

# Define paths
desktop = get_desktop_path()
ransom_folder = os.path.join(desktop, "RansomLearn")
files_folder = os.path.join(ransom_folder, "Files")
key_folder = os.path.join(ransom_folder, "Key")
key_file = os.path.join(key_folder, "encryption.key")
ransom_note = os.path.join(ransom_folder, "RansomNote.txt")

def load_key():
    """Load the encryption key from file."""
    if not os.path.exists(key_file):
        print("❌ Error: Key file not found!")
        exit(1)
    with open(key_file, "rb") as f:
        return f.read()

# Load key and create cipher
key = load_key()
cipher = Fernet(key)

def decrypt_files():
    """Decrypt all encrypted files in the 'Files' folder."""
    if not os.path.exists(files_folder):
        print("❌ Error: 'Files' folder not found!")
        exit(1)

    encrypted_files = glob.glob(os.path.join(files_folder, "*.locked"))

    for enc_file in encrypted_files:
        try:
            with open(enc_file, "rb") as f:
                encrypted_data = f.read()

            decrypted_data = cipher.decrypt(encrypted_data)
            original_filename = enc_file.replace(".locked", "")

            with open(original_filename, "wb") as f:
                f.write(decrypted_data)

            os.remove(enc_file)  # Delete encrypted file
            print(f"🔓 Decrypted: {os.path.basename(original_filename)}")

        except Exception as e:
            print(f"❌ Error decrypting {enc_file}: {e}")

# Run decryption
decrypt_files()
if os.path.exists(ransom_note):
    os.remove(ransom_note)  # Remove ransom note after decryption

print("\n✅ All files have been decrypted!")
