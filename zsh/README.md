# ZSH

Use `zsh`, it is pure bliss.

## Table of contents

- [ZSH](#zsh)
    - [Table of contents](#table-of-contents)
    - [Tasks](#tasks)
    - [Contents](#contents)
    - [Extra links](#extra-links)
    - [Anaconda](#anaconda)

## Tasks

1. Install `zsh`

    ```bash
    sudo apt install zsh -y
    ```

2. Copy the [setup.zshrc](./setup.zshrc) as `~/.zshrc`
3. Run `zsh` and [install Oh-my-zsh](https://ohmyz.sh/#install)

    ```bash
    curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh > ~/Downloads/install_omz.sh
    bash ~/Downloads/install_omz.sh
    ```

4. Use `agnoster` theme, use the font `MesloLGS Regular`
5. Install plugins [zsh-autocomplete](https://github.com/marlonrichert/zsh-autocomplete) (new! - may not work everywhere), [zsh-z](https://github.com/agkozak/zsh-z), [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions), [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting), and [zsh-command-time](https://github.com/popstas/zsh-command-time).

    ```sh
    cd $ZSH_CUSTOM/plugins/
    git clone https://github.com/marlonrichert/zsh-autocomplete
    git clone https://github.com/zsh-users/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting
    git clone https://github.com/agkozak/zsh-z
    git clone https://github.com/popstas/zsh-command-time.git command-time
    ```
    
    Then, in the `~/.zshrc`, list these under `plugins=(...)`
    
    ```bash
    plugins=(
        git
        zsh-syntax-highlight
        zsh-autocomplete
        zsh-autosuggestion
        zsh-z
        docker
        conda-zsh-completion
        command-time
    )
    ```

## Contents

The contents of this folder are summarized as follows

| Item name | Description |
| :---- | :---- |
| [setup.zshrc](./setup.zshrc) | The `~/.zshrc` file, upon first setting up ZSH. Use this before installing anything like OMZ! and after installing zsh. You won't have to go through the setup menu anymore. |
| [MesloLGS NF Regular.ttf](./MesloLGS%20NF%20Regular.ttf) | Font for `agnoster` theme on terminal |
| [JetBrainsMonoNerdFont-Medium.ttf](./JetBrainsMonoNerdFont-Medium.ttf) | Another nerd font |
| [userconfig.zshrc](./userconfig.zshrc) | User configurations, you can add this in the end, after everything is set up. Make sure you see what you're adding. |

## Extra links

- [LS_COLORS](https://www.howtogeek.com/307899/how-to-change-the-colors-of-directories-and-files-in-the-ls-command/)
- Convert files from CRLF to LF using `dos2unix`, recursively done [here](https://unix.stackexchange.com/a/279818/456203)

## Anaconda

If using [Anaconda](https://www.anaconda.com/products/individual), the following can be kept in mind

1. Refer to the `conda-init` method of initializing anaconda in [userconfig.zshrc](./userconfig.zshrc) file
2. Use the [conda-zsh-completion](https://github.com/esc/conda-zsh-completion) plugin

    ```bash
    cd $ZSH_CUSTOM/plugins
    git clone https://github.com/esc/conda-zsh-completion
    ```

    In the `~/.zshrc` file, do the following

    ```bash
    plugins=( ... conda-zsh-completion)
    ```

    And then run

    ```bash
    source ~/.zshrc
    ```
