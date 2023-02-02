# KBackup tool - Backup made easy

[KBackup](https://apps.kde.org/kbackup/) is a helpful KDE backup tool. I use it to backup my [Obsidian](./Obsidian/) vaults.

> [Official Source Code](https://invent.kde.org/utilities/kbackup)

Install using

```bash
sudo apt install kbackup
```

## Automated Backups

Open the GUI and configure the profile. Set the backup properties and store the profile.

> See [Handbook](https://docs.kde.org/stable5/en/kbackup/kbackup/index.html): [This](https://docs.kde.org/stable5/en/kbackup/kbackup/using-kbackup.html), and [this](https://docs.kde.org/stable5/en/kbackup/kbackup/automating.html)

Add this to the crontab

```txt
0 2 * * * /usr/bin/kbackup --verbose --autobg /home/avneesh/KBackup/obsidian_vault.kbp
```
