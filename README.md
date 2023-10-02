# supercloud util

For managing mamba/conda in supercloud, clone this repo to your home dir
source the following from your .bashrc:

```
source $HOME/supercloud_util/conda_env_tools.bash
```

Exit the shell, and login again to the same login node,
check `sync_conda_login_to_global` is defined (eg shows up in tab autocomplete)

NB.
.bashrc is not called on batch jobs within supercloud



# general conda instructions:


When logged in again, check
`which python` and it should be `/state/partition1/user/...`
