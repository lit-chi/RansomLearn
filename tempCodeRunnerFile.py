)
        return None
    with open(KEY_FILE, "rb") as keyfile:
        return keyfile.read()

def decrypt_data(data, key):
    """Decrypt data using AES-256-CBC."""
    iv = data[:16]
    encrypted = data[16:]
    cipher = AES.new(key, AES.MODE_CBC, iv)