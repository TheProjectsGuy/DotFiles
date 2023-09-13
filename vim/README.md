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
alias nvim=/global/nvim-linux64/bin/nvim
alias vi=nvim
alias vim=vi
```

**Risky**: You can also change this default (system-wide).

```bash
sudo apt install vim neovim
# Use Neovim to edit everything
update-alternatives --display editor
sudo update-alternatives --config editor
```

### Using NVChad

Setup `nvim` as above. Then setup nvchad.

```bash
# Make backups
cp -r ~/.config/nvim ~/.config/nvim-before-nvchad
cp -r ~/.local/share/nvim ~/.local/share/nvim-before-nvchad
# Main install
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
nvim
```

## References

- [Vim Cheatsheet](https://vim.rtorr.com/)
- [Cursor movements](https://stackoverflow.com/a/3458821/5836037)
- Vim [Plugins](https://www.baeldung.com/linux/vim-install-neovim-plugins)
    - [Plugins Directory](https://stackoverflow.com/a/50122211/5836037)
    - [Good plugins](https://hannadrehman.com/top-neovim-plugins-for-developers-in-2022)
- [NVChad](https://nvchad.com/)
