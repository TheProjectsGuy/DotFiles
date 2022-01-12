# ZSH

Use `zsh`, it is pure bliss.

## Table of contents

- [ZSH](#zsh)
    - [Table of contents](#table-of-contents)
    - [Tasks](#tasks)
    - [Contents](#contents)

## Tasks

1. Install `zsh`

    ```bash
    sudo apt install zsh -y
    ```

2. Copy the [.zshrc_setup](./.zshrc_setup) as `~/.zshrc`
3. Run `zsh` and [install Oh-my-zsh](https://ohmyz.sh/#install)

    ```bash
    curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh > ~/Downloads/install_omz.sh
    bash ~/Downloads/install_omz.sh
    ```

4. Use `agnoster` theme, use the font `MesloLGS Regular`
5. Install plugins [zsh-autocomplete](https://github.com/marlonrichert/zsh-autocomplete) (new!), [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions), and [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

    ```sh
    cd $ZSH_CUSTOM/plugins/
    git clone https://github.com/marlonrichert/zsh-autocomplete
    git clone https://github.com/zsh-users/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting
    ```

    Then, in the `~/.zshrc`, list these under `plugins=(...)`

## Contents

The contents of this folder are summarized as follows

| Item name | Description |
| :---- | :---- |
| [.zshrc_setup](./.zshrc_setup) | The `~/.zshrc` file, upon first setting up ZSH. Use this before installing anything like OMZ! and after installing zsh. You won't have to go through the setup menu anymore. |
| [MesloLGS NF Regular.ttf](./MesloLGS%20NF%20Regular.ttf) | Font for `agnoster` theme on terminal |
| [.zshrc_userconfig](./.zshrc_userconfig) | User configurations, you can add this in the end, after everything is set up |
