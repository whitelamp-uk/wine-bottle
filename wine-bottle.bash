

if [ "$1" = "exe" ]
then
    # cd to the program directory
    cd "$(dirname "$(realpath "$2")")"
    # Run the program
    wine "$(realpath "$2")"
    exit $?
fi


if [ ! "$3" ]
then
    echo "Usage: bash $0 bottle_name installer_file architecture"
    exit
fi

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

# Change into this directory
cd "$(dirname "$(realpath "$0")")"
bottleBank="$(pwd)"

# Create/edit bottle config (usually you want 32-bit)
echo "Bottle = $bottleBank/$bottle"
if [ -f "./$bottle.cfg.info" ]
then
    cat "./$bottle.cfg.info"
fi
echo -n "Configure? [y/N] "
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

# Use winetricks
echo "For winetricks: use \"Select the default wineprefix\""
echo "When finished, use \"Cancel\" to escape"
if [ -f "./$bottle.tricks.info" ]
then
    cat "./$bottle.tricks.info"
fi
echo -n "Use winetricks? [y/N] "
read ok
if [ "$ok" = "Y" ] || [ "$ok" = "y" ]
then
    WINEARCH=$arch WINEPREFIX="$bottleBank/$bottle" winetricks
fi

# Do install
echo "Attempt to install $installer into $bottleBank/$bottle"
if [ -f "./$bottle.install.info" ]
then
    cat "./$bottle.install.info"
fi
echo -n "Run installer? [y/N] "
read ok
if [ "$ok" = "Y" ] || [ "$ok" = "y" ]
then
    WINEARCH=$arch WINEPREFIX="$bottleBank/$bottle" wine "$installer"
fi

cd "$wd"

