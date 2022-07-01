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
cppVersion=20 # 98, 03, 11, 17, 20, 23
cVersion=17 # 89, 99, 11, 17
# --------------------------------------

# PRIVATE
# --------------------------------------
# DO NOT CHANGE THESE CONFIG VARIABLES
# > PASS THROUGH THE COMMAND

version=0.0.5

srcFileExt="cpp"
hdrFileExt="hpp"
guard="ifndef" # ifndef | pragma

# PROJECT MODE :
# 0: src/ClassName.cpp include/ClassName.hpp
# 1: src/ClassDir/ClassName.cpp src/ClassDir/ClassName.hpp
projectMode=1

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

makefileCode="IyBNT0RJRklBQkxFCkNGTEFHUyAJCTo9IC1XZXJyb3IgLVdhbGwgLVdleHRyYQpMREZMQUdTCQk6PQpMSUJTIAkJOj0KCiMgTk9UIE1
PRElGSUFCTEUKIyBhbGwgd2hhdCdzIGJlbG93IG11c3Qgbm90IGJlIG1vZGlmaWVkCiMgdGhlIHJ1bi5zaCBpcyBwYXNzaW5nIGFsbCB0aGUgbmVlZGVk
IGFyZ3VtZW50cwojIHlvdSBoYXZlIHRvIGRvIHRoZSBjb25maWd1cmF0aW9uIHRocm91Z2ggdGhlIHJ1bi5zaAoKIyB0eXBlIG9mIHNvdXJjZSBmaWxlc
wojIGMgb3IgY3BwIChtYWtlIHN1cmUgdG8gbm90IGhhdmUgc3BhY2UgYWZ0ZXIpClNSQ0VYVAkJPz0gY3BwCkhEUkVYVAkJPz0gaHBwCkNWRVJTSU9OCT
89IDE3CkNQUFZFUlNJT04JPz0gMTcKCiMgZGV0ZWN0IGlmIGNvbXBpbGVyIGlzIGdjYyBpbnN0ZWFkIG9mIGNsYW5nLiBOb3Qgdmlld2luZyBmb3Igb3R
oZXIgY29tcGlsZXIKIyBDCmlmZXEgKCQoU1JDRVhUKSwgYykKCWlmZXEgKCQoQ0MpLCBnY2MpCgkJQ0MgOj0gZ2NjCgllbHNlCgkJQ0MgOj0gY2xhbmcK
CWVuZGlmICMgQyA6IGNsYW5nIG9yIGdjYwoJQ0ZMQUdTICs9IC1zdGQ9YyQoQ1ZFUlNJT04pCiMgQysrCmVsc2UKCWlmZXEgKCQoQ1hYKSwgZysrKQoJC
UNDIDo9IGcrKwoJZWxzZQoJCUNDIDo9IGNsYW5nKysKCWVuZGlmICMgQysrIDogY2xhbmcrKyBvciBnKysKCUNGTEFHUyArPSAtc3RkPWMrKyQoQ1BQVk
VSU0lPTikKZW5kaWYKCiMgZXhlY3V0YWJsZSBuYW1lCmlmZGVmIFBHTkFNRQoJRVhFQ1VUQUJMRSA9ICQoUEdOQU1FKQplbHNlCglFWEVDVVRBQkxFIAk
6PSBwcm9ncmFtCmVuZGlmICMgcGduYW1lCgojIHByb2dyYW0gbmFtZSBsb2NhdGlvbgpPVVQJCQk/PSAuL2JpbgoKIyBjb21waWxhdGlvbiBtb2RlCmlm
ZGVmIERFQlVHCglUQVJHRVRESVIgPSAkKE9VVCkvZGVidWcKZWxzZQoJVEFSR0VURElSID0gJChPVVQpL3JlbGVhc2UKZW5kaWYgIyBkZWJ1ZwoKIyBma
W5hbCBmdWxsIGV4ZWN1dGFibGUgbG9jYXRpb24KVEFSR0VUIAkJOj0gJChUQVJHRVRESVIpLyQoRVhFQ1VUQUJMRSkKIyAubyBsb2NhdGlvbgpCVUlMRE
RJUgk/PSAuL2J1aWxkCiMgc291cmNlIGZpbGVzIGxvY2F0aW9uClNSQ0RJUgkJPz0gLi9zcmMKIyBoZWFkZXIgZmlsZXMgbG9jYXRpb24KSU5DRElSCQk
/PSAuL2luY2x1ZGUKClNPVVJDRVMgCTo9ICQoc2hlbGwgZmluZCAkKFNSQ0RJUikvKiogLXR5cGUgZiAtbmFtZSAqLiQoU1JDRVhUKSkKCklOQ0RJUlMJ
CTo9CklOQ0xJU1QJCTo9CkJVSUxETElTVAk6PQpJTkMJCQk6PSAtSSQoSU5DRElSKQoKaWZkZWYgTUFDUk8KCUNGTEFHUwkJKz0gJChNQUNSTykKZW5ka
WYKCgppZm5lcSAoLCAkKGZpcnN0d29yZCAkKHdpbGRjYXJkICQoSU5DRElSKS8qKSkpCglJTkNESVJTIAk6PSAkKHNoZWxsIGZpbmQgJChJTkNESVIpLy
ovKiogLW5hbWUgJyouJChIRFJFWFQpJyAtZXhlYyBkaXJuYW1lIHt9IFw7IHwgc29ydCB8IHVuaXEpCglJTkNMSVNUIAk6PSAkKHBhdHN1YnN0ICQoSU5
DRElSKS8lLCAtSSQoSU5DRElSKS8lLCAkKElOQ0RJUlMpKQoJQlVJTERMSVNUIAk6PSAkKHBhdHN1YnN0ICQoSU5DRElSKS8lLCAkKEJVSUxERElSKS8l
LCAkKElOQ0RJUlMpKQoJSU5DIAkJKz0gJChJTkNMSVNUKQplbmRpZiAjIGluY2RpcgoKCmlmZGVmIERFQlVHCk9CSkVDVFMgCTo9ICQocGF0c3Vic3QgJ
ChTUkNESVIpLyUsICQoQlVJTERESVIpLyUsICQoU09VUkNFUzouJChTUkNFWFQpPS5vKSkKCiQoVEFSR0VUKTogJChPQkpFQ1RTKQoJQG1rZGlyIC1wIC
QoVEFSR0VURElSKQoJQGVjaG8gIkxpbmtpbmcuLi4iCglAZWNobyAiICBMaW5raW5nICQoVEFSR0VUKSIKCUAkKENDKSAtZyAtbyAkKFRBUkdFVCkgJF4
gJChMSUJTKSAkKExERkxBR1MpCgokKEJVSUxERElSKS8lLm86ICQoU1JDRElSKS8lLiQoU1JDRVhUKQoJQG1rZGlyIC1wICQoQlVJTERESVIpCmlmZGVm
IEJVSUxETElTVAoJQG1rZGlyIC1wICQoQlVJTERMSVNUKQplbmRpZgoJQGVjaG8gIkNvbXBpbGluZyAkPC4uLiI7CglAJChDQykgJChDRkxBR1MpICQoS
U5DKSAtYyAkPCAtbyAkQAoKZWxzZSAjIFJFTEVBU0UKCiQoVEFSR0VUKToKCUBta2RpciAtcCAkKFRBUkdFVERJUikKCUBlY2hvICJMaW5raW5nLi4uIg
oJQCQoQ0MpICQoSU5DKSAtbyAkKFRBUkdFVCkgJChTT1VSQ0VTKSAkKExJQlMpICQoTERGTEFHUykKCmVuZGlmICNkZWJ1ZyAvIHJlbGVhc2UgdGFyZ2V
0cwoKCmNsZWFuOgoJcm0gLWYgLXIgJChCVUlMRERJUikvKioKCUBlY2hvICJBbGwgb2JqZWN0cyByZW1vdmVkIgoKY2xlYXI6IGNsZWFuCglybSAtZiAt
ciAgJChPVVQpLyoqCglAZWNobyAiJChPVVQpIGZvbGRlciBjbGVhcmVkIgoKLlBIT05ZOiBjbGVhbiBjbGVhcg=="

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
        CVERSION=$cVersion CPPVERSION=$cppVersion\
        MACRO="$1 -D${mode^^}"
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

    ext=''
    os='LINUX'

    # detect os and adapt executable's extension
    if [ "$OSTYPE" == "darwin"* ]; then # mac OS
        ext='.app'
        os='MACOS'
    elif [ "$OSTYPE" == "cygwin" -o "$OSTYPE" == "msys" -o "$OSTYPE" == "win32" ]; then # windows
        ext='.exe'
        os='WINDOWS'
    fi

    pgname=$"$pgname$ext"

    macro="-D$os"

    # get header files folder
    [[ $projectMode -eq 1 ]] && includeDir=$srcDir || includeDir=$incDir

    if [ $verbose -eq 1 ]; then
        echo -e "Compiling..."
    fi

	echo -e -n "\033[0;90m"

    # compile and execute if succeed
    [ $verbose -eq 1 ] && compile "$macro" || compile "$macro" 2> /dev/null

    res=$?

	echo -e "\033[0m"

    if [ $res -eq 0 ]; then
        cd "$outDir/"

        if [ $verbose -eq 1 ]; then
            echo -e "\n\033[0;32mCompilation succeed\033[0m\n"
            echo -e "----- Executing ${mode^^} mode -----\n\n"
        fi
        if [ $pseudoMode == "debug" ]; then
            gdb ./$mode/$pgname $@
        else
            ./$mode/$pgname $@
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
