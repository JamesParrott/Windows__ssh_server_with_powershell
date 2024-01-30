import secrets
import string


chars=string.printable.strip()
print(f"password={''.join(secrets.choice(chars) for __ in range(30))}")