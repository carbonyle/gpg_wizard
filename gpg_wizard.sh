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
echo "Insert Yubikey & run again" && osascript -e 'display notification "You might have forgotten something" with title "AI"'&& exit 1
fi

#menu

osascript -e 'display notification "Greetings" with title "AI"'

read -p "$(echo -e '
1: Asymmetric (Public-key cryptography) \b
2: Symmetric (AES, Blowfish or Twofish ciphers) \b
3: Decrypt \b
4: Sign \b
5: Verify \b
6: Smartcard operations \b
7: Other \b
8: Exit \n\b')" choice

    if [[ $choice =~ ^([1aA])$ ]]
    then read -p "$(echo -e '
1: To self, with signature \b
2: To self, without key_id \b
3: To: \b
4: Main menu \b
5: Exit \n\b')" asymm_option
        if [[ $asymm_option =~ ^([1])$ ]]
            then read -p "$(echo -e 'File to encrypt: \n\b')" file_to_encrypt && gpg -r $USER -e $file_to_encrypt && gpg -sb $file_to_encrypt.gpg
            elif [[ $asymm_option =~ ^([2])$ ]]
            then read -p "$(echo -e 'File to encrypt: \n\b')" file_to_encrypt && gpg -r $USER --hidden-recipient $USER --throw-keyids -e $file_to_encrypt
            elif [[ $asymm_option =~ ^([3])$ ]]
            then read -p "$(echo -e 'Email of the recipient: \n\b')" recipient && read -p "$(echo -e 'File to encrypt: \n\b')" file_to_encrypt && gpg -r $recipient -e $file_to_encrypt
            elif [[ $asymm_option =~ ^([4mM])$ ]]
            then /Users/gaetan/git/gpg_wizard
            elif [[ $asymm_option =~ ^([5])$ ]]
            then  echo "bye" && osascript -e 'display notification "See you again!" with title "AI"' && exit 0
            else echo "Invalid choice" && osascript -e 'display notification "What happened?" with title "AI"' && exit 1
        fi
    elif [[ $choice =~ ^([2sS])$ ]]
    then read -p "$(echo -e 'File to encrypt: \n\b')" file_to_encrypt && read -p "$(echo -e 'Cipher: [A]ES, [B]lowfish or [T]wofish \n\b')" Symm_choice
        if [[ $Symm_choice =~ ^([aA])$ ]]
            then gpg --symmetric --cipher-algo AES256 $file_to_encrypt
            elif [[ $Symm_choice =~ ^([bB])$ ]]
            then gpg --symmetric --cipher-algo BLOWFISH $file_to_encrypt
            elif [[ $Symm_choice =~ ^([tT])$ ]]
            then gpg --symmetric --cipher-algo TWOFISH $file_to_encrypt
            else echo "Invalid choice" && osascript -e 'display notification "What happened?" with title "AI"' && exit 1
        fi
    elif [[ $choice =~ ^([3dD])$ ]]
    then read -p "$(echo -e 'File to decrypt: \n\b')" file_to_decrypt && gpg -o "$(basename $file_to_decrypt .gpg)" -d $file_to_decrypt && mv "$(basename $file_to_decrypt .gpg)" "$(dirname $file_to_decrypt)"
    elif [[ $choice =~ ^([4sS])$ ]]
    then read -p "$(echo -e 'File to sign: \n\b')" file_to_sign && gpg -sb $file_to_sign
    elif [[ $choice =~ ^([5vV])$ ]]
    then read -p "$(echo -e 'File to verify: \n\b')" file_to_verify && gpg --verify $file_to_verify
    elif [[ $choice =~ ^([6yY])$ ]]
    then clear && read -p "$(echo -e '
1: Card status \b
2: Show public keys \b
3: Show private keys \b
4: Import public key \b
5: Edit card \b
6: Main menu \b
7: Exit \b')" card_operation
            if [[ $card_operation =~ ^([1sS])$ ]]
                then gpg --card-status
                elif [[ $card_operation =~ ^([2])$ ]]
                then gpg --list-keys
                elif [[ $card_operation =~ ^([3])$ ]]
                then gpg --list-secret-keys
                elif [[ $card_operation =~ ^([4iI])$ ]]
                then read -p "$(echo -e 'Key to import\n\b')" import && gpg --import $import
                elif [[ $card_operation =~ ^([5eE])$ ]]
                then read -p "$(echo -e 'Are you sure [Y]? \n\b')" confirmation
                            if [[ $confirmation =~ ^([Y])$ ]]
                                then gpg --card-edit
                                else osascript -e 'display notification "You shall not pass!" with title "AI"' && exit 1
                            fi
                elif [[ $card_operation =~ ^([6mM])$ ]]
                then /Users/gaetan/git/gpg_wizard
                elif [[ $card_operation =~ ^([7qQ])$ ]]
                then echo "bye" && osascript -e 'display notification "See you again!" with title "AI"' && exit 0
                else echo "Invalid choice" && osascript -e 'display notification "What happened?" with title "AI"' && exit 1
            fi
    elif [[ $choice =~ ^([7])$ ]]
    then clear && read -p "$(echo -e '
1: Create a encrypted container (not using GPG) \b
2: Print email addresses from public keyring \b
3: Prepare gpg-agent for Mail \b
4: Run ssh script \b
5: Run backup script \b
6: Main menu \b
7: Exit \n\b')" other_options
            if [[ $other_options =~ ^([1])$ ]]
                then read -p "$(echo -e 'size in MB (50m)\n\b')" size && read -p "$(echo -e 'name \n\b')" name && read -p "$(echo -e 'path \n\b')" path  && hdiutil create -size $size -fs HFS+ -encryption AES-256 -volname $name $path/$name.dmg
                elif [[ $other_options =~ ^([2])$ ]]
                then gpg --list-key | grep -o -E "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" | sort | uniq -i
                elif [[ $other_options =~ ^([3])$ ]]
                then    pkill gpg-agent
                        gpg-agent
                        clear
                        open /Applications/Mail.app
                elif [[ $other_options =~ ^([4])$ ]]
                then /Users/gaetan/git/ssh_script
                elif [[ $other_options =~ ^([5])$ ]]
                then /Users/gaetan/git/backup_
                elif [[ $other_options =~ ^([6mM])$ ]]
                then /Users/gaetan/git/gpg_wizard
                elif [[ $other_options =~ ^([7qQ])$ ]]
                then echo "bye" && osascript -e 'display notification "See you again!" with title "AI"' && exit 0
                else echo "invalid choice" && osascript -e 'display notification "What happened?" with title "AI"' && exit 1
            fi
    elif [[ $choice =~ ^([8qQ])$ ]]
    then echo "bye" && osascript -e 'display notification "See you again!" with title "AI"' && exit 0
    else echo "invalid choice" && osascript -e 'display notification "What happened?" with title "AI"' && exit 1
fi
