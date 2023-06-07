#! /bin/bash
# Скопируйте скрипт и архив bin.tar в домашнюю директорию.
# Для выполнения скрипта, пользователь из под которого будет запущен скрипт должен быть добавлен в группу SUDO
##############################################################################################
# Проверяем есть ли уже такие строки в файле sudoers. Вносим измеения если строки не найдены
read -p "Введите имя пользователся которого необходимо проверить: " USER_NEW
if ! sudo grep -q "^Cmnd_Alias MPROOTCMD =" /etc/sudoers; then
    # Если строка не найдена, добавляем ее в файл
    echo "Cmnd_Alias MPROOTCMD = /usr/bin/at -l, /usr/bin/crontab * -l, /sbin/fdisk -l, /sbin/iptables-save, /bin/netstat, /bin/ss, /usr/sbin/dmidecode, /sbin/vgdisplay, /sbin/lvdisplay, /sbin/auditctl -[lv]" | sudo tee -a /etc/sudoers
fi

if ! sudo grep -q "^Cmnd_Alias MPFILECMD =" /etc/sudoers; then
    echo "Cmnd_Alias MPFILECMD = /bin/cat, /usr/bin/find *, /bin/ls, /usr/bin/getfacl, /usr/bin/test" |sudo tee -a /etc/sudoers
fi

if ! sudo grep -q "^Cmnd_Alias MPEXCPTNSCMD =" /etc/sudoers; then
    echo "Cmnd_Alias MPEXCPTNSCMD = !/usr/bin/find *-exec*, !/usr/bin/find *-fprint*, !/usr/bin/find *-ok*, !/usr/bin/find *-delete*, !/usr/bin/find *-fls*, !/bin/ss *--diag*, !/bin/ss *-D*, !/usr/sbin/dmidecode *-dump*" | sudo tee -a /etc/sudoers 
fi 

if ! sudo grep -q "env_reset" /etc/sudoers; then
    echo "Defaults  env_reset" | sudo tee -a /etc/sudoers
fi

if ! sudo grep -q "^$USER_NEW ALL = (ALL) NOPASSWD: MPROOTCMD" /etc/sudoers; then
    echo "$USER_NEW ALL = (ALL) NOPASSWD: MPROOTCMD" | sudo tee -a /etc/sudoers
fi

if ! sudo grep -q "^$USER_NEW ALL = (ALL) NOPASSWD: MPFILECMD" /etc/sudoers; then
    echo "$USER_NEW ALL = (ALL) NOPASSWD: MPFILECMD" | sudo tee -a /etc/sudoers 
fi 

if ! sudo grep -q "^$USER_NEW ALL = (ALL) NOPASSWD: MPEXCPTNSCMD" /etc/sudoers; then
    echo "$USER_NEW ALL = (ALL) NOPASSWD: MPEXCPTNSCMD" | sudo tee -a /etc/sudoers
fi
echo "sudoers настроено"
###############################################################################################

# Проверяем существует ли директория $HOME/bin если нет то создаем
DIRECTORIA=/home/$USER_NEW/bin
if [ -d "$DIRECTORIA" ] ; then
  echo "Директория существует $DIRECTORIA"
else
  sudo mkdir -p $DIRECTORIA
  sudo chown -R $USER_NEW:$USER_NEW $DIRECTORIA
fi
###############################################################################################

# Указываем директорию, которую нужно добавить в PATH

if ! sudo grep -q "^export PATH=" /home/$USER_NEW/.bashrc; then
    echo "export PATH=$DIRECTORIA:$PATH" | sudo tee -a /home/$USER_NEW/.bashrc
    #source ~/.bashrc
    export PATH=$DIRECTORIA:$PATH
    echo "Добавлена директория $DIRECTORIA в PATH"
else
    # Если директория уже есть в PATH, выводим сообщение об этом
   echo "Директория $DIRECTORIA уже есть в PATH"
fi
###############################################################################################
# Распаковываем содержимое архива bin.tar в директорию NEW_DIR_BIN
if [ -f "$DIRECTORIA/.soft" ]; then
    echo "bit.tar уже распакован в $DIRECTORIA"
else 
FIND_ARCHIV=$(sudo find /home/  -name bin.tar)
ARCHIV=$(echo $FIND_ARCHIV | cut -d' ' -f1)

sudo tar -xvf $ARCHIV -C $DIRECTORIA >> $DIRECTORIA/.soft
sudo mv $DIRECTORIA/bin/* $DIRECTORIA/
sudo rm -r $DIRECTORIA/bin
fi 
sudo chown -R $USER_NEW /home/$USER_NEW/bin
sudo chgrp -R $USER_NEW /home/$USER_NEW/bin
###############################################################################################
# Проверяетм права доступа к домашней директории, должен быть равен 700

if [[ "$(stat -c '%a' "/home/$USER_NEW")" != "700" ]]; then
  # Если права доступа отличаются от 700, то изменяем их
  sudo chmod 700 -R "/home/$USER_NEW"
  echo "Установлены права доступа 700 для директории /home/$USER_NEW/"
else
  echo "Права доступа для директории /home/$USER_NEW уже установлены на 700"
fi


