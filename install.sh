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
SOFTWARE_PATH_BASE=/usr/local/
SOFTWARE_SRC=/opt/src/

YCM_GITHUB=https://github.com/ycm-core/YouCompleteMe
PY3_SOURCE=https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tgz

PY3_SOURCE_MD5=68111671e5b2db4aef7b9ab01bf0f9be

GO_BINARY=https://dl.google.com/go/go1.13.linux-amd64.tar.gz
GO_SOURCE_MD5=f88286704f2b5aaff8041cb269745427


function logging () { 
    echo "$(date '+%F %H:%M:%S')    |  $*"
}

function ensure_dir_exist(){
    dir=$1
    if [ ! -d "$dir" ];then
        mkdir -p $dir 
    fi
}

function check_file_md5(){
    filepath=$1
    value=$2
    md5value=`md5sum $filepath|awk '{print $1}'`

    if [ $value == $md5value ]
    then
        echo "true"
    else
        echo "false"
    fi
}

function install_base_sortware(){
    yum install bc git cmake openssl -y
    yum groupinstall "Development Tools" -y
}

function dir_is_empty(){
    empty_dir=$1
    file_num=`ls -l $empty_dir |grep -v "^total"|wc -l`
    if [ $file_num -gt 0 ]
    then
        echo "false"
    else
        echo "true"
    fi
}

function check_dir_exist(){
    check_dir=$1
    if [ -d "$check_dir" ]
    then
        echo "true"
    else
        echo "false"
    fi
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

function build_py3(){
    if `check_dir_exist ${SOFTWARE_SRC}Python-3.7.4`
    then
        rm -fr ${SOFTWARE_SRC}Python-3.7.4
    fi
    tar xf ${SOFTWARE_SRC}Python-3.7.4.tgz -C ${SOFTWARE_SRC}
    worddir=`pwd`
    cp -f ${worddir}/Setup.dist ${SOFTWARE_SRC}Python-3.7.4/Modules/
    cd ${SOFTWARE_SRC}Python-3.7.4
    ./configure --prefix=${SOFTWARE_PATH_BASE}python3.7 --enable-shared  --enable-optimizations --enable-ipv6
    make && make install
    echo -n "${SOFTWARE_PATH_BASE}python3.7/lib" >> /etc/ld.so.conf.d/python3.conf
    ldconfig -v
}

function build_go(){
    tar xf ${SOFTWARE_SRC}go1.13.linux-amd64.tar.gz -C ${SOFTWARE_SRC}
    mv ${SOFTWARE_SRC}go ${SOFTWARE_SRC}go1.13
}


function install_py3(){
    if [ -e ${SOFTWARE_SRC}Python-3.7.4.tgz ]
    then
        if ! `check_file_md5 ${SOFTWARE_SRC}Python-3.7.4.tgz PY3_SOURCE_MD5`
        then
            rm -f ${SOFTWARE_SRC}Python-3.7.4.tgz
            wget $PY3_SOURCE
        else
            build_py3
        fi
    else
        wget $PY3_SOURCE
        build_py3
    fi
}

function install_py3(){
    if [ -e ${SOFTWARE_SRC}go1.13.linux-amd64.tar.gz ]
    then
        if ! `check_file_md5 ${SOFTWARE_SRC}go1.13.linux-amd64.tar.gz GO_SOURCE_MD5`
        then
            rm -f ${SOFTWARE_SRC}go1.13.linux-amd64.tar.gz
            wget $GO_BINARY
        else
            build_go
        fi
    else
        wget $GO_BINARY
        build_go
    fi
}

function main(){
    if `check_dir_exist ${SOFTWARE_PATH_BASE}python3.7`
    then
        if ! `dir_is_empty ${SOFTWARE_PATH_BASE}python3.7`
         
        then
            logging "${SOFTWARE_PATH_BASE}python3.7 not empty!"
            exit 1
        fi
    fi

    if `check_dir_exist ${SOFTWARE_PATH_BASE}vim81`
    then
        if ! `dir_is_empty ${SOFTWARE_PATH_BASE}vim81`
        then
            logging "${SOFTWARE_PATH_BASE}vim81 not empty!"
            exit 2
        fi
    fi

    if `check_dir_exist ${SOFTWARE_PATH_BASE}go1.13`
    then
        if ! `dir_is_empty ${SOFTWARE_PATH_BASE}go1.13`
        then
            logging "${SOFTWARE_PATH_BASE}go1.13 not empty!"
            exit 3
        fi
    fi
}

# 入口函数
main
