#!/bin/bash

#  gpg_wizard
#
#
#  Created by Gaëtan Cherbuin on 27.07.15
#

#prepare gpg

if system_profiler SPUSBDataType | grep -q Yubikey;
then pkill gpg-agent
export PINENTRY_USER_DATA="USE_CURSES=1"
gpg-agent --use-standard-socket --daemon
clear
else
echo "Insert Yubikey & run again" && exit 1
fi

#menu

read -p "$(echo -e '
1: Asymmetric (with signature)\b
2: Asymmetric (without key_id)\b
3: Symmetric \b
4: Create encrypted image (not using GPG)\b
5: exit\n\b')" choice

if [[ $choice =~ ^([1])$ ]]
then read -p "$(echo -e 'File to encrypt: \n\b')" file_to_encrypt && gpg -r $USER -e $file_to_encrypt && gpg -sb $file_to_encrypt.gpg
elif [[ $choice =~ ^([2])$ ]]
then read -p "$(echo -e 'File to encrypt: \n\b')" file_to_encrypt && gpg -r $USER --hidden-recipient $USER --throw-keyids -e $file_to_encrypt
elif [[ $choice =~ ^([3])$ ]]
then read -p "$(echo -e 'File to encrypt: \n\b')" file_to_encrypt && read -p "$(echo -e 'Cipher: [A]ES, [B]lowfish or [T]wofish \n\b')" Symm_choice
if [[ $Symm_choice =~ ^([aA])$ ]]
then gpg --symmetric --cipher-algo AES256 $file_to_encrypt
elif [[ $Symm_choice =~ ^([bB])$ ]]
then gpg --symmetric --cipher-algo BLOWFISH $file_to_encrypt
elif [[ $Symm_choice =~ ^([tT])$ ]]
then gpg --symmetric --cipher-algo TWOFISH $file_to_encrypt
else echo "Invalid choice" && exit 1
fi
elif [[ $choice =~ ^([4])$ ]]
then read -p "$(echo -e 'size in MB (50m)\n\b')" size && read -p "$(echo -e 'name \n\b')" name && read -p "$(echo -e 'path \n\b')" path  && hdiutil create -size $size -fs HFS+ -encryption AES-256 -volname $name $path/$name.dmg
elif [[ $choice =~ ^([5])$ ]]
then echo "bye" && exit 0
else echo "invalid choice" && exit 1
fi
