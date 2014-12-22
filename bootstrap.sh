# Based on Ubuntu 14.4
set -e

# Install build dependencies
apt-get update
apt-get install -y build-essential subversion libncurses-dev libz-dev git gawk cmake pkg-config

# Build and install ecdsautils for key generation and signing
if command -v ecdsakeygen; then
    echo "ecdsautils already installed :)"
else
    echo "ecdsautils not found :( Building..."
    mkdir -p /tmp/build
    cd /tmp/build/
    git clone http://git.universe-factory.net/libuecc
    cd libuecc/
    cmake ./
    make && make install
    ldconfig

    cd ..
    git clone https://github.com/tcatm/ecdsautils
    cd ecdsautils/
    cmake ./
    make && make install
fi

