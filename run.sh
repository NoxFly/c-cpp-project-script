#!/bin/bash

# Author : NoxFly
# Copyrights 2021-2022

# PUBLIC
# --------------------------------------
# YOU CAN CHANGE THESE CONFIG VARIABLES

# project folder's name is the default application's name
pgname=${PWD##*/}

# adapt these pathes for your project
# don't forget to do execute 'updateMakefile' after any modification.
# If you don't do it, it's not dangerous, because the script will always
# pass these variables as arguments to the makefile.
# But if you pass to the makefile directly, it'll not be updated.
srcDir="./src"
incDir="./include" # availible only on projectMode = 0
outDir="./bin"
buildDir="./build"
cppVersion=17 # 98, 03, 11, 17, 20, 23
cVersion=17 # 89, 99, 11, 17
# --------------------------------------

# PRIVATE
# --------------------------------------
# DO NOT CHANGE THESE CONFIG VARIABLES
# > PASS THROUGH THE COMMAND

version=0.0.9

srcFileExt="cpp"
hdrFileExt="hpp"
guard="ifndef" # ifndef | pragma

# PROJECT MODE :
# 0: src/ClassName.cpp include/ClassName.hpp
# 1: src/ClassDir/ClassName.cpp src/ClassDir/ClassName.hpp
projectMode=0

# if any mode is precised, then release is the default one
mode="debug"
# makefile rule, depending on the mode
rule="build"

ext=""
os="linux"

#
updateUrl="https://raw.githubusercontent.com/NoxFly/c-cpp-project-script/main/run.sh"

# declare -a optionsList
helpMessage="
C/C++ run script v$version
Usage : $(basename -- $0) [OPTION]
        $(basename -- $0) -g to generate project's structure.
        $(basename -- $0) [--dev|-d|-r] to compile and run the program in [dev(default)|debug|release] mode.
All added options not handled by the script will be executable's options.

\033[1;21mOPTIONS:\033[0m\n
[]: mandatory parameter
(): optional parameter

--help              -h                  Show the command's version and its basic usage.
--version           -V                  Show the command's version.
--patch                                 Download latest online version.

--generate          -g                  Generates project's structure with a main file. Re-create missing folders.
--update-makefile                       Updates some Makefile's variables, like file extensions and c/c++ versions.

--swap-mode                             Swap between the two structure modes. Reorganize files.
--set-language      -l [c|cpp]          Set the current used language for further file creation (0=c, 1=cpp).
                    -c [ClassName]      Create class files (header and source) with basic constructor and destructor.
--set-guard         [ifndef|pragma]     Defines either it has to be #ifndef FILENAME_H or #pragma once on header
                                        file creation.
--set-name          [projectName]       Set the project executable's name.

--dev                                   Compile code and run it in dev mode. It's debug mode with modified options.
--debug             -d                  Compile code and run it in debug mode.
--release           -r                  Compile code and run it in release mode. If no mode precised, this is the
                                        default one.

--force             -f                  Make clean before compiling again.
--verbose           -v                  Add this option to have details of current process.
--no-run                                Only builds the project.
--static                                Build the project as static library.
--shared                                Build the project as shared library.

Note : the libs/ folder is only for Window's libraries. On Linux it will find on the \$path.
Also, you can need to put .dll on the $binDir folder.
The script will adapt depending on which OS you're building and running the project.
It means that you can develop, build and run on Linux and Windows the same project."


makefileCode="IyBNT0RJRklBQkxFCkNGTEFHUyAJCTo9IC1XZXJyb3IgLVdhbGwgLVdleHRyYQpMREZMQUdTCQk6PQpMSUJTIAkJOj0gCgojIE5PVCBN
T0RJRklBQkxFCiMgYWxsIHdoYXQncyBiZWxvdyBtdXN0IG5vdCBiZSBtb2RpZmllZAojIHRoZSBydW4uc2ggaXMgcGFzc2luZyBhbGwgdGhlIG5lZWRlZC
Bhcmd1bWVudHMKIyB5b3UgaGF2ZSB0byBkbyB0aGUgY29uZmlndXJhdGlvbiB0aHJvdWdoIHRoZSBydW4uc2gKCiMgdHlwZSBvZiBzb3VyY2UgZmlsZXMK
IyBjIG9yIGNwcCAobWFrZSBzdXJlIHRvIG5vdCBoYXZlIHNwYWNlIGFmdGVyKQpTUkNFWFQJCT89IGNwcApIRFJFWFQJCT89IGhwcApDVkVSU0lPTgk/PS
AxNwpDUFBWRVJTSU9OCT89IDE3CgpMSUJfU1RBVElDX0VYVCA6PSAuYQpMSUJfU0hBUkVEX0VYVCA6PSAuc28KTElCX1NIQVJFRF9XSU5fRVhUIDo9IC5k
bGwKCkxJQl9TVEFUSUNfQ0ZMQUdTIDo9IApMSUJfU0hBUkVEX0NGTEFHUyA6PSAtZlBJQwoKTElCX1NUQVRJQ19MREZMQUdTIDo9IHIKTElCX1NIQVJFRF
9MREZMQUdTIDo9IC1zaGFyZWQgLWZQSUMgLW8KCiMgcHJvZ3JhbSBsb2NhdGlvbgpPVVQJCQk/PSAuL2JpbgpPVVRMSUIJCTo9ICQoT1VUKS9saWIKRVhU
CQkJOj0KCgpVU1JfSU5DRElSIDo9IC91c3IvbG9jYWwvaW5jbHVkZQpVU1JfTElCRElSIDo9IC91c3IvbG9jYWwvbGliCgojIGRldGVjdCBpZiBjb21waW
xlciBpcyBnY2MgaW5zdGVhZCBvZiBjbGFuZy4gTm90IHZpZXdpbmcgZm9yIG90aGVyIGNvbXBpbGVyCiMgQwppZmVxICgkKFNSQ0VYVCksIGMpCglpZmVx
ICgkKENDKSwgZ2NjKQoJCUNDIDo9IGdjYwoJCUxEQ0MgOj0gZ2NjCgllbHNlCgkJQ0MgOj0gY2xhbmcKCQlMRENDIDo9IGNsYW5nCgllbmRpZiAjIEMgOi
BjbGFuZyBvciBnY2MKCUNGTEFHUyArPSAtc3RkPWMkKENWRVJTSU9OKQojIEMrKwplbHNlCglpZmVxICgkKENYWCksIGcrKykKCQlDQyA6PSBnKysKCQlM
RENDIDo9IGcrKwoJZWxzZQoJCUNDIDo9IGNsYW5nKysKCQlMRENDIDo9IGNsYW5nKysKCWVuZGlmICMgQysrIDogY2xhbmcrKyBvciBnKysKCUNGTEFHUy
ArPSAtc3RkPWMrKyQoQ1BQVkVSU0lPTikKZW5kaWYKCiMgZXhlY3V0YWJsZSBuYW1lCmlmZGVmIFBHTkFNRQoJRVhFQ1VUQUJMRSA6PSAkKFBHTkFNRSkK
ZWxzZQoJRVhFQ1VUQUJMRSAJOj0gcHJvZ3JhbQplbmRpZiAjIHBnbmFtZQoKIyBjb21waWxhdGlvbiBtb2RlCmlmZGVmIExJQgpUQVJHRVRESVIgOj0gJC
hPVVRMSUIpCkVYRUNVVEFCTEUgOj0gbGliJChFWEVDVVRBQkxFKQoKIyBzaGFyZWQKCWlmZXEgKCQoTElCKSwgU0hBUkVEKQoJCUVYVCA9ICQoTElCX1NI
QVJFRF9FWFQpCgkJQ0ZMQUdTICs9ICQoTElCX1NIQVJFRF9DRkxBR1MpCgkJTERGTEFHUyA9ICQoTElCX1NIQVJFRF9MREZMQUdTKQoKCQlpZmVxICgkKE
9TKSwgV0lORE9XUykKCQkJRVhUID0gJChMSUJfU0hBUkVEX1dJTl9FWFQpCgkJZW5kaWYKIyBzdGF0aWMKCWVsc2UgaWZlcSAoJChMSUIpLCBTVEFUSUMp
CgkJRVhUID0gJChMSUJfU1RBVElDX0VYVCkKCQlDRkxBR1MgKz0gJChMSUJfU1RBVElDX0NGTEFHUykKCQlMREZMQUdTID0gJChMSUJfU1RBVElDX0xERk
xBR1MpCgkJTERDQyA6PSAkKEFSKQoJZWxzZQoJCSQoZXJyb3IgaW5jb3JyZWN0IExJQiB2YWx1ZSkKCWVuZGlmCmVsc2UKIyB0YXJnZXRkaXIKCWlmZGVm
IERFQlVHCgkJVEFSR0VURElSID0gJChPVVQpL2RlYnVnCgkJQ0ZMQUdTICs9IC1nCgkJTERGTEFHUyArPSAtbwoJZWxzZQoJCVRBUkdFVERJUiA9ICQoT1
VUKS9yZWxlYXNlCgllbmRpZiAjIGRlYnVnCgojIGV4dGVuc2lvbgoJaWZlcSAoJChPUyksIE1BQ09TKQoJCUVYVCA6PSAuYXBwCgllbHNlIGlmZXEgKCQo
T1MpLCBXSU5ET1dTKQoJCUVYVCA6PSAuZXhlCgllbmRpZgplbmRpZgoKIyBmaW5hbCBmdWxsIGV4ZWN1dGFibGUgbG9jYXRpb24KVEFSR0VUIAkJOj0gJC
hUQVJHRVRESVIpLyQoRVhFQ1VUQUJMRSkkKEVYVCkKIyAubyBsb2NhdGlvbgpCVUlMRERJUgk/PSAuL2J1aWxkCiMgc291cmNlIGZpbGVzIGxvY2F0aW9u
ClNSQ0RJUgkJPz0gLi9zcmMKIyBoZWFkZXIgZmlsZXMgbG9jYXRpb24KSU5DRElSCQk/PSAuL2luY2x1ZGUKClNPVVJDRVMgCTo9ICQoc2hlbGwgZmluZC
AkKFNSQ0RJUikvKiogLXR5cGUgZiAtbmFtZSAqLiQoU1JDRVhUKSkKCklOQ0RJUlMJCTo9CklOQ0xJU1QJCTo9CkJVSUxETElTVAk6PQpJTkMJCQk6PSAt
SSQoSU5DRElSKQoKaWZkZWYgTUFDUk8KCUNGTEFHUwkJKz0gJChNQUNSTykKZW5kaWYKCgppZm5lcSAoLCAkKGZpcnN0d29yZCAkKHdpbGRjYXJkICQoSU
5DRElSKS8qKi8qKSkpCglJTkNESVJTIAk6PSAkKHNoZWxsIGZpbmQgJChJTkNESVIpLyovKiogLXR5cGUgZiAtbmFtZSAnKi4kKEhEUkVYVCknIC1leGVj
IGRpcm5hbWUge30gXDspCglJTkNMSVNUIAk6PSAkKHBhdHN1YnN0ICQoSU5DRElSKS8lLCAtSSQoSU5DRElSKS8lLCAkKElOQ0RJUlMpKQoJQlVJTERMSV
NUIAk6PSAkKHBhdHN1YnN0ICQoSU5DRElSKS8lLCAkKEJVSUxERElSKS8lLCAkKElOQ0RJUlMpKQoJSU5DIAkJKz0gJChJTkNMSVNUKQplbmRpZiAjIGlu
Y2RpcgoKIyBwcm9qZWN0IHNwZWNpZmljCiMgd2luZG93cyBsaWJzIGluY2x1ZGUKaWZlcSAoJChPUyksIFdJTkRPV1MpCglJTkMgKz0gLUkuL2xpYnMvaW
5jbHVkZQoJTERGTEFHUyA6PSAtTC4vbGlicy9saWIgJChMREZMQUdTKQplbmRpZgoKCkxJQlMgOj0gJChwYXRzdWJzdCAlLCAtbCUsICQoTElCUykpCgoK
CmlmZGVmIERFQlVHCk9CSkVDVFMgCTo9ICQocGF0c3Vic3QgJChTUkNESVIpLyUsICQoQlVJTERESVIpLyUsICQoU09VUkNFUzouJChTUkNFWFQpPS5vKS
kKCmJ1aWxkOiAkKE9CSkVDVFMpCglAbWtkaXIgLXAgJChUQVJHRVRESVIpCmlmZXEgKCQoVkVSQk9TRSksIDEpCglAZWNobyAiTGlua2luZyAkKFRBUkdF
VCkuLi4iCmVuZGlmCglAJChMRENDKSAkKExERkxBR1MpICQoVEFSR0VUKSAkXiAkKExJQlMpCgokKEJVSUxERElSKS8lLm86ICQoU1JDRElSKS8lLiQoU1
JDRVhUKQoJQG1rZGlyIC1wICQoQlVJTERESVIpCmlmZGVmIEJVSUxETElTVAoJQG1rZGlyIC1wICQoQlVJTERMSVNUKQplbmRpZgppZmVxICgkKFZFUkJP
U0UpLCAxKQoJQGVjaG8gIkNvbXBpbGluZyAkPC4uLiI7CmVuZGlmCglAJChDQykgJChJTkMpICQoQ0ZMQUdTKSAtYyAtbyAkQCAkPAoKZWxzZSAjIFJFTE
VBU0UKCmJ1aWxkOgoJQG1rZGlyIC1wICQoVEFSR0VURElSKQppZmVxICgkKFZFUkJPU0UpLCAxKQoJQGVjaG8gIkxpbmtpbmcuLi4iCmVuZGlmCglAJChD
QykgJChJTkMpIC1vICQoVEFSR0VUKSAkKFNPVVJDRVMpICQoTElCUykgJChMREZMQUdTKQoKZW5kaWYgI2RlYnVnIC8gcmVsZWFzZSB0YXJnZXRzCgoKIy
BzaGFyZWQKc2hhcmVkOgppZmVxICgkKFZFUkJPU0UpLCAxKQoJQGVjaG8gIkJ1aWxkaW5nIHNoYXJlZCBsaWJyYXJ5Li4uIgplbmRpZgoJQCQoTUFLRSkg
LXMgYnVpbGQgTElCPVNIQVJFRAoKc3RhdGljOgppZmVxICgkKFZFUkJPU0UpLCAxKQoJQGVjaG8gIkJ1aWxkaW5nIHN0YXRpYyBsaWJyYXJ5Li4uIgplbm
RpZgoJQCQoTUFLRSkgLXMgYnVpbGQgTElCPVNUQVRJQwoKaW5zdGFsbDogc2hhcmVkCglAbXYgJChPVVRMSUIpL2luY2x1ZGUvICQoVVNSX0lOQ0RJUikK
CUBtdiAkKE9VVExJQikvbGliJChFWEVDVVRBQkxFKS5zbyAkKFVTUl9MSUJESVIpCgpjbGVhbjoKCUBybSAtZiAtciAkKEJVSUxERElSKS8qKgoJQGVjaG
8gIkFsbCBvYmplY3RzIHJlbW92ZWQiCgouUEhPTlk6IGNsZWFuIGNsZWFyIGJ1aWxkIHNoYXJlZCBzdGF0aWM="

runAfterCompile=1

# --------------------------------------

log()
{
    if [ $verbose -eq 1 -a $# -gt 0 ]; then
        echo -e $1
    fi
}

updateMakefile()
{
    if [[ ! -f './Makefile' ]]; then
        return
    fi

    # update makefile depending on current settings
    sed -i -e "s/^SRCEXT\t*?=\s[a-z]\+/SRCEXT\t\t?= $srcFileExt/" './Makefile' # src ext
    sed -i -e "s/^HDREXT\t*?=\s[a-z]\+/HDREXT\t\t?= $hdrFileExt/" './Makefile' # hdr exxt
    sed -i -e "s/^CVERSION\t*?=\s[0-9]\+/CVERSION\t?= $cVersion/" './Makefile' # c version
    sed -i -e "s/^CPPVERSION\t*?=\s[0-9]\+/CPPVERSION\t?= $cppVersion/" './Makefile' # cpp version
    sed -i -e "s@^OUT\t*?=\s.*@OUT\t\t\t?= $outDir@" './Makefile' # out path
    sed -i -e "s@^BUILDDIR\t*?=\s.*@BUILDDIR\t?= $buildDir@" './Makefile' # build path
    sed -i -e "s@^SRCDIR\t*?=\s.*@SRCDIR\t\t?= $srcDir@" './Makefile' # src path
    sed -i -e "s@^INCDIR\t*?=\s.*@INCDIR\t\t?= $incDir@" './Makefile' # inc path

    echo "Makefile updated."
}

getHelp()
{
    echo -e "$helpMessage"
}

createClass()
{
    if [[ ! $1 =~ ^([a-zA-Z0-9_\-]+/)*[a-zA-Z_][a-zA-Z0-9_]+$ ]]; then
        echo "Error : class name must only contains alphanumeric characters and underscores"
    else
        echo "Creating class $1..."
        
        if [ ! -d $srcDir ]; then
            echo -e "Project's structure not created yet.\nAborting."
            getHelp
            exit 2
        fi

        className=${1##*/}
        path=${1%/*}

        if [ "$className" == "$path" ]; then
            path=''
        else
            path="$path/"
        fi

        if [ $projectMode -eq 0 ]; then
            mkdir -p "$srcDir/$path"
            mkdir -p "$incDir/$path"

            srcPath="$srcDir/$path$className.$srcFileExt"
            incPath="$incDir/$path$className.$hdrFileExt"
        else
            folderPath="$srcDir/$path$className"
            mkdir -p $folderPath

            srcPath="$folderPath/$className.$srcFileExt"
            incPath="$folderPath/$className.$hdrFileExt"
        fi

        if [ -f "$srcPath" ] || [ -f "$incPath" ]; then
            echo "A file with this name already exists."
            echo "Aborting"
        else
            touch $srcPath
            touch $incPath
            getSrcCode $className > $srcPath
            getHeaderCode $className > $incPath
            echo "Done"
        fi
    fi
}

createBaseProject() {
    echo "Creating structure..."
    i=0
    if [ ! -d "$srcDir" ]; then
        mkdir $srcDir
        [ $? -eq 0 ] && log "Created $srcDir folder"
        ((i=i+1))
    fi

    if [ $projectMode -eq 0 ] && [ ! -d "$incDir" ]; then
        mkdir $incDir
        [ $? -eq 0 ] && log "Created $incDir folder"
        ((i=i+1))
    fi

    if [ ! -d "$outDir" ]; then
        mkdir $outDir
        [ $? -eq 0 ] && log "Created $outDir folder"
        ((i=i+1))
    fi

    if [ ! -d "$buildDir" ]; then
        mkdir $buildDir
        [ $? -eq 0 ] && log "Created $buildDir folder"
        ((i=i+1))
    fi

    if [ ! -d "libs/" ]; then
        mkdir './libs'
        [ $? -eq 0 ] && log "Created ./libs folder"
        ((i=i+1))
    fi
    
    if [ ! -f "$srcDir/main.$srcFileExt" ]; then
        touch "$srcDir/main.$srcFileExt"
        getMainCode > "$srcDir/main.$srcFileExt"
        [ $? -eq 0 ] && log "Created main file"
        ((i=i+1))
    fi

    if [ ! -f "Makefile" ]; then
        touch "Makefile"
        echo -e "$makefileCode"  | base64 --decode > "Makefile"
        updateMakefile
        [ $? -eq 0 ] && log "Created Makefile"
        ((i=i+1))
    fi

    [ $i -eq 0 ] && log "No changes made" || echo "Done"
}

getSrcCode()
{
    if [ $srcFileExt == "c" ]; then
        echo -e -n "#include \"$1.$hdrFileExt\"\n\n"
    else
        echo -e -n "#include \"$1.$hdrFileExt\"\n\n$1::$1() {\n\n}\n\n$1::~$1() {\n\n}"
    fi
}

getHeaderCode()
{
    [ $srcFileExt == "c" ] && pp='' || pp='PP'

    if [ $guard == "ifndef" ]; then
        guard_top="#ifndef ${1^^}_H$pp\n#define ${1^^}_H$pp\n\n"
        guard_bottom="\n\n#endif // ${1^^}_H$pp"
    else
        guard_top="#pragma once\n\n"
        guard_bottom=""
    fi

    echo -e -n "$guard_top"

    if [ $srcFileExt == "cpp" ]; then
        echo -e -n "class $1 {\n\tpublic:\n\t\t$1();\n\t\t~$1();\n};"
    fi

    echo -e -n "$guard_bottom"
}

getMainCode() {
    if [ $srcFileExt == "cpp" ]; then
        echo -e -n "#include <iostream>\n\nint main(int argc, char **argv) {\n\t(void)argc;\n\t(void)argv;\n\tstd::cout << \"Hello World\" << std::endl;\n\treturn EXIT_SUCCESS;\n}"
    elif [ $srcFileExt == "c" ]; then
        echo -e -n "#include <stdio.h>\n\nint main(int argc, char **argv) {\n\t(void)argc;\n\t(void)argv;\n\tprintf(\"Hello World \");\n\treturn 0;\n}"
    fi
}


setMode()
{
    [ $1 -eq 0 -o $1 -eq 1 ] && sed -i -e "s/projectMode=[0-9]/projectMode=$1/g" $0 || echo "Unknown mode : $1"
}

setLang()
{
    srcExt=""
    hdrExt=""
    
    case $1 in
        c)
            srcExt="c"
            hdrExt="h";;
        cpp)
            srcExt="cpp"
            hdrExt="hpp";;
        *)
            echo "Unknown language mode."
            return;;
    esac

    sed -i -e 's/srcFileExt="'$srcFileExt'"/srcFileExt="'$srcExt'"/' $0
    sed -i -e 's/hdrFileExt="'$hdrFileExt'"/hdrFileExt="'$hdrExt'"/' $0

    echo "Files extensions set to .$srcExt/.$hdrExt"

    srcFileExt="$srcExt"
    hdrFileExt="$hdrExt"

    updateMakefile
}

setGuard()
{
    if [ $1 == "ifndef" -o $1 == "pragma" ]; then
        sed -i -e 's/guard="'$guard'"/guard="'$1'"/' $0
        echo "Guard changed to $1."
    else
        echo "Unknown guard."
    fi
}

moveRec()
{
    # recursion limit
    if [ $5 -gt 500 ]; then
        echo "Too much recursion. Stop. ($5)"
        return 3
    fi

    # empty folder
    if [ -z "$(ls -A $4)" ]; then
        [ $6 -eq 1 ] && echo -e "\033[0;90m (Empty)\033[0m"
        return 0
	elif [ $6 -eq 1 ]; then
		echo
    fi

    # for each files / subdirs
    for i in "$4"/*; do
        # verbose
        if [ $6 -eq 1 ]; then
            [ -f $i ] && s="\n" || s="/"
            repeat_spaces $(($5))
            echo -e -n "└ $(basename "$i")$s"
        fi
        #

        # file
        if [ -f $i ]; then
            ext=$(echo "$i" | sed 's/^.*\.//')
            # .h
            if [ "$ext" == 'h' -o "$ext" == 'hpp' ]; then
                # filename.ext
                suffix="$(basename "$i")"
                # left trim folders
                subDir=${i/#"$2/"}
                [ $suffix == $subDir ] && newFileDir="$3/" || newFileDir="$3/${subDir/%"/$suffix"}/"

                # make folders + move file
                mkdir -p "$newFileDir"
                mv "$i" "$newFileDir"

                if [ $? -eq 0 ]; then
                    # verbose
                    if [ $6 -eq 1 ]; then
                        repeat_spaces $5
                        echo -e "\033[0;90m   > moved in $newFileDir\033[0m"
                    fi
                else
                    echo -e "\033[0;31mFailed to move $i\033[0m"
                    return 4
                fi
                #
            fi

        # dir
        else
            moveRec $1 $2 $3 $i $(($5 + 1)) $6
        fi
    done

    return 0
}

swapMode()
{
    if [ $1 -eq 1 ]; then
        dir=$incDir
        dest=$srcDir
    else
        dir=$srcDir
        dest=$incDir
        if [ ! -d "$incDir" ]; then
            mkdir $incDir
            if [ $2 -eq 1 ]; then
                if [ $? -eq 0 ]; then
                    echo "Create $incDir/ folder"
                else
                    echo "Failed to swap: cannot create $incDir/ folder"
                    exit 2
                fi
            fi
        fi
    fi
    [ $2 -eq 1 ] && echo -e -n "└ $dir/"
    # moveRec newMode source dest currentHeadersDir stage verbose
    moveRec $1 $dir $dest $dir 1 $2
    res=$?

    if [ $1 -eq 1 -a $res -eq 0 ]; then
        rm -r $incDir
        [ $2 -eq 1 ] && echo "Delete $incDir/ folder"
    fi

    [ $res -eq 0 ] && echo -e "\033[0;32mSuccesfully swapped\033[0m" || echo -e "\033[0;31mFailed to swap\033[0m"
    setMode $1
}

setProjectName()
{
    if [ $# -gt 0 ]; then
        sed -i -e '0,/pgname=.*/s//pgname="'$1'"/' $0

        [ $? -eq 0 ] && echo -e "\033[0;32mDone.\033[0m" || echo -e "\033[0;31mFailed.\033[0m"
    fi
}

updateLibraryInclude()
{
	log "\033[0;90mUpdating shared include folder... "

    baseIncludePath="$outDir/lib/include/$pgname/"

    rsync -avq --delete --prune-empty-dirs --include="*/" --include="*.$hdrFileExt" --include "*.inl" --exclude="*" "$includeDir/" "$baseIncludePath"

    # 1st scan :
    # update file position
    find "$baseIncludePath" -type f |
    while read file; do
        dir="$(dirname "$file")/"
        nFile=$(ls $dir | wc -l)

        while [[ $nFile -eq 1 && "$dir" != "$path" ]]; do
            oldDir="$dir"
            dir="${dir%*/*/}/"
            mv "$file" "$dir"
            rm -r "$oldDir"
            file="${file%/*/*}/${file##*/}"
            nFile=$(ls $dir | wc -l)
        done
    done

    # 2nd scan :
    # update includes path
    find "$baseIncludePath" -type f |
    while read file; do
        cat "$file" | grep -Po '(?<=#include ")(.*\.('$hdrFileExt'|inl))(?=")' |
        while read -r dep; do
            location=$(find "$baseIncludePath" -type f -name "$dep")
            relative=$(realpath --relative-to="$file" "$location")

            search="#include \"$dep\""
            replacement="#include \"${relative#'../'}\""

            sed -i -e "s|$search|$replacement|" "$file"
        done
    done

    log "Done."
}

# $1 = build/static/shared
# $2 = macro
compile()
{
    [[ rule == 'build' ]] &&  macro="-D${mode^^}" || macro=""


    make "$1" ${mode^^}=1 PGNAME=$pgname\
        SRCEXT=$srcFileExt HDREXT=$hdrFileExt\
        SRCDIR=$srcDir INCDIR=$includeDir\
        OUT=$outDir BUILDDIR=$buildDir\
        CVERSION=$cVersion CPPVERSION=$cppVersion\
        OS="$os" MACRO="$2 $macro"\
        VERBOSE=$verbose
}

launch()
{
    if [ ! -d "$srcDir" ] || [ $projectMode -eq 0 -a ! -d "$incDir" ]; then
        echo -e "There's no project's structure.\nTo create it, write $0 -g"
        exit 1
    fi

    verbose=0
	pseudoMode="dev"
    ext=''

    j=0
    hasMode=0
    hasClean=0

    for i in 1 2 3; do
        if [ $i -le $# ]; then
            case ${!i} in
                "-d" | "-r" | "--debug" | "--release" | "--dev" | "--static" | "--shared")
                ((j=j+1))

                if [[ hasMode -eq 0 ]]; then
                    hasMode=1
                    rule="build"

                    case ${!i} in
                        "-d" | "--debug")
                            mode="debug"
                            pseudoMode="debug";;

                        "--dev")
                            mode="debug"
                            pseudoMode="dev";;

                        "-r" | "--release")
                            mode="release";;

                        "--static")
                            mode="debug"
                            rule="static"
                            runAfterCompile=0;;

                        "--shared")
                            mode="debug"
                            rule="shared"
                            runAfterCompile=0;;
                    esac
                fi;;

                "-f" | "--force")
                    ((j=j+1))

                    if [[ hasClean -eq 0 ]]; then
                        hasClean=1
                    fi;;

                "-v" | "--verbose")
                    ((j=j+1))
                    verbose=1;;
            esac
        fi
    done

    while ((j > 0)); do
        shift
        ((j=j-1))
    done

    if [[ hasClean -eq 1 ]]; then
        [[ $verbose -eq 0 ]] && make clean 1>/dev/null || make clean
    fi

    case "$OSTYPE" in
        "linux"*)
            ext=""
            os="LINUX";;
        "darwin"*)
            ext=".app"
            os="MACOS";;
        "cygwin" | "msys" | "win32")
            ext=".exe"
            os="WINDOWS";;
    esac

    if [ ! -z "$os" ]; then
        macro="-D$os"
    fi

    # get header files folder
    [ $projectMode -eq 1 ] && includeDir=$srcDir || includeDir=$incDir

    log "Compiling..."

	echo -e -n "\033[0;90m"

    # compile and execute if succeed
    [ $verbose -eq 1 ] && compile "$rule" "$macro" || compile "$rule" "$macro" 2> /dev/null

    res=$?

	echo -e -n "\033[0m"

    if [ $res -eq 0 ]; then
        log "\n\033[0;32mCompilation succeed\033[0m\n"
        
        if [ "$rule" == "shared" ]; then
            updateLibraryInclude
        elif [ $runAfterCompile -eq 1 ]; then
            log "----- Executing ${mode^^} mode -----\n\n"

            cd "$outDir/"

            if [ $pseudoMode == "debug" ]; then
                gdb ./$mode/$pgname$ext $@
            else
                ./$mode/$pgname$ext $@
            fi
        fi
    else
        echo -e "\n\033[0;31mCompilation failed\033[0m\n"
    fi

    echo -e -n "\033[0m"
}


patch()
{
    wget -q -O "$0" "$updateUrl"
    r=$?
    version=${version:-0.1}

    if [ $r -eq 0 ]; then
        newVersion="$(echo $(grep version=[0-9]\.[0-9] $0) | sed -E 's/version=//')"
        
        if [ $version == $newVersion ]; then
            echo "Already on latest version ($version)."
        else
            echo "v$version -> v$newVersion"
            echo -e "\033[0;32mSuccessfully updated\033[0m"
        fi

        # save our current mode, don't take the online one.
        setMode $projectMode
    else
        echo -e "\033[0;31mFailed to update\033[0m"
    fi

    exit 0
}

############

if [ $# -gt 0 ]; then
    case $1 in
        "-h" | "--help")
            getHelp;;

        "-V" | "--version")
            echo $version;;

        "--patch")
            patch;;

        "-g" | "--generate")
            [ $# -gt 1 ] && [ $2 == "-v" -o $2 == "--verbose" ]  && verbose=1 || verbose=0
            createBaseProject $verbose;;

        "--update-makefile")
            updateMakefile;;

        "--swap-mode")
            [ $# -gt 1 ] && [ $2 == "-v" -o $2 == "--verbose" ]  && verbose=1 || verbose=0
            swapMode $((1 - $projectMode)) $verbose;;

        "--set-name")
            [ $# -gt 1 ] && setProjectName $2;;

        "-l" | "--set-language")
            setLang $2;;

        "--set-guard")
            setGuard $2;;

        "-c")
            [ $# -gt 1 ] && createClass $2 || echo "Error : no class name provided.";;

        "--no-run")
            runAfterCompile=0
            launch $@;;

        "--static")
            compile "static";;

        "--shared")
            compile "shared";;

        # compile and run project
        *)
            launch $@;;
    esac
else
    launch $@
fi
