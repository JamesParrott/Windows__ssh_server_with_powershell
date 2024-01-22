FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-Command"]

RUN Add-WindowsCapability -Online -Name OpenSSH.Client

RUN Add-WindowsCapability -Online -Name OpenSSH.Server

# Start the sshd service
RUN Start-Service sshd

# OPTIONAL but recommended:
RUN Set-Service -Name sshd -StartupType 'Automatic'

# # Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
# if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
#     Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
#     New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
# } else {
#     Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
# }

# RUN powershell -NoExit -Command "Add-WindowsFeature OpenSSH-Client; Enable-WindowsOptionalFeature -FeatureName OpenSSH-Server"

# Install additional tools (optional)
# RUN powershell -NoExit -Command "Install-WindowsPackage xpsviewer"

# # Configure SSH server
# RUN powershell -NoExit -Command @" \
# $sshConfig = New-Object System.Management.Automation.PSCustomObject \
# $sshConfig.Add('ListenAddress', '0.0.0.0') \
# $sshConfig.Add('Port', 22) \
# $sshConfig.Add('ChrootDirectory', '%UserProfile%') \
# $sshConfig.Add('LoginShell', 'cmd.exe') \
# $sshConfig | ConvertTo-Xml | Format-List -OutFile -FilePath C:\ProgramData\ssh\sshd_config \
# "@

# # Configure service to run as Local System account
# RUN powershell -NoExit -Command @" \
# New-Service -Name "sshd" -DisplayName "OpenSSH SSH Server" -StartupType Automatic -Description "Provides secure shell access." -Path "C:\Windows\System32\OpenSSH\sshd.exe" -Credential (Get-LocalUser -Name "SYSTEM") -PassThru \
# "@

# # Start the service
# RUN powershell -NoExit -Command "Start-Service sshd"

# # Expose port 22
# EXPOSE 22

# # Set working directory (optional)
# # WORKDIR C:\Users\Administrator

# # CMD as default entrypoint
# ENTRYPOINT ["cmd.exe"]

# # (Optional) Set a custom username and password (replace with desired values)
# RUN pwsh -NoExit -Command "New-LocalUser -Name username_123 -Password (ConvertTo-SecureString -AsPlainText password123_456 -Force)"

# Add additional users (optional)
# RUN pwsh -NoExit -Command "Add-LocalUser -Name additionaluser -Password (ConvertTo-SecureString -AsPlainText password -Force)"

# Disable password logins (recommended for increased security)
# RUN powershell -NoExit -Command "Set-Service sshd -Authentication 'publickey'"
