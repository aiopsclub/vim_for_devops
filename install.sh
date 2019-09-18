#!/bin/bash -
#===============================================================================
#
#          FILE: install.sh
#
#         USAGE: ./install.sh
#
#   DESCRIPTION: 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: yuanxiongxiong (yxxhero), aiopsclub@163.com
#  ORGANIZATION: genedock
#       CREATED: 09/18/2019 02:08:21 PM
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error
set -e

# 配置参数
BASE_VIM_VERSION=8
GO_MAJGOR_VERSION=1
GO_MINOR_VERSION=11

YCM_GITHUB=https://github.com/ycm-core/YouCompleteMe
PY3_SOURCE=https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tgz
GO_BINARY=https://dl.google.com/go/go1.13.linux-amd64.tar.gz


function logging () { 
    echo "$(date '+%F %H:%M:%S')    |  $*"
}

function install_base_sortware(){
    yum install bc -y
    yum install git -y
    yum groupinstall "Development Tools" -y
}

function go_depend_source() {
   
    git clone https://github.com/golang/lint.git $GOPATH/src/golang.org/x/lint
    git clone https://github.com/golang/tools.git $GOPATH/src/golang.org/x/tools
    git clone https://github.com/golang/sync.git $GOPATH/src/golang.org/x/sync
    git clone https://github.com/golang/net.git $GOPATH/src/golang.org/x/net
    git clone https://github.com/golang/xerrors.git $GOPATH/src/golang.org/x/xerrors
    go install golang.org/x/lint
    go install golang.org/x/tools/...
}

function check_go_version(){
    go_version=`go version | sed -rn "s@.*go([0-9]+\.[0-9]*\.?[0-9]*) .*@\1@p"`
    go_major_version=`echo $go_version | cut -d '.' -f 1`
    go_minor_version=`echo $go_version | cut -d '.' -f 2`
    if [ `echo "$go_major_version > $GO_MAJGOR_VERSION"|bc` -eq 1  ] ; then
        logging "go version check pass..."
    elif [[ `echo "$go_major_version == $GO_MAJGOR_VERSION"| bc` -eq 1 && `echo "$go_minor_version >= $GO_MINOR_VERSION"|bc` -eq 1  ]];then
        logging "go version check pass..."
    else
        logging "go version too low..."
    fi
}

function copy_vimrc_to_home(){
    # 备份源文件
    cp -a ~/.vimrc ~/.vimrc.bak
    cp -af ./vimrc ~/.vimrc 
}

function install_vim_plugins(){
    vim +PluginInstall +qall
}

function go_install_binaries(){
    vim +GoInstallBinaries +qall
}

function install_vim_vundle(){
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
}

function check_vim_version(){
    vim_version=`vim --version | head -1 | sed -nr 's@.* ([0-9]+\.[0-9]*\.?[0-9]*) .*@\1@p'`
    if [ `echo "$vim_version < $BASE_VIM_VERSION"|bc` -eq 1  ] ; then
        logging "Your vim version is too low, require vim 8.0+"
        exit 1
    else
        logging "vim version check pass..."
    fi
}


check_vim_version
check_go_version

