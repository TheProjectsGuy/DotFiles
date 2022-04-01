# GitHub configurations

Common configurations for GitHub

## Table of Contents

- [GitHub configurations](#github-configurations)
    - [Table of Contents](#table-of-contents)
    - [Common links](#common-links)
    - [Signing your commits](#signing-your-commits)
        - [Setup GPG Key](#setup-gpg-key)
            - [Windows](#windows)

## Common links

- Emojis on GitHub and a [list](https://emojipedia.org/) of them (also [this](https://gist.github.com/rxaviers/7360908))

## Signing your commits

Official documentation [here](https://docs.github.com/en/authentication/managing-commit-signature-verification).

### Setup GPG Key

#### Windows

On Windows, do the following

1. From the official [gnupg webpage](https://www.gnupg.org/download/), download [gpg4win](https://gpg4win.org/download.html). Install the program.
2. Verify that the program is in your path by running

    ```pwsh
    ($ENV:Path).Replace(";","`n")
    ```

    An entry like `C:\Program Files (x86)\Gpg4win\..\GnuPG\bin` will be in the path, allowing the discovery of `gpg.exe`

3. Open `Kleopatra` and generate new key pair (`Ctrl + N` or use GUI)

    Make sure you use the GitHub verified email address and set the expiration date accordingly

4. After the key is generated, verify it by running

    ```pwsh
    gpg --list-secret-keys --keyid-format=long
    ```

    The key ID under `sec` and `ssb` should match the _subkey_ details in Kleopatra (double click on key -> more details)

5. Copy the public key through Kleopatra

    1. Double click the key in Kleopatra
    2. Click Export and copy everything in the window, starting from `-----BEGIN PGP PUBLIC KEY BLOCK-----` and ending with `-----END PGP PUBLIC KEY BLOCK-----`

6. Open GitHub and go to [GPG key settings](https://github.com/settings/keys), and add a GPG key. Paste the contents of the clipboard (from the previous step).
7. Configure the local `git` to sign commits be default

    Sign commits using GPG by default

    ```pwsh
    git config --global commit.gpgsign true
    ```

    Set the path to the GPG program

    ```pwsh
    git config --global gpg.program "C:\Program Files (x86)\GnuPG\bin\gpg.exe"
    ```

That's it, try this with a test commit and see the `Verified` badge beside it on GitHub :tada:

> **WIP**: Not working currently for WSL

For **WSL**, do the following (assuming Ubuntu WSL)

1. Verify existing keys and program

    ```bash
    gpg --list-secret-keys --keyid-format=long
    which gpg
    ```

    The above should create a `~/.gnupg` folder

2. Verify that `git` configurations do not already have something setup

    ```bash
    git config --global -l
    ```

3. Generate a new key

    Start the utility

    ```bash
    gpg --full-generate-key
    ```

    Select any algorithm (RSA works) and make sure the keysize is 4096. You may set a passphrase.

4. Get the key

    List them all

    ```bash
    gpg --list-secret-keys --keyid-format=long
    ```

    Get a particular key (assuming ID - after `algo/` in `sec` line - is `3AA5C34371567BD2`)

    ```bash
    gpg --armor --export 3AA5C34371567BD2
    ```

    Copy the output to clipboard

5. Open GitHub and go to [GPG key settings](https://github.com/settings/keys), and add a GPG key. Paste the contents of the clipboard (from the previous step).

6. Configure `git` locally to use gpg

    Automatically sign commits

    ```bash
    git config --global commit.gpgsign true
    ```

    Set the path

    ```bash
    git config --global gpg.program `which gpg`
    ```

    Verify

    ```bash
    git config --global -l
    ```
