# escape=`

# The tag year (e.g. 2022 or 2019) should match that of the Windows host, 
# e.g. the version of the Windows github Actions runner image, that's
# running the action that builds an image of this file.

FROM mcr.microsoft.com/windows/servercore:ltsc2022

USER ContainerAdministrator

RUN dir C:\Windows\System32\*Powershell*

# # To match Martin's Dockerfile.  OpensSH is likely to be installed elsewhere.
# WORKDIR c:\OpenSSH-Win64\

# # servercore already has Powershell installed, and set as the default shell,
# # but the next command doens't work so well in Powershell, so is run in cmd.exe
# SHELL ["cmd.exe", "/C"]

# # "Add local user"
# RUN net USER ssh "Passw0rd" /ADD && net localgroup "Administrators" "ssh" /ADD


# SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]


# # Set the login shell to PowerShell
# # RUN New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force

# ###################################################################################################################
# # The commands in this block are taken from "Get started with OpenSSH for Windows", from Microsoft Learn,
# # and prepended by "RUN " for use in a Dockerfile:
# # https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=powershell
# #
# # "Check if in admin group"
# # RUN (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
# #
# # "Check if OpenSSH already available"
# # RUN Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
# #
# #
# # # "Install the OpenSSH Client"
# # RUN Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
# #
# # "Install the OpenSSH Server"
# RUN Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
# #
# # "Start the sshd service"
# RUN Start-Service sshd
# #
# # "OPTIONAL but recommended"
# RUN Set-Service -Name sshd -StartupType 'Automatic'
# #
# # "Confirm the Firewall rule is configured. " 
# #   # It should be created automatically by setup. Run the following to verify"
# # RUN >
# #     if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
# #       Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
# #       New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
# #     } else {
# #       Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
# # }
# #
# #
# ###################################################################################################################

# # # Optional.  Set Powershell as default Shell.  
# # RUN Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name Shell -Value 'PowerShell.exe -NoExit'

# # Set PS as default shell
# # RUN New-Item -Path HKLM:\SOFTWARE -Name OpenSSH -Force; `
# #     New-ItemProperty -Path HKLM:\SOFTWARE\OpenSSH -Name DefaultShell -Value 'PowerShell.exe -NoExit' -PropertyType string -Force ; 
#     # New-ItemProperty -Path HKLM:\SOFTWARE\OpenSSH -Name DefaultShell -Value c:\ps6\pwsh.exe -PropertyType string -Force ; 

# # Expose port 22 for SSH
# EXPOSE 22

# # Start the SSH server
# CMD powershell.exe -Command Start-Service sshd ; powershell.exe -Command Get-Service sshd
# # # keep container from this image running, when it's "docker run".
# # CMD ["cmd.exe", "/c", "ping", "-t", "localhost", ">", "NUL"]