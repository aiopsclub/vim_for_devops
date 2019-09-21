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
    md5value=`md5sum ${filepath}|awk '{print $1}'`

    if [ $value == $md5value ]
    then
        echo "true"
    else
        echo "false"
    fi
}

function install_base_software(){
    logging "Start install base software..."
    yum install bc ncurses-devel openssl openssl-devel wget git cmake openssl perl* libffi-devel python-devel ruby-devel lua-devel perl-devel perl ruby lua -y
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
    rm -fr $GOPATH/src/golang.org/x/lint || true
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
    if [ -e ~/.vimrc ]
    then
        cp -a ~/.vimrc ~/.vimrc.bak
    fi
    cp -af ./vimrc ~/.vimrc 
}

function install_vim_plugins(){
    vim +PluginInstall +qall
}

function go_install_binaries(){
    vim +GoInstallBinaries +qall
}

function install_vim_vundle(){
    rm -fr ~/.vim.bak &> /dev/null || true
    if [ -d ~/.vim ]
    then
        mv ~/.vim ~/.vim.bak
    fi
    rm -fr ~/.vim &> /dev/null || true
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
}

function install_ycm_plugin(){
    ycm_old_dir=`pwd`
    export GO111MODULE=on
    export GOPROXY=https://goproxy.io
    if ! [ -d  ~/.vim/bundle/YouCompleteMe ]
    then
        git clone ${YCM_GITHUB} ~/.vim/bundle/YouCompleteMe
    fi
    cd  ~/.vim/bundle/YouCompleteMe
    git submodule update --init --recursive
    python3 ./install.py --clang-completer  --go-completer
    cd $ycm_old_dir
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
    old_dir=`pwd`
    if `check_dir_exist ${SOFTWARE_SRC}Python-3.7.4`
    then
        rm -fr ${SOFTWARE_SRC}Python-3.7.4
    fi
    tar xf ${SOFTWARE_SRC}Python-3.7.4.tgz -C ${SOFTWARE_SRC}
    worddir=`pwd`
    cp -f ${worddir}/Setup.dist ${SOFTWARE_SRC}Python-3.7.4/Modules/
    cd ${SOFTWARE_SRC}Python-3.7.4
    ./configure --prefix=${SOFTWARE_PATH_BASE}python3.7 --enable-shared  --enable-optimizations --enable-ipv6
    make && make install || exit 6
    echo -n "${SOFTWARE_PATH_BASE}python3.7/lib" > /etc/ld.so.conf.d/python3.conf
    ldconfig -v
    
    if ! `cat /etc/profile | grep ${PATH}:${SOFTWARE_PATH_BASE}python3.7/bin`
    then
       echo "export PATH=${PATH}:${SOFTWARE_PATH_BASE}python3.7/bin" >> /etc/profile 
    fi
    cd $old_dir	
}

function build_go(){
    # 创建临时目录
    tmp_dir=`mktemp -d`
    tar xf ${SOFTWARE_SRC}go1.13.linux-amd64.tar.gz -C ${tmp_dir}
    mv ${tmp_dir}/go ${SOFTWARE_PATH_BASE}go1.13
    rm -fr ${tmp_dir}
    if ! `cat /etc/profile | grep ${PATH}:${SOFTWARE_PATH_BASE}go1.13/bin`
    then
        echo "export PATH=${PATH}:${SOFTWARE_PATH_BASE}go1.13/bin" >> /etc/profile 
    fi
}

function build_vim(){
    old_dir=`pwd`
    if `python3_install_mode`
    then
        python3_install_config=${SOFTWARE_PATH_BASE}python3.7/lib/python3.7/config-3.7m-x86_64-linux-gnu
    else
        python3_install_config=${python3_config}
    fi

    cd ${SOFTWARE_SRC}vim/src
    ./configure --with-features=huge --enable-multibyte --enable-rubyinterp=yes --enable-pythoninterp=yes --with-python-config-dir=${python27_config} --enable-python3interp=yes --with-python3-config-dir=${python3_install_config} --enable-perlinterp=yes --enable-luainterp=yes --enable-cscope --prefix=${SOFTWARE_PATH_BASE}vim8   --enable-terminal --enable-multibyte
    make && make install || exit 6 
    # echo -n "export PATH=${PATH}:${SOFTWARE_PATH_BASE}vim8/bin" >> /etc/profile 
    if `which vi &> /dev/null`
    then
        vi_path=`which vi`
        mv ${vi_path} ${vi_path}.bak
    fi
    rm -fr /usr/bin/vim || true
    rm -fr /usr/bin/vi || true
    ln -svf ${SOFTWARE_PATH_BASE}vim8/bin/vim /usr/bin/vim 
    ln -svf ${SOFTWARE_PATH_BASE}vim8/bin/vim /usr/bin/vi 
    cd $old_dir
}

function install_vim(){
    if [ -d ${SOFTWARE_SRC}vim ]
    then
        rm -fr ${SOFTWARE_SRC}vim
    fi
    ensure_dir_exist ${SOFTWARE_SRC}vim 
    git clone https://github.com/vim/vim.git ${SOFTWARE_SRC}vim
    build_vim
}


function install_py3(){
    if [ -e ${SOFTWARE_SRC}Python-3.7.4.tgz ]
    then
        logging "find python3.7.4 source"
        if ! `check_file_md5 ${SOFTWARE_SRC}Python-3.7.4.tgz $PY3_SOURCE_MD5`
        then
            logging "python3.7.4 md5value unmatch.."
            rm -f ${SOFTWARE_SRC}Python-3.7.4.tgz
            wget $PY3_SOURCE -P ${SOFTWARE_SRC}
        fi
        build_py3
    else
        wget $PY3_SOURCE -P ${SOFTWARE_SRC}
        build_py3
    fi
}

function install_go(){
    if [ -e ${SOFTWARE_SRC}go1.13.linux-amd64.tar.gz ]
    then
        if ! `check_file_md5 ${SOFTWARE_SRC}go1.13.linux-amd64.tar.gz $GO_SOURCE_MD5`
        then
            rm -f ${SOFTWARE_SRC}go1.13.linux-amd64.tar.gz
            wget $GO_BINARY -P ${SOFTWARE_SRC}
        else
            build_go
        fi
    else
        wget $GO_BINARY -P ${SOFTWARE_SRC}
        build_go
    fi
}

function install_choice() {
    choice_soft_name=$1
    read -n1 -p "Do you want to install ${choice_soft_name} default:Y [Y/N]? " answer 
    case $answer in 
    Y|y) 
        echo "true";; 
    N|n) 
        echo "false";; 
    *) 
        echo "true" 
        ;; 
    esac
}

function check_soft_is_install(){

    soft_name=$1
    if `check_dir_exist ${SOFTWARE_PATH_BASE}${soft_name}`
    then
        if ! `dir_is_empty ${SOFTWARE_PATH_BASE}${soft_name}`
         
        then
            echo ""
            logging "${SOFTWARE_PATH_BASE}${soft_name} not empty!"
            exit 3
        fi
    fi

}

function set_gopath(){
    gopath=/opt/src/go
    read -p "Set env GOPATH[/opt/src/go]: " go_path 
    if [[ "$go_path" =~ ^/[a-zA-Z0-9]+(/[a-zA-Z0-9]+)*  ]]
    then
        export GOPATH=$go_path
    else
        export GOPATH=$gopath
    fi
    logging "set GOPATH $GOPATH"
}

function install_me(){
    ensure_dir_exist ${SOFTWARE_SRC}
    install_base_software
    set_gopath
    ensure_dir_exist $GOPATH
    
    logging "Install python3..."

    logging "find python config dir..."
    if [ -d /usr/lib64/python2.7/config  ]
    then
        python27_config=/usr/lib64/python2.7/config
    elif [ -d /usr/lib/python2.7/config   ] 
    then
        python27_config=/usr/lib64/python2.7/config
    else
        read -p "python2.7 config not found, please input custom python2.7 config dir:" python27_config
        echo ""
    fi

    if `install_choice python3` 
    then
        check_soft_is_install python3.7 
        python3_install_mode=true
        install_py3
        source /etc/profile
    else
        python3_install_mode=false
        echo ""
        read -p "please input custom python3 config dir:" python3_config
        while true
        do
            if [[ "$python3_config" =~ ^/[a-zA-Z0-9]+(/[a-zA-Z0-9]+)*  ]]
            then
                break
            else
                read -p "dir format error, please input custom python3 config dir:" python3_config
            fi
        done
    fi
    pip3 install --upgrade pip
    pip3 install flake8
    pip3 install black
    pip3 install isort
    echo ""
    
    logging "Install vim..."
    if `install_choice vim8` 
    then
        check_soft_is_install vim8
        install_vim
        source /etc/profile
    fi
    echo ""

    logging "Install golang..."
    if `install_choice go1.13` 
    then
       check_soft_is_install go1.13 
       install_go
       source /etc/profile
       go_depend_source
    fi
    echo ""

    logging "install vim vundle plugin manager..."
    install_vim_vundle
    logging "Copy vimrc..."
    copy_vimrc_to_home
    logging "install ycm plugin..."
    install_ycm_plugin
    logging "install vim plugins..."
    install_vim_plugins
    logging "go binarys..."
    go_install_binaries

    logging "Install successfully..."
    

    
}

function usage(){
    echo "help: bash $0 install | clean"

}

function remove_software(){
   spath=$1
   if [ -d $spath ]
   then
       logging "remove $spath"
       rm -fr $spath
   fi

}

function restroe_vim_conf(){
    logging "restroe vim conf if exists"
    rm -fr ~/.vim &> /dev/null || true
    if [ -d ~/.vim.bak ]
    then
        mv ~/.vim.bak ~/.vim
    fi

    rm -f ~/.vimrc &> /dev/null || true
    if [ -d ~/.vimrc ]
    then
        mv ~/.vimrc.bak ~/.vimrc
    fi

}

function clean_me() {
    remove_software ${SOFTWARE_PATH_BASE}python3.7
    remove_software  ${SOFTWARE_PATH_BASE}go1.13
    remove_software ${SOFTWARE_PATH_BASE}vim8
    if ! [ -z $GOPATH ]
    then
       remove_software $GOPATH
    fi
    remove_software $SOFTWARE_SRC
    
    restroe_vim_conf
}

# 入口函数

function main(){
    if [ $# -ne 1 ]
    then
        usage
    else
        case $1 in
        install)
            logging "Install Start..."
            install_me
            ;;
        clean)
            logging "Clean Start..."
            clean_me
            ;;
        *)
            logging "Unkown Choice[install | clean ]" 
            exit 999
            ;;
        esac
    fi
}

main $@
