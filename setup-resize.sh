#!/bin/bash
# This is a general-purpose function to ask Yes/No questions in Bash, either
# with or without a default answer. It keeps repeating the question until it
# gets a valid answer.
ask() {
  #printf '\n--> Function: %s <--\n' "${FUNCNAME[0]}"
  # https://djm.me/ask
  local prompt default reply

  while true; do

    if [[ "${2:-}" == "Y" ]]; then
      prompt="[Y/n]"
      default=Y
    elif [[ "${2:-}" == "N" ]]; then
      prompt="[y/N]"
      default=N
    else
      prompt="[y/n]"
      default=
    fi

    # Ask the question (not using "read -p" as it uses stderr not stdout)
    printf '\n'
    printf '%s ' $1 $prompt

    read reply

    # Default?
    if [[ -z "$reply" ]]; then
      reply=${default}
    fi

    # Check if the reply is valid
    case "$reply" in
    Y* | y*) return 0 ;;
    N* | n*) return 1 ;;
    esac

  done
}

Greeting () {
    printf '\nHello!\nThis script should get your Kali and Parrot OS VMs using XFCE and MATE to resize automatically with Spice-VD Agent installed.\nCredit to DannyDa for this solution.\n\nDISCLAIMER\nIt is not recommended that you run scripts that you find on the internet without knowing exactly what they do.\n\nThis script contains functions that require root privilages.\n'
    sleep 1s
    if ask "Do you wish to proceed?" N; then
        Proceeding
        ScriptDirCheck
        RootCheck
    else
        GoodBye
    fi
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
    if ! IsRoot; then
        printf "\nThis script is not being run as root. Please Run this script as Root or with sudo."
        sleep 1s
        Goodbye
    fi
}

#Make sure script is being run from within the script's directory.
ScriptDirCheck() {
    sleep 1s
    DirCheckFile=./files/.dircheckfile
    if [[ -f "$DirCheckFile" ]]; then
        return 0
    else
        printf '\nThis script is being run from outside its intended directory. Please run this script from its main directory.'
        GoodBye
        exit
    fi
}

#Check if apt package is installed.
# If CheckForPackage package; then
# package is not installed.
# If ! CheckForPackage package; then
# package is installed.
CheckForPackage() {
    return $(dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -c "ok installed")
}

#Install specified Package
InstallPKG() {
    $PKGMGR install -y $1
    check_exit_status;
}

#Install Qemu guest agent and/or Spice-vdagent for QEMU VMs
VMSetup() {
    if CheckForPackage spice-vdagent; then
        if ask "Would you like to install spice-vdagent for an improved desktop VM experience?" N; then
            InstallPKG spice-vdagent
            check_exit_status
        else
            printf '\nSkipping installing Spice-vdagent.\n'
        fi
    fi
    if CheckForPackage qemu-guest-agent; then
        if ask "Would you like to install qemu-guest-agent for improved VM control and monitoring" N; then
            InstallPKG qemu-guest-agent
            check_exit_status
        else
            printf '\nSkipping installing qemu-guest-agent.\n'
        fi
    fi
    if ! CheckForPackage spice-vdagent; then
        printf "Sometimes, the VM doesn't resize automatically. If that's the case this part of the script can usually fix that."
        if ask "Would you like to apply the resize VM fix?" N; then
            ResizeVM
        else
            printf "\nSkipping Resize Fix.\n"
        fi
    else
        printf "\nSpice-vdagent not installed, Skipping resize VM fix.\n"
    fi
}

#Move Files to specified locations and apply executable permission.
ResizeVM () {
    mkdir -p /usr/local/bin
    mkdir -p /etc/udev/rules.d
    cp ./files/x-resize /usr/local/bin/x-resize
    cp ./files/50-x-resize.rules /etc/udev/rules.d/50-x-resize.rules
    chmod +x /usr/local/bin/x-resize
}

#check process for errors and prompt user to exit script if errors are detected.
check_exit_status() {
    if [ $? -eq 0 ]; then
        printf '\nSuccess\n'
    else
        printf '\nError\nThe last command exited with an error.\n'
        if ask "Exit script?" N; then
            GoodBye
        else
            Proceeding
        fi
    fi
}

#Print Proceeding
Proceeding() {
    printf "\nProceeding\n"
}

#Print Goodbye and exit the script
GoodBye() {
    printf "\nGoodbye.\n";
    exit
}

#Functions ---> ^ ^ ^ ^ ^ ^ ^ ^ <-----
#Script ------> V V V V V V V V <----- 


#Greet The User and Warn of using scripts that need root privilages.
Greeting
PKGMGR=apt
DefinedSHELL=/bin/bash
if IsRoot; then
    echo 'export LC_ALL=C.UTF-8' >> /etc/profile
    echo 'export LANG=C.UTF-8' >> /etc/profile
fi
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

#Setup Nala
if ! CheckForPackage nala; then
    PKGMGR=nala
elif ! CheckForPackage nala-legacy; then
    PKGMGR=nala
else
    if IsRoot; then
        printf "Nala is a front-end for libapt-pkg with a variety of features such as parallel downloads, clear display of what is happening, and the ability to fetch faster mirrors."
        if ask "Would you like to install Nala?" N; then
            SetupNala
        else
            printf '\nSkipping Nala Setup.\n'
        fi
    else
        PKGMGR=apt
    fi
fi

#Install spice VD agent if it's not already installed
VMSetup
GoodBye