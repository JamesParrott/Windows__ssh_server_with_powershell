# escape=`

# The tag (2022 or 2019) should match that of the Windows host, 
# e.g. the version of the Windows github Actions runner image.
# servercore has Powershell installed, and set as default shell.
FROM mcr.microsoft.com/windows/servercore:ltsc2022


# " 
# WARNING 
# It is not recommended to use build-time variables for passing secrets 
# like GitHub keys, user credentials etc. Build-time variable values are 
# visible to any user of the image with the docker history command.

# Refer to the RUN --mount=type=secret section to learn about secure ways 
# to use secrets when building images.  
# "
# https://docs.docker.com/engine/reference/builder/#arg
ARG USERNAME
ARG PASSWORD
ARG PORT

USER ContainerAdministrator

# Use same Workdir as Martin's Dockerfile, even though OpenSSH will most
# likely be installed elsewhere (by Add-WindowsCapability below).
WORKDIR c:\OpenSSH-Win64\

# SHELL ["cmd.exe", "/C"]

# # "Add local user"
# # RUN net USER ${USERNAME} ${PASSWORD}  /ADD && net localgroup "Administrators" ${USERNAME} /ADD
# RUN net USER ssh "Passw0rd" /ADD && net localgroup "Administrators" "ssh" /ADD

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Hencefoth, commands taken from "Get started with OpenSSH for Windows", from Microsfot Learn.
# https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=powershell

# "Check if in admin group"
# RUN (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# "Check if OpenSSH already available"
# RUN Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'


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

EXPOSE ${PORT}

# keep container from this image running, when it's "docker run".
CMD ["cmd.exe", "/c", "ping", "-t", "localhost", ">", "NUL"]

ENTRYPOINT ["cmd.exe", "/c", "set_user_and_keep_container_running.bat"]