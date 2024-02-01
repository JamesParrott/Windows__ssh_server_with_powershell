# escape=`

# The tag year (e.g. 2022 or 2019) should match that of the Windows host, 
# e.g. the version of the Windows github Actions runner image, that's
# running the action that builds an image of this file.
FROM mcr.microsoft.com/windows/servercore:ltsc2022
# hadolint shell=powershell

USER ContainerAdministrator

# servercore already has Powershell installed, and set as the default shell,
# but as Martin found, the next command doesn't work so well in Powershell, 
# so is run in cmd.exe
SHELL ["cmd.exe", "/C"]

# "Add local user"
RUN net USER ssh "Passw0rd" /ADD && net localgroup "Administrators" "ssh" /ADD


SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]


# Set the login shell to PowerShell.  Without this line, the login shell is cmd.
RUN New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force

###################################################################################################################
# The commands in this block are taken from "Get started with OpenSSH for Windows", from Microsoft Learn,
# and simply preppended by "RUN " or combined into multi-line commands, for use in a Dockerfile:
# https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=powershell
#
# "Check if in admin group"
# RUN (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
#
# "Check if OpenSSH already available"
# RUN Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
#
#
# # "Install the OpenSSH Client"
# RUN Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
#
# "Install the OpenSSH Server"
# "Start the sshd service"
# "OPTIONAL but recommended (to set startup type to auto)"
RUN Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0; `
    Start-Service sshd; `
    Set-Service -Name sshd -StartupType 'Automatic'
#
# "Confirm the Firewall rule is configured. " 
#   # It should be created automatically by setup. Run the following to verify"
# RUN >
#     if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
#       Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
#       New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
#     } else {
#       Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
# }
#
#
###################################################################################################################

# Expose port 22 for SSH
EXPOSE 22


# Ping self to keep container alive
CMD ["cmd.exe", "/c", "ping", "-t", "localhost", ">", "NUL"]