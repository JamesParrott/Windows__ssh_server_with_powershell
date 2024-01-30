# escape=`


# FROM python:windowsservercore-ltsc2022

# Use the .NET Framework runtime image
# FROM mcr.microsoft.com/dotnet/framework/runtime:4.8.1
#AS base

# FROM mcr.microsoft.com/windows/server:ltsc2022

# FROM mcr.microsoft.com/windows/servercore:ltsc2022

# FROM mcr.microsoft.com/windows/nanoserver:ltsc2022

# FROM python:windowsservercore-ltsc2022

FROM mcr.microsoft.com/powershell:lts-7.2-nanoserver-ltsc2022

USER ContainerAdministrator

WORKDIR c:\OpenSSH-Win64\

# RUN Get-WindowsCapability -Online | Where-Object Name -like 'python*'

# RUN Get-WindowsCapability -Online | Where-Object Name -like 'Python*'


SHELL ["cmd.exe", "/C"]
# "Add local user"
# RUN cmd.exe "/C" net USER ssh "Passw0rd" /ADD && net localgroup "Administrators" "ssh" /ADD
RUN net USER ssh "Passw0rd" /ADD && net localgroup "Administrators" "ssh" /ADD

# SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

SHELL ["$ProgramFiles\\PowerShell\\pwsh.exe", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install Python
RUN Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.9.6/python-3.9.6-amd64.exe" -OutFile "python-installer.exe"; `
    Start-Process python-installer.exe -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1' -Wait; `
    Remove-Item python-installer.exe

# Test Python installation
RUN python --version


# "Check if in admin group"
RUN (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# "Check if OpenSSH already available"
RUN Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'


# # "Install the OpenSSH Client.  "
# RUN Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# "Install the OpenSSH Server"
RUN Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# "Start the sshd service"
RUN Start-Service sshd

# "OPTIONAL but recommended"
RUN Set-Service -Name sshd -StartupType 'Automatic'

# "Confirm the Firewall rule is configured. " 
#   # It should be created automatically by setup. Run the following to verify"
# RUN >
#     if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
#       Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
#       New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
#     } else {
#       Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
# }

# keep container from this image running, when it's "docker run".
CMD ["cmd.exe", "/c", "ping", "-t", "localhost", ">", "NUL"]