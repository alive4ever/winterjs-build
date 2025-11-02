set -e
HOME=/home/$(whoami)
cd $HOME
START_TIME=$(date -u +%s.%N)
CLANG_VERSION=20
CLANG_BASE="/usr/lib/llvm-$CLANG_VERSION"
export LIBCLANG_PATH="$CLANG_BASE/lib"
PATH="$CLANG_BASE/bin:$PATH"
clang --version
RUST_TARGET="clang -dumpmachine"
PKG_VERSION="v1.2.0"
curl -L -o rustup-install.sh https://sh.rustup.rs
sh rustup-install.sh -y --default-toolchain 1.90.0
. $HOME/.cargo/env
rustc --version
cargo --version
git clone --depth=1 --branch="$PKG_VERSION" https://github.com/wasmerio/winterjs
cd winterjs
cargo build --release
BIN_PATH=$(find ./target/release -executable -type f -name winterjs | head -n 1)
echo "Testing the built binary"
[ -x "$BIN_PATH" ]
"$BIN_PATH" ./tests/simple.js
mkdir -p /tmp/hosttmp/winterjs_deb
PKG_FILENAME="winterjs-$PKG_VERSION-$RUST_TARGET.tar.gz"
tar --numeric-owner -C ./target/release -cvf - . | gzip -n > /tmp/hosttmp/winterjs_deb/"$PKG_FILENAME"
cd /tmp/hosttmp/winterjs
sha256sum "$PKG_FILENAME" | tee "${PKG_FILENAME}.sha256"
cd $OLDPWD
cargo install cargo-deb
cargo deb --release
DEBNAME=$(basename $(find ./target/debian -name '*.deb'))
cp -v ./target/debian/"$DEBNAME" /tmp/hosttmp/deno_deb/
cd /tmp/hosttmp/deno_deb
sha256sum "$DEBNAME" | tee "$DEBNAME".sha256
cd $OLDPWD
END_TIME=$(date -u +%s.%N)
echo "Done in $(echo $END_TIME-$START_TIME | bc) s"
