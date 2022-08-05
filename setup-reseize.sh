#!/bin/bash
Greeting () {
    sleep 1s
    printf '\nHello!'
    sleep 1s
    printf '\nThis script should get your Kali and Parrot OS VMs using XFCE and MATE to resize automatically with Spice-VD Agent installed.'
    printf '\nCredit to DannyDa for this solution.'
    sleep 1s
    printf '\n\nDISCLAIMER'
    sleep 1s
    printf '\nIt is not recommended that you run scripts that you find on the internet without knowing exactly what they do.\n\n
This script contains functions that require root privilages.\n'
    sleep 2s
    while true; do
        read -p $'Do you wish to proceed? [y/N]' yn
        yn=${yn:-N}
        case $yn in
            [Yy]* ) Proceeding
            ScriptDirCheck
            RootCheck
            return 0
            ;;
            [Nn]* ) GoodBye
            ;;
            * ) AnswerYN
            ;;
        esac
    done
}
#Check if User is Root.
IsRoot() {
    sleep 1s
    if [[ $EUID = 0 ]]; then
      return 0
      else
      return 1
    fi
}

#Check for Root and inform user that the script has parts that require root and parts for non-root users.
RootCheck() {
    sleep 1s
    if ! IsRoot; then
        printf "\nThis script is not being run as root. Please Run this script as Root or with sudo."
        sleep 1s
        Goodbye
    fi
}

#Make sure script is being run from within the script's directory.
ScriptDirCheck() {
    sleep 1s
    DirCheckFile=./.dircheckfile
    if [[ -f "$DirCheckFile" ]]; then
        return 0
    else
        printf '\nThis script is being run from outside its intended directory. Please run this script from its main directory.'
        GoodBye
        exit
    fi
}

#Check if apt package is installed.
CheckForPackage() {
    printf '\n--------------------> Function: %s <--------------------\n' "${FUNCNAME[0]}"
    sleep 1s
    REQUIRED_PKG=$1
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
    echo Checking for $REQUIRED_PKG: $PKG_OK
    if [ "install ok installed" = "$PKG_OK" ]; then
      return 0
    else
      return 1
    fi
}

#Install specified Package
InstallPKG() {
    sleep 1s
    if IsRoot; then
        if ! CheckForPackage $1; then
            printf '\nWould you like to install %s? [y/n]' "$1"
            read -r yn
            case $yn in
                [Yy]* ) printf '\nInstalling %s\n' "$1"
                        $PKGMGR install -y $1
                        check_exit_status;
                        return 0
                        ;;
                [Nn]* ) printf '\nSkipping %s\n' "$1"
                        return 0
                        ;;
                    * ) printf '\nPlease enter yes or no.\n'
                        ;;
            esac
        else
            printf '\nSkipping %s, already installed.\n' "$1"
        fi
    fi
}

#Install Spice-vdagent for QEMU VMs
VMSetup() {
    sleep 1s
    if ! CheckForPackage spice-vdagent; then
        printf '\nWould you like to install spice-vdagent for an improved VM desktop experience? [Y/n] '
        read -r yn
        yn=${yn:-Y}
        case $yn in
            [Yy]* ) InstallPKG spice-vdagent
                check_exit_status
            ;;
            [Nn]* ) printf '\nSkipping installing Spice-vdagent.'
            ;;
            * ) AnswerYN
            ;;
        esac
    fi
}

#Move Files to specified locations
MoveFiles() {
    mkdir -p /usr/local/bin
    mkdir -p /etc/udev/rules.d
    cp ./files/x-resize /usr/local/bin/x-resize
    cp ./files/50-x-resize.rules /etc/udev/rules.d/50-x-resize.rules
}

#Modify File Permissions
ModifyFiles() {
    chmod +x /usr/local/bin/x-resize
}

#check process for errors and prompt user to exit script if errors are detected.
check_exit_status() {
    sleep 1s
    if [ $? -eq 0 ]; then
        printf '\nSuccess\n'
    else
        printf '\nError\nThe last command exited with an error. Exit script? (y/N) '
        read -r yn
        yn=${yn:-Y}
        case $yn in
            [Yy]* ) GoodBye
            ;;
            [Nn]* ) Proceeding
            ;;
            *) AnswerYN
            ;;
        esac
    fi
}

#Print Proceeding
Proceeding() {
    printf '\n--------------------> Function: %s <--------------------\n' "${FUNCNAME[0]}"
    sleep 1s
    printf "\nProceeding\n"
}

#Print Goodbye and exit the script
GoodBye() {
    printf '\n--------------------> Function: %s <--------------------\n' "${FUNCNAME[0]}"
    sleep 1s
    printf "\nGoodbye.\n";
    exit
}

AnswerYN() {
    printf '\nPlease answer yes or no.'
}

#Functions ---> ^ ^ ^ ^ ^ ^ ^ ^ <-----
#Script ------> V V V V V V V V <----- 


#Greet The User and Warn of using scripts that need root privilages.
Greeting
PKGMGR=apt
DefinedSHELL=/bin/bash

#Check if Nala is installed
if CheckForPackage nala; then
    PKGMGR=nala
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8
elif CheckForPackage nala-legacy; then
    PKGMGR=nala
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8
else
    PKGMGR=apt
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8
fi

#Install spice VD agent if it's not already installed
VMSetup
#Move files to specified locations
MoveFiles
#Modify file permisions
ModifyFiles
GoodBye