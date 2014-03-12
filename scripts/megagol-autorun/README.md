Prerequisite
============
This script is intended to work on the french meso-centre hpc@lr (see https://www.hpc-lr.univ-montp2.fr/).
Apply to a project creation and then access to your user/passwd.

Your account has to be updated in each cmd file instead of 'mirmidon' account_name.

Compilation
===========
Before any submission, please compile the WaveWatch III (v4.18 or later) model. Then link the exe binaries in '$PATH-TO-MEGAGOL/resources/exe' .

Launch
======
Once all the prerequisite stuff has been done, just submit the autorun.cmd on the cluster. You'll find udpate of your job in the $LOG -- default = logs -- file.

