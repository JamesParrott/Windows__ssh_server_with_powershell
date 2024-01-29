# escape=`


FROM python:windowsservercore-ltsc2022

SHELL ["cmd.exe", "/C"]
# "Add local user"
RUN net USER ssh "Passw0rd" /ADD && net localgroup "Administrators" "ssh" /ADD

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# "Check if in admin group"
RUN (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# "Check if OpenSSH already available"
RUN Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'


# # "Install the OpenSSH Client"
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


CMD ["cmd.exe", "/c", "ping", "-t", "localhost", ">", "NUL"]