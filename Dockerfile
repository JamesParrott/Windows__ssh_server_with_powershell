# Use the official nanoserver:lts-ltsc2022 base image
FROM mcr.microsoft.com/windows/nanoserver:ltsc2022

# Set environment variables
ENV SSHD_VERSION="9.5.0.0p1-Beta"
ENV SSHD_INSTALL_FOLDER="C:\Program Files\OpenSSH"

# Download and install OpenSSH
RUN mkdir $env:SSHD_INSTALL_FOLDER ; \
    Invoke-WebRequest -Uri "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v${env:SSHD_VERSION}/OpenSSH-Win64.zip" -OutFile "openssh.zip" -UseBasicParsing ; \
    Expand-Archive -Path "openssh.zip" -DestinationPath $env:SSHD_INSTALL_FOLDER ; \
    Remove-Item "openssh.zip" -Force ; \
    $env:PATH = "${env:SSHD_INSTALL_FOLDER}\bin;$env:PATH" ; \
    [System.Environment]::SetEnvironmentVariable('PATH', $env:PATH, [System.EnvironmentVariableTarget]::Machine)

# Configure OpenSSH
RUN ssh-keygen -A ; \
    Set-Service -Name sshd -StartupType 'Automatic' ; \
    New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

# Expose the SSH port
EXPOSE 22

# Start the SSH server
CMD ["sshd", "-D"]
