#!/bin/bash
PATH_DISTRIB=$(pwd)

# Определение дистрибутива 
if [ -f /etc/redhat-release ]; then
    DISTRIB=$( cat /etc/redhat-release |cut -d " " -f1 | head -n1 )
    if [ "$DISTRIB" == "Red" ]; then
    echo 'У вас установлена ОС Red-Hat'
    elif [ "$DISTRIB" == "CentOS" ]; then
    echo 'У вас установлена ОС Centos'
    elif [ "$DISTRIB" == "ALT" ]; then
    echo 'У вас установлена ОС ALT'
    elif [ "$DISTRIB" == "Oracle" ]; then
    echo 'У вас установлена Oracle Linux'
    elif  [ "$DISTRIB" == "RED" ]; then
    echo "У вас установлеа ОС RedOS "
    echo ' Выполняется проверка и при необходимости будут внесены изменения в Sudoers&bashrc'
    . $PATH_DISTRIB/RED\ OS/redos_sudoers_c.sh
    fi

elif [ -f /etc/lsb-release ]; then
    DISTRIB=$( cat /etc/lsb-release | cut -d '=' -f2 | head -n1 )
    if [ "$DISTRIB" == "Ubuntu" ]; then 
    echo 'У вас установлена ОС Ubuntu'
    echo ' Выполняется проверка и при необходимости будут внесены изменения в Sudoers&bashrc'
    . $PATH_DISTRIB/Canonical\ Ubuntu/ubuntu_sudoers_c.sh
    fi

elif [ -f /etc/debian_version ]; then
    echo 'У вас установлена ОС Debian'
    echo ' Выполняется проверка и при необходимости будут внесены изменения в Sudoers&bashrc'
    . $PATH_DISTRIB/Debian/Ubuntu/debian_sudoers_c.sh

elif [ -f /etc/os-release ]; then
    echo 'У вас установлена ОС SUSE Linux Enterprise Server' 

elif [ -f /etc/version ]; then
    echo 'У вас установлена ОС FreeBSD'

elif [ -f /etc/issue]; then
    echo 'У вас установлена ОС HP-UX'

elif [ -f /etc/oslevel ]; then
    echo 'У вас установлена ОС IBM AIX'

elif [ -f /etc/release ]; then
    echo 'У вас установлена ОС Oracle Solaris'
else
echo "Под вашу ОС скрипт еще не создан!)"

fi