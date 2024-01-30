import sys

import fabric

username, password, port, env_var = sys.argv[1:5]

with fabric.Connection(
        'localhost',
        username = username,
        port = port,
        connect_kwargs ={'password' : password}
        ) as c:
    print(c.run('$PSVersionTable'))
    # print(c.run(f'echo %{env_var}%'))
    print(c.run(f'Write-Host $env:{env_var}'))
