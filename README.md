# Cross-compile Bluez5

A bash shell script is provded for the prebuilt toolchain of `gcc-sigmastar-9.1.0-2019.11-x86_64_arm-linux-gnueabihf` cross-compiling `Bluez5` project . 

### Bluez5 dependencies

zlib

```bash
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
```
