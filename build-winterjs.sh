set -e
HOME=/home/$(whoami)
cd $HOME
[ -d $HOME/.local/bin ] || mkdir -p $HOME/.local/bin
[ -f /etc/skel/.profile ] && . /etc/skel/.profile
START_TIME=$(date -u +%s.%N)
CLANG_VERSION=20
CLANG_BASE="/usr/lib/llvm-$CLANG_VERSION"
export LIBCLANG_PATH="$CLANG_BASE/lib"
PATH="$CLANG_BASE/bin:$PATH"
clang --version
export CC="sccache clang"
export CXX="sccache clang++"
export RUST_WRAPPER="sccache"
export RUST_BACKTRACE=1
PYTHON_VERSION=3.11
RUST_TARGET="$($CC -dumpmachine)"
PKG_VERSION="main"
RELEASE_DIR="/tmp/hosttmp/winterjs_deb"
curl -L -o rustup-install.sh https://sh.rustup.rs
sh rustup-install.sh -y --default-toolchain 1.90
. $HOME/.cargo/env
rustc --version
cargo --version
git clone https://github.com/nvm-sh/nvm ~/.nvm
[ -d ~/.nvm ] && . ~/.nvm/nvm.sh
nvm install --lts
curl -L -o uv-install.sh https://astral.sh/uv/install.sh
sh uv-install.sh
uv --version
uv python install "$PYTHON_VERSION"
python"$PYTHON_VERSION" --version
uv venv
. ./.venv/bin/activate
uv pip install -U setuptools pip
pip --version
node --version
git clone --depth=1 --branch="$PKG_VERSION" https://github.com/wasmerio/winterjs
cd winterjs
PKG_COMMIT="$(git log --oneline -1 | cut -d \  -f 1 | head -n 1)"
echo "1.90" | tee ./rust-toolchain
cargo build --release
BIN_PATH=$(find ./target/release -executable -type f -name winterjs | head -n 1)
echo "Testing the built binary"
[ -x "$BIN_PATH" ]
"$BIN_PATH" ./tests/simple.js
mkdir -p $RELEASE_DIR
PKG_FILENAME="winterjs-$PKG_VERSION-$PKG_COMMIT-$RUST_TARGET.tar.gz"
tar --numeric-owner -C ./target/release -cvf - . | gzip -n > $RELEASE_DIR/"$PKG_FILENAME"
cd $RELEASE_DIR
sha256sum "$PKG_FILENAME" | tee "${PKG_FILENAME}.sha256"
cd $OLDPWD
cargo install cargo-deb
cargo deb --release
DEBNAME=$(basename $(find ./target/debian -name '*.deb'))
cp -v ./target/debian/"$DEBNAME" $RELEASE_DIR/
cd $RELEASE_DIR
sha256sum "$DEBNAME" | tee "$DEBNAME".sha256
cd $OLDPWD
END_TIME=$(date -u +%s.%N)
echo "Done in $(echo $END_TIME-$START_TIME | bc) s"
