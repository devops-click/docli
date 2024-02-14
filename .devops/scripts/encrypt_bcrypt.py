import bcrypt
import sys

def generate_bcrypt_hash(password):
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode(), salt)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 script.py <password>")
        sys.exit(1)

    password = sys.argv[1]
    hashed_password = generate_bcrypt_hash(password)
    print(hashed_password)
