import secrets
import string


chars=(string.ascii_letters + string.digits)
print(f"password={''.join(secrets.choice(chars) for __ in range(30))}")