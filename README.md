dotfiles (.bashrc, .bash_profile, etc) for windows

# Requirements

[windows-workstation-bootstrap](https://github.com/micnigh/windows-workstation-bootstrap)

# Quick start

```bash
cd ~/
git init .
git remote add origin https://github.com/micnigh/windows-dotfiles.git
git fetch --all
git reset --hard origin/master
```

# Troubleshooting

## Windows 10 and docker-machine

 - Can't create a new machine due to `Error Renaming Connection`
  - Workaround - see [#1706](https://github.com/docker/machine/issues/1706)

    ```bash
    # remove all docker-machines and remove `~/.docker/machine`
    docker-machine-init # start this but it will fail, Ctrl+C to cancel once it hangs
    docker rm -f dev # this will delete dev machine - but keep network interfaces created earlier
    docker-machine-init # should now complete without problems
    ```

# Resources

[how-to-use-git-to-manage-your-user-configuration-files-on-a-linux-vps](https://www.digitalocean.com/community/tutorials/how-to-use-git-to-manage-your-user-configuration-files-on-a-linux-vps)
