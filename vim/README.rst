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

Notes:

- Put the neovim init files in `~/.config/nvim` (for CLI) and `~/.config/nvim-qt` (for GUI) and name them as `init.vim`

************
References
************

- CheatSheet: https://vim.rtorr.com/
