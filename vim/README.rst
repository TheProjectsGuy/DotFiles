=========
Use Vim!
=========

.. contents:: Table of contents
    :depth: 2

***********
Contents
***********

.. csv-table:: Contents of this folder
    :header: "S No.", "File", "Description"
    :widths: 15, 50, 100

    1, `<./.vimrc>`_, Basic configuration for main ``vim`` editor
    2, `<./nvim_init.vim>`_, Neovim configuration
    3, `<./nvim-qt_init.vim>`_, Neovim configuration for Qt window (GUI)

Configure the editor on Linux machines using

.. code-block:: bash

    sudo apt install vim neovim
    # Use Neovim to edit everything
    update-alternatives --display editor
    sudo update-alternatives --config editor

If you want the latest build of neovim, add the following (`reference <https://vi.stackexchange.com/a/25200>`_)

.. code-block:: bash

    # Add PPA
    sudo add-apt-repository ppa:neovim-ppa/stable
    sudo apt-get update
    sudo apt install neovim

Notes:

- Put the neovim init files in `~/.config/nvim` (for CLI) and `~/.config/nvim-qt` (for GUI) and name them as `init.vim`

************
References
************

- CheatSheet: https://vim.rtorr.com/
- Cursor movements: https://stackoverflow.com/a/3458821/5836037
- Plugins: https://www.baeldung.com/linux/vim-install-neovim-plugins
    - Plugins Directory: https://stackoverflow.com/a/50122211/5836037
    - Good plugins: https://hannadrehman.com/top-neovim-plugins-for-developers-in-2022
