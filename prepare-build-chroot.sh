set -e
export DEBIAN_FRONTEND="noninteractive"
DEBIAN_CODENAME="bookworm"
echo "deb http://apt.llvm.org/$DEBIAN_CODENAME/ llvm-toolchain-$DEBIAN_CODENAME-20 main" > /etc/apt/sources.list.d/llvm.list
if grep "deb-src" <  /etc/apt/sources.list ; then
sed -i".orig" -E "s/#\s+?deb-src/deb-src/" /etc/apt/sources.list
else
echo "deb-src http://deb.debian.org/debian/ $DEBIAN_CODENAME main contrib" >> /etc/apt/sources.list
fi
curl -sSL https://apt.llvm.org/llvm-snapshot.gpg.key | sudo dd of=/etc/apt/trusted.gpg.d/apt.llvm.org.asc
apt-get update
apt-get build-dep -y firefox-esr
apt-get install -y lld-20 clang-20 clang-tools-20 clang-tidy-20 clang-format-20 libclang-20-dev
useradd -m -G sudo -s /bin/bash builder
passwd -d builder
