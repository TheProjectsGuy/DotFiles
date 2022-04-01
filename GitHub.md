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
