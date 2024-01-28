# escape=`
# # # Copyright (c) Microsoft Corporation.
# # # Licensed under the MIT License.

# # # https://raw.githubusercontent.com/PowerShell/PowerShell-Docker/master/release/7-3/nanoserver2022/docker/Dockerfile

# # # Args used by from statements must be defined here:
# # ARG InstallerVersion=nanoserver
# # ARG dockerHost=mcr.microsoft.com
# # ARG InstallerRepo=mcr.microsoft.com/powershell
# # ARG NanoServerRepo=windows/nanoserver
# # ARG tag=ltsc2022

# # # Use server core as an installer container to extract PowerShell,
# # # As this is a multi-stage build, this stage will eventually be thrown away
# # FROM ${InstallerRepo}:$InstallerVersion  AS installer-env

# # # Arguments for installing PowerShell, must be defined in the container they are used
# # ARG PS_VERSION=7.0.0

# # ARG PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v$PS_VERSION/PowerShell-$PS_VERSION-win-x64.zip

# # SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# # # disable telemetry
# # ENV POWERSHELL_TELEMETRY_OPTOUT="1"

# # ARG PS_PACKAGE_URL_BASE64

# # RUN Write-host "Verifying valid Version..."; `
# #     if (!($env:PS_VERSION -match '^\d+\.\d+\.\d+(-\w+(\.\d+)?)?$' )) { `
# #         throw ('PS_Version ({0}) must match the regex "^\d+\.\d+\.\d+(-\w+(\.\d+)?)?$"' -f $env:PS_VERSION) `
# #     } `
# #     $ProgressPreference = 'SilentlyContinue'; `
# #     if($env:PS_PACKAGE_URL_BASE64){ `
# #         Write-host "decoding: $env:PS_PACKAGE_URL_BASE64" ;`
# #         $url = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($env:PS_PACKAGE_URL_BASE64)) `
# #     } else { `
# #         Write-host "using url: $env:PS_PACKAGE_URL" ;`
# #         $url = $env:PS_PACKAGE_URL `
# #     } `
# #     Write-host "downloading: $url"; `
# #     [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12; `
# #     New-Item -ItemType Directory /installer > $null ; `
# #     Invoke-WebRequest -Uri $url -outfile /installer/powershell.zip -verbose; `
# #     Expand-Archive /installer/powershell.zip -DestinationPath \PowerShell

# # # Install PowerShell into NanoServer
# # FROM mcr.microsoft.com/${NanoServerRepo}:${tag}

# # # Copy PowerShell Core from the installer container
# # ENV ProgramFiles="C:\Program Files" `
# #     # set a fixed location for the Module analysis cache
# #     PSModuleAnalysisCachePath="C:\Users\Public\AppData\Local\Microsoft\Windows\PowerShell\docker\ModuleAnalysisCache" `
# #     # Persist %PSCORE% ENV variable for user convenience
# #     PSCORE="$ProgramFiles\PowerShell\pwsh.exe" `
# #     # Set the default windows path so we can use it
# #     WindowsPATH="C:\Windows\system32;C:\Windows" `
# #     POWERSHELL_DISTRIBUTION_CHANNEL="PSDocker-NanoServer-ltsc2022"

# # ### Begin workaround ###
# # # Note that changing user on nanoserver is not recommended
# # # See, https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/container-base-images#base-image-differences
# # # But we are working around a bug introduced in the nanoserver image introduced in 1809
# # # Without this, PowerShell Direct will fail
# # # this command sholud be like this: https://github.com/PowerShell/PowerShell-Docker/blob/f81009c42c96af46aef81eb1515efae0ef29ad5f/release/preview/nanoserver/docker/Dockerfile#L76
# # USER ContainerAdministrator

# # # This is basically the correct code except for the /M
# # RUN setx PATH "%PATH%;%ProgramFiles%\PowerShell;" /M

# # USER ContainerUser
# # ### End workaround ###

# # COPY --from=installer-env ["\\PowerShell\\", "$ProgramFiles\\PowerShell"]

# # # intialize powershell module cache
# # RUN pwsh `
# #         -NoLogo `
# #         -NoProfile `
# #         -Command " `
# #           $stopTime = (get-date).AddMinutes(15); `
# #           $ErrorActionPreference = 'Stop' ; `
# #           $ProgressPreference = 'SilentlyContinue' ; `
# #           while(!(Test-Path -Path $env:PSModuleAnalysisCachePath)) {  `
# #             Write-Host "'Waiting for $env:PSModuleAnalysisCachePath'" ; `
# #             if((get-date) -gt $stopTime) { throw 'timout expired'} `
# #             Start-Sleep -Seconds 6 ; `
# #           }"

# # # re-enable telemetry
# # ENV POWERSHELL_TELEMETRY_OPTOUT="0"

# # # CMD ["pwsh.exe"]


# # Use the official nanoserver:lts-ltsc2022 base image
# # FROM mcr.microsoft.com/windows/nanoserver:ltsc2022

# # Use an official PowerShell Nanoserver image https://hub.docker.com/_/microsoft-powershell
# FROM mcr.microsoft.com/powershell:lts-7.2-nanoserver-ltsc2022

# # Set environment variables
# ENV SSHD_VERSION=9.5.0.0p1-Beta
# # ENV SSHD_INSTALL_FOLDER="C:\OpenSSH"

# USER ContainerAdministrator


# # Download and install OpenSSH
# # RUN mkdir SSHD_INSTALL_FOLDER

# SHELL ["pwsh.exe", "-Command"]

# RUN Invoke-WebRequest -Uri "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.5.0.0p1-Beta/OpenSSH-Win64.zip" -OutFile "openssh.zip" -UseBasicParsing
# # RUN Expand-Archive -Path "openssh.zip" -DestinationPath .
# # # RUN Remove-Item "openssh.zip" -Force
# # # RUN $env:PATH = "${SSHD_INSTALL_FOLDER}\bin;${PATH}"


# # # RUN setx PATH %PATH%;SSHD_INSTALL_FOLDER\OpenSSH-Win64; /M

# # # RUN [System.Environment]::SetEnvironmentVariable('PATH', %PATH%;SSHD_INSTALL_FOLDER\OpenSSH-Win64;, [System.EnvironmentVariableTarget]::Machine)

# # # Configure OpenSSH
# # WORKDIR OpenSSH-Win64

# # RUN cmd /C mkdir %PROGRAMDATA%\ssh
# # # RUN mkdir __PROGRAMDATA__\ssh
# # RUN .\ssh-keygen.exe -A
# # # RUN Set-Service -Name sshd -StartupType 'Automatic'
# # RUN New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

# ##################################################################################################################################################
# # https://www.saotn.org/install-openssh-in-windows-server/
# RUN Unblock-File "openssh.zip"
# RUN Expand-Archive "openssh.zip" -DestinationPath .
# # RUN Copy-Item -Recurse .\OpenSSH-Win64\ 'C:\'
# RUN &icacls C:\OpenSSH-Win64\libcrypto.dll /grant Everyone:RX
# RUN C:\OpenSSH-Win64\install-sshd.ps1 
# # to create the OpenSSH Authentication Agent and OpenSSH SSH Server services. It also sets some permissions and registers an Event Tracing (ETW) provider.
# RUN &sc.exe config sshd start= auto
# RUN &sc.exe config ssh-agent start= auto
# # RUN &sc.exe start sshd
# # RUN &sc.exe start ssh-agent
# #    Make sure your Windows Defender Firewall is open for port 22, rule OpenSSH-Server-In-TCP must be enabled. If this rule is not available, manually create it:

# # RUN Register-PSRepository -Default

# RUN $PSVersionTable

# RUN Install-Module -Name NetSecurity

# # RUN New-NetFirewallRule `
# #   -Name sshd `
# #   -DisplayName 'OpenSSH SSH Server' `
# #   -Enabled True `
# #   -Direction Inbound `
# #   -Protocol TCP `
# #   -Action Allow `
# #   -LocalPort 22 `
# #   -Program "C:\OpenSSH\sshd.exe"


# ##################################################################################################################################################

# # Expose the SSH port
# EXPOSE 22

# # Start the SSH server
# CMD ["sshd", "-D", "-e"]


##################################################################################################################################################
# https://gitlab.com/DarwinJS/ChocoPackages/-/blob/master/openssh/Dockerfile

#Docker file for installing SSH

#Adjust line following comments to select desired edition of Server 2016
#FROM microsoft/windowsservercore:latest

# FROM microsoft/nanoserver:latest

# FROM mcr.microsoft.com/windows/nanoserver:ltsc2022

# FROM mcr.microsoft.com/windows/servercore:ltsc2022
# FROM mcr.microsoft.com/powershell:lts-7.2-windowsservercore-ltsc2022

# SHELL ["pwsh.exe", "-Command"]

# USER ContainerAdministrator

# # RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# RUN Install-PackageProvider NuGet -forcebootstrap -force
# RUN Register-PackageSource -name chocolatey -provider nuget -location http://chocolatey.org/api/v2/ -trusted
# RUN Install-Package openssh -provider NuGet
# RUN If (Test-Path "$env:programfiles\PackageManagement\NuGet\Packages") {$NuGetPkgRoot = "$env:programfiles\PackageManagement\NuGet\Packages"} elseIf (Test-Path "$env:programfiles\NuGet\Packages") {$NuGetPkgRoot = "$env:programfiles\NuGet\Packages"} ; cd ("$NuGetPkgRoot\openssh." + "$((dir "$env:ProgramFiles\nuget\packages\openssh*" | %{[version]$_.name.trimstart('openssh.')} | sort | select -last 1) -join '.')\tools") ; . ".\barebonesinstaller.ps1" -SSHServerFeature

# # # USER ContainerUser

# EXPOSE 22/tcp


##################################################################################################################################################
# https://gist.github.com/MartinSGill/0d29fbddfae9f742abfd04ce83dd7f67

# FROM mcr.microsoft.com/windows/servercore:ltsc2022

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

# EXPOSE 22
# # For some reason SSH stops after build. So start it again when container runs.
# CMD [ "c:/ps7/pwsh.exe", "-NoExit", "-Command", "Start-Service" ,"sshd" ]





##################################################################################################################################################

# 
# FROM mcr.microsoft.com/powershell:lts-7.2-windowsservercore-ltsc2022

FROM python:windowsservercore-ltsc2022

USER ContainerAdministrator

# SHELL ["pwsh.exe", "-Command"]

# RUN $PSVersionTable

# Install Powershell v7.3.6
ADD https://github.com/PowerShell/PowerShell/releases/download/v7.3.6/PowerShell-7.3.6-win-x64.zip c:\powershell.zip
# RUN powershell.exe -Command Expand-Archive c:\powershell.zip c:\PS7 ; Remove-Item c:\powershell.zip
RUN Expand-Archive c:\powershell.zip c:\PS7 ; Remove-Item c:\powershell.zip


SHELL ["c:\\PS7\\pwsh.EXE", "-Command"]

RUN c:\PS7\Install-PowerShellRemoting.ps1

# Install SSH	
ADD https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.2.2.0p1-Beta/OpenSSH-Win64.zip c:\openssh.zip
RUN Expand-Archive c:\openssh.zip c:\ ; Remove-Item c:\openssh.zip
RUN c:\OpenSSH-Win64\Install-SSHd.ps1

# Configure SSH
COPY sshd_config c:\OpenSSH-Win64\sshd_config
COPY sshd_banner c:\OpenSSH-Win64\sshd_banner
WORKDIR c:\OpenSSH-Win64\


SHELL ["cmd.exe", "/C"]

# Don't use powershell as -f parameter causes problems.
RUN c:\OpenSSH-Win64\ssh-keygen.exe -t dsa -N "" -f ssh_host_dsa_key && `
    c:\OpenSSH-Win64\ssh-keygen.exe -t rsa -N "" -f ssh_host_rsa_key && `
    c:\OpenSSH-Win64\ssh-keygen.exe -t ecdsa -N "" -f ssh_host_ecdsa_key && `
    c:\OpenSSH-Win64\ssh-keygen.exe -t ed25519 -N "" -f ssh_host_ed25519_key

# Create a user to login, as containeradministrator password is unknown
RUN net USER ssh "Passw0rd" /ADD && net localgroup "Administrators" "ssh" /ADD

# SHELL ["pwsh.exe", "-Command"]

SHELL ["c:\\PS7\\pwsh.EXE", "-Command"]

# Set PS7 as default shell
# RUN c:\PS7\pwsh.EXE -Command `
RUN New-Item -Path HKLM:\SOFTWARE -Name OpenSSH -Force; `
    New-ItemProperty -Path HKLM:\SOFTWARE\OpenSSH -Name DefaultShell -Value c:\ps7\pwsh.exe -PropertyType string -Force ; 

# RUN c:\PS7\pwsh.EXE -Command `
RUN .\Install-sshd.ps1; `
    .\FixHostFilePermissions.ps1 -Confirm:$false;

# RUN New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

# EXPOSE 22

WORKDIR c:\test_ssh_script

# ENTRYPOINT ["c:\PS7\pwsh.EXE"]

COPY test_windows_dockerfile.py .

# For some reason SSH stops after build. So start it again when container runs.
CMD [ "pwsh.exe", "-NoExit", "-Command", "Start-Service" ,"sshd", "-D", "-e" ]
