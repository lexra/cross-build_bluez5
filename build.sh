#!/bin/bash -e

##############################
[ ! -x /opt/gcc-sigmastar-9.1.0-2019.11-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-gcc ] && exit 1
[ ! -x ./build.sh ] && exit 1

##############################
export TOOLCHAIN_HOME=/opt/gcc-sigmastar-9.1.0-2019.11-x86_64_arm-linux-gnueabihf
export PATH=$TOOLCHAIN_HOME/bin:$PATH

export CC=arm-linux-gnueabihf-gcc
export CXX=arm-linux-gnueabihf-g++
export CPP='arm-linux-gnueabihf-gcc -E'
export AS=arm-linux-gnueabihf-as
export AR=arm-linux-gnueabihf-ar
export LD=arm-linux-gnueabihf-ld
export NM=arm-linux-gnueabihf-nm
export STRIP=arm-linux-gnueabihf-strip
export RANLIB=arm-linux-gnueabihf-ranlib
export LDSHARED='arm-linux-gnueabihf-gcc -shared -Wl,-soname,libz.so.1,--version-script,zlib.map'

WORK=`pwd`
mkdir -p `pwd`/foo && export FOO=`pwd`/foo
PARALLEL_MAKE="-j $(grep ^processor /proc/cpuinfo | wc -l)"

##############################
# /usr/bin/pkg-config
export PKG_CONFIG_PATH=${TOOLCHAIN_HOME}/arm-linux-gnueabihf/libc/usr/lib/pkgconfig
export PKG_CONFIG_LIBDIR=${TOOLCHAIN_HOME}/arm-linux-gnueabihf/libc/usr/lib/pkgconfig
export SYSROOT=${TOOLCHAIN_HOME}/arm-linux-gnueabihf/libc
export PREFIX=${SYSROOT}/usr

##############################
function build_zlib() {
	cd $WORK
	[ ! -e zlib-1.2.8.tar.gz ] && wget https://www.zlib.net/fossils/zlib-1.2.8.tar.gz -O zlib-1.2.8.tar.gz
	[ ! -d zlib-1.2.8 ] && tar zxvf zlib-1.2.8.tar.gz
	cd zlib-1.2.8
	unset DESTDIR
	if [ 0 -eq $# ]; then
		./configure --prefix=${SYSROOT}/usr
		make ${PARALLEL_MAKE}
		make uninstall || true
		make install
		cd -
		return 0;
	fi
	./configure --prefix=/usr
	make ${PARALLEL_MAKE}
	DESTDIR="$1" make uninstall || true
	DESTDIR="$1" make install
	cd -
	return 0;
}
function build_libffi() {
	cd $WORK
	[ ! -e libffi-3.0.13.tar.gz ] && wget ftp://sourceware.org/pub/libffi/libffi-3.0.13.tar.gz -O libffi-3.0.13.tar.gz
	[ ! -d libffi-3.0.13 ] && tar zxvf libffi-3.0.13.tar.gz
	cd libffi-3.0.13
	unset DESTDIR
	if [ 0 -eq $# ]; then
		./configure --host=arm-linux-gnueabihf --prefix=${SYSROOT}/usr --with-sysroot=${SYSROOT} --enable-shared=yes --enable-maintainer-mode=no --enable-debug=no
		make -j8
		make uninstall || true
		make install
		cd -
		return 0;
	fi
	./configure --host=arm-linux-gnueabihf --prefix=/usr --with-sysroot=${SYSROOT} --enable-shared=yes --enable-maintainer-mode=no --enable-debug=no
	make -j8
	DESTDIR="$1" make uninstall || true
	DESTDIR="$1" make install
	cd -
	return 0;
}
function build_glib() {
	cd $WORK
	[ ! -e glib-2.40.2.tar.xz ] && wget https://download.gnome.org/sources/glib/2.40/glib-2.40.2.tar.xz -O glib-2.40.2.tar.xz
	[ ! -d glib-2.40.2 ] && tar Jxvf glib-2.40.2.tar.xz
	cd glib-2.40.2
	unset DESTDIR
	if [ 0 -eq $# ]; then
		glib_cv_stack_grows=no glib_cv_uscore=yes ac_cv_func_posix_getpwuid_r=yes ac_cv_func_posix_getgrgid_r=yes \
		./configure --host=arm-linux-gnueabihf --prefix=${SYSROOT}/usr --with-sysroot=${SYSROOT} --enable-shared=yes \
			--enable-debug=no --enable-maintainer-mode=no --with-threads=posix \
			--disable-selinux --disable-fam --with-libiconv=no --disable-gtk-doc-html --disable-compile-warnings --disable-installed-tests
		make -j8
		make uninstall || true
		make install
		cd -
		return 0;
	fi
	glib_cv_stack_grows=no glib_cv_uscore=yes ac_cv_func_posix_getpwuid_r=yes ac_cv_func_posix_getgrgid_r=yes \
	./configure --host=arm-linux-gnueabihf --prefix=/usr --with-sysroot=${SYSROOT} --enable-shared=yes \
	--enable-debug=no --enable-maintainer-mode=no --with-threads=posix \
	--disable-selinux --disable-fam --with-libiconv=no --disable-gtk-doc-html --disable-compile-warnings --disable-installed-tests
	make -j8
	DESTDIR="$1" make uninstall || true
	DESTDIR="$1" make install
	cd -
	return 0;
}
function build_expat() {
	cd $WORK
	[ ! -e expat-2.1.0.tar.gz ] && wget https://src.fedoraproject.org/repo/pkgs/expat/expat-2.1.0.tar.gz/dd7dab7a5fea97d2a6a43f511449b7cd/expat-2.1.0.tar.gz -O expat-2.1.0.tar.gz
	[ ! -d expat-2.1.0 ] && tar zxvf expat-2.1.0.tar.gz
	cd expat-2.1.0
	unset DESTDIR INSTALL_ROOT
	if [ 0 -eq $# ]; then
		./configure --host=arm-linux-gnueabihf --prefix=${SYSROOT}/usr --with-sysroot=${SYSROOT} --enable-shared=yes
		make -j8
		make uninstall || true
		make install
		cd -
		return 0;
	fi
	./configure --host=arm-linux-gnueabihf --prefix=/usr --with-sysroot=${SYSROOT} --enable-shared=yes
	make -j8
	INSTALL_ROOT="$1" make uninstall || true
	INSTALL_ROOT="$1" make install
	cd -
	return 0;
}
function build_dbus() {
	cd $WORK
	[ ! -e dbus-1.9.4.tar.gz ] && wget http://dbus.freedesktop.org/releases/dbus/dbus-1.9.4.tar.gz -O dbus-1.9.4.tar.gz
	[ ! -d dbus-1.9.4 ] && tar zxvf dbus-1.9.4.tar.gz
	cd dbus-1.9.4
	unset DESTDIR
	if [ 0 -eq $# ]; then
		./configure --host=arm-linux-gnueabihf --prefix=${SYSROOT}/usr --with-sysroot=${SYSROOT} --sysconfdir=${SYSROOT}/etc --with-systemdsystemunitdir=${SYSROOT}/etc --enable-shared --disable-Werror --disable-tests \
        		--disable-systemd --disable-selinux --disable-libaudit --with-x=no --disable-x11-autolaunch --enable-inotify --disable-doxygen-docs --disable-xml-docs --enable-maintainer-mode=no
		make -j8
		make uninstall || true
		make install
		cd -
		return 0;
	fi
	./configure --host=arm-linux-gnueabihf --prefix=/usr --sysconfdir=/etc --with-systemdsystemunitdir=/etc --enable-shared --disable-Werror --disable-tests \
        	--disable-systemd --disable-selinux --disable-libaudit --with-x=no --disable-x11-autolaunch --enable-inotify --disable-doxygen-docs --disable-xml-docs --enable-maintainer-mode=no
	make -j8
	DESTDIR="$1" make uninstall || true
	DESTDIR="$1" make install
	cd -
	return 0;
}
function build_libical() {
	cd $WORK
	[ ! -e libical-1.0.tar.gz ] && wget http://downloads.sourceforge.net/freeassociation/libical-1.0.tar.gz -O libical-1.0.tar.gz
	[ ! -d libical-1.0 ] && tar zxvf libical-1.0.tar.gz
	mkdir -p libical-1.0/build
	cd libical-1.0/build
	unset DESTDIR
	if [ 0 -eq $# ]; then
		cmake -DCMAKE_INSTALL_PREFIX=${SYSROOT}/usr ..
		make clean
		make ${PARALLEL_MAKE}
		make install
		cd -
		return 0;
	fi
	cmake -DCMAKE_INSTALL_PREFIX=/usr ..
	make clean
	make ${PARALLEL_MAKE}
	DESTDIR="$1" make install
	cd -
	return 0;
}
function build_ncurses() {
	cd $WORK
	git clone https://github.com/mirror/ncurses.git || true
	cd ncurses
	unset DESTDIR
	if [ 0 -eq $# ]; then
		./configure --host=arm-linux-gnueabihf --prefix=${SYSROOT}/usr --with-sysroot=${SYSROOT} --enable-shared=yes --with-shared --disable-stripping \
			--enable-symlinks --without-xterm-new --without-valgrind --without-develop --enable-exp-win32=no --without-manpages --disable-ext-funcs --enable-warnings=no
		make -j8
		make uninstall || true
		make install
		cd -
		return 0;
	fi
	DESTDIR="$1" ./configure --host=arm-linux-gnueabihf --prefix=/usr --with-sysroot=${SYSROOT} --enable-shared=yes --with-shared --disable-stripping \
		--enable-symlinks --without-xterm-new --without-valgrind --without-develop --enable-exp-win32=no --without-manpages --disable-ext-funcs --enable-warnings=no
	make -j8
	make uninstall || true
	make install
	cd -
	return 0;
}
function build_readline() {
	cd $WORK
	git clone https://git.savannah.gnu.org/git/readline.git || true
	cd readline
	unset DESTDIR
	if [ 0 -eq $# ]; then
		bash_cv_wcwidth_broken=yes ./configure --host=arm-linux-gnueabihf --prefix=${SYSROOT}/usr --with-sysroot=${SYSROOT} --enable-shared=yes --disable-install-examples
		make -j8
		make uninstall || true
		make install
		cd -
		return 0;
	fi
	bash_cv_wcwidth_broken=yes ./configure --host=arm-linux-gnueabihf --prefix=${FOO}/usr --with-sysroot=${SYSROOT} --enable-shared=yes --disable-install-examples
	make SHLIB_LIBS=-lncurses -j8
	make uninstall || true
	make install
	cd -
	return 0;
}
function build_bluez() {
	cd $WORK
	[ ! -e bluez-5.25.tar.xz ] && wget http://www.kernel.org/pub/linux/bluetooth/bluez-5.25.tar.xz -O bluez-5.25.tar.xz
	[ ! -d bluez-5.25 ] && tar Jxvf bluez-5.25.tar.xz
	cd bluez-5.25
	unset DESTDIR
	if [ 0 -eq $# ]; then
		./configure --host=arm-linux-gnueabihf --prefix=${SYSROOT}/usr --with-sysroot=${SYSROOT} --enable-shared=yes \
			--disable-systemd --disable-udev --disable-cups --disable-obex --enable-library --enable-threads --enable-android=no
		make -j8
		make uninstall || true
		make install
		cd -
		return 0;
	fi
	./configure --host=arm-linux-gnueabihf --prefix=/usr --with-sysroot=${SYSROOT} --enable-shared=yes \
		--disable-systemd --disable-udev --disable-cups --disable-obex --enable-library --enable-threads --enable-android=no
	make -j8
	DESTDIR="$1" make uninstall || true
	DESTDIR="$1" make install
	cd -
	return 0;
}

##############################
build_zlib
build_libffi
build_glib
build_expat
build_dbus
build_libical
build_ncurses
build_readline
build_bluez

build_zlib "${FOO}"
build_libffi "${FOO}"
build_glib "${FOO}"
build_expat "${FOO}"
build_dbus "${FOO}"
build_libical "${FOO}"
build_ncurses "${FOO}"
build_readline "${FOO}"
build_bluez "${FOO}"

exit 0

