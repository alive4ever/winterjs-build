set -e
umask 022
DEBIAN_CODENAME="trixie"
sudo apt update
sudo apt install -y mmdebstrap systemd-container debian-archive-keyring
sudo mmdebstrap --arch=arm64 --include sudo,curl,build-essential,devscripts,lsb-release,git,python3,python3-venv,python3-distutils-extra,nodejs,bc,libc6-dev,linux-libc-dev,libelf-dev,binutils-dev,pkgconf "$DEBIAN_CODENAME" /var/lib/machines/arm64-debian http://deb.debian.org/debian
echo "Container successfully created"

