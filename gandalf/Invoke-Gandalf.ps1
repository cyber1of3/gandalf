<#
 .Synopsis
 Collects forensic artefacts on Windows hosts; compatible with elrond
 Version: 1.0
 Author : cyberg3cko
 License: MIT
 .Description
 Collects digital forensic artefacts from Windows hosts. Output is compatible
  with elrond (https://github.com/cyberg3cko/elrond)
 .Parameter EncryptionObject
 Method of encryption used for archive file - Key, Password or None
 .Parameter Acquisition
 Method of acquisition - either Remote or Local
 .Parameter OutputDirectory
 Destination directory of where the collected will be stored
 .Parameter Memory
 Collect a live memory dump
 .Parameter ShowProgress
 Print progress of individual artefact acquisition to screen
 .Parameter CollectFiles
 Collect files containing string (provided in files.list) in file name
 .Example
 The following example invokes all of the parameters with the default arguments;
   -EncryptionObject None -Acquisition Local -OutputDirectory C:\TEMP\gandalf\gandalf
  PS C:\> .\Invoke-Gandalf.ps1
 .Example
 The following example invokes all of the parameters with the default arguments;
  explicitly stated:
  PS C:\> .\Invoke-Gandalf.ps1 -EncryptionObject Key -Acquisition Local -OutputDirectory C:\TEMP\gandalf\gandalf
 .Example
 The following example invokes all of the parameters with non-default arguments;
  deployment against a remote host, specified by IP or Hostnames, a (less secure) 
  password-protected package, and outputted to the root directory on the D: drive.
  PS C:\> .\Invoke-Gandalf.ps1 -EncryptionObject Password -Acquisition <REMOTE_HOST> -OutputDirectory D: -Memory -ShowProgress
#>

Param(
    [Parameter(Mandatory = $True, Position = 0)][string]$EncryptionObject,
    [Parameter(Position = 1)][string]$Acquisition,
    [Parameter(Position = 2)][string]$OutputDirectory,
    [Parameter(Position = 3)][switch]$Memory,
    [Parameter(Position = 4)][switch]$ShowProgress,
    [Parameter(Position = 5)][switch]$CollectFiles
)

function Format-Art {
    $quotes = @("     Not come the days of the King.`n     May they be blessed.`n", "     If my old gaffer could see me now.`n", "     I'll have no pointy-ear outscoring me!`n", "     I think there is more to this hobbit, than meets the eye.`n", "     You are full of surprises Master Baggins.`n", "     One ring to rule them all, one ring to find them.`n     One ring to bring them all, and in the darkness bind them.`n", "     The world is changed.`n     I feel it in the water.`n     I feel it in the earth.`n     I smell it in the air.`n", "     Who knows? Have patience. Go where you must go, and hope!`n", "     All we have to decide is what to do with the time that is given us.`n", "     Deeds will not be less valiant because they are unpraised.`n", "     It is not the strength of the body, but the strength of the spirit.`n", "     But in the end it's only a passing thing, this shadow; even darkness must pass.`n", "     It's the job that's never started as takes longest to finish.`n", "     Coward? Not every man's brave enough to wear a corset!`n", "     Bilbo was right. You cannot see what you have become.`n", "     He is known in the wild as Strider.`n     His true name, you must discover for yourself.`n", "     Legolas said you fought well today. He's grown very fond of you.`n", "     You will take NOTHING from me, dwarf.`n     I laid low your warriors of old.`n     I instilled terror in the hearts of men.`n     I AM KING UNDER THE MOUNTAIN!`n", "     You've changed, Bilbo Baggins.`n     You're not the same Hobbit as the one who left the Shire...`n", "     The world is not in your books and maps. It's out there.`n", "     That is private, keep your sticky paws off! It's not ready yet!`n", "     I wish you all the luck in the world. I really do.`n", "     No. No. You can't turn back now. You're part of the company.`n     You're one of us.`n", "     True courage is about knowing not when to take a life, but when to spare one.`n", "     The treacherous are ever distrustful.`n", "     Let him not vow to walk in the dark, who has not seen the nightfall.`n", "     He that breaks a thing to find out what it is has left the path of wisdom.`n", "     I was there, Gandalf.`n     I was there three thousand years ago, when Isildur took the ring.`n     I was there the day the strength of Men failed.`n", "     I don't know half of you half as well as I should like,`n     and I like less than half of you half as well as you deserve.`n", "     Certainty of death. Small chance of success.`n     What are we waiting for?`n", "     Do not spoil the wonder with haste!`n", "     It came to me, my own, my love... my... preciousssss.`n", "     One does not simply walk into Mordor...`n", "     Nine companions. So be it. You shall be the fellowship of the ring.`n", "     You have my sword. You have my bow; And my axe!`n", "     Build me an army, worthy of Mordor!`n", "     Nobody tosses a Dwarf!`n", "     If in doubt, Meriadoc, always follow your nose.`n", "     This is beyond my skill to heal; he needs Elven medicine.`n", "     No, thank you! We don't want any more visitors, well-wishers or distant relations!`n", "     Mordor! I hope the others find a safer road.`n", "     YOU SHALL NOT PASS!`n", "     You cannot hide, I see you!`n     There is no life, after me.`n     Only!.. Death!`n", "     A wizard is never late, Frodo Baggins.`n     Nor is he early.`n     He arrives precisely when he means to.`n", "     Is it secret?! Is it safe?!`n", "     Even the smallest person can change the course of the future.`n", "     We must move on, we cannot linger.`n", "     I wish the ring had never come to me. I wish none of this had happened.`n", "     Moonlight drowns out all but the brightest stars.`n", "     A hunted man sometimes wearies of distrust and longs for friendship.`n", "     The world is indeed full of peril and in it there are many dark places.`n", "     Someone else always has to carry on the story.`n", "     Your time will come. You will face the same Evil, and you will defeat it.`n", "     It is useless to meet revenge with revenge; it will heal nothing.`n", "     Despair is only for those who see the end beyond all doubt. We do not.`n", "     Anyways, you need people of intelligence on this sort of... mission... quest... thing.`n", "     Oh, it's quite simple. If you are a friend, you speak the password, and the doors will open.`n", "     The wise speak only of what they know.`n", "     Not all those who wander are lost.`n", "     It's the deep breath before the plunge.`n")

    Write-Host "
    `n`n`n`n`n
         ____                      .___        .__    _____  
        / ___\ _____     ____    __| _/_____   |  | _/ ____\ 
       / /_/  >\__  \   /    \  / __ | \__  \  |  | \   __\  
       \___  /  / __ \_|   |  \/ /_/ |  / __ \_|  |__|  |    
      /_____/  (____  /|___|  /\____ | (____  /|____/|__|    
                    \/      \/      \/      \/               
    "  -Foreground Magenta
    $quote = Get-Random -InputObject $quotes
    Write-Host $quote -Foreground Gray
}

function Format-Time {
    Param ($TimeDifference)

    $Seconds = [math]::round($TimeDifference % 60)
    $Minutes = [math]::round($TimeDifference / 60 % 60)
    $Hours = [math]::round($TimeDifference / 60 / 60)

    if ($Hours -gt 1 -Or $Hours -eq 1) {
        if ($Hours -gt 1 -And $Minutes -gt 1 -And $Seconds -gt 1) {
            $ElapsedTime = "$Hours hours, $Minutes minutes and $Seconds seconds."
        }
        elseif ($Hours -gt 1 -And $Minutes -gt 1 -And $Seconds -eq 1) {
            $ElapsedTime = "$Hours hours, $Minutes minutes and $Seconds second."
        }
        elseif ($Hours -gt 1 -And $Minutes -eq 1 -And $Seconds -gt 1) {
            $ElapsedTime = "$Hours hours, $Minutes minute and $Seconds seconds."
        }
        elseif ($Hours -eq 1 -And $Minutes -gt 1 -And $Seconds -gt 1) {
            $ElapsedTime = "$Hours hour, $Minutes minutes and $Seconds seconds."
        }
        elseif ($Hours -gt 1 -And $Minutes -eq 1 -And $Seconds -eq 1) {
            $ElapsedTime = "$Hours hours, $Minutes minute and $Seconds second."
        }
        elseif ($Hours -eq 1 -And $Minutes -gt 1 -And $Seconds -eq 1) {
            $ElapsedTime = "$Hours hour, $Minutes minutes and $Seconds second."
        }
        elseif ($Hours -eq 1 -And $Minutes -eq 1 -And $Seconds -gt 1) {
            $ElapsedTime = "$Hours hour, $Minutes minute and $Seconds seconds."
        }
        elseif ($Hours -gt 1 -And $Minutes -gt 1 -And $Seconds -eq 0) {
            $ElapsedTime = "$Hours hours and $Minutes minutes."
        }
        elseif ($Hours -gt 1 -And $Minutes -eq 0 -And $Seconds -gt 0) {
            $ElapsedTime = "$Hours hours and $Seconds seconds."
        }
        elseif ($Hours -eq 1 -And $Minutes -gt 1 -And $Seconds -eq 0) {
            $ElapsedTime = "$Hours hour and $Minutes minutes."
        }
        elseif ($Hours -eq 1 -And $Minutes -eq 0 -And $Seconds -gt 0) {
            $ElapsedTime = "$Hours hour and $Seconds second."
        }
        elseif ($Hours -gt 1 -And $Minutes -eq 0 -And $Seconds -eq 0) {
            $ElapsedTime = "$Hours hours."
        }
        else {
            $ElapsedTime = "$Hours hour."
        }
    }
    elseif ($Minutes -gt 1 -Or $Minutes -eq 1) {
        if ($Minutes -gt 1 -And $Seconds -gt 1) {
            $ElapsedTime = "$Minutes minutes and $Seconds seconds."
        }
        elseif ($Minutes -eq 1 -And $Seconds -gt 1) {
            $ElapsedTime = "$Minutes minute and $Seconds seconds."
        }
        elseif ($Minutes -gt 1 -And $Seconds -eq 1) {
            $ElapsedTime = "$Minutes minute and $Seconds seconds."
        }
        elseif ($Minutes -eq 1 -And $Seconds -eq 1) {
            $ElapsedTime = "$Minutes minute and $Seconds second."
        }
        else {
            $ElapsedTime = "$Minutes minutes."
        }
    }
    else {
        if ($Seconds -gt 1) {
            $ElapsedTime = "$Seconds seconds."
        }
        else {
            $ElapsedTime = "$Seconds second."
        }
    }

    return $ElapsedTime
}

function Reset-Modules {
    Param ($EncryptionObject, $Session)

    if ($EncryptionObject -eq "Key" -Or $EncryptionObject -eq "Password") {
        try {
            Invoke-Command -Session $Session -ScriptBlock { Uninstall-Module -Name 7Zip4PowerShell -Force -ErrorAction SilentlyContinue }
            Remove-PSSession -Session $Session
        }
        catch {
            Write-Host "`n     Additional modules could not be removed"
        }
    }
    else {
        try {
            Uninstall-Module -Name 7Zip4PowerShell -Force -ErrorAction SilentlyContinue
        }
        catch {
            Write-Host "`n     Additional modules could not be removed"
        }
    }
}

function Set-Defaults {
    Param ($EncryptionObject, $Acquisition, $OutputDirectory, $NoPrompt)

    if ($null -eq $Acquisition -Or $Acquisition -eq "" -Or $Acquisition -eq "Local") {
        $Acquisition = "Local"
    }
    else {
        $Acquisition = "Remote"
    }

    if ($EncryptionObject -eq "Key" -Or $EncryptionObject -eq "Password") {
        if ($EncryptionObject -eq "Key") {
            Write-Host "     You have chosen to use Key-based encryption but unfortunately this is not yet supported. Please try again`n`n"
            Exit
        }
        $ConfirmEncryption = Read-Host "     You have chosen to use encryption when archiving the artefacts. Although this is recommended, you will need an Internet connection on each endpoint, to download the additional modules.`n      Do you wish to proceed? Y/n [Y] "
        if ($ConfirmEncryption -eq "n") {
            Write-Host "      Please try again with the " -NoNewLine; Write-Host "-EncryptionObject" -NoNewLine -Foreground Magenta; Write-Host " parameter set to 'None'`n`n"
            Exit
        }
        Write-Host `r
    }
    elseif ($EncryptionObject -eq "None" -And $Acquisition -eq "Remote") {
        if (-Not ($NoPrompt)) {
            $ConfirmNoEncryption = Read-Host "     You have chosen to use no encryption when archiving the artefacts. This is not recommended.`n      Are you sure you want to proceed? y/N [N] "
            if ($ConfirmNoEncryption -ne "y") {
                Write-Host "      Please try again with the " -NoNewLine; Write-Host "-EncryptionObject" -NoNewLine -Foreground Magenta; Write-Host " parameter set to 'Key' or 'Password'`n`n"
                Exit
            }
        }
        else {
            $ConfirmNoEncryption = "y"
        }
    }
    elseif ($EncryptionObject -ne "None") {
        Write-Host "    '$EncryptionObject' is not a valid option for the -EncryptionObject parameter. You can choose from 'Key' (Most Secure), 'Password' or 'None' (Least Secure)`n`n"
        Exit
    }

    if ($null -eq $OutputDirectory -Or $OutputDirectory -eq "") {
        $OutputDirectory = "C:\TEMP\gandalf\acquisitions"
    }

    if (Test-Path -LiteralPath $OutputDirectory) {
        if (-Not($OutputDirectory.Startswith(".\"))) {
            $OutputDirectory = [IO.Path]::Combine(".\", $OutputDirectory)
        }
        if (-Not ($NoPrompt)) {
            $OverwriteDestination = Read-Host "    The destination of '$OutputDirectory' already exists. Do you wish to overwrite it? Y/n [Y]"
        }
        else {
            $OverwriteDestination = "y"
        }
        if ($OverwriteDestination -ne "n") {
            Remove-Item -Path $OutputDirectory -Recurse > $null
            New-Item -Path $OutputDirectory -ItemType Directory > $null
        }
        Write-Host `n
    }

    if (-not (Test-Path -LiteralPath $OutputDirectory)) {
        New-Item -Path $OutputDirectory -ItemType Directory > $null
    }

    if ($Acquisition -eq "Local") {
        if (-not (Test-Path -LiteralPath $OutputDirectory)) {
            New-Item -Path $OutputDirectory -ItemType Directory -ErrorAction Stop | Out-Null
        }
    }

    return $EncryptionObject, $Acquisition, $OutputDirectory
}

function Set-ArtefactParams {
    Param ($EncryptionObject, $OutputDirectory, $ShowProgress, $Memory, $CollectFiles, $Hostnames, $ArchiveObject, $GandalfRoot)

    $InvokeArtefactAcquisition = [IO.Path]::Combine($GandalfRoot, "gandalf", "tools", "Invoke-ArtefactAcquisition.ps1"); $SetArtefactCollection = [IO.Path]::Combine($GandalfRoot, "gandalf", "shire", "Set-ArtefactCollection")
    $ArtefactParams = "Param(`$EncryptionObject = '$EncryptionObject', `$OutputDirectory = '$OutputDirectory', `$ShowProgress = '$ShowProgress', `$Memory = '$Memory', `$CollectFiles = '$CollectFiles', `$Hostnames = '$Hostnames', `$ArchiveObject = '$ArchiveObject')"
    $ArtefactCollection = Get-Content -Path $SetArtefactCollection

    Add-Content -Path $InvokeArtefactAcquisition -Value $ArtefactParams
    Add-Content -Path $InvokeArtefactAcquisition -Value $ArtefactCollection
}

function Invoke-RemoteArtefactCollection {
    Param ($EncryptionObject, $OutputDirectory, $ShowProgress, $Memory, $CollectFiles, $DriveLetter, $Hostnames, $Session, $ArchiveObject, $GandalfRoot)

    Set-ArtefactParams $EncryptionObject $OutputDirectory $ShowProgress $Memory $CollectFiles $Hostnames $ArchiveObject $GandalfRoot

    $ToolsPath = [IO.Path]::Combine($GandalfRoot, "gandalf", "tools"); $DiskTools = [IO.Path]::Combine($ToolsPath, "disk_tools.zip"); $DumpIt = [IO.Path]::Combine($ToolsPath, "memory", "DumpIt.exe"); $DumpItx86 = [IO.Path]::Combine($ToolsPath, "memory", "DumpItx86.exe"); $InvokeArtefactAcquisition = [IO.Path]::Combine($ToolsPath, "Invoke-ArtefactAcquisition.ps1")

    Invoke-Command -Session $Session -ScriptBlock { if (Test-Path -LiteralPath "C:\TEMP\gandalf") { Remove-Item "C:\TEMP\gandalf" -Recurse -Force } }
    Invoke-Command -Session $Session -ScriptBlock { New-Item -Path "C:\TEMP\gandalf" -ItemType Directory > $null }; Invoke-Command -Session $Session -ScriptBlock { New-Item -Path "C:\TEMP\gandalf\gandalf" -ItemType Directory > $null }; Invoke-Command -Session $Session -ScriptBlock { New-Item -Path "C:\TEMP\gandalf\acquisitions" -ItemType Directory > $null }; Invoke-Command -Session $Session -ScriptBlock { New-Item -Path "C:\TEMP\gandalf\gandalf\tools" -ItemType Directory > $null }; Invoke-Command -Session $Session -ScriptBlock { New-Item -Path "C:\TEMP\gandalf\gandalf\tools\memory" -ItemType Directory > $null }; Invoke-Command -Session $Session -ScriptBlock { New-Item -Path "C:\TEMP\gandalf\gandalf\lists" -ItemType Directory > $null }
    Copy-Item -ToSession $Session -Path $DiskTools -Destination "C:\TEMP\gandalf\gandalf\tools\disk_tools.zip" -Force -Recurse; Copy-Item -ToSession $Session -Path $InvokeArtefactAcquisition -Destination "C:\TEMP\gandalf\gandalf\tools\Invoke-ArtefactAcquisition.ps1" -Force

    if ($Memory -And $Memory -ne "False") {
        Copy-Item -ToSession $Session -Path $DumpIt -Destination "C:\TEMP\gandalf\gandalf\tools\memory\DumpIt.exe" -Force; Copy-Item -ToSession $Session -Path $DumpItx86 -Destination "C:\TEMP\gandalf\gandalf\tools\memory\DumpItx86.exe" -Force
    }

    if ($CollectFiles -And $CollectFiles -ne "False") {
        Copy-Item -ToSession $Session -Path [IO.Path]::Combine($GandalfRoot, "gandalf", "lists", "files.list") -Destination "C:\TEMP\gandalf\gandalf\lists\files.list" -Force
    }

    Invoke-Command -Session $Session -FilePath C:\TEMP\gandalf\gandalf\tools\.\Invoke-ArtefactAcquisition.ps1
    Remove-PSSession -Session $Session
    Invoke-RemoteArchiveCollection $OutputDirectory $Hostnames $ArchiveObject $GandalfRoot
}

function Invoke-RemoteArchiveCollection {
    Param ($OutputDirectory, $Hostnames, $ArchiveObject, $GandalfRoot)

    $FilePath = [IO.Path]::Combine($GandalfRoot, "gandalf", $OutputDirectory, $Hostnames)
    $Session = New-PSSession -ComputerName $Hostnames -Credential $RemoteCredentials

    Write-Progress "Collecting acquired artefacts from '$Hostnames'..."
    $RemoteComputer = Invoke-Command -Session $Session -ScriptBlock { $env:COMPUTERNAME }
    New-Item -Path $OutputDirectory\$RemoteComputer -ItemType Directory > $null

    $LogSource = [IO.Path]::Combine($OutputDirectory, $RemoteComputer, "log.audit"); $LogDestination = [IO.Path]::Combine($FilePath, "log.audit"); $MetaSource = [IO.Path]::Combine($OutputDirectory, $RemoteComputer, "meta.audit"); $MetaDestination = [IO.Path]::Combine($FilePath, "meta.audit"); $ZipSource = [IO.Path]::Combine($OutputDirectory, $RemoteComputer, "$RemoteComputer.zip"); $ZipDestination = [IO.Path]::Combine($FilePath, "$RemoteComputer.zip"); $7ZSource = [IO.Path]::Combine($OutputDirectory, $RemoteComputer, "$RemoteComputer.7z"); $7ZDestination = [IO.Path]::Combine($FilePath, "$RemoteComputer.7z")
    Copy-Item -FromSession $Session -Path $LogSource -Destination $LogDestination -Force > $null 2>&1
    Copy-Item -FromSession $Session -Path $MetaSource -Destination $MetaDestination -Force > $null 2>&1
    Copy-Item -FromSession $Session -Path $ZipSource -Destination $ZipDestination -Force > $null 2>&1
    Copy-Item -FromSession $Session -Path $7zSource -Destination $7zDestination -Force > $null 2>&1

    Write-Host "`n   -> Collected acquired artefacts from '$Hostnames'"
    Write-Progress "Cleaning up '$Hostnames'..."

    Invoke-Command -Session $Session -ScriptBlock { Remove-Item -Path "C:\TEMP\gandalf" -Recurse }
    Remove-PSSession -Session $Session
    $Session = New-PSSession -ComputerName $Hostnames -Credential $RemoteCredentials

    Reset-Modules $EncryptionObject $Session

    Write-Progress -Activity "_" -Completed
}

# Gathering Date/Time information
$DateTime = "{0}" -f (Get-Date)
$StartTime = Get-Date -Date $DateTime -UFormat %s
$StartTime = [convert]::ToInt32($StartTime)
$global:ProgressPreference = "Continue"
$Environment = Get-ChildItem -Path Env:

# Checking if ps1 file is running on Windows or *nix
if (($Environment -like "*XPC_*" -Or $Environment -like "*com.apple.Terminal*" -Or $Environment -like "*/bin/zsh*" -Or $Environment -like "*com.apple.launchd.*") -Or ($Environment -like "*XDG_*" -Or $Environment -like "*/Terminal/*" -Or $Environment -like "*/bin/bash*" -Or $Environment -like "*/home/*")) {
    $GandalfRoot = [IO.Path]::Combine("/tmp", "gandalf")
}
else {
    $GandalfRoot = [IO.Path]::Combine("C:\", "TEMP", "gandalf")
}

# Checking existance of disk_tools.zip
if (-Not (Test-Path -LiteralPath "C:\TEMP\gandalf\gandalf\tools\disk_tools.zip")) {
    Clear-Host
    Write-Host "`n`n`n`n      WARNING: 'C:\TEMP\gandalf\gandalf\tools\disk_tools.zip' does not exist." -Foreground Yellow; Write-Host "       As a result, some disk artefacts (inc. the `$MFT will not be collected." -Foreground White
    $ContinueWithoutDiskTools = Read-Host "      Do you wish to continue? y/N [N] "
    if ($ContinueWithoutDiskTools -ne "y") {
        Write-Host "`n`n       Read the " -NoNewLine; Write-Host "Configuration" -Foreground Grey -NoNewLine; Write-Host " section in the README.md before trying again.`n`n"
        Exit
    }
}

# Removing files which if exist during second attempt will cause failures
$ArtefactAquisitionPath = [IO.Path]::Combine($GandalfRoot, "gandalf", "tools", "Invoke-ArtefactAcquisition.ps1")
$RemnantFiles = @("C:\TEMP\gandalf\gandalf\tools\RawCopy.exe", "C:\TEMP\gandalf\gandalf\tools\RawCopy64.exe", "C:\TEMP\gandalf\gandalf\tools\sleuthkit-4.12.1-win32", "C:\TEMP\gandalf\gandalf\tools\sleuthkit-4.12.1-win32.zip", "C:\TEMP\gandalf\gandalf\tools\icat", "C:\TEMP\gandalf\gandalf\tools\tsk", $ArtefactAquisitionPath)
ForEach ($RemnantFile in $RemnantFiles) {
    if (Test-Path -LiteralPath $RemnantFile) {
        Remove-Item $RemnantFile -Recurse -Force
    }
}

Clear-Host
Format-Art

if (-Not ($NoPrompt)) {
    Write-Host `r
}

# Exiting if running .ps1 file locally on *nix
if ($GandalfRoot -eq "/tmp/gandalf" -And $Acquisition -eq "Local") {
    Write-Host "      Invoke-Gandalf.ps1 is not designed to run Locally on Linux/macOS devices."; Write-Host "       Please use gandalf.py instead.`n`n"
    Exit
}

# Setting default parameters
$EncryptionObject, $Acquisition, $OutputDirectory = Set-Defaults $EncryptionObject $Acquisition $OutputDirectory $NoPrompt

if ($EncryptionObject -eq "Key") {
    $ArchiveObject = Read-Host "     Provide path to PGP Public Key for archive encryption"
}
elseif ($EncryptionObject -eq "Password") {
    $ArchiveObject = Read-Host "     Enter Password for archive encryption" -AsSecureString
    $ArchiveObject = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($ArchiveObject)
    $ArchiveObject = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ArchiveObject)
}
else {
    $ArchiveObject = "None"
}

Write-Host `r

if ($Acquisition -eq "Local") {
    $Hostnames = $env:COMPUTERNAME
    Set-ArtefactParams $EncryptionObject $OutputDirectory $ShowProgress $Memory $CollectFiles $Hostnames $ArchiveObject $GandalfRoot
    C:\TEMP\gandalf\gandalf\tools\.\Invoke-ArtefactAcquisition.ps1
}
else {
    $RemoteCredentials = $host.ui.PromptForCredential("Local Admin authentication required", "Please enter credentials for PowerShell remoting", "", "")
    $HostListPath = [IO.Path]::Combine("lists", "hosts.list")
    $Hostnames = Get-Content $HostListPath
    $Session = New-PSSession -ComputerName $Hostnames -Credential $RemoteCredentials -ErrorAction SilentlyContinue -ErrorVariable SessionError
    if ($SessionError) {
        if ((Select-String -InputObject $SessionError -Pattern "server name cannot be resolved") -Or (Select-String -InputObject $SessionError -Pattern "Access is denied")) { 
            if (Select-String -InputObject $SessionError -Pattern "server name cannot be resolved") { 
                Write-Host "      FAILURE: Server name '$Hostnames' could not be resolved." -Foreground Red; Write-Host "       Perhaps the host is offline or there is a networking issue?" -Foreground White
                $ContinueAcquisition = Read-Host "      Do you wish to continue? Y/n [Y] "
                if ($ContinueAcquisition -eq "n") {
                    Write-Host "`r      Please try again.`n`n"
                    Exit
                }
            }
            elseif (Select-String -InputObject $SessionError -Pattern "Access is denied") { 
                Write-Host "      FAILURE: Invalid credentials provided to access '$Hostnames'." -Foreground Red; Write-Host "       Ensure you are using an account which is a member of the necessary Administrators Group" -Foreground White
                $ContinueAcquisition = Read-Host "      Do you wish to continue? Y/n [Y] "
                if ($ContinueAcquisition -eq "n") {
                    Write-Host "`r      Please try again.`n`n"
                    Exit
                }
            }
        }
    }
    else {
        Write-Host "      Session(s) opened for '$Hostnames'" -ForegroundColor Green
        Invoke-RemoteArtefactCollection $EncryptionObject $OutputDirectory $ShowProgress $Memory $CollectFiles $DriveLetter $Hostnames $Session $ArchiveObject $GandalfRoot
    }
}

# Removing files only needed during acquisition
ForEach ($RemnantFile in $RemnantFiles) {
    if (Test-Path -LiteralPath $RemnantFile) {
        Remove-Item $RemnantFile -Recurse -Force
    }
}

# Gathering Date/Time information
$DateTime = "{0}" -f (Get-Date)
$EndTime = Get-Date -Date $DateTime -UFormat %s
$EndTime = [convert]::ToInt32($EndTime)
$TimeDifference = $EndTime - $StartTime
$ElapsedTime = Format-Time $TimeDifference

# Finishing
Write-Host "`n`n  -> Finished. Total elapsed time: $ElapsedTime`n    ----------------------------------------" -Foreground Gray
Write-Host "      gandalf completed for:"

ForEach ($EachHost in $Hostnames.split("`n")) {
    Write-Host "       - $EachHost"
}

Write-Host `n`n
