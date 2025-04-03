import os
import glob
from cryptography.fernet import Fernet

def get_desktop_path():
    user_profile = os.environ["USERPROFILE"]
    onedrive_desktop = os.path.join(user_profile, "OneDrive", "Desktop")
    default_desktop = os.path.join(user_profile, "Desktop")
    return onedrive_desktop if os.path.exists(onedrive_desktop) else default_desktop

desktop = get_desktop_path()
ransom_folder = os.path.join(desktop, "RansomLearn")
files_folder = os.path.join(ransom_folder, "Files")
key_folder = os.path.join(ransom_folder, "Key")
key_file = os.path.join(key_folder, "encryption.key")

if not os.path.exists(key_file):
    exit(1)

with open(key_file, "rb") as f:
    key = f.read()

cipher = Fernet(key)

def decrypt_files():
    if not os.path.exists(files_folder):
        exit(1)

    files = glob.glob(os.path.join(files_folder, "*.locked"))

    for file_path in files:
        try:
            with open(file_path, "rb") as f:
                encrypted_data = f.read()

            decrypted_data = cipher.decrypt(encrypted_data)

            original_file_path = file_path.replace(".locked", "")

            with open(original_file_path, "wb") as f:
                f.write(decrypted_data)

            os.remove(file_path)

        except:
            pass

decrypt_files()
