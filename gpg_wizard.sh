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

#file input

read -p "$(echo -e 'File to encrypt: \n\b')" file_to_encrypt

#encryption process

read -p "$(echo -e '[A]symmetric or [S]ymmetric cryptography: \n\b')" enc_type

if [[ $enc_type =~ ^([aA])$ ]]
then read -p "$(echo -e '[S]ign or [H]ide key_id: \n\b')" Asymm_choice
	if [[ $Asymm_choice =~ ^([sS])$ ]]
	then gpg -r $USER -e $file_to_encrypt
	     gpg -sb $file_to_encrypt.gpg
	elif [[ $Asymm_choice =~ ^([hH])$ ]]
	then gpg -r $USER --hidden-recipient $USER --throw-keyids -e $file_to_encrypt
	else echo "Invalid choice" && exit 1
	fi
elif [[ $enc_type =~ ^([sS])$ ]]
then
read -p "$(echo -e 'Cipher: [A]ES, [B]lowfish or [T]wofish \n\b')" Symm_choice
	if [[ $Symm_choice =~ ^([aA])$ ]]
        then gpg --symmetric --cipher-algo AES256 $file_to_encrypt
        elif [[ $Symm_choice =~ ^([bB])$ ]]
        then gpg --symmetric --cipher-algo BLOWFISH $file_to_encrypt
        elif [[ $Symm_choice =~ ^([tT])$ ]]
	then gpg --symmetric --cipher-algo TWOFISH $file_to_encrypt
	else echo "Invalid choice" && exit 1
	fi
else echo "Invalid choice" && exit 1
fi

echo "encryption successful"
