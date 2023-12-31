# setup supercloud util

clone this repo into your homedir (form a login node) run the follwing

```
echo 'source $HOME/supercloud_util/conda_env_tools.bash' >> .bashrc
```
To add this to your bashrc

Exit the shell, and login again to the same login node,
(login-4 is 172.22.254.14 for now)
*Test*:  `$MAMBA_LOCAL` direvtory is defined now eg. `echo $MAMBA_LOCAL`

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

```sync_conda_login_to_global```

This may take a couple of seconds.
This command saves $MAMBA_LOCAL to $MAMBA_GLOBAL (in the shared filesystem)

# testing:
* Batch worker. First submit a job using LLsub. This will test that the environment setup works also in worker nodes.

  ```LLsub  ~/supercloud_util/test.bash -s 1 -q xeon-p8```
  
The log output file should be at `~/test.bash-<some job number>`

The last line in this file should be `SUCCESS`

* Interactive worker:
Request an interactive worker:

```LLsub -i full -q xeon-p8```

then upon loggin in to worker node:

```bash ~/supercloud_util/test.bash``` 

SUCCESS should be printed, as before.

# Example: setting up a mamba env for open_flamingo 

On a login node:

```
mkdir repos; cd repos; git clone https://github.com/orm011/open_flamingo.git
cd open_flamingo
git checkout supercloud
mamba create -n open_flamingo
mamba env update -n open_flamingo -f ./environment.yml  # will install deps
```
now you should be able to run
```
cd ~
mamba activate open_flamingo
python -c 'import open_flamingo' 
```

This was all installed on ephemeral `/state/partition1/`
Now run 
```
sync_conda_login_to_global
```
This will make this env. available in other nodes.

* *test*:
```LLsub  ~/supercloud_util/test.bash -s 1 -q xeon-p8 -- open_flamingo```
should produce success. If this doesnt work, lets chat.

# Appendix

## Setting up project env for seesaw:
Same as for open_flamingo but with 
`~/fastai_shared/seesaw/envs/seesaw.tar `

## Setting up new mamba environments of your own 
In login nodes you can create your own app env
`mamba create -n myenv python=3.11` etc..

then `sync_conda_login_to_global` will back it up so its usable in worker nodes.

You can test this similar to the base with with extra argument:
`LLsub  ~/supercloud_util/test.bash -s 1 -q xeon-p8 -- myenv`

## Modifying existing envs.
You can install new packages on login nodes 
`mamba activate <env>`
`mamba install <my pkg>`

but to see those upgrades in other nodes you need to 
`sync_conda_login_to_global`

















