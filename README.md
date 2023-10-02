# supercloud util

For conda stuff, on a login node install miniforge:
(we're using mamba client for conda)
https://github.com/conda-forge/miniforge#download
x86_64 (amd64) flavor


*Important*: 
when asked about the path for miniforge:
enter 
"/state/partition1/user/$USER/miniforge"
This path is used by the conta utils, known as MAMBA_LOCAL.

NB: /state/partition1/ is not a global file system, its local 
but its fast, so we run conda from here. not doing this makes life very painful when using supercloud.

This is still painful, but once set up works ok.
The tools in the repo help sync this folder and to other nodes, by copying into /home/gridsan/...
and then unpacking on the other nodes /state/partition1/ folder.

Say yes when it offers to run conda init for you.
This will modify your bashrc.

exit the shell and login again to the *same* login node

Independently of this, clone this repo to your home dir

Then two things:
1.  source the following from your .bashrc:

```
source $HOME/supercloud_util/conda_env_tools.bash
```

.bashrc is not called on batch jobs within supercloud


Exit the shell, and login again to the same login node
eg, login-4 is 172.31.130.22 (from within superlcoud), you can add this to your .ssh/config.


When logged in again, check
`which python` and it should be `/state/partition1/user/...`
