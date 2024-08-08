#system
AddPackage btrfs-progs # Btrfs filesystem utilities
AddPackage keepassxc # Cross-platform community-driven port of Keepass password manager
AddPackage libva-nvidia-driver # VA-API implementation that uses NVDEC as a backend
AddPackage alacritty # A cross-platform, GPU-accelerated terminal emulator
AddPackage discord # All-in-one voice and text chat for gamers
AddPackage dictd # Online dictionary client and server
AddPackage wireshark-qt # Network traffic and protocol analyzer/sniffer - Qt GUI
AddPackage xdg-desktop-portal # Desktop integration portals for sandboxed apps
AddPackage chntpw # Offline NT Password Editor - reset passwords in a Windows NT SAM user database file
AddPackage qemu-ui-opengl # QEMU OpenGL UI driver
AddPackage wine # A compatibility layer for running Windows programs
AddPackage libva-utils # Intel VA-API Media Applications and Scripts for libva
AddPackage erofs-utils # Userspace utilities for linux-erofs file system
AddPackage dbus-glib # GLib bindings for D-Bus (deprecated)
AddPackage exfatprogs # exFAT filesystem userspace utilities for the Linux Kernel exfat driver
AddPackage uutils-coreutils # Cross-platform Rust rewrite of the GNU coreutils
AddPackage linux # The Linux kernel and modules
AddPackage linux-firmware # Firmware files for Linux
AddPackage linux-headers # Headers and scripts for building modules for the Linux kernel
AddPackage amd-ucode # Microcode update image for AMD CPUs
AddPackage efibootmgr # Linux user-space application to modify the EFI Boot Manager
AddPackage grub # GNU GRand Unified Bootloader (2)
AddPackage cronie # Daemon that runs specified programs at scheduled times and related tools
AddPackage iw # nl80211 based CLI configuration utility for wireless devices
AddPackage bluez # Daemons for the bluetooth protocol stack
AddPackage bluez-utils # Development and debugging utilities for the bluetooth protocol stack
AddPackage fd # Simple, fast and user-friendly alternative to find

AddPackage libavif # Library for encoding and decoding .avif files
AddPackage libheif # HEIF file format decoder and encoder
#AddPackage svt-hevc # Scalable Video Technology HEVC encoder

AddPackage man-db # A utility for reading man pages
AddPackage upower # Abstraction for enumerating power devices, listening to device events and querying history and statistics
AddPackage procs # A modern replacement for ps written in Rust
AddPackage libreoffice-fresh # LibreOffice branch which contains new features and program enhancements
AddPackage gnome-keyring # Stores passwords and encryption keys
AddPackage git-sizer # Compute various size metrics for a Git repository
AddPackage gvfs # Virtual filesystem implementation for GIO
AddPackage dua-cli # A tool to conveniently learn about the disk usage of directories, fast!
AddPackage btop # A monitor of system resources, bpytop ported to C++
AddPackage fzf # Command-line fuzzy finder

AddPackage gparted # A Partition Magic clone, frontend to GNU Parted

AddPackage geary # A lightweight email client for the GNOME desktop
AddPackage jdk17-openjdk # OpenJDK Java 17 development kit
AddPackage jre-openjdk # OpenJDK Java 22 full runtime environment
AddPackage jre11-openjdk # OpenJDK Java 11 full runtime environment

#X server
AddPackage xorg-xhost # Server access control program for X
AddPackage xf86-video-amdgpu # X.org amdgpu video driver
AddPackage xorg-server # Xorg X server
AddPackage xorg-xinit # X.Org initialisation program
AddPackage xorg-xrandr # Primitive command line interface to RandR extension
AddPackage xorg-xinput # Small commandline tool to configure devices
AddPackage xorg-xev # Print contents of X events
AddPackage base # Minimal package set to define a basic Arch Linux installation
AddPackage base-devel # Basic tools to build Arch Linux packages
AddPackage make # GNU make utility to maintain groups of programs
#AddPackage autoconf-archive # A collection of freely re-usable Autoconf macros
AddPackage git # the fast distributed version control system
AddPackage lazygit # Simple terminal UI for git commands

#system services
AddPackage networkmanager # Network connection manager and user applications
AddPackage openssh # SSH protocol implementation for remote login, command execution and file transfer

AddPackage rtkit # Realtime Policy and Watchdog Daemon
AddPackage lxqt-policykit # The LXQt policykit authentication agent

AddPackage --foreign fend-bin # Arbitrary-precision unit-aware calculator

# sound
AddPackage pipewire
AddPackage pipewire-audio
AddPackage pipewire-alsa # Low-latency audio/video router and processor - ALSA configuration
AddPackage pipewire-pulse # Low-latency audio/video router and processor - PulseAudio replacement
AddPackage pipewire-jack # Low-latency audio/video router and processor - 32-bit - JACK support
AddPackage wireplumber # Session / policy manager implementation for PipeWire
#video drivers
AddPackage nvidia-dkms # NVIDIA drivers for linux
AddPackage nvidia-utils # NVIDIA drivers utilities
AddPackage nvidia-settings # Tool for configuring the NVIDIA graphics driver
AddPackage nvidia-prime # NVIDIA Prime Render Offload configuration and utilities
AddPackage lib32-nvidia-utils # NVIDIA drivers utilities (32-bit)
# fonts
AddPackage ttf-meslo-nerd # Patched font Meslo LG from nerd fonts library
AddPackage noto-fonts-emoji # Google Noto emoji fonts
#packages
AddPackage sudo # Give certain users the ability to run some commands as root
AddPackage bat # Cat clone with syntax highlighting and git integration
AddPackage curl

AddPackage zsh # A very advanced and programmable command interpreter (shell) for UNIX
AddPackage --foreign zsh-you-should-use # ZSH plugin that reminds you to use existing aliases for commands you just typed
AddPackage zsh-syntax-highlighting # Fish shell like syntax highlighting for Zsh

AddPackage acpi # Client for battery, power, and thermal readings
AddPackage --foreign light # A program to control backlights (and other hardware lights)
AddPackage xmobar # Minimalistic Text Based Status Bar
AddPackage stow # Manage installation of multiple softwares in the same directory tree
AddPackage p7zip # Command-line file archiver with high compression ratio
AddPackage os-prober # Utility to detect other OSes on a set of drives
AddPackage ntfs-3g # NTFS filesystem driver and utilities
AddPackage navi # An interactive cheatsheet tool for the command-line
AddPackage xmonad # Lightweight X11 tiled window manager written in Haskell
AddPackage mesa-utils # Essential Mesa utilities
AddPackage tealdeer # A fast tldr client in Rust
AddPackage opencl-nvidia # OpenCL implemention for NVIDIA
AddPackage --foreign wired-git # Lightweight notification daemon with highly customizable layout blocks, written in Rust.
AddPackage lxsession-gtk3 # Lightweight X11 session manager (GTK+ 3 version)
AddPackage xclip # Command line interface to the X11 clipboard
AddPackage xdg-user-dirs # Manage user directories like ~/Desktop and ~/Music
#AddPackage cpupower # Linux kernel tool to examine and tune power saving related features of your processor
#AddPackage turbostat # Report processor frequency and idle statistics
AddPackage bc # An arbitrary precision calculator language
AddPackage dmidecode # Desktop Management Interface table related utilities
AddPackage fuse2 # its for app images to work
AddPackage ifuse # A fuse filesystem to access the contents of an iPhone or iPod Touch
AddPackage tk # A windowing toolkit for use with tcl
AddPackage unzip # For extracting and viewing files in .zip archives
# term programs
AddPackage htop # Interactive process viewer
AddPackage nvtop # GPUs process monitoring for AMD, Intel and NVIDIA
AddPackage pass # Stores, retrieves, generates, and synchronizes passwords securely
#AddPackage rofi # A window switcher, application launcher and dmenu replacement
AddPackage dmenu
AddPackage ncdu # Disk usage analyzer with an ncurses interface
AddPackage dust # A more intuitive version of du in rust

AddPackage nnn # The fastest terminal file manager ever written.
#AddPackage dolphin # KDE File Manager
#AddPackage kimageformats5 # Image format plugins for Qt5

AddPackage imagemagick # An image viewing/manipulation program
AddPackage sxiv # Simple X Image Viewer
AddPackage mpv # a free, open source, and cross-platform media player
AddPackage yt-dlp # A youtube-dl fork with additional features and fixes
AddPackage zathura # Minimalistic document viewer
AddPackage zathura-pdf-mupdf # PDF support for Zathura (MuPDF backend) (Supports PDF, ePub, and OpenXPS)
AddPackage redshift # Adjusts the color temperature of your screen according to your surroundings.

AddPackage neovim # Fork of Vim aiming to improve user experience, plugins, and GUIs
AddPackage skim # like fzf but Rust
AddPackage ripgrep # A search tool that combines the usability of ag with the raw speed of grep
AddPackage the_silver_searcher # Code searching tool similar to Ack, but faster

AddPackage --foreign streamlink-git # CLI program that launches streams from various streaming services in a custom video player (livestreamer fork)
AddPackage --foreign languagetool-rust # LanguageTool API in Rust
AddPackage --foreign palemoon-bin # Open source web browser based on Firefox focusing on efficiency.
AddPackage --foreign ttf-meslo # Meslo LG is a customized version of Apple's Menlo font with various line gap and dotted zero
# programs
AddPackage qbittorrent # An advanced BitTorrent client programmed in C++, based on Qt toolkit and libtorrent-rasterbar
AddPackage sqlitebrowser # SQLite Database browser is a light GUI editor for SQLite databases, built on top of Qt
#gaming
#AddPackage calibre # Ebook management application

#browsers
AddPackage chromium # A web browser built for speed, simplicity, and security
#AddPackage --foreign palemoon-bin # Open source web browser based on Firefox focusing on efficiency.
AddPackage --foreign librewolf-bin # Community-maintained fork of Firefox, focused on privacy, security and freedom.

# aur
AddPackage --foreign yay-bin # Yet another yogurt. Pacman wrapper and AUR helper written in go. Pre-compiled.
AddPackage --foreign aconfmgr-git # A configuration manager for Arch Linux
#AddPackage --foreign nchat-git # nchat is a console-based chat client for Linux and macOS with support for Telegram.
AddPackage --foreign ps_mem # List processes by memory usage
AddPackage --foreign anki-bin # Helps you remember facts (like words/phrases in a foreign language) efficiently. Installed with wheel.
AddPackage --foreign autokey-gtk # A desktop automation utility for Linux and X11 - GTK frontend
AddPackage --foreign downgrade # Bash script for downgrading one or more packages to a version in your cache or the A.L.A.
#AddPackage --foreign scid_vs_pc # Shane's Chess Information Database
AddPackage --foreign zoom # Video Conferencing and Web Conferencing Service
