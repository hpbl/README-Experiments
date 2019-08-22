# RetDec

[![Travis CI build status](https://travis-ci.org/avast/retdec.svg?branch=master)](https://travis-ci.org/avast/retdec)
[![AppVeyor build status](https://ci.appveyor.com/api/projects/status/daqstq396hb8ixjg/branch/master?svg=true
)](https://ci.appveyor.com/project/avast/retdec?branch=master)
[![TeamCity build status](https://retdec-tc.avast.com/app/rest/builds/aggregated/strob:(buildType:(project:(id:Retdec)))/statusIcon)](https://retdec-tc.avast.com/project.html?projectId=Retdec&guest=1)

[RetDec](https://retdec.com/) is a retargetable machine-code decompiler based on [LLVM](https://llvm.org/).

The decompiler is not limited to any particular target architecture, operating system, or executable file format:
* Supported file formats: ELF, PE, Mach-O, COFF, AR (archive), Intel HEX, and raw machine code
* Supported architectures:
    * 32-bit: Intel x86, ARM, MIPS, PIC32, and PowerPC
    * 64-bit: x86-64, ARM64 (AArch64)

Features:
* Static analysis of executable files with detailed information.
* Compiler and packer detection.
* Loading and instruction decoding.
* Signature-based removal of statically linked library code.
* Extraction and utilization of debugging information (DWARF, PDB).
* Reconstruction of instruction idioms.
* Detection and reconstruction of C++ class hierarchies (RTTI, vtables).
* Demangling of symbols from C++ binaries (GCC, MSVC, Borland).
* Reconstruction of functions, types, and high-level constructs.
* Integrated disassembler.
* Output in two high-level languages: C and a Python-like language.
* Generation of call graphs, control-flow graphs, and various statistics.

For more information, check out our
* [Wiki](https://github.com/avast/retdec/wiki) (in progress)
* Botconf 2017 talk: [slides](https://retdec.com/static/publications/retdec-slides-botconf-2017.pdf), [video](https://www.youtube.com/watch?v=HHFvtt5b6yY)
* REcon Montreal 2018 talk: [slides](https://retdec.com/static/publications/retdec-slides-recon-2018.pdf)
* [Publications](https://retdec.com/publications/)

## Installation and Use

Currently, we support Windows (7 or later), Linux, macOS, and (experimentally) FreeBSD. An installed version of RetDec requires approximately 4 GB of free disk space.

### Windows

1. Either download and unpack a [pre-built package](https://github.com/avast/retdec/releases), or build and install the decompiler by yourself (the process is described below).

2. Install [Microsoft Visual C++ Redistributable for Visual Studio 2015](https://www.microsoft.com/en-us/download/details.aspx?id=48145).

3. Install the following programs:

    * [Python](https://www.python.org/) (version >= 3.4)
    * [UPX](https://upx.github.io/) (Optional: if you want to use UPX unpacker in the preprocessing stage)
    * [Graphviz](https://graphviz.gitlab.io/_pages/Download/windows/graphviz-2.38.msi) (Optional: if you want to generate call or control flow graphs)

4. Now, you are all set to run the decompiler. To decompile a binary file named `test.exe`, run the following command (ensure that `python` runs Python 3; as an alternative, you can try `py -3`)

    ```
    python $RETDEC_INSTALL_DIR/bin/retdec-decompiler.py test.exe
    ```

   For more information, run `retdec-decompiler.py` with `--help`.

### Linux

1. Either download and unpack a [pre-built package](https://github.com/avast/retdec/releases), or build and install the decompiler by yourself (the process is described below).

2. After you have built the decompiler, you will need to install the following packages via your distribution's package manager:

    * [Python](https://www.python.org/) (version >= 3.4)
    * [UPX](https://upx.github.io/) (Optional: if you want to use UPX unpacker in the preprocessing stage)
    * [Graphviz](http://www.graphviz.org/) (Optional: if you want to generate call or control flow graphs)

3. Now, you are all set to run the decompiler. To decompile a binary file named `test.exe`, run

    ```
    $RETDEC_INSTALL_DIR/bin/retdec-decompiler.py test.exe
    ```

   For more information, run `retdec-decompiler.py` with `--help`.

### macOS

1. Either download and unpack a [pre-built package](https://github.com/avast/retdec/releases), or build and install the decompiler by yourself (the process is described below).

2. After you have built the decompiler, you will need to install the following packages:

    * [Python](https://www.python.org/) (version >= 3.4)
    * [UPX](https://upx.github.io/) (Optional: if you want to use UPX unpacker in the preprocessing stage)
    * [Graphviz](http://www.graphviz.org/) (Optional: if you want to generate call or control flow graphs)

3. Now, you are all set to run the decompiler. To decompile a binary file named `test.exe`, run

    ```
    $RETDEC_INSTALL_DIR/bin/retdec-decompiler.py test.exe
    ```

   For more information, run `retdec-decompiler.py` with `--help`.

### FreeBSD (Experimental)

1. There are currently no pre-built "ports" packages for FreeBSD. You will have to build and install the decompiler by yourself. The process is described below.

2. After you have built the decompiler, you may need to install the following packages and execute the following command:

    ```
    sudo pkg install python37
    sudo ln -s /usr/local/bin/python3.7 /usr/local/bin/python3
    ```

3. Now, you are all set to run the decompiler. To decompile a binary file named `test.exe`, run

    ```
    $RETDEC_INSTALL_DIR/bin/retdec-decompiler.py test.exe
    ```

   For more information, run `retdec-decompiler.py` with `--help`.

## Build and Installation

This section describes a local build and installation of RetDec. Instructions for Docker are given in the next section.

### Requirements

#### Linux

* A C++ compiler and standard C++ library supporting C++14 (e.g. GCC >= 5)
* [CMake](https://cmake.org/) (version >= 3.6)
* [Git](https://git-scm.com/)
* [Perl](https://www.perl.org/)
* [Python](https://www.python.org/) (version >= 3.4)
* [Bison](https://www.gnu.org/software/bison/) (version >= 3.0)
* [Flex](https://www.gnu.org/software/flex/) (version >= 2.6)
* [autotools](https://en.wikipedia.org/wiki/GNU_Build_System) ([autoconf](https://www.gnu.org/software/autoconf/autoconf.html), [automake](https://www.gnu.org/software/automake/), and [libtool](https://www.gnu.org/software/libtool/))
* [pkg-config](https://www.freedesktop.org/wiki/Software/pkg-config/)
* [m4](https://www.gnu.org/software/m4/m4.html)
* [zlib](http://zlib.net/)
* Optional: [Doxygen](http://www.stack.nl/~dimitri/doxygen/) and [Graphviz](http://www.graphviz.org/) for generating API documentation

On Debian-based distributions (e.g. Ubuntu), the required packages can be installed with `apt-get`:

```sh
sudo apt-get install build-essential cmake git perl python3 bison flex libfl-dev autoconf automake libtool pkg-config m4 zlib1g-dev upx doxygen graphviz
```

On RPM-based distributions (e.g. Fedora), the required packages can be installed with `dnf`:

```sh
sudo dnf install gcc gcc-c++ cmake make git perl python3 bison flex autoconf automake libtool pkg-config m4 zlib-devel upx doxygen graphviz
```

On Arch Linux, the required packages can be installed with `pacman`:

```sh
sudo pacman --needed -S base-devel cmake git perl python3 bison flex autoconf automake libtool pkg-config m4 zlib upx doxygen graphviz
```

#### Windows

* Microsoft Visual C++ (version >= Visual Studio 2015 Update 2)
* [CMake](https://cmake.org/) (version >= 3.6)
* [Git](https://git-scm.com/)
* [Flex + Bison](https://sourceforge.net/projects/winflexbison/files/win_flex_bison3-latest.zip/download) ([mirror](https://github.com/avast/retdec-support/releases/download/2018-07-27/win_flex_bison3-latest.zip)) from the [Win flex-bison project](https://sourceforge.net/projects/winflexbison/). Add the extracted directory to the system `Path` ([HOWTO](https://www.computerhope.com/issues/ch000549.htm)).
* [Active Perl](https://www.activestate.com/activeperl). It needs to be the first Perl in `PATH`, or it has to be provided to CMake using `CMAKE_PROGRAM_PATH` variable, e.g. `-DCMAKE_PROGRAM_PATH=/c/perl/bin`. Does NOT work with Strawberry Perl or MSYS2 Perl (you would have to install a pre-built version of OpenSSL, see below).
  * Alternatively, you can install OpenSSL directly from [here](https://slproweb.com/products/Win32OpenSSL.html). This means OpenSSL won't be built and you don't need to install any Perl. Do not install Light version of OpenSSL as they don't contain development files.
* [Python](https://www.python.org/) (version >= 3.4)
* Optional: [Doxygen](http://ftp.stack.nl/pub/users/dimitri/doxygen-1.8.13-setup.exe) and [Graphviz](https://graphviz.gitlab.io/_pages/Download/windows/graphviz-2.38.msi) for generating API documentation

#### macOS

Packages should be preferably installed via [Homebrew](https://brew.sh).

* Full Xcode installation ([including command-line tools](https://github.com/frida/frida/issues/338#issuecomment-426777849), see [#425](https://github.com/avast/retdec/issues/425) and [#433](https://github.com/avast/retdec/issues/433))
* [CMake](https://cmake.org/) (version >= 3.6)
* [Git](https://git-scm.com/)
* [Perl](https://www.perl.org/)
* [Python](https://www.python.org/) (version >= 3.4)
* [Bison](https://www.gnu.org/software/bison/) (version >= 3.0)
* [Flex](https://www.gnu.org/software/flex/) (version >= 2.6)
* [autotools](https://en.wikipedia.org/wiki/GNU_Build_System) ([autoconf](https://www.gnu.org/software/autoconf/autoconf.html), [automake](https://www.gnu.org/software/automake/), and [libtool](https://www.gnu.org/software/libtool/))
* Optional: [Doxygen](http://www.stack.nl/~dimitri/doxygen/) and [Graphviz](http://www.graphviz.org/) for generating API documentation

#### FreeBSD (Experimental)

Packages should be installed via FreeBSDs pre-compiled package repository using the `pkg` command or built from scratch using the `ports` database method.

* Full "pkg" tool instructions: [handbook pkg method](https://www.freebsd.org/doc/handbook/pkgng-intro.html)
  * `pkg install cmake python37 bison git autotools`
OR
* Full "ports" instructions: [handbook ports method](https://www.freebsd.org/doc/handbook/ports-using.html)
  * `portsnap fetch`
  * `portsnap extract`
* For example, `cmake` would be
  * `whereis cmake`
  * `cd /usr/ports/devel/cmake`
  * `make install clean`

### Process

Note: Although RetDec now supports a system-wide installation ([#94](https://github.com/avast/retdec/issues/94)), unless you use your distribution's package manager to install it, we recommend installing RetDec locally into a designated directory. The reason for this is that uninstallation will be easier as you will only need to remove a single directory. To perform a local installation, run `cmake` with the `-DCMAKE_INSTALL_PREFIX=<path>` parameter, where `<path>` is directory into which RetDec will be installed (e.g. `$HOME/projects/retdec-install` on Linux and macOS, and `C:\projects\retdec-install` on Windows).

* Clone the repository:
  * `git clone https://github.com/avast/retdec`
* Linux:
  * `cd retdec`
  * `mkdir build && cd build`
  * `cmake .. -DCMAKE_INSTALL_PREFIX=<path>`
  * `make -jN` (`N` is the number of processes to use for parallel build, typically number of cores + 1 gives fastest compilation time)
  * `make install`
* Windows:
  * Open a command prompt (e.g. `cmd.exe`)
  * `cd retdec`
  * `mkdir build && cd build`
  * `cmake .. -DCMAKE_INSTALL_PREFIX=<path> -G<generator>`
  * `cmake --build . --config Release -- -m`
  * `cmake --build . --config Release --target install`
  * Alternatively, you can open `retdec.sln` generated by `cmake` in Visual Studio IDE
* macOS:
  * `cd retdec`
  * `mkdir build && cd build`
  * ```sh
    # Apple ships old Flex & Bison, so Homebrew versions should be used.
    export CMAKE_INCLUDE_PATH="/usr/local/opt/flex/include"
    export CMAKE_LIBRARY_PATH="/usr/local/opt/flex/lib;/usr/local/opt/bison/lib"
    export PATH="/usr/local/opt/flex/bin:/usr/local/opt/bison/bin:$PATH"
    ```
  * `cmake .. -DCMAKE_INSTALL_PREFIX=<path>`
  * `make -jN` (`N` is the number of processes to use for parallel build, typically number of cores + 1 gives fastest compilation time)
  * `make install`
* FreeBSD:
  * `sudo pkg install git cmake`
  * `git clone https://github.com/avast/retdec`
  * `cd retdec`
  * `mkdir build && cd build`
  * ```sh
    # FreeBSD (and other BSDs) do need cmake, python3, bison, git, autotools. Flex and perl are pre-installed in the OS but check versions.
    # Later versions may be available for each of the packages.
    # See what is installed:
    sudo pkg info cmake python37 bison autotools
    # Install/upgrade them:
    sudo pkg install cmake python37 bison autotools
    ```
  * `cmake .. -DCMAKE_INSTALL_PREFIX=<path>`
  * `make -jN` (`N` is the number of processes to use for parallel build, typically number of cores + 1 gives fastest compilation time)
  * `make install`

You have to pass the following parameters to `cmake`:
* `-DCMAKE_INSTALL_PREFIX=<path>` to set the installation path to `<path>`. Quote the path if you are using backslashes on Windows (e.g. `-DCMAKE_INSTALL_PREFIX="C:\retdec"`).
* (Windows only) `-G<generator>` is `-G"Visual Studio 14 2015"` for 32-bit build using Visual Studio 2015, or `-G"Visual Studio 14 2015 Win64"` for 64-bit build using Visual Studio 2015. Later versions of Visual Studio may be used.

You can pass the following additional parameters to `cmake`:
* `-DRETDEC_DOC=ON` to build with API documentation (requires Doxygen and Graphviz, disabled by default).
* `-DRETDEC_TESTS=ON` to build with tests (disabled by default).
* `-DRETDEC_DEV_TOOLS=ON` to build with development tools (disabled by default).
* `-DRETDEC_FORCE_OPENSSL_BUILD=ON` to force OpenSSL build even if it is installed in the system (disabled by default).
* `-DRETDEC_COMPILE_YARA=OFF` to disable YARA rules compilation at installation step (enabled by default).
* `-DCMAKE_BUILD_TYPE=Debug` to build with debugging information, which is useful during development. By default, the project is built in the `Release` mode. This has no effect on Windows, but the same thing can be achieved by running `cmake --build .` with the `--config Debug` parameter.
* `-DCMAKE_PROGRAM_PATH=<path>` to use Perl at `<path>` (probably useful only on Windows).
* `-D<dep>_LOCAL_DIR=<path>` where `<dep>` is from `{CAPSTONE, ELFIO, GOOGLETEST, JSONCPP, KEYSTONE, LIBDWARF, LLVM, PELIB, RAPIDJSON, TINYXML, YARACPP, YARAMOD}` (e.g. `-DCAPSTONE_LOCAL_DIR=<path>`), to use the local repository clone at `<path>` for RetDec dependency instead of downloading a fresh copy at build time. Multiple such options may be used at the same time.

## Build in Docker

Docker support is maintained by community. If something does not work for you or if you have suggestions for improvements, open an issue or PR.

### Build Image

Building in Docker does not require installation of the required libraries locally. This is a good option for trying out RetDec without setting up the whole build toolchain.

To build the RetDec Docker image, run
```
docker build -t retdec - < Dockerfile
```

This builds the image from the master branch of this repository.

To build the image using the local copy of the repository, use the development Dockerfile, `Dockerfile.dev`:
```
docker build -t retdec:dev . -f Dockerfile.dev
```

### Run Container

If your `uid` is not 1000, make sure that the directory containing your input binary files is accessible for RetDec:
```
chmod 0777 /path/to/local/directory
```
Now, you can run the decompiler inside a container:
```
docker run --rm -v /path/to/local/directory:/destination retdec retdec-decompiler.py /destination/binary
```
Note: Do not modify the `/destination` part is. You only need to change `/path/to/local/directory`. Output files will then be generated to `/path/to/local/directory`.

## Automated TeamCity Builds

Our TeamCity servers are continuously generating up-to-date RetDec packages from the latest commit in the `master` branch. These are mostly meant to be used by RetDec developers, contributors, and other people experimenting with the product (e.g. testing if an issue present in the official release still exists in the current `master`).

You can use these as you wish, but keep in mind that there are no guarantees they will work on your system (especially the Linux version), and that regressions are a possibility. To get a stable RetDec version, either download the latest official pre-built package or build the latest RetDec version tag.

* [Windows Server 2016, version 10.0](https://retdec-tc.avast.com/repository/download/Retdec_WinBuild/.lastSuccessful/package/retdec-master-windows-64b.zip?guest=1)
* [CentOS Linux, version 3.10.0-693.21.1.el7.x86_64](https://retdec-tc.avast.com/repository/download/RetDec_LinuxBuild/.lastSuccessful/package/retdec-master-linux-64b.zip?guest=1)
* [Mac OS X, version 10.13.4](https://retdec-tc.avast.com/repository/download/Retdec_MacBuild/.lastSuccessful/package/retdec-master-macos-64b.zip?guest=1)

## Repository Overview

This repository contains the following libraries:
* `ar-extractor` - library for extracting object files from archives (based on LLVM).
* `bin2llvmir` - library of LLVM passes for translating binaries into LLVM IR modules.
* `capstone2llvmir` - binary instructions to LLVM IR translation library.
* `config` - library for representing and managing RetDec configuration databases.
* `cpdetect` - library for compiler and packer detection in binaries.
* `crypto` - collection of cryptographic functions.
* `ctypes` - C++ library for representing C function data types.
* `debugformat` - library for uniform representation of DWARF and PDB debugging information.
* `demangler` - demangling library capable to handle names generated by the GCC/Clang, Microsoft Visual C++, and Borland C++ compilers.
* `dwarfparser` - library for high-level representation of DWARF debugging information.
* `fileformat` - library for parsing and uniform representation of various object file formats. Currently supporting the following formats: COFF, ELF, Intel HEX, Mach-O, PE, raw data.
* `llvm-support` - set of LLVM related utility functions.
* `llvmir-emul` - LLVM IR emulation library used for unit testing.
* `llvmir2hll` - library for translating LLVM IR modules to high-level source codes (C, Python-like language).
* `loader` - library for uniform representation of binaries loaded to memory. Supports the same formats as fileformat.
* `macho-extractor` - library for extracting regular Mach-O binaries from fat Mach-O binaries (based on LLVM).
* `patterngen` - binary pattern extractor library.
* `pdbparser` - Microsoft PDB files parser library.
* `stacofin` - static code finder library.
* `unpacker` - collection of unpacking functions.
* `utils` - general C++ utility library.

This repository contains the following tools:
* `ar-extractortool` - frontend for the ar-extractor library (installed as `retdec-ar-extractor`).
* `bin2llvmirtool` - frontend for the `bin2llvmir` library (installed as `retdec-bin2llvmir`).
* `bin2pat` - tool for generating patterns from binaries (installed as `retdec-bin2pat`).
* `capstone2llvmirtool` - frontend for the `capstone2llvmir` library (installed as `retdec-capstone2llvmir`).
* `configtool` - frontend for the `config` library (installed as `retdec-config`).
* `ctypesparser` - C++ library for parsing C function data types from JSON files into `ctypes` representation (installed as `retdec-ctypesparser`).
* `demangler_grammar_gen` -- tool for generating new grammars for the `demangler` library (installed as `retdec-demangler-grammar-gen`).
* `demanglertool` -- frontend for the `demangler` library (installed as `retdec-demangler`).
* `fileinfo` - binary analysis tool. Supports the same formats as `fileformat` (installed as `retdec-fileinfo`).
* `idr2pat` - tool for extracting patterns from IDR knowledge bases (installed as `retdec-idr2pat`).
* `llvmir2hlltool` - frontend for the `llvmir2hll` library (installed as `retdec-llvmir2hll`).
* `macho-extractortool` - frontend for the `macho-extractor` library (installed as `retdec-macho-extractor`).
* `pat2yara` - tool for processing patterns to YARA signatures (installed as `retdec-pat2yara`).
* `stacofintool` - frontend for the `stacofin` library (installed as `retdec-stacofin`).
* `unpackertool` - plugin-based unpacker (installed as `retdec-unpacker`).

This repository contains the following scripts:
* `retdec-decompiler.py` - the main decompilation script binding it all together. This is the tool to use for full binary-to-C decompilations.
* Support scripts used by `retdec-decompiler.py`:
  * `retdec-color-c.py` - decorates output C sources with IDA color tags - syntax highlighting for IDA.
  * `retdec-config.py` - decompiler's configuration file.
  * `retdec-archive-decompiler.py` - decompiles objects in the given AR archive.
  * `retdec-fileinfo.py` - a Fileinfo tool wrapper.
  * `retdec-signature-from-library-creator.py` - extracts function signatures from the given library.
  * `retdec-unpacker.py` - tries to unpack the given executable file by using any of the supported unpackers.
  * `retdec-utils.py` - a collection of Python utilities.
* `retdec-tests-runner.py` - run all tests in the unit test directory.
* `type_extractor` - generation of type information (for internal use only)

## Project Documentation

See the [project documentation](https://retdec-tc.avast.com/repository/download/Retdec_DoxygenBuild/.lastSuccessful/build/doc/doxygen/html/index.html?guest=1) for an up to date Doxygen-generated software reference corresponding to the latest commit in the `master` branch.

## Related Repositories

* [retdec-idaplugin](https://github.com/avast/retdec-idaplugin) -- Embeds RetDec into IDA (Interactive Disassembler) and makes its use much easier.
* [retdec-regression-tests-framework](https://github.com/avast/retdec-regression-tests-framework) -- A framework for writing and running regression tests for RetDec and related tools. This is a must if you plan to contribute to the RetDec project.
* [retdec-regression-tests](https://github.com/avast/retdec-regression-tests) -- A suite of regression tests for RetDec and related tools.
* [vim-syntax-retdecdsm](https://github.com/s3rvac/vim-syntax-retdecdsm) -- Vim syntax-highlighting file for the output from the RetDec's disassembler (`.dsm` files).

## License

Copyright (c) 2017 Avast Software, licensed under the MIT license. See the [`LICENSE`](https://github.com/avast/retdec/blob/master/LICENSE) file for more details.

RetDec uses third-party libraries or other resources listed, along with their licenses, in the [`LICENSE-THIRD-PARTY`](https://github.com/avast/retdec/blob/master/LICENSE-THIRD-PARTY) file.

## Contributing

See [RetDec contribution guidelines](https://github.com/avast/retdec/wiki/Contribution-Guidelines).

## Acknowledgements

This software was supported by the research funding TACR (Technology Agency of the Czech Republic), ALFA Programme No. TA01010667.
