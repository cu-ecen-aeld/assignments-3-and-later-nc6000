#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.
# Modified: Anastasia Zagorodnikova

set -e
set -u

# Prevent full script execution as root
if [ "$EUID" -eq 0 ]; then
  echo "Please DO NOT run this script as root. Sudo will be used only when needed."
  exit 1
fi

KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath "$(dirname "$0")")
ARCH=arm64
CROSS_COMPILE=/home/nc6000/arm-cross-compiler/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-

# Handle optional outdir argument
if [ $# -lt 1 ]; then
    OUTDIR="/tmp/aeld"
    echo "Using default directory ${OUTDIR} for output"
else
    OUTDIR=$(realpath "$1")
    echo "Using passed directory ${OUTDIR} for output"
fi

if [ ! -d "${OUTDIR}" ]; then
    mkdir -p "${OUTDIR}" || { echo "Failed to create output directory: ${OUTDIR}"; exit 1; }
fi

cd "$OUTDIR"

# Clone the kernel source if not already cloned
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
    git clone --depth 1 --branch ${KERNEL_VERSION} ${KERNEL_REPO}
fi

# Build the kernel if not already built
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd "${OUTDIR}/linux-stable"
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    echo "Building the kernel for ${ARCH}"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    make -j$(nproc) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} Image

    # Fix permissions and copy kernel image
    chmod a+r arch/${ARCH}/boot/Image
    
fi
# Copy the kernel image from the kernel build directory to the OUTDIR root
# Always copy the kernel image to OUTDIR root to ensure it's available,
# even if the kernel was previously built.
cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}/Image


echo "Kernel build complete. Images should be at:"
echo "  Original: ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image"
echo "  Copied:   ${OUTDIR}/Image"

echo "Creating the staging directory for the root filesystem"

cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]; then
    echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm -rf "${OUTDIR}/rootfs"
fi

mkdir -p ${OUTDIR}/rootfs/{bin,dev,etc,home,lib,proc,sbin,sys,tmp,usr/bin,usr/sbin,var}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]; then
    git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
else
    cd busybox
fi

echo "Configuring BusyBox"
make distclean
make defconfig

echo "Building BusyBox"
make -j$(nproc) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}

echo "Installing BusyBox to rootfs"
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

echo "Copying library dependencies to rootfs"

SYSROOT=${CROSS_COMPILE%/*}/../aarch64-none-linux-gnu/libc

mkdir -p ${OUTDIR}/rootfs/lib
mkdir -p ${OUTDIR}/rootfs/lib64

cp -a ${SYSROOT}/lib/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib/
cp -a ${SYSROOT}/lib64/libc.so.6 ${OUTDIR}/rootfs/lib64/
cp -a ${SYSROOT}/lib64/libm.so.6 ${OUTDIR}/rootfs/lib64/
cp -a ${SYSROOT}/lib64/libresolv.so.2 ${OUTDIR}/rootfs/lib64/



echo "Creating device nodes"
mkdir -p ${OUTDIR}/rootfs/dev
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/null c 1 3
sudo mknod -m 600 ${OUTDIR}/rootfs/dev/console c 5 1

echo "Building writer utility"
cd ${FINDER_APP_DIR}
make clean
make CROSS_COMPILE=${CROSS_COMPILE}

echo "Copying writer to rootfs home directory"
cp writer ${OUTDIR}/rootfs/home/

echo "Copying finder-app scripts and autorun-qemu.sh to rootfs home directory"
mkdir -p ${OUTDIR}/rootfs/home

cp ${FINDER_APP_DIR}/finder.sh ${OUTDIR}/rootfs/home/
mkdir -p ${OUTDIR}/rootfs/home/conf
cp ${FINDER_APP_DIR}/conf/username.txt ${OUTDIR}/rootfs/home/conf/
cp ${FINDER_APP_DIR}/conf/assignment.txt ${OUTDIR}/rootfs/home/conf/

cp ${FINDER_APP_DIR}/finder-test.sh ${OUTDIR}/rootfs/home/
cp ${FINDER_APP_DIR}/autorun-qemu.sh ${OUTDIR}/rootfs/home/

echo "Changing ownership to root for rootfs"
sudo chown -R root:root ${OUTDIR}/rootfs

echo "Adding /init to rootfs (required for QEMU boot)"
sudo cp ${OUTDIR}/rootfs/bin/busybox ${OUTDIR}/rootfs/init
sudo chmod +x ${OUTDIR}/rootfs/init

echo "Creating initramfs.cpio.gz"
cd ${OUTDIR}/rootfs
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
cd ${OUTDIR}
gzip -f initramfs.cpio

echo "Build complete."
echo "Kernel Image (original): ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image"
echo "Kernel Image (copied to): ${OUTDIR}/Image"

echo "Initramfs: ${OUTDIR}/initramfs.cpio.gz"

