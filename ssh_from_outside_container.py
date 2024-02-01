
import sys

import fabric

username, password, port = sys.argv[1:4]

with fabric.Connection(
        'localhost',
        user = username,
        port = port,
        connect_kwargs ={'password' : password}
        ) as c:
    
    # https://stackoverflow.com/a/61469226/20785734
    c.run('(dir 2>&1 *`|echo CMD);&<# rem #>echo $PSVersionTable'),
                # Returns:CMD or $PSVersionTable
    
    # Alternative if using cmd as login shell:
    #     c.run(f'echo Hello World!')
    
    c.run('Write-Host "Hello_World"')


