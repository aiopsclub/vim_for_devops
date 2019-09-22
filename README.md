# vim-for-devops 

A vim ide install script, it support code highlight, automatic code completion for shell or python or golang.

# Requirements

* Vim >= 8.1 (most features needed +python or +python3 support) 
* golang >= 1.11
* python >= 3.6

This script will auto install all software. 
 

Import: it only run Centos7


# Usage

[(Back to top)](#vim-for-devops)

```sh
git clone https://github.com/yxxhero/vim_for_devops.git
cd vim_for_devops
bash ./install.sh install
```

# ScreenShot
python 代码检查以及自动补全和代码高亮 

![python 代码检查以及自动补全和代码高亮](https://github.com/yxxhero/vim_for_devops/blob/master/screenshoot/python_auto.gif)

python isort自动格式化import相关的库

![python isort自动格式化import相关的库](https://github.com/yxxhero/vim_for_devops/blob/master/screenshoot/isort.gif)

python isort自动格式化import相关的库

![python isort自动格式化import相关的库](https://github.com/yxxhero/vim_for_devops/blob/master/screenshoot/isort.gif)

python目录树以及自动pep8格式化代码

![python目录树以及自动pep8格式化代码](https://github.com/yxxhero/vim_for_devops/blob/master/screenshoot/tree_pep8.gif)

shell自动补全和代码高亮

![shell自动补全和代码高亮](https://github.com/yxxhero/vim_for_devops/blob/master/screenshoot/shell.gif)

golang 自动补全和代码高亮 代码检查自动格式化 自动import未导入的包
![golang 自动补全和代码高亮 代码检查自动格式化 自动import未导入的包](https://github.com/yxxhero/vim_for_devops/blob/master/screenshoot/go.gif)


# Uninstallation

[(Back to top)](#vim-for-devops)


```sh
bash install.sh clean
```

