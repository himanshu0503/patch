#!/bin/bash -e
export PS1="$ "
source ~/.bashrc
echo 'Creating symbolic link for pickle'
ln -s /tmp/pickle/bin/pickle /usr/bin/
