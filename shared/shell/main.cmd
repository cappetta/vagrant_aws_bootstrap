echo 'Ensuring .NET 4.0 is installed'
@powershell -NoProfile -ExecutionPolicy Bypass -File "c:\vagrantshared\shell\InstallNet4.ps1"

echo 'Ensuring Chocolatey is Installed'
@powershell -NoProfile -ExecutionPolicy Bypass -File "c:\vagrantshared\shell\InstallChocolatey.ps1"

echo 'Install puppet if missing'
@powershell -NoProfile -ExecutionPolicy Bypass -File "c:\vagrantshared\shell\InstallPuppetFromMSI.ps1"

SET PATH=%PATH%;%SystemDrive%\Program Files (x86)\Puppet Labs\Puppet\bin;%SystemDrive%\Program Files\Puppet Labs\Puppet\bin;
@powershell -NoProfile -ExecutionPolicy Bypass -File "c:\vagrantshared\shell\NotifyGuiAppsOfEnvironmentChanges.ps1"

echo 'Install Required libraries for puppet if missing'
@powershell -NoProfile -ExecutionPolicy Bypass -File "c:\vagrantshared\shell\PreparePuppetProvisioner.ps1" 2>&1 | more

&choco install -y ruby
&gem install -y librarian-puppet

:: puppet resource
:: call puppet agent --test --debug --verbose
