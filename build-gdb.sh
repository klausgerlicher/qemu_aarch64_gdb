#! /bin/bash
_SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
source $_SCRIPT_DIR/bconfig.sh

mkdir -p $_BLD_DIR
mkdir -p $_GDB_BLD_DIR
mkdir -p $_INSTALL_DIR

pushd $_GDB_BLD_DIR
echo $_GDB_SRC_DIR
# Configure with python3 support
$_GDB_SRC_DIR/configure \
   CFLAGS='-O0 -g' CXXFLAGS='-O0 -g' \
   --prefix=$_INSTALL_DIR \
   --disable-ld \
   --disable-gold \
   --disable-binutils \
   --disable-gas \
   --disable-gprof \
   --disable-elfcpp \
   --with-python=python3 \
   --with-additional-debug-dirs=/usr/lib/debug
   # Build (this takes a while)
make -j$(nproc) all-gdb all-gdbserver all-binutils |& tee $_GDB_BLD_DIR/made_gdb.txt
# Install binary
make install-gdb install-gdbserver |& tee $_GDB_BLD_DIR/inst_gdb.txt
popd
