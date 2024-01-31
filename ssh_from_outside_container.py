

import fabric

# username, password, port, env_var = sys.argv[1:5]
username, password, port = 'ssh', 'Passw0rd', 22

with fabric.Connection(
        'localhost',
        user = username,
        port = port,
        connect_kwargs ={'password' : password}
        ) as c:
    # print(c.run('$PSVersionTable'))
    # print(c.run(f'echo %{env_var}%'))
    # print(c.run(f'Write-Host $env:{env_var}'))
    # print(c.run(f'Write-Host "Hello_World"'))
    print(c.run(f'echo Hello World!'))