
import sys

import fabric

# username, password, port, env_var = sys.argv[1:5]
username, password, port = sys.argv[1:4]

with fabric.Connection(
        'localhost',
        user = username,
        port = port,
        connect_kwargs ={'password' : password}
        ) as c:
    print('CMD or PSVersionTable: Shell is: ',
                # https://stackoverflow.com/a/61469226/20785734
          c.run('(dir 2>&1 *`|echo CMD);&<# rem #>echo $PSVersionTable'),
                # Returns one of: CMD, Core, Desktop}')
          )  
    
    # Alternatives if using cmd as login shell
    #     print(c.run(f'echo %{env_var}%'))
    #     print(c.run(f'echo Hello World!'))
    
    print(c.run(f'Write-Host $env:{env_var}'))
    print(c.run('Write-Host "Hello_World"'))

