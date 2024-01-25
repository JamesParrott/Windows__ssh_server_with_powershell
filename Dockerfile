FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Install Powershell
ADD https://github.com/PowerShell/PowerShell/releases/download/v7.3.6/PowerShell-7.3.6-win-x64.zip c:/powershell.zip
RUN powershell.exe -Command Expand-Archive c:/powershell.zip c:/PS7 ; Remove-Item c:/powershell.zip
RUN C:/PS7/pwsh.EXE -Command C:/PS7/Install-PowerShellRemoting.ps1

# Install SSH	
ADD https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.2.2.0p1-Beta/OpenSSH-Win64.zip c:/openssh.zip
RUN c:/PS7/pwsh.exe -Command Expand-Archive c:/openssh.zip c:/ ; Remove-Item c:/openssh.zip
RUN c:/PS7/pwsh.exe -Command c:/OpenSSH-Win64/Install-SSHd.ps1

# Configure SSH
COPY sshd_config c:/OpenSSH-Win64/sshd_config
COPY sshd_banner c:/OpenSSH-Win64/sshd_banner
WORKDIR c:/OpenSSH-Win64/
# Don't use powershell as -f paramtere causes problems.
RUN c:/OpenSSH-Win64/ssh-keygen.exe -t dsa -N "" -f ssh_host_dsa_key && \
    c:/OpenSSH-Win64/ssh-keygen.exe -t rsa -N "" -f ssh_host_rsa_key && \
    c:/OpenSSH-Win64/ssh-keygen.exe -t ecdsa -N "" -f ssh_host_ecdsa_key && \
    c:/OpenSSH-Win64/ssh-keygen.exe -t ed25519 -N "" -f ssh_host_ed25519_key

# Create a user to login, as containeradministrator password is unknown
RUN net USER ssh "Passw0rd" /ADD && net localgroup "Administrators" "ssh" /ADD

# Set PS7 as default shell
RUN C:/PS7/pwsh.EXE -Command \
    New-Item -Path HKLM:\SOFTWARE -Name OpenSSH -Force; \
    New-ItemProperty -Path HKLM:\SOFTWARE\OpenSSH -Name DefaultShell -Value c:\ps7\pwsh.exe -PropertyType string -Force ; 

RUN C:/PS7/pwsh.EXE -Command \
    ./Install-sshd.ps1; \
    ./FixHostFilePermissions.ps1 -Confirm:$false;

RUN C:/PS7/pwsh.EXE -Command \
    Install-Module -Name NetSecurity

RUN C:/PS7/pwsh.EXE -Command \
  New-NetFirewallRule \
  -Name sshd \
  -DisplayName 'OpenSSH SSH Server' \
  -Enabled True \
  -Direction Inbound \
  -Protocol TCP \
  -Action Allow \
  -LocalPort 22 \
  -Program "C:\OpenSSH\sshd.exe"

EXPOSE 22
# For some reason SSH stops after build. So start it again when container runs.
CMD [ "c:/ps7/pwsh.exe", "-NoExit", "-Command", "Start-Service" ,"sshd" ]