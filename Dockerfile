FROM mcr.microsoft.com/windows/servercore:ltsc2019
RUN powershell -NoExit -Command "Add-WindowsFeature OpenSSH-Client; Enable-WindowsOptionalFeature -FeatureName OpenSSH-Server"

# Install additional tools (optional)
# RUN powershell -NoExit -Command "Install-WindowsPackage xpsviewer"

# Configure SSH server
RUN powershell -NoExit -Command @" \
$sshConfig = New-Object System.Management.Automation.PSCustomObject \
$sshConfig.Add('ListenAddress', '0.0.0.0') \
$sshConfig.Add('Port', 22) \
$sshConfig.Add('ChrootDirectory', '%UserProfile%') \
$sshConfig.Add('LoginShell', 'cmd.exe') \
$sshConfig | ConvertTo-Xml | Format-List -OutFile -FilePath C:\ProgramData\ssh\sshd_config \
"@

# Configure service to run as Local System account
RUN powershell -NoExit -Command @" \
New-Service -Name "sshd" -DisplayName "OpenSSH SSH Server" -StartupType Automatic -Description "Provides secure shell access." -Path "C:\Windows\System32\OpenSSH\sshd.exe" -Credential (Get-LocalUser -Name "SYSTEM") -PassThru \
"@

# Start the service
RUN powershell -NoExit -Command "Start-Service sshd"

# Expose port 22
EXPOSE 22

# Set working directory (optional)
# WORKDIR C:\Users\Administrator

# CMD as default entrypoint
ENTRYPOINT ["cmd.exe"]

# (Optional) Set a custom username and password (replace with desired values)
RUN pwsh -NoExit -Command "New-LocalUser -Name username_123 -Password (ConvertTo-SecureString -AsPlainText password123_456 -Force)"

# Add additional users (optional)
# RUN pwsh -NoExit -Command "Add-LocalUser -Name additionaluser -Password (ConvertTo-SecureString -AsPlainText password -Force)"

# Disable password logins (recommended for increased security)
# RUN powershell -NoExit -Command "Set-Service sshd -Authentication 'publickey'"
