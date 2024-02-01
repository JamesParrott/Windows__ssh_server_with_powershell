# Use Windows Server Core as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Set the working directory
WORKDIR /ssh-server

# Install OpenSSH Server
RUN Add-WindowsFeature OpenSSH.Server~~~~0.0.1.0

# Set the password for the ssh user
RUN net USER /ADD ssh Passw0rd && net localgroup Administrators ssh /ADD

# Set the login shell to PowerShell
RUN New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force

# Expose port 22 for SSH
EXPOSE 22

# Start the SSH server
CMD powershell.exe -Command Start-Service sshd ; powershell.exe -Command Get-Service sshd
