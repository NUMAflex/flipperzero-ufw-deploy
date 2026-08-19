#!/usr/bin/env bash

#################################################################################
#Copyright (C) 2007 Free Software Foundation.

#This program is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 2 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

##################################################################################

SCRIPT_VERSION=0.89

# 1.0.ufw    00/00/2027 firmware development functions implemented (repo update, --build and all that)

# 0.89  03/07/2026 second most fully tested and refactored version yet (ufw syncronized versioning as of ufw 0.89)
# 0.3.1 04/06/2026 added all cool faps
# 0.3   01/06/2026 dialog wrapped progress bar
# 0.2.6 08/05/2026 added tagtinker fap (extra)
# 0.2   31/12/2025 most fully tested and working version (menu interface, welcome message and debug flag added)
# 0.1   00/00/2023 first commit

# mostly stolen from alsa-info.sh and Kali Nethunter Kernel build.sh

readonly WORKDIR="$HOME/Documents/Flipper"
readonly FWDIR="$WORKDIR/fw"
readonly EXTDIR="$WORKDIR/ext"
readonly APDIR="$EXTDIR/apps"
readonly APDDIR="$EXTDIR/apps_data"
readonly BASEZFILE="all-the-apps-base.zip"
readonly BASEFILEDIR="base_pack_build/artifacts-base"
readonly EXTRAZFILE="all-the-apps-extra.zip"
readonly EXTRAFILEDIR="extra_pack_build/artifacts-extra"
readonly TOTPFILEDIR="base_pack_build/apps_data"
# readonly DEBUG=1
# Escape spaces in literals. Quote variables at expansion.
if (( DEBUG )) ; then
	SDDIR="$WORKDIR/FLIPPER SD"
else
	# CHANGE THIS TO YOUR SD CARD MOUNTED DIR (also make sure it's Flipper Formated, labeled FLIPPER SD)
	SDDIR="/run/media/numaflex/FLIPPER SD"
fi


#############################################
# ! - comment to skip FAP category entirely #
#############################################
readonly BLDIR="Bluetooth"
readonly GMDIR="Games"
readonly GPDIR="GPIO"
readonly IBDIR="iButton"
readonly IRDIR="Infrared"
readonly MDDIR="Media"
readonly NFDIR="NFC"
readonly RFDIR="RFID"
readonly SBDIR="Sub-GHz"
readonly TLDIR="Tools"
readonly USDIR="USB"


#Set the locale (this may or may not be a good idea.. let me know)
export LC_ALL=C

# Change the PATH variable
PATH=$PATH:/bin:/usr/bin
BGTITLE="Flipper Zero - v$SCRIPT_VERSION"

GIT=$(command -v git)
CURL=$(command -v curl)
REQUIRES="git curl"

# Bash Color
green='\e[32m'
red='\e[31m'
yellow='\e[33m'
blue='\e[34m'
lgreen='\e[92m'
lyellow='\e[93m'
lblue='\e[94m'
lmagenta='\e[95m'
lcyan='\e[96m'
blink_red='\033[05;31m'
restore='\033[0m'
reset='\e[0m'


##############################################
# Functions
##############################################
# Bootstrap dir structure
function _foo_dir_bootstrap() {
	if [[ ! -d "$WORKDIR" ]]; then
		mkdir -pv "$WORKDIR"/{apps/{$BLDIR,$GMDIR,$GPDIR,$IBDIR,$IRDIR,$MDDIR,$NFDIR,$RFDIR,$SBDIR,$TLDIR,$USDIR},{badusb,infrared,music_player,nfc,pocsag,subghz,subghz_remote,subplaylist,tama_p1},apps_data/{totp/plugins,fordradiocodes}}
	fi
}

# Bootstrap DEBUG dir structure
function _foo_dir_dbootstrap() {
	if [[ ! -d "$WORKDIR/FLIPPER\ SD" ]]; then
		mkdir -pv "$WORKDIR"/FLIPPER\ SD/{apps/{$BLDIR,$GMDIR,$GPDIR,$IBDIR,$IRDIR,$MDDIR,$NFDIR,$RFDIR,$SBDIR,$TLDIR,$USDIR},{badusb,infrared,music_player,nfc,pocsag,subghz,subghz_remote,subplaylist,tama_p1},apps_data/{totp/plugins,fordradiocodes}}
	fi
}

# splash related
function _tinker-toy() {
	echo -e "${yellow}
			o--o o                      o-o
			|    | o                   o  /o
			O-o  |   o-o  o-o  o-o o-o | / |
			|    | | |  | |  | |-' |   o/  o
			o    o | O-o  O-o  o-o o    o-o
				 |    |
				 o    o
	\n\t\t\t$BGTITLE${reset}\n"
}

function _moscow() {
	echo -e "${yellow}
		  #   ##### #   # ##### ##### ##### ####  ###
		 ###   #  # #  ## #   # #   # #     #   # # #
		# # #  #  # # # # #   # #   # ####  ####  # #
		 ###   #  # ##  # #   # #   # #     #     # #
		  #   #   # #   # #   # #   # ##### #     ###
	\n\t\t\t$BGTITLE${reset}\n"
}

function _dos-rebel() {
	echo -e "${yellow}
	 ███████████ ████   ███
	░░███░░░░░░█░░███  ░░░
	 ░███   █ ░  ░███  ████  ████████  ████████   ██████  ████████
	 ░███████    ░███ ░░███ ░░███░░███░░███░░███ ███░░███░░███░░███
	 ░███░░░█    ░███  ░███  ░███ ░███ ░███ ░███░███████  ░███ ░░░
	 ░███  ░     ░███  ░███  ░███ ░███ ░███ ░███░███░░░   ░███
	 █████       █████ █████ ░███████  ░███████ ░░██████  █████
	░░░░░       ░░░░░ ░░░░░  ░███░░░   ░███░░░   ░░░░░░  ░░░░░
				 ░███      ░███
				 █████     █████
				░░░░░     ░░░░░
	\n\t\t$BGTITLE${reset}\n"
}

function _bloody() {
	echo -e "${yellow}
	  █████▒██▓     ██▓ ██▓███   ██▓███  ▓█████  ██▀███
	▓██   ▒▓██▒    ▓██▒▓██░  ██▒▓██░  ██▒▓█   ▀ ▓██ ▒ ██▒
	▒████ ░▒██░    ▒██▒▓██░ ██▓▒▓██░ ██▓▒▒███   ▓██ ░▄█ ▒
	░▓█▒  ░▒██░    ░██░▒██▄█▓▒ ▒▒██▄█▓▒ ▒▒▓█  ▄ ▒██▀▀█▄
	░▒█░   ░██████▒░██░▒██▒ ░  ░▒██▒ ░  ░░▒████▒░██▓ ▒██▒
	 ▒ ░   ░ ▒░▓  ░░▓  ▒▓▒░ ░  ░▒▓▒░ ░  ░░░ ▒░ ░░ ▒▓ ░▒▓░
	 ░     ░ ░ ▒  ░ ▒ ░░▒ ░     ░▒ ░      ░ ░  ░  ░▒ ░ ▒░
	 ░ ░     ░ ░    ▒ ░░░       ░░          ░     ░░   ░
		   ░  ░ ░                       ░  ░   ░
	\n\t\t$BGTITLE${reset}\n"
}

function _poison() {
	echo -e "${yellow}
	@@@@@@@@  @@@       @@@  @@@@@@@   @@@@@@@   @@@@@@@@  @@@@@@@
	@@@@@@@@  @@@       @@@  @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@@@@@@
	@@!       @@!       @@!  @@!  @@@  @@!  @@@  @@!       @@!  @@@
	!@!       !@!       !@!  !@!  @!@  !@!  @!@  !@!       !@!  @!@
	@!!!:!    @!!       !!@  @!@@!@!   @!@@!@!   @!!!:!    @!@!!@!
	!!!!!:    !!!       !!!  !!@!!!    !!@!!!    !!!!!:    !!@!@!
	!!:       !!:       !!:  !!:       !!:       !!:       !!: :!!
	:!:        :!:      :!:  :!:       :!:       :!:       :!:  !:!
	 ::        :: ::::   ::   ::        ::        :: ::::  ::   :::
	 :        : :: : :  :     :         :        : :: ::    :   : :
	\n\t\t$BGTITLE${reset}\n"
}

#  Let me tell you something, this is the 1990's, alright? In this day and age a man has to have choices, a man has to have a little bit of variety.
function _splash() {
	clear
	let "SPLASH = $RANDOM % 6 +1";
	case $SPLASH in
		1)
			_tinker-toy
		;;
		2)
			_moscow
		;;
		3)
			_dos-rebel
		;;
		4)
			_bloody
		;;
		5)
			_poison
		;;
		*)
			_moscow
		;;
	esac
}

# chaotic evil sign-off
function _signoff() {
	echo -e "\nciao."
}


#
# me·tic·u·lous·ly
#
# i'm a good man and thorough
#


declare -a FAPS=()

function _foo_register_fap() {
	[[ -n "$2" && -n "$3" ]] || return
	FAPS+=("$1|$2|$3")
}



##############################################################################################################
# ! - EACH AND EVERY FAP SHOULD HAVE A NAME ENTRY BELOW                                                      #
#                                                                                                            #
#   this reflects my personal selection built on top of the clean ufw version (less extra apps),             #
#   the idea is for you explore the fap ecosystem and modify it according to your needs. have fun.           #
#                                                                                                            #
#  Hint:                                                                                                     #
#   type _foo_register_fap base_or_extra "FAP_DIR_NAME" "fap_name_as_in_zip.fap"                             #
#                                                                                                            #
##############################################################################################################


#############
# Bluetooth #
#############
# BLE_SPAM
_foo_register_fap base "$BLDIR" "ble_spam.fap"


#########
# Games #
#########
# SNAKE20 (extra)
_foo_register_fap extra "$GMDIR" "Arcade/snake20.fap" # extra package
# T_REX_RUNNER (extra)
_foo_register_fap extra "$GMDIR" "Arcade/t_rex_runner.fap" # extra
# TAMA_P1 (extra)
_foo_register_fap extra "$GMDIR" "Simulation/tama_p1.fap" # extra


########
# GPIO #
########
# I2CTOOLS
_foo_register_fap base "$GPDIR" "i2ctools.fap"
# LIGHTMETER
_foo_register_fap base "$GPDIR" "Sensors/lightmeter.fap"
# NRF24_MOUSE_JACKER
_foo_register_fap base "$GPDIR" "NRF24/nrf24_mouse_jacker.fap"
# NRF24_SNIFFER
_foo_register_fap base "$GPDIR" "NRF24/nrf24_sniffer.fap"
# SIGNAL_GENERATOR
_foo_register_fap base "$GPDIR" "signal_generator.fap"
# SPI_MEM_MANAGER
_foo_register_fap base "$GPDIR" "Programmers/spi_mem_manager.fap"
# UART_TERMINAL
_foo_register_fap base "$GPDIR" "UART/uart_terminal.fap"
# UNITEMP
_foo_register_fap base "$GPDIR" "Sensors/unitemp.fap"


###########
# iButton #
###########
# FUZZER_IBTN
_foo_register_fap base "$IBDIR" "fuzzer_ibtn.fap"
# IBUTTON_CONVERTER
_foo_register_fap base "$IBDIR" "ibutton_converter.fap"


############
# Infrared #
############
# IR_SCOPE
_foo_register_fap base "$IRDIR" "ir_scope.fap"
# TAGTINKER (extra)
_foo_register_fap extra "$IRDIR" "tagtinker.fap" # extra


#########
# Media #
#########
# METRONOME
_foo_register_fap base "$MDDIR" "Instruments/metronome.fap"
# MORSE_CODE
_foo_register_fap base "$MDDIR" "morse_code.fap"
# MUSIC_PLAYER
_foo_register_fap base "$MDDIR" "Players/music_player.fap"
# WAV_PLAYER
_foo_register_fap base "$MDDIR" "Players/wav_player.fap"


#######
# NFC #
#######
# MFC_EDITOR
_foo_register_fap base "$NFDIR" "MIFARE/mfc_editor.fap"
# NFC_EINK
_foo_register_fap base "$NFDIR" "nfc_eink.fap"
# NFC_MAGIC
_foo_register_fap base "$NFDIR" "MIFARE/nfc_magic.fap"
# NFC_MAKER
_foo_register_fap base "$NFDIR" "nfc_maker.fap"
# PICOPASS
_foo_register_fap base "$NFDIR" "Access/picopass.fap"


########
# RFID #
########
# FUZZER_RFID
_foo_register_fap base "$RFDIR" "fuzzer_rfid.fap"
# RFID_METAL_DETECTOR (extra)
_foo_register_fap extra "$RFDIR" "rfid_metal_detector.fap" # extra


###########
# Sub-GHz #
###########
# FLIPPER_SHARE
_foo_register_fap base "$SBDIR" "flipper_share.fap"
# POCSAG_PAGER
#_foo_register_fap base "$SBDIR" "pocsag_pager.fap"
# PROTO_PIRATE
_foo_register_fap base "$SBDIR" "proto_pirate.fap"
# PROTOVIEW
_foo_register_fap base "$SBDIR" "Analyzers/protoview.fap"
# RADIO_SCANNER
_foo_register_fap base "$SBDIR" "Analyzers/radio_scanner.fap"
# SPECTRUM_ANALYZER
_foo_register_fap base "$SBDIR" "Analyzers/spectrum_analyzer.fap"
# SUB_DUP_FINDER (extra)
_foo_register_fap extra "$SBDIR" "sub_dup_finder.fap" # extra
# SUBGHZ_BRUTEFORCER
_foo_register_fap base "$SBDIR" "subghz_bruteforcer.fap"
# SUBGHZ_PLAYLIST
_foo_register_fap base "$SBDIR" "subghz_playlist.fap"
# SUBGHZ_PLAYLIST_CREATOR
_foo_register_fap extra "$SBDIR" "subghz_playlist_creator.fap" # extra
# SUBGHZ_RAW_EDIT
_foo_register_fap extra "$SBDIR" "subghz_raw_edit.fap" # extra
# SUBGHZ_SCHEDULER
_foo_register_fap base "$SBDIR" "subghz_scheduler.fap"
# WEATHER_STATION
#_foo_register_fap base "$SBDIR" "weather_station.fap"


#########
# Tools #
#########
# BARCODE_APP
_foo_register_fap base "$TLDIR" "barcode_app.fap"
# DTMF_DOLPHIN
_foo_register_fap base "$TLDIR" "dtmf_dolphin.fap"
# FORDRADIOCODE (extra)
_foo_register_fap extra "$TLDIR" "Calculators/fordradiocode.fap" # extra
# HEX_VIEWER
_foo_register_fap base "$TLDIR" "Editors/hex_viewer.fap"
# KEY_COPIER (extra)
_foo_register_fap extra "$TLDIR" "key_copier.fap" # extra
# MULTI_CONVERTER
_foo_register_fap base "$TLDIR" "Calculators/multi_converter.fap"
# POMODORO_TIMER
_foo_register_fap extra "$TLDIR" "Timers/pomodoro_timer.fap" # extra
# QUAC
_foo_register_fap base "$TLDIR" "quac.fap"
# TEXT_VIEWER
_foo_register_fap base "$TLDIR" "Editors/text_viewer.fap"
# TOTP
_foo_register_fap base "$TLDIR" "Crypto/totp.fap"
# VIN_DECODER
_foo_register_fap extra "$TLDIR" "Calculators/vin_decoder.fap" # extra


#######
# USB #
#######
# mass_storage.fap
_foo_register_fap base "$USDIR" "mass_storage.fap"


##############################################################################################################
# ! - EACH AND EVERY FAP SHOULD HAVE A UNZIP ENTRY ABOVE                                                     #
##############################################################################################################



# WHAT TO CLEAN
# - FLIPPER SD (debug dir - e posterior extract from zip)
# - ext backup (e posterior backup)
# - UberGuidoZ (repo)
#
# Erase all leftovers
function _cleanup() {
	printf "\n"
	warning "cleaning up..."

	if (( DEBUG )) ; then
		if [ -d "$SDDIR" ] ; then
			rm -Rfv "$SDDIR" #2>/dev/null
		else
			printf "\n"
			error "$SDDIR ${red} not found!${reset}"
			exit 1
		fi
	fi
}

# Pause
function pause() {
	if [ -n "$DIALOG" ] ; then
		local message="$@"
		[ -z $message ] && message="Press [Enter] to continue.."
		read -p "$message" readEnterkey
	fi
}

function info() {
	printf " ${lcyan}[i]${reset} $*${reset}\n"
}

function success() {
	printf " ${lgreen}[OK]${reset} $*${reset}\n"
}

function warning() {
	printf " ${lyellow}[!]${reset} $*${reset}\n"
}

function error() {
	printf " ${lmagenta}err0r${reset} $*${reset}\n"
}

function question() {
	printf " ${blink_red}(?)${reset} $*${reset}"
}

function ask() {
   # http://djm.me/ask
	if [ -n "$DIALOG" ]; then
		opts=()
		[ "$2" = "N" ] && opts+=(--defaultno)

		dialog --colors --title "\Z1\Zb Please answer" "${opts[@]}" --yesno "\n$1" 7 70
		rc=$?
		clear

		case $rc in
			0) return 0 ;;      # Yes
			1|255) return 1 ;;  # No ou Esc
		esac
	else
		while true; do
			if [ "${2:-}" = "Y" ]; then
				prompt="Y/n"
				default=Y
			elif [ "${2:-}" = "N" ]; then
				prompt="y/N"
				default=N
			else
				prompt="y/n"
				default=
			fi

			question
			read -rp "$1 [$prompt] " REPLY

			[ -z "$REPLY" ] && REPLY=$default

			case "$REPLY" in
				[Yy]*) return 0 ;;
				[Nn]*) return 1 ;;
			esac
		done

	fi
}

# Spin spin sugar
function _spinner() {
	local pid=$1
	local i=0
	local sp="/-\|"
	#printf " "
	#while pgrep ${pid} &>/dev/null
	while kill -0 ${pid} 2>/dev/null; do
		echo -en "\b${sp:i++%${#sp}:1}"
		#printf "\b%s" "${sp:i++%${#sp}:1}"
		#sleep 0.1
	done
}

function _foo_suzuki() {
	find . -name "*.py" -type f -delete -print
	find . -name "*.docx" -type f -delete -print
	find . -name "*.jp*" -type f -delete -print
	find . -name "*.png" -type f -delete -print
	find . -name "*.md" -type f -delete -print
	find . -name "*.json" -type f -delete -print
	rm -Rfv _Converted_
	rm -Rfv .git*
}

function _foo_suzuki_subghz() {
	cd "$EXTDIR/subghz" || exit 1
	find . -name "*.md" -type f -delete -print
	find . -name "*.pdf" -type f -delete -print
	find . -name "*.jp*" -type f -delete -print
	find . -name "*.png" -type f -delete -print
}

function _foo_suzuki_irdb() {
	cd "$EXTDIR/$IRDIR/IRDB" || exit 1
	find . -name "*.jp*" -type f -delete -print
	find . -name "*.png" -type f -delete -print
	find . -name "*.md" -type f -delete -print
	find . -name "*.json" -type f -delete -print
	rm -Rfv _Converted_
	rm -Rfv .git*
	find . -name "*.zip" -type f -delete -print
	find . -name "*.wav" -type f -delete -print
	find . -name "*.*16*" -type f -delete -print
	find . -name "*.pdf" -type f -delete -print
	find . -name "*.raw" -type f -delete -print
	find . -name "*.py*" -type f -delete -print
	find . -name "*.sh" -type f -delete -print
	find . -name "*.yml" -type f -delete -print
	find . -name "*.css" -type f -delete -print
	find . -name "*.html" -type f -delete -print
	find . -name "*.git" -type f -delete -print
	find . -name "*.cu8" -type f -delete -print
	find . -name "*.txt" -type f -delete -print
	find . -name "*.mp4" -type f -delete -print
	find . -name "*.mov" -type f -delete -print
}

function _foo_suzuki_fap() {
	ask "erase all your previous Flipper Application Files (FAPs)?" Y || {
		_foo_msg_error "aborted"
		return 1 # check this condititon later
	}

	[[ -d "$APDIR" ]] || {
		error "$APDIR directory not found!"
		return 1
	}

	if ! find "$APDIR" -type f -name "*.fap" -print -quit | grep -q .; then
		printf "\n"
		info "no previous FAPs files found."
		return 0
	fi

	printf "\n"
	warning "cleaning old FAP files"
	find "$APDIR" -type f -name "*.fap" -print -delete
}

function _foo_suzuki_totp() {
	local -a files

	ask "erase all your previous totp plugins?" Y || {
		_foo_msg_error "aborted"
		return 1 # check this condititon later
	}

	[[ -d "$APDDIR/totp/plugins" ]] || {
		error "$APDDIR/totp/plugins directory not found!"
		return 1
	}

	mapfile -t files < <(
		find "$APDDIR/totp/plugins" -type f -name "*.fal"
	)

	if (( ${#files[@]} == 0 )); then
		printf "\n"
		info "no previous TOTP plugins found."
		return 0
	fi

	printf "\n"
	warning "cleaning previous totp plugins"
	#printf '%s\n' "${files[@]}"
	rm -Rfv "${files[@]}"
}

function _foo_suzuki_amiibo() {
	find . -name "*.py" -type f -delete -print
	find . -name "*.docx" -type f -delete -print
}

function _foo_msg_error() {
	if [ -n "$DIALOG" ] ; then
		dialog --colors --title "\Z1\Zb error " --msgbox "\n$1!" 7 70
		clear
	else
		printf "\n"
		error "${red}$1!${reset}"
	fi
}

# generic helpers
function _get_latest_release() {
    curl -fsSL "https://api.github.com/repos/$1/releases/latest"
}

function _json() {
    jq -r "$1"
}

function _download_file() {
	local url="$1"
	local out="$2"
	if [ -n "$DIALOG" ]; then
		local size
		size=$(wget --spider "$url" 2>&1 | awk '/Length:/ {print $2}')
		if [ -z "$size" ]; then
			dialog --msgbox "Failed to get size for:\n$out" 7 50
			return 1
		fi
		( wget -qO- "$url" | pv -n -s "$size" > "$out" ) 2>&1 | dialog --title " downloading " --gauge "\n$out" 8 70 0
		local rc=${PIPESTATUS[0]}
		clear
		if [ "$rc" -ne 0 ]; then
			dialog --msgbox "Download failed:\n$out" 7 50
			rm -f "$out"
			return 1
		fi
	else
		printf "\n"
		info "downloading $out"
		if ! curl -fL --progress-bar -o "$out" "$url"; then
			error "Failed downloading $out"
			rm -f "$out"
			return 1
		fi
		success "$out downloaded"
	fi
	return 0
}

function _foo_get_ufw() {
	local release
	local version
	local body
	local api

	release=$(_get_latest_release "DarkFlippers/unleashed-firmware")
	version=$(printf '%s\n' "$release" | _json '.tag_name')
	body=$(printf '%s\n' "$release" | _json '.body')
	api=$(printf '%s\n' "$body" | sed -n 's/.*Current API:[[:space:]]*\([0-9][0-9.]*\).*/\1/p')

	if ask "download $version (API $api) files?" N; then
		cd "$FWDIR" || exit 1
		if [[ -f "$FWDIR/flipper-z-f7-update-$version.tgz" || -f "$FWDIR/flipper-z-f7-update-${version}c.tgz" || -f "$FWDIR/flipper-z-f7-update-${version}e.tgz" ]] ; then
			printf "\n"
			if ask "erase local files?" N; then
				printf "\n"
				warning "erasing local files"
				rm -Rfv "flipper-z-f7-update-${version}"* # globs lol
			fi
			# else abort
		fi
		_foo_download_ufw "$version"
	fi
}

function _foo_download_ufw() {
	local version="$1"
	local base="https://github.com/DarkFlippers/unleashed-firmware"
	for build in "" c e; do
		_download_file "$base/releases/download/$version/flipper-z-f7-update-$version${build}.tgz" "flipper-z-f7-update-$version${build}.tgz"
	done
}

function _foo_get_apps() {
	local release
	local tag
	local body
	local api

	release=$(_get_latest_release "xMasterX/all-the-plugins")
	tag=$(printf '%s\n' "$release" | _json '.tag_name')
	body=$(printf '%s\n' "$release" | _json '.body')
	api=$(printf '%s\n' "$body" | sed -n 's/.*API version:[[:space:]]*\([0-9][0-9.]*\).*/\1/p')

	if ask "download $tag (API $api) files?" N; then
		cd "$FWDIR" || exit 1
		if [[ -f "$FWDIR/all-the-apps-base.zip" || -f "$FWDIR/all-the-apps-extra.zip" ]] ; then
			printf "\n"
			if ask "erase local $tag files?" N; then
				printf "\n"
				warning "erasing local $tag files"
				rm -Rfv "all-the-apps"* # globs lol
			fi
			# else abort
		fi
		_foo_download_apps "$tag"
	fi
}

function _foo_download_apps() {
	local tag="$1"
	local base="https://github.com/xMasterX/all-the-plugins"
	for pack in base extra; do
		_download_file "$base/releases/download/$tag/all-the-apps-${pack}.zip" "all-the-apps-${pack}.zip"
	done
}

function _foo_copy_dir_contents() {
	local src="$1"
	local dst="$2"
	local name="$3"

	[[ -d "$src" ]] || return
	[[ -d "$dst" ]] || return

	mapfile -t files < <(find "$src" -mindepth 1 -type f)

	# ((${#files[@]})) || return
	if (( ${#files[@]} == 0 )); then
		printf "\n"
		info "$name: nothing to copy"
		return
	fi

	printf "\n"
	info "copying $name files"
	cp -Rfv "$src"/. "$dst"/
	success "$name files copied"
}

function _foo_copy_dir() {
	local src="$1"
	local dst="$2"
	local name="$3"

	[[ -d "$src" ]] || return

	mapfile -t files < <(find "$src" -mindepth 1 -type f)

	# (( ${#files[@]} )) || return
	if (( ${#files[@]} == 0 )); then
		printf "\n"
		info "$name: nothing to copy"
		return
	fi

	printf "\n"
	info "copying $name directory"
	cp -Rfv "$src" "$dst"/
	success "$name directory copied"
}

function _foo_copy_special_assets() {
    _foo_copy_dir "$APDDIR/totp"            "$SDDIR/apps_data" "totp"
    _foo_copy_dir "$APDDIR/fordradiocodes"  "$SDDIR/apps_data" "fordradiocodes"
    _foo_copy_dir "$EXTDIR/pocsag"          "$SDDIR"           "pocsag"
    _foo_copy_dir "$EXTDIR/tama_p1"         "$SDDIR"           "tama_p1"
}

function _foo_post_copy_hook() {
	local fap="$1"
	case "$fap" in
		totp.fap)
			if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$TLDIR" && -d "$APDDIR/totp/plugins" ]] ; then
				#unzip -o -j $FWDIR/$BASEZFILE $TOTPFILEDIR/totp/plugins/* -d $APDDIR/totp/plugins
				unzip -oj "$FWDIR/$BASEZFILE" "$TOTPFILEDIR/totp/plugins/*" -d "$APDDIR/totp/plugins"
			fi
			;;
	esac
}

# _foo_cp_* refactor
function _foo_copy_fap() {
	local pack="$1"     # base|extra
	local category="$2" # GPIO, Games...
	local fap="$3"

	local zip filedir

	case "$pack" in
	base)
		zip="$BASEZFILE"
		filedir="$BASEFILEDIR"
		;;
	extra)
		zip="$EXTRAZFILE"
		filedir="$EXTRAFILEDIR"
		;;
	*)
		error "unknown pack: $pack"
		return 1
		;;
	esac

	[[ -f "$FWDIR/$zip" ]] || {
	    warning "$zip not found"
	    return
	}

	[[ -d "$APDIR/$category" ]] || {
	    warning "$category not found"
	    return
	}

	if unzip -oj "$FWDIR/$zip" "$filedir/$category/$fap" -d "$APDIR/$category" ; then
		_foo_post_copy_hook "$fap" "$pack"
	else
		warning "$fap extraction failed"
	fi
}

# for copying registered faps
function _foo_copy_registered_faps() {
	local item pack dir file
	for item in "${FAPS[@]}"; do
		IFS='|' read -r pack dir file <<< "$item"
		_foo_copy_fap "$pack" "$dir" "$file"
	done
}

# for copying newly released faps
function _foo_unzip_to_ext() {
	# Move to the working dir
	cd $WORKDIR || exit 1

	if [[ ! -d "$WORKDIR" ]]; then
		_foo_dir_bootstrap
		_foo_dir_dbootstrap
		_foo_get_apps
	else
		_foo_get_apps
		printf "\n"
		_foo_suzuki_fap
		printf "\n"
		_foo_suzuki_totp
	fi

	printf "\n"
	if ask "extract FAPs from newly released zip files?" Y; then
		printf "\n"
		warning "extracting FAPs from newly released zip files"
		_foo_copy_registered_faps
		success "Flipper Application Files (FAPs) extracted"
	else
		_foo_msg_error "aborted"
		exit 1
	fi
}

# deploy local ext copy to sdcard
function _foo_deploy_to_sd() {
	# Move to the working dir
	cd $WORKDIR || exit 1

	if [ -d "$SDDIR" ] ; then
		if ask "deploy FAPs to the sd card?" Y; then
			printf "\n"
			warning "copying FAPs"
			# copy whole local ext structure to sd card
			local -a categories=(
			    "$BLDIR"
			    "$GMDIR"
			    "$GPDIR"
			    "$IBDIR"
			    "$IRDIR"
			    "$NFDIR"
			    "$RFDIR"
			    "$SBDIR"
			    "$TLDIR"
			    "$USDIR"
			)
			for fapcat in "${categories[@]}"; do
				if [[ -d "$EXTDIR/apps/$fapcat" && -d "$SDDIR/apps/${fapcat}" ]] ; then
				   	src="$EXTDIR/apps/$fapcat"
				   	dst="$SDDIR/apps/$fapcat"
				   	[[ -d "$src" ]] || continue
				   	#mkdir -p "$dst"
				   	find "$src" -mindepth 1 -type f -print -quit | read -r _ || continue
					printf "\n"
					warning "copying ${fapcat} FAPs"
					if cp -iRfv "$EXTDIR/apps/$fapcat/"* "$SDDIR/apps/$fapcat/"; then # Erro lógico: glob dentro de aspas
						success "done copying $fapcat FAPs"
					else
						error "failed copying $fapcat FAPs"
					fi
				fi
			done

			# Media is absent from clean build
			# check for fap category, source and destination and if there's content
			if [[ -d "$EXTDIR/apps/$MDDIR" && -d "$SDDIR/apps" ]] \
			   && find "$EXTDIR/apps/$MDDIR" -mindepth 1 -type f -print -quit | read -r _; then
				printf "\n"
				warning "copying $MDDIR FAPs"
				cp -Rfv "$EXTDIR/apps/$MDDIR" "$SDDIR/apps/"
				success "done copying $MDDIR FAPs"
			fi
			printf "\n"
			success "done copying FAPs"
		fi

		printf "\n"
		pause
		# copy library
		if ask "deploy additional files to the sd card?" Y; then
			printf "\n"
			warning "copying additional files"
			for dir in badusb infrared music_player nfc subghz subplaylist; do
				_foo_copy_dir_contents \
					"$EXTDIR/$dir" \
					"$SDDIR/$dir" \
					"$dir"
			done

			for dir in subghz_remote; do
				_foo_copy_dir \
					"$EXTDIR/$dir" \
					"$SDDIR" \
					"$dir"
			done
			_foo_copy_special_assets
			printf "\n"
			success "additional files copied"
		fi
	else
		if [ -n "$DIALOG" ] ; then
			dialog --colors --title "\Z1\Zb error " --msgbox "\n$ZFILE \Z1file not found!" 7 70
			clear
		else
			error "$ZFILE ${red}file not found!${reset}"
		fi
		exit 1
	fi
}

function _foo_uberguidoz() {
	local repo="$WORKDIR/UberGuidoZ/Flipper"

	if [[ -d "$repo/.git" ]] ; then
		info "local UberGuidoZ repository found, syncing with upstream"
		printf "\n"
		cd "$repo" || return 1

		printf "\n"
		warning "Fetching updates" 
		git fetch origin

		info "Resetting local copy to origin/main" 
		git reset --hard origin/main

		git submodule update --init --recursive

		success "repository synced"
	else
		warning "creating UberGuidoZ repository dir"
		mkdir -pv "$WORKDIR/UberGuidoZ"
		cd "$WORKDIR/UberGuidoZ" || return 1

		printf "\n"
		info "Cloning UberGuidoZ repository"
		git clone --recursive https://github.com/UberGuidoZ/Flipper.git

		success "done cloning UberGuidoZ repository"
		printf "\n"
	fi
}

# https://askubuntu.com/questions/377438/how-can-i-recursively-delete-all-files-of-a-specific-extension-in-the-current-di
function _foo_cp_irdb() {
	local UWORKDIR="$WORKDIR/UberGuidoZ/Flipper"

	if [[ -d "$UWORKDIR/.git" ]] ; then
		if [[ -d "$EXTDIR/infrared/IRDB" ]] ; then
			# warning "this will erase all your previous $IRDIR files"
			if ask "Erase all your previous $IRDIR files?" Y; then
				if [ -n "$DIALOG" ] ; then
					# v0.2
					(
						P=0
						while [ $P -lt 95 ]; do
							echo $P
							sleep 0.3

							if [ $P -lt 70 ]; then
								P=$((P+2))
							else
								P=$((P+1))
							fi
						done &

						FAKEPID=$!

						rm -Rfv "$EXTDIR/infrared/IRDB" >/dev/null || exit 1
						cp -iRfv "$UWORKDIR/Infrared/IRDB" "$EXTDIR/infrared/IRDB" >/dev/null || exit 1
						_foo_suzuki_irdb

						kill $FAKEPID 2>/dev/null

						echo 100
						sleep 0.3
					) | dialog --title " replacing " --gauge "\n  $ZFILE" 8 70 0
				else
					info "erasing old $IRDIR files"
					rm -Rfv "$EXTDIR/infrared/IRDB"
					success "done erasing $IRDIR files"

					printf "\n"
					info "copying new $IRDIR files"
					cp -iRfv "$UWORKDIR/Infrared/IRDB" "$EXTDIR/infrared/IRDB"
					success "done copying $IRDIR files"

					printf "\n"
					info "cleaning $IRDIR repo"
					_foo_suzuki_irdb
					success "done cleaning $IRDIR repo"
				fi
			fi
		fi
	else
		# UberGuidoZ dir not found
		if [ -n "$DIALOG" ] ; then
			dialog --colors --title "\Z1\Zb error " --msgbox "\n$UWORKDIR \Z1dir not found." 7 70
			clear
		else
			error "$UWORKDIR ${red} not found!${reset}"
		fi
		exit 1
	fi
}

function _foo_unleashed_fw() {
	local repo="$WORKDIR/DarkFlippers/unleashed-firmware"

	printf "\n"

	if [[ -d "$repo/.git" ]] ; then
		warning "local unleashed repository found, syncing with upstream"
		printf "\n"
		cd "$repo" || return 1
		pwd
		printf "\n"

		info "Fetching updates" 
		git fetch origin

		info "Resetting local copy to origin/main" 
		git reset --hard origin/main

		git submodule update --init --recursive

		success "repository synced"
	else
		warning "creating unleashed repository dir"
		mkdir -pv "$WORKDIR/DarkFlippers"
		printf "\n"
		cd "$WORKDIR/DarkFlippers" || return 1
		pwd
		printf "\n"

		info "Cloning unleashed repository"
		git clone --recursive https://github.com/DarkFlippers/unleashed-firmware.git

		success "repository cloned"
		printf "\n"
	fi
}

function _foo_flipper_fw() {
	local repo="$WORKDIR/flipperdevices/Flipper"

	printf "\n"

	if [[ -d "$repo/.git" ]] ; then

		warning "local flipperdevices repository found, syncing with upstream"
		printf "\n"
		cd "$repo" || return 1
		pwd
		printf "\n"

		info "Fetching updates" 
		git fetch origin

		info "Resetting local copy to origin/main" 
		git reset --hard origin/main

		git submodule update --init --recursive

		success "repository synced"
	else
		warning "creating flipperdevices repository dir"
		mkdir -pv "$WORKDIR/flipperdevices"
		printf "\n"
		cd "$WORKDIR/flipperdevices" || return 1
		pwd
		printf "\n"

		info "Cloning flipperdevices repository"
		git clone --recursive https://github.com/flipperdevices/flipperzero-firmware.git

		success "repository cloned"
		printf "\n"
	fi
}

function _foo_emoisemo() {
	info "Updating emoisemo repository" 
	cd $WORKDIR/emoisemo/FLIPPER-JAMM || return 1
	git fetch
	git merge origin/main
}

function _foo_lucaslhm() {
	# flow deve seguir: check if existing dir, clone repo if not found, update else if found
	# git clone --recursive https://github.com/Lucaslhm/Flipper-IRDB.git
	info "Updating Lucaslhm repository" 
	cd $WORKDIR/Lucaslhm/Flipper-IRDB || return 1
	git fetch
	git merge origin/main
}

function _foo_prune_fw() {
	local IFS FWFILE options f i
	local confdir=fw
	info "Please select the image you would like to use"
	cd $confdir
	while IFS= read -r -d $'\0' f; do
		options[i++]="$f"
	done < <(find *.tgz -type f -print0 )

	select FWFILE in "${options[@]}" "Cancel"; do
		case $FWFILE in
			"Cancel")
			    return 1
			    ;;
			*)
			    break
			    ;;
		esac
	done

	if [ -f ${FWFILE} ] ; then
		if verify_sha256 ${FWFILE}.sha256 ; then
			printf "\n"
			warning "Device should have ADB mode enabled in order to proceed!"
			printf "\n"
			if ask "All systems ready?" Y; then
				rm -Rfv ${FWFILE}
				printf "\n"
				success "Have a nice day! ${yellow}:)${reset}"
				#return 0
			else
				printf "\n"
				error "${red}aborted!${reset}"
				exit 1
			fi
		fi
	else
		printf "\n"
		error ""${FWFILE}" ${red}file not found!${reset}"
		exit 1
	fi
	cd ..
}

function _foo_sevenza() {
	if [[ -f "ext-full-backup.7z" ]]; then
		7za -y x "ext-full-backup.7z"
	else
		printf "\n"
		error "${red}7z file not found. aborted!${reset}"
		exit 1
	fi
}

function _foo_sevenz() {
	if [[ -f "ext-full-backup.7z" ]]; then
		mv -v "ext-full-backup.7z" "ext-full-backup_${date}.7z"
	else
		7z -y ext "ext-full-backup.7z"

		printf "\n"
		error "${red}7z file not found. aborted!${reset}"
		exit 1
	fi
}

# build
# - check if exist before building
#   call internal deploy function if not
# Building
# - Build firmware using Flipper Build Tool:
# ./fbt

# Flashing firmware using an in-circuit debugger
# - Connect your in-circuit debugger to your Flipper and flash firmware using Flipper Build Tool:
# ./fbt flash

# Flashing firmware using USB
# - Make sure your Flipper is on, and your firmware is functioning. Connect your Flipper with a USB cable and flash firmware using Flipper Build Tool:
# ./fbt flash_usb

# https://github.com/DarkFlippers/unleashed-firmware/blob/dev/documentation/HowToBuild.md#vscode-integration
# VSCode integration
# fbt includes basic development environment configuration for VSCode. Run ./fbt vscode_dist to deploy it. That will copy the initial environment configuration to the .vscode folder. After that, you can use that configuration by starting VSCode and choosing the firmware root folder in the File > Open Folder menu.

# Build on Linux/macOS
# - Check out documentation/fbt.md for details on building and flashing firmware.

# - Compile plugin and run it on connected flipper
# ./fbt COMPACT=1 DEBUG=0 launch_app APPSRC=applications_user/yourplugin

# - Compile everything + get updater package to update from microSD card
# ./fbt COMPACT=1 DEBUG=0 updater_package

# - Check dist/ for build outputs.
# Use flipper-z-{target}-update-{suffix}.tgz to flash your device.

# REFACTOR it at some time
function quit() {
	if [ -n "$DIALOG" ]; then
		dialog --backtitle "$BGTITLE" --title " Exit " --defaultno --yesno "\nDo you really want to quit?" 7 40
		DIALOG_EXIT_CODE=$?
		if [ $DIALOG_EXIT_CODE != 0 ]; then
			continue
		else
			exit 0
		fi
	else
		while :
		do
			# Store the exit code away, calling another function
			# overwrites $1.
			code=$1

			# Display the string passed in in $1, followed by "(Y/N)?"
			# The -e enable interpretation of backslash escapes
			# The \c causes suppression of echo's newline
			#echo -e "$* (Y/N)? \c"
			echo -e "Do you really want to quit (Y/N)? \c"
			#question "Do you really want to quit?"

			# Read the answer - only the first word of the answer will
			# be stored in "yn".  The rest will be discarded
			# (courtesy of "junk")
			read -n1 yn junk

			case $yn in
				y|Y|s|S|0)
					# return TRUE
					#return 0
					exit $code
				;;
				n|N|1)
					return 1
				;;
				*)
					echo -e "\nPlease answer Y or N."
				;;
			esac
		done
	fi
}

# Basic requires
for prg in $REQUIRES; do
	t=$(command -v $prg)
	if test -z "$t"; then
		#echo -en "$0 requires ${red}$prg${reset} utility to continue."
		error "$0 requires $prg utility to continue."
		exit 1
	fi
done

# Run checks to make sure the programs we need are installed.
GIT="$(command -v git)"
CURL="$(command -v curl)"
DIALOG="$(command -v dialog)"

WELCOME="no"
MENU="yes"

SPLASH="yes"
CIAO="yes"

REPEAT=""
while [ -z "$REPEAT" ]; do
	REPEAT="no"
	case "$1" in
		--about|--bootstrap|--dbootstrap|--help|--emoisemo|--lucaslhm|--uberguidoz|--clean-fap|--clean-totp|--copy|--cp-irdb|--get-apps|--get-fw|--new-fw|--copy-sd|--test|--update-all)
			# DIALOG="" # uncomment to disable dialog execution
			MENU="no"
			;;
		--no-dialog)
			DIALOG=""
			REPEAT=""
			shift
			;;
		--welcome)
			WELCOME="yes"
			;;
	esac
done

if [ "$SPLASH" = "yes" ] ; then
	_splash
fi

#Script header output.
if [ "$WELCOME" = "yes" ]; then
	greeting_message="\

	This script is a Flipper Zero maintenance Swiss knife.

	  This can download ufw and apps from the internet
	  process and deploy the zip files
	  then copy everything to sd card.

	See '$0 --help' for command line options.
	"
	if [ -n "$DIALOG" ]; then
		dialog  --backtitle "$BGTITLE" --title " $BGTITLE " --msgbox "$greeting_message" 20 80
	else
		echo "$BGTITLE"
		echo "--------------------------------"
		echo "$greeting_message"
	fi # dialog
fi # WELCOME

if [ "$CIAO" = "yes" ] ; then
	trap _signoff 0
fi

if [ "$MENU" = "yes" ]; then
	while true
	do
		if [ -n "$DIALOG" ] ; then
			ans=$(dialog --stdout --nocancel --title " $BGTITLE " --menu "What do you want to do?" 0 0 0 \
				1 "Firmware" \
				2 "Apps" \
				3 "Deploy" \
				4 "Copy" \
				5 "UberGuidoZ" \
				0 "Exit"
			)
		else
			# clear screen
			clear
			_splash
			echo -e "\t1.\tFirmware"
			echo -e "\t2.\tApps"
			echo -e "\t3.\tDeploy"
			echo -e "\t4.\tCopy"
			echo -e "\t5.\tUberGuidoZ"
			echo -e "\n\t0.\tExit\n"

			# user prompt
			echo -e "flipper0 $ \c"
			read -n1 ans

			# Empty answers (pressing ENTER) cause the menu to redisplay,
			# so .... back around the loop
			# We only make it to the "continue" bit if the "test"
			# program ("[") returned 0 (True)
			[ "$ans" = "" ] && continue
		fi

		case $ans in
			1|f)
				clear
				_foo_get_ufw
				printf "\n"
				pause
			;;
			2|a)
				clear
				_foo_get_apps
				printf "\n"
				pause
			;;
			3|d)
				clear
				--new-fw
				printf "\n"
				pause
			;;
			4|c)
				clear
				--copy-sd
				printf "\n"
				pause
			;;
			5|u)
				clear
				_foo_uberguidoz
				printf "\n"
				pause
			;;
			q|Q|0|$'\e')
				clear
				quit 0
			;;
			*)
				continue
			;;
		esac
	done
fi # proceed

# loop through command line arguments, until none are left.
if [ -n "$1" ]; then
	until [ -z "$1" ]
	do
		case "$1" in
			--about)
				echo -e "  Copyright (C) 2022 Free Software Foundation, Inc."
				echo -e "\n  This is free software; see the source for copying conditions. There is NO"
				echo -e "  warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE."
				echo -e "\n  Written/Tested by ${red}NUMAflex${reset}"
				exit 0
			;;
			--bootstrap)
				_foo_dir_bootstrap
				exit 0
			;;
			--dbootstrap)
				_foo_dir_dbootstrap
				exit 0
			;;
			--uberguidoz)
				_foo_uberguidoz
				exit 0
			;;
			--clean-fap)
				_foo_suzuki_fap
				exit 0
			;;
			--clean-totp)
				_foo_suzuki_totp
				exit 0
			;;
			--cp-irdb)
				_foo_cp_irdb
				exit 0
			;;
			#--copy)
			#	info "Updating all..."
				#_foo_emoisemo
			#	_foo_lucaslhm
			#	_foo_uberguidoz
			#	info "Copying..."
			#	_foo_cp_irdb
			#	exit 0
			#;;
			--get-apps)
				_foo_get_apps
				exit 0
			;;
			--get-fw)
				_foo_get_ufw
				exit 0
			;;
			--new-fw)
				_foo_unzip_to_ext
				exit 0
			;;
			--copy-sd)
				warning "make sure it's Flipper formated, labeled FLIPPER SD and mounted!"
				printf "\n"
				_foo_deploy_to_sd
				pause
				if [ -n "$DIALOG" ] ; then
					dialog --colors --title " OK " --msgbox "\nHave a nice day! \Z3:)\Zn" 7 70
					clear
				else
					printf "\n"
					success "Have a nice day! ${yellow}:)${reset}"
				fi
				exit 0
			;;
			# --test)
			# 	exit 0
			# ;;
			#--update-all)
			#	info "Updating all..."
			#	#_foo_emoisemo
			#	_foo_lucaslhm
			#	_foo_uberguidoz
			#	exit 0
			#;;
			*)
				echo -e "\n$BGTITLE"
				echo -e "\nusage: \$$0 [command]\n"
				echo "Commands:"
				echo -e "\t--clean-fap \terase all your previous fap"
				echo -e "\t--clean-totp \terase all your previous totp plugins"
				echo -e "\t--new-fw \tcopy new firmware version from released zip files"
				echo -e "\t--copy-sd \tcopy files to sd card"
				echo -e "\t--get-fw \tdownload new firmware version zip files"
				echo -e "\t--get-apps \tdownload base and extra apps zip files"
				echo -e "\t--uberguidoz \clone UberGuidoZ repository (or update if present)"
				echo -e "\t--help \t(this screen)"
				echo -e "\t--about"
				exit 0
			;;
		esac
		shift 1
	done
fi

if [ "$MENU" = "no" ]; then
	exit 1
fi

# eof
