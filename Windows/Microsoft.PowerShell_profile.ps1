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

# === Ada commands ===
$USER_ADA = "avneesh.mishra"
$USER_RRC = $USER_ADA
Function Link-Gnode {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$NodeNum,
        [Parameter(Mandatory=$false, Position=1)]
        [string]$LocalPort = "60000",
        [Parameter(Mandatory=$false, Position=2)]
        [string]$RemotePort = "22"
    )
    $gnode = $NodeNum.PadLeft(3, '0')
    $ssh_keygen_cmd = "ssh-keygen -f ${HOME}\.ssh\known_hosts -R '[localhost]:$LocalPort'"
    echo "Running: >> $ssh_keygen_cmd"
    Invoke-Expression $ssh_keygen_cmd
    $ssh_cmd = "ssh -t -i ${HOME}\.ssh\id_rsa_ada_win -L ${LocalPort}:localhost:${RemotePort} -J ${USER_ADA}@ada ${USER_ADA}@gnode${gnode} zsh"
    echo "Running: >> $ssh_cmd"
    Invoke-Expression $ssh_cmd
}

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
Function Mamba-Init {
    #region conda initialize
    # !! Contents within this block are managed by 'conda init' !!
    If (Test-Path "C:\Users\123av\miniforge3\Scripts\conda.exe") {
        (& "C:\Users\123av\miniforge3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
    }
    #endregion
}
# ----- Oh My Posh! -----
Import-Module oh-my-posh
Set-PoshPrompt -Theme blue-owl
Import-Module -Name Terminal-Icons
Import-Module DockerCompletion
