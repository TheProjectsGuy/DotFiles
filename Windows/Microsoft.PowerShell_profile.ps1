# Powershell $profile file

# Use tab completion
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# ----- Posh Git -----
# Installation
Import-Module posh-git

# ========== Alias commands ==========
# Edit the profile file
Function Edit-Profile {
    code -n $PROFILE
}
Set-Alias editprofile Edit-Profile
# Create new file
Function New-File {
    param (
        $FileName
    )
    New-Item -Type File -Name $FileName
}
Set-Alias touch New-File

# ========== Path modifications ==========
# Add Java path
$JavaPath = "C:\Program Files\Java\jdk-11.0.9"
$env:Path += ";$JavaPath\bin"

# ========== Installed programs ==========
# ----- AWS -----
# Set default AWS user and password
# Initialize-AWSDefaultConfiguration -ProfileName avneesh_admin -Region us-east-1
# ----- Anaconda -----
Function Conda-Init {
    #region conda initialize
    # !! Contents within this block are managed by 'conda init' !!
    (& "C:\ProgramData\Anaconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | Invoke-Expression
    #endregion
}
# ----- Oh My Posh! -----
Import-Module oh-my-posh
Set-PoshPrompt -Theme blue-owl
Import-Module -Name Terminal-Icons
