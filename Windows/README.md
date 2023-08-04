# Windows Terminal

Use [Windows Terminal](https://github.com/Microsoft/Terminal) on Windows. Nothing else compares.

## Table of contents

- [Windows Terminal](#windows-terminal)
    - [Table of contents](#table-of-contents)
    - [WSL](#wsl)
    - [OneCommander](#onecommander)
    - [Contents](#contents)
    - [PowerShell](#powershell)
        - [Extensions](#extensions)
    - [References](#references)

## WSL

Use [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/) for experiencing GNU/Linux on Windows with little to no overhead (direct kernel integration).

## OneCommander

Windows file explorer is not very good (specially if you're used to Cinnamon DE on Mint). Use [OneCommander](https://www.onecommander.com/) for exploring files.

## Contents

The following are the contents of this folder

| S. No. | Item | Description |
| :--- | :---- | :----- |
| 1 | [wt_keybindings.json](./wt_keybindings.json) | Keyboard shortcuts (associated with actions) for Windows Terminal |
| 2 | [Microsoft.PowerShell_profile.ps1](./Microsoft.PowerShell_profile.ps1) | The PowerShell profile for Windows Terminal. See path using `echo $PROFILE`. |
| 3 | [wt_settings_backup.json](./wt_settings_backup.json) | Latest backup of the windows terminal settings (includes profile information, keybindings, etc.). |

## PowerShell

[PowerShell](https://docs.microsoft.com/en-us/powershell/) is an amazing shell (all outputs are objects, not texts).

### Extensions

Powershell, like `zsh`, can be heavily customized. Check out [Oh My Posh](https://ohmyposh.dev/docs/pwsh) and install the `Meso LG M Bold Nerd Font Complete.ttf` and `agave regular Nerd Font Complete.ttf` (across all users) from [here](https://ohmyposh.dev/docs/fonts). The theme currently being used is `gmay`. This is best enjoyed with Windows Terminal.

Use [DockerCompletion](https://github.com/matt9ucci/DockerCompletion) for Docker tab autocomplete.

## References

- [Windows Terminal](https://learn.microsoft.com/en-us/windows/terminal/)
    - [Panes](https://docs.microsoft.com/en-us/windows/terminal/panes)
    - [Actions](https://learn.microsoft.com/en-us/windows/terminal/customize-settings/actions)
