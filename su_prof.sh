#! /bin/bash
# Проверяем есть ли уже такие строки в файле sudoers. Вносим измеения если строки не найдены

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

if ! sudo grep -q "^$USER ALL = (ALL) NOPASSWD: MPROOTCMD" /etc/sudoers; then
    echo "$USER ALL = (ALL) NOPASSWD: MPROOTCMD" | sudo tee -a /etc/sudoers
fi

if ! sudo grep -q "^$USER ALL = (ALL) NOPASSWD: MPFILECMD" /etc/sudoers; then
    echo "$USER ALL = (ALL) NOPASSWD: MPFILECMD" | sudo tee -a /etc/sudoers 
fi 

if ! sudo grep -q "^$USER ALL = (ALL) NOPASSWD: MPEXCPTNSCMD" /etc/sudoers; then
    echo "$USER ALL = (ALL) NOPASSWD: MPEXCPTNSCMD" | sudo tee -a /etc/sudoers
fi

echo "sudoers настроено"
# Проверяем существует ли директория $HOME/bin если нет то создаем
if [ -d "$HOME/bin" ] ; then
echo "Директория существует $HOME/bin"
else
 mkdir -p $HOME/bin
fi
# Проверяетм права доступа к домашней директории, должен быть равен 700

if [[ "$(stat -c '%a' "$HOME")" != "700" ]]; then
  # Если права доступа отличаются от 700, то изменяем их
  chmod 700 -R "$HOME"
  echo "Установлены права доступа 700 для директории $HOME"
else
  echo "Права доступа для директории $HOME уже установлены на 700"
fi

# Указываем директорию, которую нужно добавить в PATH
NEW_DIR_BIN="$HOME/bin"

if ! sudo grep -q "^export PATH=" ~/.bashrc; then
    echo "export PATH=$NEW_DIR_BIN:$PATH" | sudo tee -a ~/.bashrc
    #source ~/.bashrc
    export PATH=$NEW_DIR_BIN:$PATH
    echo "Добавлена директория $NEW_DIR_BIN в PATH"
    echo $PATH
else
    # Если директория уже есть в PATH, выводим сообщение об этом
   echo "Директория $NEW_DIR_BIN уже есть в PATH"
fi

# Распаковываем содержимое архива bin.tar в директорию NEW_DIR_BIN
if [ -f "$NEW_DIR_BIN/.soft" ]; then
    echo "bit.tar уже распакован в $NEW_DIR_BIN"
else 
tar -xvf $HOME/bin.tar -C $NEW_DIR_BIN >> $NEW_DIR_BIN/.soft
mv $NEW_DIR_BIN/bin/* $NEW_DIR_BIN/
rm -r $NEW_DIR_BIN/bin
fi 