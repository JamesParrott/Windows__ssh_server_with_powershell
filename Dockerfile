# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2022
# hadolint shell=powershell

USER ContainerAdministrator

SHELL ["cmd.exe", "/C"]

RUN net USER ssh "Passw0rd" /ADD && net localgroup "Administrators" "ssh" /ADD

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force

RUN Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0; `
    Start-Service sshd; `
    Set-Service -Name sshd -StartupType 'Automatic'

EXPOSE 22

# Ping self to keep container alive
CMD ["cmd.exe", "/c", "ping", "-t", "localhost", ">", "NUL"]