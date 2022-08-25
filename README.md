# Shell script for C/C++ projects

1. Download the script or the repo in a new project folder.
1. do `chmod 755 run.sh` to let you execute it if you don't have the permissions for.
1. do `./run.sh -g` to generate the project's structure. By default it's for `cpp`. See `./run.sh -l` command.
1. do `./run.sh` to compile the code and execute it.

Run `./run.sh --patch` to download latest online version of the script.

## Script usage
```sh
$ ./run.sh -h # shows every possible usages (help command)
```

The script applies the right executable's extension depending on which OS you are :
* none for Linux
* `.exe` for Windows
* `.app` for MacOS

## Structure

### Project's mode 0 
```sh
| bin/ # executable folder
    | release/ # folder where there's the release executable version
    | debug/ # folder where there's the debug executable version
| build/ # follows the sub-folders structure you made in your src/ folder.
    | # all object files (.o) are stored here
| include/
    | # every header files are stored here (.h/.hpp/.inl)
| src/
    | # every source files are stored here (.c, .cpp)
    | main.cpp
.gitignore
License
Makefile
README.md
run.sh
```

### Project's mode 1
```sh
| bin/ # executable folder
    | release/ # folder where there's the release executable version
    | debug/ # folder where there's the debug executable version
| build/ # follows the sub-folders structure you made in your src/ folder.
    | # all object files (.o) are stored here
| src/
    | # every source and header files are stored here (.c, .cpp, .h, .hpp, .inl)
    | Engine/
        | Engine.cpp
        | Engine.h
    | main.cpp
.gitignore
License
Makefile
README.md
run.sh
```

The makefile will compile every source it will find on the `src/` folder.
It is also adding every sub-folders of `include/` (or `src/` if prject's mode = 1) folder so when you're doing an include, you just have to write the filename (with .h at the end) without its path.
So you don't have to be worried about the Makefile, just code and `./run.sh` !

Tip : you can add `./run.sh` as an alias or symlink so you just have to write `run` instead.


## Script for libraries

You can use the script to build static and/or shared libraries :

`./run.sh --static` or `./run.sh --shared`.

This will create the object files in the build folder, then create the `.a`, `.so` or `.dll` (on Windows) in the `bin/lib/` folder.<br>
Plus, it will copy/paste all the header files you have (`.h`, `.hpp` and `.inl`) in `bin/lib/include/{Project_Name}/`, reorganizing these as follow :
- All files header files that are alone in their folder will be up to their parent, recusivly. This avoids a ton of subfolders just for a file.
