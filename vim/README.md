# Use Vim!

## Table of contents

- [Use Vim!](#use-vim)
    - [Table of contents](#table-of-contents)
    - [Contents](#contents)
    - [Install Neovim](#install-neovim)
        - [Using NVChad](#using-nvchad)
    - [References](#references)

## Contents

| S. No. | File | Description |
| :----- | :--- | :---------- |
| 1 | [.vimrc](./.vimrc) | Basic configuration for the main `vim` editor |
| 2 | [nvim_init.vim](./nvim_init.vim) | Neovim configuration |
| 3 | [nvim-qt_init.vim](./nvim-qt_init.vim) | Neovim configuration for Qt window (GUI) |

Notes:

- Put the neovim init files in `~/.config/nvim` (for CLI) and `~/.config/nvim-qt` (for GUI) and name them as `init.vim`

## Install Neovim

Install neovim using (check [latest stable build](https://github.com/neovim/neovim/releases/tag/stable))

```bash
cd ~/Downloads
wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz
# See contents and unzip
tar -tvzf ./nvim-linux64.tar.gz
tar -xvzf ./nvim-linux64.tar.gz
# Move it somewhere everybody can use
cd /opt
sudo mv ~/Downloads/nvim-linux64 ./
```

Change your `.*rc` file to use neovim instead of vim

```bash
alias nvim=/opt/nvim-linux64/bin/nvim
```

**Risky**: You can also change this default (system-wide).

```bash
sudo apt install vim neovim
# Use Neovim to edit everything
update-alternatives --display editor
sudo update-alternatives --config editor
```

### Using NVChad

Setup `nvim` as above. Use the [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads) (try `JetBrainsMonoNerdFont-Medium.ttf`). Then setup nvchad.

```bash
# Make backups
cp -r ~/.config/nvim ~/.config/nvim-before-nvchad
cp -r ~/.local/share/nvim ~/.local/share/nvim-before-nvchad
# Main install
# git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1   # Old command (do not use)
git clone https://github.com/NvChad/starter ~/.config/nvim
nvim
```

Set the following configurations

- Theme: `penumbra_dark`

Run the following as vim commands (`:`, ignore `" comments`)

```vim
" Syntax highlighting 
TSInstall python
TSInstallInfo
```

Cheatsheet: `Space` + `c` + `h`

Finally, remember the notes below :wink:

```txt

  
  ███╗   ██╗   ██████╗  ████████╗ ███████╗ ███████╗
  ████╗  ██║  ██╔═══██╗ ╚══██╔══╝ ██╔════╝ ██╔════╝
  ██╔██╗ ██║  ██║   ██║    ██║    █████╗   ███████╗
  ██║╚██╗██║  ██║   ██║    ██║    ██╔══╝   ╚════██║
  ██║ ╚████║  ╚██████╔╝    ██║    ███████╗ ███████║
  
  
    Please read the docs at nvchad.com from start to end 󰕹 󰱬
  
    All NvChad available options are in 'core/default_config.lua', Know them
  
    Mason just downloads binaries, dont expect it to configure lsp automatically
  
    Dont edit files outside custom folder or you lose NvChad updates forever 󰚌
  
    Ask NvChad issues in nvchad communities only, go to https://nvchad.com/#community
  
    Read the plugin docs to utilize 100% of their functionality.
  
    If you dont see any syntax highlighting not working, install a tsparser for it
  
    Check the default mappings by pressing space + ch or NvCheatsheet command
  
  Now quit nvim!

```

## References

- [Vim Cheatsheet](https://vim.rtorr.com/)
- [Cursor movements](https://stackoverflow.com/a/3458821/5836037)
- Vim [Plugins](https://www.baeldung.com/linux/vim-install-neovim-plugins)
    - [Plugins Directory](https://stackoverflow.com/a/50122211/5836037)
    - [Good plugins](https://hannadrehman.com/top-neovim-plugins-for-developers-in-2022)
- [NVChad](https://nvchad.com/)
    - [YouTube setup tutorial](https://youtu.be/Mtgo-nP_r8Y?si=beYoQZltvrcb034P)
