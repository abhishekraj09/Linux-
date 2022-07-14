#!/bin/bash

# This script has been copied from: 
# https://github.com/KamalDGRT/Linux/blob/master/distro/F34/post_install_f34.sh 
# and modified


clear

banner() {
    printf "\n\n\n"
    msg="| $* |"
    edge=$(echo "$msg" | sed 's/./-/g')
    echo "$edge"
    echo "$msg"
    echo "$edge"
    printf "\n\n"
}

pause() {
    read -s -n 1 -p "Press any key to continue . . ."
    clear
}

enable_xorg_windowing() {
    # Find & Replace part contributed by: https://github.com/nanna7077
    clear
    banner "Enable Xorg, Disable Wayland"
    printf "\n\nThe script will change the gdm default file."
    printf "\n\nThe file is: /etc/gdm/custom.conf\n"
    printf "\nIn that file, there will be a line that looks like this:"
    printf "\n\n     #WaylandEnable=false\n\n"
    printf "\nThe script will uncomment that line\n"

    SUBJECT='/etc/gdm/custom.conf'
    SEARCH_FOR='#WaylandEnable=false'
    sudo sed -i "/^$SEARCH_FOR/c\WaylandEnable=false" $SUBJECT
    printf "\n/etc/gdm/custom.conf file changed.\n"

    printf "\n\nGDM config updated. It will be reflected in the next boot.\n\n"
}

install_RPM_Fusion_Repos() {
    banner "Enabling the RPM Fusion Repositories"
    sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
}

install_Neofetch() {
    banner "Installing Neofetch"
    sudo dnf install -y neofetch
}

install_Brave_Browser() {
    banner "Installing Brave Browser"

    printf "\nGetting the dependencies...\n"
    sudo dnf install dnf-plugins-core -y

    printf "\nAdding repository for brave...\n"
    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/

    printf "\nImporting and signing the Keys...\n"
    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

    printf "\nDownloading and installing Brave browser...\n"
    sudo dnf install brave-browser -y
}

install_Xclip() {
    banner "Installing xclip"
    sudo dnf install -y xclip
}

gitsetup() {
    banner "Setting up SSH for git and GitHub"

    read -e -p "Enter your GitHub Username                 : " GITHUB_USERNAME
    read -e -p "Enter the GitHub Email Address             : " GITHUB_EMAIL_ID
    read -e -p "Enter the default git editor (vim / nano)  : " GIT_CLI_EDITOR

    if [[ $GITHUB_EMAIL_ID != "" && $GITHUB_USERNAME != "" && $GIT_CLI_EDITOR != "" ]]; then
        printf "\n - Configuring GitHub username as: ${GITHUB_USERNAME}"
        git config --global user.name "${GITHUB_USERNAME}"

        printf "\n - Configuring GitHub email address as: ${GITHUB_EMAIL_ID}"
        git config --global user.email "${GITHUB_EMAIL_ID}"

        printf "\n - Configuring Default git editor as: ${GIT_CLI_EDITOR}"
        git config --global core.editor "${GIT_CLI_EDITOR}"

        printf "\n - Setting up the defaults for git pull"
        git config --global pull.rebase false

        printf "\n - The default branch name for new git repos will be: main"
        git config --global init.defaultBranch main

        printf "\n - Generating a new SSH key for ${GITHUB_EMAIL_ID}"
        printf "\n\nJust press Enter and add passphrase if you'd like to. \n\n"
        ssh-keygen -t ed25519 -C "${GITHUB_EMAIL_ID}"

        printf "\n\nAdding your SSH key to the ssh-agent..\n"

        printf "\n - Start the ssh-agent in the background..\n"
        eval "$(ssh-agent -s)"

        printf "\n\n - Adding your SSH private key to the ssh-agent\n\n"
        ssh-add ~/.ssh/id_ed25519

        printf "\n - Copying the SSH Key Content to the Clipboard..."

        printf "\n\nLog in into your GitHub account in the browser (if you have not)"
        printf "\nOpen this link https://github.com/settings/keys in the browser."
        printf "\nClik on New SSH key."
        xclip -selection clipboard <~/.ssh/id_ed25519.pub
        printf "\nGive a title for the SSH key."
        printf "\nPaste the clipboard content in the textarea box below the title."
        printf "\nClick on Add SSH key.\n\n"
        pause
    else
        printf "\nYou have not provided the details correctly for Git Setup."
        if ask_user "Want to try Again ?"; then
            gitsetup
        else
            printf "\nSkipping: Git and GitHub SSH setup..\n"
        fi
    fi
}

install_VSCode() {
    banner "Installing VS Code"

    printf "\nImporting and signing the necessary keys...\n"
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

    printf "\nAdding the VS Code repository...\n"
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

    printf "\nChecking for updates in the repo list...\n"
    sudo dnf check-update

    printf "\nDownloading and installing VS Code...\n"
    sudo dnf install code -y
}

install_Sublime_Text() {
    banner "Installing Sublime Text"

    printf "\nImporting and signing the necessary keys...\n"
    sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg

    printf "\nAdding the Sublime Text stable repository...\n"
    sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo

    printf "\nDownloading and installing Sublime Text...\n"
    sudo dnf install sublime-text -y
}

install_Vim_Editor() {
    banner "Installing Vim Editor"
    sudo dnf install vim -y
}

install_Neovim_Editor() {
    banner "Installing install_Neovim_Editor"
    sudo dnf install neovim -y
}

install_htop() {
    banner "Installing htop utility"
    sudo dnf install -y htop
}

install_GNOME_Shell_Themes() {
    banner "Installing GNOME Themes Stuff..."
    sudo dnf install -y arc-theme moka-icon-theme gnome-tweaks \
        gnome-shell-extension-appindicator \
        gnome-shell-extension-user-theme \
        gnome-extensions-app
}

install_Telegram_Desktop() {
    banner "Installing Telegram Desktop (rpm)"
    sudo dnf install telegram-desktop -y
}


install_VLC_Media_Player() {
    banner "Installing VLC Media Playyer (rpm)"
    sudo dnf install -y vlc
}

install_Discord_RPM() {
    banner "Installing Discord (rpm)"
    
    # will be installed if RPM fusion repositories are enabled
    sudo dnf install -y discord
}

install_Nodejs() {
    banner "Installing Nodejs"
    sudo dnf install nodejs -y
}

install_qBittorrent() {
    banner "Installing qBittorrent Client"
    sudo dnf install -y qbittorrent
}

install_Google_Chrome_Stable() {
    banner "Installing Google Chrome Stable"

    printf "\ninstall the Fedora's workstation repositories:\n"
    sudo dnf install fedora-workstation-repositories -y

    printf "\nEnabling the Google Chrome Repository..\n"
    sudo dnf config-manager --set-enabled google-chrome

    printf "\nDownloading and Installing Google Chrome"
    sudo dnf install google-chrome-stable -y
}


install_Megasync() {
    banner "Installing MegaSync App"
    
    # will be installed if RPM fusion repositories are enabled
    sudo dnf install megasync -y
}

install_OBS_Studio() {
	banner "Installing OBS Studio"
	
	# will be installed if RPM fusion repositories are enabled
	sudo dnf install obs-studio -y
}

install_MongoDB() {
    banner "Installing MongoDB"
    
    printf "\nUpdating and Upgrading the system"
    sudo dnf update -y && sudo dnf upgrade -y

    printf "\nGoing inside Downloads Folder..."
    cd ~/Downloads/

    printf "\nGetting the mongod server for Fedora..."
    wget 'https://repo.mongodb.org/yum/redhat/8/mongodb-org/5.0/x86_64/RPMS/mongodb-org-server-5.0.7-1.el8.x86_64.rpm'

    printf "\nInstalling the mongod server for Fedora..."
    sudo dnf localinstall mongodb-org-server-5.0.7-1.el8.x86_64.rpm -y
    rm mongodb-org-server-5.0.7-1.el8.x86_64.rpm

    sudo systemctl enable mongod 
    sudo systemctl start mongod 

    # If 'mongo' command does not work, restart your system and then in terminal
    # type the following - 
    # sudo systemctl enable mongod
    # sudo systemctl start mongod

    printf "\nGetting the MongoDB Community Shell..."
    # This will make mongodb run in terminal
    wget 'https://repo.mongodb.org/yum/redhat/8/mongodb-org/5.0/x86_64/RPMS/mongodb-org-shell-5.0.7-1.el8.x86_64.rpm'

    printf "\nInstalling the MongoDB Community Shell..."
    sudo dnf localinstall mongodb-org-shell-5.0.7-1.el8.x86_64.rpm -y
    rm mongodb-org-shell-5.0.7-1.el8.x86_64.rpm

}

install_MongoDB_Compass() {
    banner "Installing MongoDB Compass"

    printf "\nGetting the MongoDB Compass package for Fedora..."
    wget 'https://downloads.mongodb.com/compass/mongodb-compass-1.31.2.x86_64.rpm'

    printf "\nInstalling MongoDB Compass for Fedora..."
    sudo dnf localinstall mongodb-compass-1.31.2.x86_64.rpm -y
    rm mongodb-compass-1.31.2.x86_64.rpm
}
