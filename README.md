# setup supercloud util

clone this repo into your homedir (form a login node), and add this line to your .bashrc:

```
source $HOME/supercloud_util/conda_env_tools.bash
```

Exit the shell, and login again to the same login node,
(login-4 is 172.22.254.14 for now)
*Test*:  `$MAMBA_LOCAL` is defined now

# setup mamba base env.

Assuming $MAMBA_LOCAL is defined

from a login node download the Miniforge install script:
```
curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash ./Miniforge-pypy3-Linux-x86_64.sh -b -p  $MAMBA_LOCAL
$MAMBA_LOCAL/bin/python -m mamba.mamba init
```

Log out, and log in back into the *same* login node (try a few times if needed)
*Test*: `which python` should be `/state/partition1/user/...`.

# saving mamba base env

Run ```sync_conda_login_to_global```. This may take a couple of seconds.
This command saves $MAMBA_LOCAL to $MAMBA_GLOBAL (in the shared filesystem)

# tests:
* Batch worker: `LLsub  ~/supercloud_util/test.bash -s 1 -q xeon-p8`
check the log output file (after job is done, can check `LLstat` is empty)
`test.bash-<some job number>`

The last line should be `SUCCESS`
This tests that the environment setup works also in worker nodes.

* Interactive worker:
`LLsub -i full -q xeon-p8`
run `bash ~/supercloud_util/test.bash` from the command line.
SUCCESS should be printed

# Setting up new mamba environments of your own
In login nodes you can create your own app env
`mamba create -n myenv python=3.11` etc..

then `sync_conda_login_to_global` will back it up so its usable in worker nodes.

You can test this similar to the base with with extra argument:
`LLsub  ~/supercloud_util/test.bash -s 1 -q xeon-p8 -- myenv`

# Setting up project env for open_flamingo:
A working open flamingo env tarball is available at askem_shared
On a login node:

`cp ~/askem_shared/envs/open_flamingo.tar $MAMBA_GLOBAL/envs/`
then run
`sync_conda_login_to_local`

now you should be able to run
`mamba activate open_flamingo` on the login node.

`LLsub  ~/supercloud_util/test.bash -s 1 -q xeon-p8 -- open_flamingo` should produce success.
If this doesnt work, lets chat.

# modifying environments:
You can install new packages on login nodes 
`mamba activate <env>`
`mamba install <my pkg>`
but to see those upgrades in other nodes you need to 
`sync_conda_login_to_global`

















