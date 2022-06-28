#!/bin/bash

# Author : NoxFly
# Copyrights 2021-2022

# PUBLIC
# --------------------------------------
# YOU CAN CHANGE THESE CONFIG VARIABLES

# adapt these pathes for your project
# don't forget to do execute 'updateMakefile' after any modification.
# If you don't do it, it's not dangerous, because the script will always
# pass these variables as arguments to the makefile.
# But if you pass to the makefile directly, it'll not be updated.
srcDir="./src"
incDir="./include" # availible only on projectMode = 0
outDir="./bin"
buildDir="./build"
cppVersion=17 # 98, 03, 11, 17, 20
cVersion=17 # 89, 99, 11, 17
# --------------------------------------

# PRIVATE
# --------------------------------------
# DO NOT CHANGE THESE CONFIG VARIABLES
# > PASS THROUGH THE COMMAND

version=0.0.1

srcFileExt="cpp"
hdrFileExt="hpp"
guard="ifndef" # ifndef | pragma

# PROJECT MODE :
# 0: src/ClassName.cpp include/ClassName.hpp
# 1: src/ClassDir/ClassName.cpp src/ClassDir/ClassName.hpp
projectMode=0

# if any mode is precised, then release is the default one
mode="dev"
# project folder's name is the default application's name
pgname=${PWD##*/}

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
--set-guard         [ifndef|pragma]      Defines either it has to be #ifndef FILENAME_H or #pragma once on header
                                        file creation.

--dev                                   Compile code and run it in dev mode. It's debug mode with modified options.
--debug             -d                  Compile code and run it in debug mode.
--release           -r                  Compile code and run it in release mode. If no mode precised, this is the
                                        default one.

--force             -f                  Make clean before compiling again.
--verbose           -v                  Add this option to have details of current process."

makefileCode="IyBNT0RJRklBQkxFCkNGTEFHUyAJCTo9IC1Xbm8tdW51c2VkLWNvbW1hbmQtbGluZS1hcmd1bWVudCMgLVdlcnJvciA
tV2FsbCAtV2V4dHJhCkxERkxBR1MJCTo9CkxJQlMgCQk6PQoKIyBOT1QgTU9ESUZJQUJMRQojIGFsbCB3aGF0J3MgYmVsb3cgbXVzdCBu
b3QgYmUgbW9kaWZpZWQKIyB0aGUgcnVuLnNoIGlzIHBhc3NpbmcgYWxsIHRoZSBuZWVkZWQgYXJndW1lbnRzCiMgeW91IGhhdmUgdG8gZ
G8gdGhlIGNvbmZpZ3VyYXRpb24gdGhyb3VnaCB0aGUgcnVuLnNoCgojIHR5cGUgb2Ygc291cmNlIGZpbGVzCiMgYyBvciBjcHAgKG1ha2
Ugc3VyZSB0byBub3QgaGF2ZSBzcGFjZSBhZnRlcikKU1JDRVhUCQk/PSBjcHAKSERSRVhUCQk/PSBocHAKQ1ZFUlNJT04JPz0gMTcKQ1B
QVkVSU0lPTgk/PSAxNwoKIyBkZXRlY3QgaWYgY29tcGlsZXIgaXMgZ2NjIGluc3RlYWQgb2YgY2xhbmcuIE5vdCB2aWV3aW5nIGZvciBv
dGhlciBjb21waWxlcgojIEMKaWZlcSAoJChTUkNFWFQpLCBjKQoJaWZlcSAoJChDQyksIGdjYykKCQlDQyA6PSBnY2MKCWVsc2UKCQlDQ
yA6PSBjbGFuZwoJZW5kaWYgIyBDIDogY2xhbmcgb3IgZ2NjCglDRkxBR1MgKz0gLXN0ZD1jJChDVkVSU0lPTikKIyBDKysKZWxzZQoJaW
ZlcSAoJChDWFgpLCBnKyspCgkJQ0MgOj0gZysrCgllbHNlCgkJQ0MgOj0gY2xhbmcrKwoJZW5kaWYgIyBDKysgOiBjbGFuZysrIG9yIGc
rKwoJQ0ZMQUdTICs9IC1zdGQ9YysrJChDUFBWRVJTSU9OKQplbmRpZgoKIyBleGVjdXRhYmxlIG5hbWUKaWZkZWYgUEdOQU1FCglFWEVD
VVRBQkxFID0gJChQR05BTUUpCmVsc2UKCUVYRUNVVEFCTEUgCTo9IHByb2dyYW0KZW5kaWYgIyBwZ25hbWUKCiMgcHJvZ3JhbSBuYW1lI
GxvY2F0aW9uCk9VVAkJCT89IC4vYmluCgojIGNvbXBpbGF0aW9uIG1vZGUKaWZkZWYgREVCVUcKCVRBUkdFVERJUiA9ICQoT1VUKS9kZW
J1ZwplbHNlCglUQVJHRVRESVIgPSAkKE9VVCkvcmVsZWFzZQplbmRpZiAjIGRlYnVnCgojIGZpbmFsIGZ1bGwgZXhlY3V0YWJsZSBsb2N
hdGlvbgpUQVJHRVQgCQk6PSAkKFRBUkdFVERJUikvJChFWEVDVVRBQkxFKQojIC5vIGxvY2F0aW9uCkJVSUxERElSCT89IC4vYnVpbGQK
IyBzb3VyY2UgZmlsZXMgbG9jYXRpb24KU1JDRElSCQk/PSAuL3NyYwojIGhlYWRlciBmaWxlcyBsb2NhdGlvbgpJTkNESVIJCT89IC4va
W5jbHVkZQoKU09VUkNFUyAJOj0gJChzaGVsbCBmaW5kICQoU1JDRElSKS8qKiAtdHlwZSBmIC1uYW1lICouJChTUkNFWFQpKQoKSU5DRE
lSUwkJOj0KSU5DTElTVAkJOj0KQlVJTERMSVNUCTo9CklOQwkJCTo9CgppZm5lcSAoLCAkKGZpcnN0d29yZCAkKHdpbGRjYXJkICQoSU5
DRElSKS8qKSkpCglJTkNESVJTIAk6PSAkKHNoZWxsIGZpbmQgJChJTkNESVIpLyoqIC1uYW1lICcqLiQoSERSRVhUKScgLWV4ZWMgZGly
bmFtZSB7fSBcOyB8IHNvcnQgfCB1bmlxKQoJSU5DTElTVCAJOj0gJChwYXRzdWJzdCAkKElOQ0RJUikvJSwgLUkgJChJTkNESVIpLyUsI
CQoSU5DRElSUykpCglCVUlMRExJU1QgCTo9ICQocGF0c3Vic3QgJChJTkNESVIpLyUsICQoQlVJTERESVIpLyUsICQoSU5DRElSUykpCg
lJTkMgCQk6PSAkKElOQ0xJU1QpCmVuZGlmICMgaW5jZGlyCgppZm5lcSAoJChTUkNESVIpLCAkKElOQ0RJUikpCglJTkMgKz0gLUkgJCh
JTkNESVIpCmVuZGlmCgoKaWZkZWYgREVCVUcKT0JKRUNUUyAJOj0gJChwYXRzdWJzdCAkKFNSQ0RJUikvJSwgJChCVUlMRERJUikvJSwg
JChTT1VSQ0VTOi4kKFNSQ0VYVCk9Lm8pKQoKJChUQVJHRVQpOiAkKE9CSkVDVFMpCglAbWtkaXIgLXAgJChUQVJHRVRESVIpCglAZWNob
yAiTGlua2luZy4uLiIKCUBlY2hvICIgIExpbmtpbmcgJChUQVJHRVQpIgoJJChDQykgLWcgLW8gJChUQVJHRVQpICReICQoTElCUykgJC
hMREZMQUdTKQoKJChCVUlMRERJUikvJS5vOiAkKFNSQ0RJUikvJS4kKFNSQ0VYVCkKCUBta2RpciAtcCAkKEJVSUxERElSKQppZmRlZiB
CVUlMRExJU1QKCUBta2RpciAtcCAkKEJVSUxETElTVCkKZW5kaWYKCUBlY2hvICJDb21waWxpbmcgJDwuLi4iOwoJJChDQykgJChDRkxB
R1MpICQoSU5DKSAtYyAkPCAtbyAkQAoKZWxzZSAjIFJFTEVBU0UKCiQoVEFSR0VUKToKCUBta2RpciAtcCAkKFRBUkdFVERJUikKCUBlY
2hvICJMaW5raW5nLi4uIgoJJChDQykgJChJTkMpIC1vICQoVEFSR0VUKSAkKFNPVVJDRVMpICQoTElCUykgJChMREZMQUdTKQoKZW5kaW
YgI2RlYnVnIC8gcmVsZWFzZSB0YXJnZXRzCgoKY2xlYW46CglybSAtZiAtciAkKEJVSUxERElSKS8qKgoJQGVjaG8gIkFsbCBvYmplY3R
zIHJlbW92ZWQiCgpjbGVhcjogY2xlYW4KCXJtIC1mIC1yICAkKE9VVCkvKioKCUBlY2hvICIkKE9VVCkgZm9sZGVyIGNsZWFyZWQiCgou
UEhPTlk6IGNsZWFuIGNsZWFy"

# --------------------------------------


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
    if [[ ! $1 =~ ^[a-zA-Z_]+$ ]]; then
        echo "Error : class name must only contains alphanumeric characters and underscores"
    else
        echo "Creating class $1..."
        if [ ! -d $srcDir ]; then
            echo -e "Project's structure not created yet.\nAborting."
            getHelp
            exit 2
        fi

        if [ $projectMode -eq 0 ]; then
            srcPath="$srcDir/$1.$srcFileExt"
            incPath="$incDir/$1.$hdrFileExt"
        else
            folderPath="$srcDir/$1"
            mkdir -p $folderPath
            srcPath="$folderPath/$1.$srcFileExt"
            incPath="$folderPath/$1.$hdrFileExt"
        fi

        if [ -f "$srcPath" ] || [ -f "$incPath" ]; then
            echo "A file with this name already exists."
            echo "Aborting"
        else
            touch $srcPath
            touch $incPath
            getSrcCode $1 > $srcPath
            getHeaderCode $1 > $incPath
            echo "Done"
        fi
    fi
}

createBaseProject() {
    echo "Creating structure..."
    i=0
    if [ ! -d "$srcDir" ]; then
        mkdir $srcDir
        [ $verbose -eq 1 -a $? -eq 0 ] && echo "Created $srcDir folder"
        ((i=i+1))
    fi

    if [ $projectMode -eq 0 ] && [ ! -d "$incDir" ]; then
        mkdir $incDir
        [ $verbose -eq 1 -a $? -eq 0 ] && echo "Created $incDir folder"
        ((i=i+1))
    fi

    if [ ! -d "$outDir" ]; then
        mkdir $outDir
        [ $verbose -eq 1 -a $? -eq 0 ] && echo "Created $outDir folder"
        ((i=i+1))
    fi

    if [ ! -d "$buildDir" ]; then
        mkdir $buildDir
        [ $verbose -eq 1 -a $? -eq 0 ] && echo "Created $buildDir folder"
        ((i=i+1))
    fi
    
    if [ ! -f "$srcDir/main.$srcFileExt" ]; then
        touch "$srcDir/main.$srcFileExt"
        getMainCode > "$srcDir/main.$srcFileExt"
        [ $verbose -eq 1 -a $? -eq 0 ] && echo "Created main file"
        ((i=i+1))
    fi

    if [ ! -f "Makefile" ]; then
        touch "Makefile"
        echo -e "$makefileCode"  | base64 --decode > "Makefile"
        updateMakefile
        [ $verbose -eq 1 -a $? -eq 0 ] && echo "Created Makefile"
        ((i=i+1))
    fi

    [ $verbose -eq 1 -a $i -eq 0 ] && echo "No changes made" || echo "Done"
}

getSrcCode()
{
    if [ $srcFileExt == "c" ]; then
        echo -e -n "#include \"$1.h\"\n\n"
    else
        echo -e -n "#include \"$1.h\"\n\n$1::$1() {\n\n}\n\n$1::~$1() {\n\n}"
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
        echo -e -n "#include <iostream>\n\nint main(int argc, char **argv) {\n\tstd::cout << \"Hello World\" << std::endl;\n\treturn 0;\n}"
    elif [ $srcFileExt == "c" ]; then
        echo -e -n "#include <stdio.h>\n\nint main(int argc, char **argv) {\n\tprintf(\"Hello World \");\n\treturn 0;\n}"
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

compile()
{
    make ${mode^^}=1 PGNAME=$pgname\
        SRCEXT=$srcFileExt HDREXT=$hdrFileExt\
        SRCDIR=$srcDir INCDIR=$includeDir\
        OUT=$outDir BUILDDIR=$buildDir\
        MODE=$projectMode\
        CVERSION=$cVersion CPPVERSION=$cppVersion
}

launch()
{
    if [ ! -d "$srcDir" ] || [ $projectMode -eq 0 -a ! -d "$incDir" ]; then
        echo -e "There's no project's structure.\nTo create it, write $0 -g"
        exit 1
    fi

    j=0
    verbose=0
	pseudoMode=$mode

    for i in 1 2 3; do
        if [ $i -le $# ]; then
            # release / debug mode / program name
            if [ $# -gt 0 ] && [ ${!i} == "-d" -o ${!i} == "-r" -o ${!i} == "--debug" -o ${!i} == "--release" ]; then
				pseudoMode=$mode
                if [[ ${!i} == "-d" || ${!i} == "--debug" || ${!i} == "--dev" ]]; then
					mode="debug"
					[ ${!i} == "--dev" ] && pseudoMode="dev" || pseudoMode="debug"
				else
					mode="release"
				fi
                ((j=j+1))
            fi

            if [ ${!i} == "-f" -o ${!i} == "--force" ]; then
                make clean
                ((j=j+1))
            fi

            if [ ${!i} == "-v" -o ${!i} == "--verbose" ]; then
                verbose=1
                ((j=j+1))
            fi
        fi
    done

	[ $mode == "dev" ] && mode="debug"

    while ((j > 0)); do
        shift
        ((j=j-1))
    done

    # detect os and adapt executable's extension
    if [ "$OSTYPE" == "darwin"* ]; then # mac OS
        pgname=$pgname.app
    elif [ "$OSTYPE" == "cygwin" -o "$OSTYPE" == "msys" -o "$OSTYPE" == "win32" ]; then # windows
        pgname=$pgname.exe
    fi

    # get header files folder
    [[ $projectMode -eq 1 ]] && includeDir=$srcDir || includeDir=$incDir

    if [ $verbose -eq 1 ]; then
        echo -e "Compiling..."
    fi

	echo -e -n "\033[0;90m"

    # compile and execute if succeed
    [ $verbose -eq 1 ] && compile || compile 2> /dev/null

    res=$?

	echo -e "\033[0m"

    if [ $res -eq 0 ]; then
        if [ $verbose -eq 1 ]; then
            echo -e "\n\033[0;32mCompilation succeed\033[0m\n"
            echo -e "----- Executing ${mode^^} mode -----\n\n"
        fi
        if [ $pseudoMode == "debug" ]; then
            gdb ./bin/$mode/$pgname $@
        else
            ./bin/$mode/$pgname $@
        fi
    else
        echo -e "\n\033[0;31mCompilation failed\033[0m\n"
    fi

    echo -e "\033[0m"
}


patch()
{
    wget -q -O "$0" "$updateUrl"
    r=$?
    version=${version:-0.1}

    if [ $r -eq 0 ]; then
        newVersion="$(echo $(grep version=[0-9]\.[0-9] $0) | sed -r 's/version=//')"
        
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

        "-l" | "--set-language")
            setLang $2;;

        "--set-guard")
            setGuard $2;;

        "-c")
            [ $# -gt 1 ] && createClass $2 || echo "Error : no class name provided.";;

        # compile and run project
        *)
            launch $@;;
    esac
else
    launch $@
fi
