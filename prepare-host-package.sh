set -e
umask 022
DEBIAN_CODENAME="bookworm"
sudo apt update
sudo apt install -y mmdebstrap systemd-container debian-archive-keyring
cat << EOL > /tmp/sources.list
deb https://deb.debian.org/debian $DEBIAN_CODENAME main non-free-firmware
deb-src https://deb.debian.org/debian $DEBIAN_CODENAME main non-free-firmware

deb https://security.debian.org/debian-security $DEBIAN_CODENAME-security main non-free-firmware
deb-src https://security.debian.org/debian-security $DEBIAN_CODENAME-security main non-free-firmware

deb https://deb.debian.org/debian $DEBIAN_CODENAME-updates main non-free-firmware
deb-src https://deb.debian.org/debian $DEBIAN_CODENAME-updates main non-free-firmware
EOL
cat /tmp/sources.list | sudo mmdebstrap --arch=arm64 --include sudo,curl,wget,build-essential,devscripts,lsb-release,git,bc,libc6-dev,linux-libc-dev,libelf-dev,binutils-dev,pkgconf,sccache,m4 "$DEBIAN_CODENAME" /var/lib/machines/arm64-debian https://deb.debian.org/debian
echo "Container successfully created"

