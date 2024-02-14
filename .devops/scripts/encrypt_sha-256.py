import hashlib
import sys

def generate_sha256_hash(password):
    return hashlib.sha256(password.encode()).hexdigest()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 script.py <password>")
        sys.exit(1)

    password = sys.argv[1]
    hashed_password = generate_sha256_hash(password)
    print(hashed_password)
