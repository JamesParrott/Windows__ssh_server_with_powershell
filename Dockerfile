# FROM mcr.microsoft.com/windows/servercore:ltsc2022

# USER ContainerAdministrator

# # Install Powershell
# ADD https://github.com/PowerShell/PowerShell/releases/download/v7.3.6/PowerShell-7.3.6-win-x64.zip c:/powershell.zip
# RUN powershell.exe -Command Expand-Archive c:/powershell.zip c:/PS7 ; Remove-Item c:/powershell.zip
# RUN C:/PS7/pwsh.EXE -Command C:/PS7/Install-PowerShellRemoting.ps1

# # Install SSH	
# ADD https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.2.2.0p1-Beta/OpenSSH-Win64.zip c:/openssh.zip
# RUN c:/PS7/pwsh.exe -Command Expand-Archive c:/openssh.zip c:/ ; Remove-Item c:/openssh.zip
# RUN c:/PS7/pwsh.exe -Command c:/OpenSSH-Win64/Install-SSHd.ps1

# # Configure SSH
# COPY sshd_config c:/OpenSSH-Win64/sshd_config
# COPY sshd_banner c:/OpenSSH-Win64/sshd_banner
# WORKDIR c:/OpenSSH-Win64/
# # Don't use powershell as -f paramtere causes problems.
# RUN c:/OpenSSH-Win64/ssh-keygen.exe -t dsa -N "" -f ssh_host_dsa_key && \
#     c:/OpenSSH-Win64/ssh-keygen.exe -t rsa -N "" -f ssh_host_rsa_key && \
#     c:/OpenSSH-Win64/ssh-keygen.exe -t ecdsa -N "" -f ssh_host_ecdsa_key && \
#     c:/OpenSSH-Win64/ssh-keygen.exe -t ed25519 -N "" -f ssh_host_ed25519_key

# # Create a user to login, as containeradministrator password is unknown
# RUN net USER ssh "Passw0rd" /ADD && net localgroup "Administrators" "ssh" /ADD

# # Set PS7 as default shell
# RUN C:/PS7/pwsh.EXE -Command \
#     New-Item -Path HKLM:\SOFTWARE -Name OpenSSH -Force; \
#     New-ItemProperty -Path HKLM:\SOFTWARE\OpenSSH -Name DefaultShell -Value c:\ps7\pwsh.exe -PropertyType string -Force ; 

# RUN C:/PS7/pwsh.EXE -Command \
#     ./Install-sshd.ps1; \
#     ./FixHostFilePermissions.ps1 -Confirm:$false;

# # RUN C:/PS7/pwsh.EXE -Command \
# #     Install-Module -Name NetSecurity


# # RUN C:/PS7/pwsh.EXE -Command \
# #   New-NetFirewallRule \
# #   -Name sshd \
# #   -DisplayName 'OpenSSH SSH Server' \
# #   -Enabled True \
# #   -Direction Inbound \
# #   -Protocol TCP \
# #   -Action Allow \
# #   -LocalPort 22 \
# #   -Program "C:\OpenSSH\sshd.exe"

# EXPOSE 22
# # For some reason SSH stops after build. So start it again when container runs.
# CMD [ "c:/ps7/pwsh.exe", "-NoExit", "-Command", "Start-Service" ,"sshd" ]

# FROM python:windowsservercore-ltsc2022

# EXPOSE 22

# CMD ["python", "-m", "http.server", "22"]


FROM mcr.microsoft.com/windows/servercore:ltsc2022

USER ContainerAdministrator

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]



RUN $PSVersionTable
# On: mcr.microsoft.com/windows/servercore:ltsc2022
# SHELL ["powershell", ...]
#  Name                           Value                                           
# ----                           -----                                           
# PSVersion                      5.1.20348.2227                                  
# PSEdition                      Desktop                                         
# PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0...}                         
# BuildVersion                   10.0.20348.2227                                 
# CLRVersion                     4.0.30319.42000                                 
# WSManStackVersion              3.0                                             
# PSRemotingProtocolVersion      2.3                                             
# SerializationVersion           1.1.0.1     

# https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=powershell

RUN Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
# Name  : OpenSSH.Client~~~~0.0.1.0
# State : Installed
# Name  : OpenSSH.Server~~~~0.0.1.0
# State : NotPresent


RUN Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

EXPOSE 22

RUN if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {\
        Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."\
        New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22\
    } else {\
        Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."\
    }

# Start the sshd service
CMD ["powershell", "-Command", "Start-Service", "sshd"]

# # OPTIONAL but recommended:
# RUN Set-Service -Name sshd -StartupType 'Automatic'

# # Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
# RUN if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {\
#         Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."\
#         New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22\
#     } else {\
#         Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."\
#     }