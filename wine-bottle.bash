# bash /home/chris/Wine/wine-bottle.bash exe "Paint_Shop_Pro_9/drive_c/Program Files/Jasc Software Inc/Paint Shop Pro 9/Paint Shop Pro 9.exe"

if [ "$1" = "exe" ]
then
    cd "$(dirname "$(realpath "$2")")"
    echo -n "In directory "
    pwd
    wine "$2"
    exit
fi


if [ ! "$3" ]
then
    echo "Usage: bash $0 bottle_name installer_file architecture"
    exit
fi

# Where to put the bottles
bottleBank="$HOME/Wine"
# Set a bottle name
bottle="$1"
# Set the location of the installer
installer="$(realpath "$2")"
# Set the architecture
if [ "$3" = "64" ]
then
    arch=""
elif [ "$3" = "32" ]
then
    arch="win32"
else
    echo "Architecture \"$3\" is not recognised"
fi
# Working directory
wd="$(pwd)"
# Sources list
list="/etc/apt/sources.list.d/wine-obs.list"
# Upstream info
upstream="/etc/upstream-release/lsb-release"
echo "Your upstream - see $upstream"
cat "$upstream"


echo -n "This script is for Ubuntu 18.04. Continue? [y/N] "
read ok
if [ "$ok" != "Y" ]
then
    if [ "$ok" != "y" ]
    then
        exit
    fi
fi


# Install wine
key="download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/Release.key"
src="$(dirname "$key")"
if [ "$(grep $src $list)" ]
then
    echo "Already found $src in $list"
else
    echo "Adding $src to $list"
    wget -O- -q "https://$key" | sudo apt-key add -
    echo "deb http://$src ./" | sudo tee "$list"
fi
echo "Update/install if missing:"
sudo apt update
sudo apt install --install-recommends winehq-stable
sudo apt install winetricks

# The following is based on this tutorial:
# https://www.youtube.com/watch?v=RmOdA5GeSqs

# Create a location for wine bottles
mkdir -p "$bottleBank"

# Change into that directory
cd "$bottleBank"

# Create/edit bottle config (usually you want 32-bit)
echo "Bottle = $bottleBank/$bottle"
echo -n "Configuration: at least make sure you have the right Windows version. Continue? [y/N] "
read ok
if [ "$ok" = "Y" ] || [ "$ok" = "y" ]
then
    WINEARCH=$arch WINEPREFIX="$bottleBank/$bottle" winecfg
fi

if [ -d "$bottleBank/$bottle/drive_c/windows/Fonts" ]
then
    echo "Currently you have these fonts installed:"
    ls -l "$bottleBank/$bottle/drive_c/windows/Fonts"
fi

# Use winetricks to install some fonts
echo "Extra winetricks: use \"Select the default wineprefix\""
echo -n "As a minimum you should install \"corefonts\" - continue [y/N] "
read ok
if [ "$ok" = "Y" ] || [ "$ok" = "y" ]
then
    WINEARCH=$arch WINEPREFIX="$bottleBank/$bottle" winetricks
fi

# Do install
echo -n "Attempt to install $installer into $bottleBank/$bottle? [y/N] "
read ok
if [ "$ok" = "Y" ] || [ "$ok" = "y" ]
then
    WINEARCH=$arch WINEPREFIX="$bottleBank/$bottle" wine "$installer"
fi

cd "$wd"

