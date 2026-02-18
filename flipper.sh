#!/usr/bin/env bash

SCRIPT_VERSION=0.2.5
#DEBUG="yes"

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

# mostly stolen from alsa-info.sh and Kali Nethunter Kernel build.sh

# 0.1 0/0/2023 first commit
# 0.2 31/12/2025 most fully tested and working version (menu interface, welcome message and debug flag added)
# 0. //2026 firmware development functions implemented (--build)

WORKDIR="$HOME/Documents/Flipper"
FWDIR="$WORKDIR/fw"
EXTDIR="$WORKDIR/ext"
APDIR="$EXTDIR/apps"
APDDIR="$EXTDIR/apps_data"
BASEZFILE="all-the-apps-base.zip"
BASEFILEDIR="base_pack_build/artifacts-base"
EXTRAZFILE="all-the-apps-extra.zip"
EXTRAFILEDIR="extra_pack_build/artifacts-extra"
TOTPFILEDIR="base_pack_build/apps_data"
# Escape spaces in literals. Quote variables at expansion.
if [ -v DEBUG ] ; then
	SDDIR="$WORKDIR/FLIPPER SD"
else
	SDDIR="/run/media/numaflex/FLIPPER SD"
fi


#############################################
# ! - comment to skip FAP category entirely #
#############################################
BLDIR="Bluetooth"
GMDIR="Games"
GPDIR="GPIO"
IBDIR="iButton"
IRDIR="Infrared"
MDDIR="Media"
NFDIR="NFC"
RFDIR="RFID"
SBDIR="Sub-GHz"
TLDIR="Tools"
USDIR="USB"


#########################################################
# ! - EACH AND EVERY FAP SHOULD HAVE A NAME ENTRY BELOW #
#########################################################

#############
# Bluetooth #
#############
BLE_SPAM="ble_spam.fap"

#########
# Games #
#########
TAMA_P1="tama_p1.fap" # extra
SNAKE20="snake20.fap" # extra
T_REX_RUNNER="t_rex_runner.fap" # extra

########
# GPIO #
########
I2CTOOLS="i2ctools.fap"
LIGHTMETER="lightmeter.fap"
NRF24_MOUSE_JACKER="nrf24_mouse_jacker.fap"
NRF24_SNIFFER="nrf24_sniffer.fap"
SIGNAL_GENERATOR="signal_generator.fap"
SPI_MEM_MANAGER="spi_mem_manager.fap"
UART_TERMINAL="uart_terminal.fap"
UNITEMP="unitemp.fap"

###########
# iButton #
###########
FUZZER_IBTN="fuzzer_ibtn.fap"
IBUTTON_CONVERTER="ibutton_converter.fap"

############
# Infrared #
############
IR_SCOPE="ir_scope.fap"

#########
# Media #
#########
METRONOME="metronome.fap"
MORSE_CODE="morse_code.fap"
MUSIC_PLAYER="music_player.fap"
WAV_PLAYER="wav_player.fap"

#######
# NFC #
#######
MFC_EDITOR="mfc_editor.fap"
NFC_EINK="nfc_eink.fap"
NFC_MAGIC="nfc_magic.fap"
NFC_MAKER="nfc_maker.fap"
PICOPASS="picopass.fap"

########
# RFID #
########
FUZZER_RFID="fuzzer_rfid.fap"

###########
# Sub-GHz #
###########
FLIPPER_SHARE="flipper_share.fap"
#POCSAG_PAGER="pocsag_pager.fap"
RADIO_SCANNER="radio_scanner.fap"
SPECTRUM_ANALYZER="spectrum_analyzer.fap"
SUBGHZ_BRUTEFORCER="subghz_bruteforcer.fap"
SUBGHZ_PLAYLIST="subghz_playlist.fap"
SUBGHZ_SCHEDULER="subghz_scheduler.fap"
#WEATHER_STATION="weather_station.fap"

#########
# Tools #
#########
BARCODE_APP="barcode_app.fap"
DTMF_DOLPHIN="dtmf_dolphin.fap"
HEX_VIEWER="hex_viewer.fap"
MULTI_CONVERTER="multi_converter.fap"
NFC_RFID_DETECTOR="nfc_rfid_detector.fap"
QUAC="quac.fap"
TEXT_VIEWER="text_viewer.fap"
TOTP="totp.fap"
KEY_COPIER="key_copier.fap" # extra

#######
# USB #
#######
MASS_STORAGE="mass_storage.fap"

#########################################################
# ! - EACH AND EVERY FAP SHOULD HAVE A NAME ENTRY ABOVE #
#########################################################


# Move to the working dir
cd $WORKDIR || return 1

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
# Pause
function pause() {
	local message="$@"
	[ -z $message ] && message="Press [Enter] to continue.."
	read -p "$message" readEnterkey
}

function ask() {
    	# http://djm.me/ask
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

        	# Ask the question
        	question	
        	read -p "$1 [$prompt] " REPLY

        	# Default?
        	if [ -z "$REPLY" ]; then
        		REPLY=$default
        	fi

        	# Check if the reply is valid
        	case "$REPLY" in
        		Y*|y*) return 0 ;;
        		N*|n*) return 1 ;;
        	esac
    	done
}

function info() {
        printf "  ${lcyan}[i]${reset} $*${reset}\n"
}

function success() {
        printf " ${lgreen}[OK]${reset} $*${reset}\n"
}

function warning() {
        printf "  ${lyellow}[!]${reset} $*${reset}\n"
}

function error() {
        printf "  ${lmagenta}err0r${reset} $*${reset}\n"
}

function question() {
        printf "  ${blink_red}(?)${reset} "
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

function _tinker-toy() {
	echo -e "\n\t$BGTITLE${green}\n"
	echo -e "   o--o o                      o-o"
	echo -e "   |    | o                   o  /o"
	echo -e "   O-o  |   o-o  o-o  o-o o-o | / |"
	echo -e "   |    | | |  | |  | |-' |   o/  o"
	echo -e "   o    o | O-o  O-o  o-o o    o-o"
	echo -e "            |    |"
	echo -e "            o    o${reset}\n"
}

function _moscow() {
	echo -e "\n\t\t $BGTITLE${green}"
	echo -e "     #   ##### #   # ##### ##### ##### ####  ###"
	echo -e "    ###   #  # #  ## #   # #   # #     #   # # #"
	echo -e "   # # #  #  # # # # #   # #   # ####  ####  # #"
	echo -e "    ###   #  # ##  # #   # #   # #     #     # #"
	echo -e "     #   #   # #   # #   # #   # ##### #     ###${reset}\n"
}

function _dos-rebel() {
	echo -e "${green}"
	echo -e "    ███████████ ████   ███"
	echo -e "   ░░███░░░░░░█░░███  ░░░"
	echo -e "    ░███   █ ░  ░███  ████  ████████  ████████   ██████  ████████"
	echo -e "    ░███████    ░███ ░░███ ░░███░░███░░███░░███ ███░░███░░███░░███"
	echo -e "    ░███░░░█    ░███  ░███  ░███ ░███ ░███ ░███░███████  ░███ ░░░"
	echo -e "    ░███  ░     ░███  ░███  ░███ ░███ ░███ ░███░███░░░   ░███"
	echo -e "    █████       █████ █████ ░███████  ░███████ ░░██████  █████"
	echo -e "   ░░░░░       ░░░░░ ░░░░░  ░███░░░   ░███░░░   ░░░░░░  ░░░░░"
	echo -e "                            ░███      ░███"
	echo -e "                            █████     █████"
	echo -e "                           ░░░░░     ░░░░░${reset}"
	echo -e "\n\t\t\t\t\t$BGTITLE\n"
}

function _bloody() {
	echo -e "${green}"
	echo -e "     █████▒██▓     ██▓ ██▓███   ██▓███  ▓█████  ██▀███"
	echo -e "   ▓██   ▒▓██▒    ▓██▒▓██░  ██▒▓██░  ██▒▓█   ▀ ▓██ ▒ ██▒"
	echo -e "   ▒████ ░▒██░    ▒██▒▓██░ ██▓▒▓██░ ██▓▒▒███   ▓██ ░▄█ ▒"
	echo -e "   ░▓█▒  ░▒██░    ░██░▒██▄█▓▒ ▒▒██▄█▓▒ ▒▒▓█  ▄ ▒██▀▀█▄"
	echo -e "   ░▒█░   ░██████▒░██░▒██▒ ░  ░▒██▒ ░  ░░▒████▒░██▓ ▒██▒"
	echo -e "    ▒ ░   ░ ▒░▓  ░░▓  ▒▓▒░ ░  ░▒▓▒░ ░  ░░░ ▒░ ░░ ▒▓ ░▒▓░"
	echo -e "    ░     ░ ░ ▒  ░ ▒ ░░▒ ░     ░▒ ░      ░ ░  ░  ░▒ ░ ▒░"
	echo -e "    ░ ░     ░ ░    ▒ ░░░       ░░          ░     ░░   ░"
	echo -e "              ░  ░ ░                       ░  ░   ░${reset}"
	echo -e "\n\t\t\t\t$BGTITLE\n"
}

function _poison() {
	echo -e "${green}"
	echo -e "   @@@@@@@@  @@@       @@@  @@@@@@@   @@@@@@@   @@@@@@@@  @@@@@@@"
	echo -e "   @@@@@@@@  @@@       @@@  @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@@@@@@"
	echo -e "   @@!       @@!       @@!  @@!  @@@  @@!  @@@  @@!       @@!  @@@"
	echo -e "   !@!       !@!       !@!  !@!  @!@  !@!  @!@  !@!       !@!  @!@"
	echo -e "   @!!!:!    @!!       !!@  @!@@!@!   @!@@!@!   @!!!:!    @!@!!@!"
	echo -e "   !!!!!:    !!!       !!!  !!@!!!    !!@!!!    !!!!!:    !!@!@!"
	echo -e "   !!:       !!:       !!:  !!:       !!:       !!:       !!: :!!"
	echo -e "   :!:        :!:      :!:  :!:       :!:       :!:       :!:  !:!"
	echo -e "    ::        :: ::::   ::   ::        ::        :: ::::  ::   :::"
	echo -e "    :        : :: : :  :     :         :        : :: ::    :   : :${reset}\n"
	echo -e "\t\t\t\t\t$BGTITLE\n"
}

function _caligraphy2() {
	echo -e "\t\t\t\t\t\t$BGTITLE${green}"
	echo -e "        ##### ##   ###"
	echo -e "     ######  /### / ###    #"
	echo -e "    /#   /  /  ##/   ##   ###"
	echo -e "   /    /  /    #    ##    #"
	echo -e "       /  /          ##"
	echo -e "      ## ##          ##  ###        /###     /###     /##  ###  /###"
	echo -e "      ## ##          ##   ###      / ###  / / ###  / / ###  ###/ #### /"
	echo -e "      ## ######      ##    ##     /   ###/ /   ###/ /   ###  ##   ###/"
	echo -e "      ## #####       ##    ##    ##    ## ##    ## ##    ### ##"
	echo -e "      ## ##          ##    ##    ##    ## ##    ## ########  ##"
	echo -e "      #  ##          ##    ##    ##    ## ##    ## #######   ##"
	echo -e "         #           ##    ##    ##    ## ##    ## ##        ##"
	echo -e "     /####           ##    ##    ##    ## ##    ## ####    / ##"
	echo -e "    /  #####         ### / ### / #######  #######   ######/  ###"
	echo -e "   /    ###           ##/   ##/  ######   ######     #####    ###"
	echo -e "   #                             ##       ##"
	echo -e "    ##                           ##       ##"
	echo -e "                                 ##       ##"
	echo -e "                                  ##       ##${reset}\n"
}

function _splash() {
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
		6)
			_caligraphy2
			;;
		*)
			echo -e "\n$BGTITLE"
			;;
	esac
}

# Chaotic evil sign-off
function _signoff() {
	echo -e "\nciao."
}

#
# me·tic·u·lous·ly lock and unlock then performs full erase on device partitions
#
# i'm a good man and thorough
#

#
#function _dir_deploy() {
# make it check if dir exists if not crreate it
#}

# WHAT TO CLEAN
# - FLIPPER SD (debug dir - e posterior extract from zip)
# - ext backup (e posterior backup)
# - UberGuidoZ (repo)
#
# Erase all leftovers
function _cleanup() {
	printf "\n"

	info "cleaning..."

	if [ -v DEBUG ] ; then
		if [ -d "$SDDIR" ] ; then
			rm -Rf "$SDDIR" 2>/dev/null
		else
			printf "\n"

			error "$SDDIR ${red} not found!${reset}"
			exit 1
		fi
	fi
}

function _foo_suzuki() {
	find . -name "*.py" -type f -delete
	find . -name "*.docx" -type f -delete
	find . -name "*.jp*" -type f -delete
	find . -name "*.png" -type f -delete
	find . -name "*.md" -type f -delete
	find . -name "*.json" -type f -delete
	rm -Rfv _Converted_
	rm -Rfv .git*
}


function _foo_suzuki_irdb() {
	cd "$EXTDIR/subghz" || return 1
	find . -name "*.md" -type f -delete
	find . -name "*.pdf" -type f -delete
	find . -name "*.jp*" -type f -delete
	find . -name "*.png" -type f -delete
}

function _foo_suzuki_subghz() {
	cd "$EXTDIR/infrared/IRDB" || return 1
	find . -name "*.jp*" -type f -delete
	find . -name "*.png" -type f -delete
	find . -name "*.md" -type f -delete
	find . -name "*.json" -type f -delete
	rm -Rfv _Converted_
	rm -Rfv .git*
	find . -name "*.zip" -type f -delete
	find . -name "*.wav" -type f -delete
	find . -name "*.*16*" -type f -delete
	find . -name "*.pdf" -type f -delete
	find . -name "*.raw" -type f -delete
	find . -name "*.py*" -type f -delete
	find . -name "*.sh" -type f -delete
	find . -name "*.yml" -type f -delete
	find . -name "*.css" -type f -delete
	find . -name "*.html" -type f -delete
	find . -name "*.git" -type f -delete
	find . -name "*.cu8" -type f -delete
	find . -name "*.txt" -type f -delete
	find . -name "*.mp4" -type f -delete
	find . -name "*.mov" -type f -delete
}

function _foo_suzuki_fap() {
	cd "$APDIR" || return 1
	warning "this will erase all your previous fap"
	if ask "are you sure?" Y; then
		printf "\n"
		info "cleaning old fap files"
		find . -name "*.fap" -type f -delete
		success "done"
	fi
}

function _foo_suzuki_totp() {
	cd "$APDDIR/totp/plugins" || return 1
	warning "this will erase all your previous totp plugins"
	if ask "are you sure?" Y; then
		printf "\n"
		info "cleaning old totp plugins"
		find . -name "*.fal" -type f -delete
		success "done"
	fi
}

function _foo_suzuki_amiibo() {
	find . -name "*.py" -type f -delete
	find . -name "*.docx" -type f -delete
}


##########################################################
# ! - EACH AND EVERY FAP SHOULD HAVE A UNZIP ENTRY BELOW #
##########################################################

#############
# Bluetooth #
#############
# BLE_SPAM
function _foo_cp_ble_spam_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$BLDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$BLDIR/$BLE_SPAM -d $APDIR/$BLDIR
	fi
}


#########
# Games #
#########
# TAMA_P1
function _foo_cp_tama_p1_fap() {
	if [[ -f "$FWDIR/$EXTRAZFILE" && -d "$APDIR/$GMDIR" ]] ; then
		#unzip -o -j $WORKDIR/fw/all-the-apps-extra.zip extra_pack_build/artifacts-extra/Games/tama_p1.fap -d $WORKDIR/ext/apps/Games/
		unzip -o -j $FWDIR/$EXTRAZFILE $EXTRAFILEDIR/$GMDIR/$TAMA_P1 -d $APDIR/$GMDIR
	fi
}

# SNAKE20
function _foo_cp_snake20_fap() {
	if [[ -f "$FWDIR/$EXTRAZFILE" && -d "$APDIR/$GMDIR" ]] ; then
		unzip -o -j $FWDIR/$EXTRAZFILE $EXTRAFILEDIR/$GMDIR/$SNAKE20 -d $APDIR/$GMDIR
	fi
}

# T_REX_RUNNER
function _foo_cp_t_rex_runner_fap() {
	if [[ -f "$FWDIR/$EXTRAZFILE" && -d "$APDIR/$GMDIR" ]] ; then
		unzip -o -j $FWDIR/$EXTRAZFILE $EXTRAFILEDIR/$GMDIR/$T_REX_RUNNER -d $APDIR/$GMDIR
	fi
}


########
# GPIO #
########
# I2CTOOLS
function _foo_cp_i2ctools_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$GPDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$GPDIR/$I2CTOOLS -d $APDIR/$GPDIR
	fi
}

# LIGHTMETER
function _foo_cp_lightmeter_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$GPDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$GPDIR/$LIGHTMETER -d $APDIR/$GPDIR
	fi
}

# NRF24_MOUSE_JACKER
function _foo_cp_nrf24_mouse_jacker_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$GPDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$GPDIR/$NRF24_MOUSE_JACKER -d $APDIR/$GPDIR
	fi
}

# NRF24_SNIFFER
function _foo_cp_nrf24_sniffer_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$GPDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$GPDIR/$NRF24_SNIFFER -d $APDIR/$GPDIR
	fi
}

# SIGNAL_GENERATOR
function _foo_cp_signal_generator_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$GPDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$GPDIR/$SIGNAL_GENERATOR -d $APDIR/$GPDIR
	fi
}

# SPI_MEM_MANAGER
function _foo_cp_spi_mem_manager_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$GPDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$GPDIR/$SPI_MEM_MANAGER -d $APDIR/$GPDIR
	fi
}

# UART_TERMINAL
function _foo_cp_uart_terminal_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$GPDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$GPDIR/$UART_TERMINAL -d $APDIR/$GPDIR
	fi
}

# UNITEMP
function _foo_cp_unitemp_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$GPDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$GPDIR/$UNITEMP -d $APDIR/$GPDIR
	fi
}


###########
# iButton #
###########
# FUZZER_IBTN
function _foo_cp_fuzzer_ibtn_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$IBDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$IBDIR/$FUZZER_IBTN -d $APDIR/$IBDIR
	fi
}

# IBUTTON_CONVERTER
function _foo_cp_ibutton_converter_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$IBDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$IBDIR/$IBUTTON_CONVERTER -d $APDIR/$IBDIR
	fi
}


############
# Infrared #
############
# IR_SCOPE
function _foo_cp_ir_scope_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$IRDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$IRDIR/$IR_SCOPE -d $APDIR/$IRDIR
	fi
}


#########
# Media #
#########
# METRONOME
function _foo_cp_metronome_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$MDDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$MDDIR/$METRONOME -d $APDIR/$MDDIR
	fi
}

# MORSE_CODE
function _foo_cp_morse_code_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$MDDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$MDDIR/$MORSE_CODE -d $APDIR/$MDDIR
	fi
}

# MUSIC_PLAYER
function _foo_cp_music_player_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$MDDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$MDDIR/$MUSIC_PLAYER -d $APDIR/$MDDIR
	fi
}

# WAV_PLAYER
function _foo_cp_wav_player_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$MDDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$MDDIR/$WAV_PLAYER -d $APDIR/$MDDIR
	fi
}


#######
# NFC #
#######
# MFC_EDITOR
function _foo_cp_mfc_editor_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$NFDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$NFDIR/$MFC_EDITOR -d $APDIR/$NFDIR
	fi
}

# NFC_EINK
function _foo_cp_nfc_eink_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$NFDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$NFDIR/$NFC_EINK -d $APDIR/$NFDIR
	fi
}

# NFC_MAGIC
function _foo_cp_nfc_magic_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$NFDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$NFDIR/$NFC_MAGIC -d $APDIR/$NFDIR
	fi
}

# NFC_MAKER
function _foo_cp_nfc_maker_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$NFDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$NFDIR/$NFC_MAKER -d $APDIR/$NFDIR
	fi
}

# PICOPASS
function _foo_cp_picopass_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$NFDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$NFDIR/$PICOPASS -d $APDIR/$NFDIR
	fi
}

########
# RFID #
########
# FUZZER_RFID
function _foo_cp_fuzzer_rfid_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$RFDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$RFDIR/$FUZZER_RFID -d $APDIR/$RFDIR
	fi
}

###########
# Sub-GHz #
###########
# FLIPPER_SHARE
function _foo_cp_flipper_share_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$SBDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$SBDIR/$FLIPPER_SHARE -d $APDIR/$SBDIR
	fi
}

# POCSAG_PAGER
function _foo_cp_pocsag_pager_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$SBDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$SBDIR/$POCSAG_PAGER -d $APDIR/$SBDIR
		# also copy additional settings at /pocsag
	fi
}

# RADIO_SCANNER
function _foo_cp_radio_scanner_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$SBDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$SBDIR/$RADIO_SCANNER -d $APDIR/$SBDIR
	fi
}

# SPECTRUM_ANALYZER
function _foo_cp_spectrum_analyzer_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$SBDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$SBDIR/$SPECTRUM_ANALYZER -d $APDIR/$SBDIR
	fi
}

# SUBGHZ_BRUTEFORCER
function _foo_cp_subghz_bruteforcer_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$SBDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$SBDIR/$SUBGHZ_BRUTEFORCER -d $APDIR/$SBDIR
	fi
}

# SUBGHZ_PLAYLIST
function _foo_cp_subghz_playlist_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$SBDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$SBDIR/$SUBGHZ_PLAYLIST -d $APDIR/$SBDIR
	fi
}

# SUBGHZ_SCHEDULER
function _foo_cp_subghz_scheduler_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$SBDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$SBDIR/$SUBGHZ_SCHEDULER -d $APDIR/$SBDIR
	fi
}

# WEATHER_STATION
function _foo_cp_weather_station_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$SBDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$SBDIR/$WEATHER_STATION -d $APDIR/$SBDIR
	fi
}


#########
# Tools #
#########
# BARCODE_APP
function _foo_cp_barcode_app_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$TLDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$TLDIR/$BARCODE_APP -d $APDIR/$TLDIR
	fi
}

# DTMF_DOLPHIN
function _foo_cp_dtmf_dolphin_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$TLDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$TLDIR/$DTMF_DOLPHIN -d $APDIR/$TLDIR
	fi
}

# HEX_VIEWER
function _foo_cp_hex_viewer_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$TLDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$TLDIR/$HEX_VIEWER -d $APDIR/$TLDIR
	fi
}

# MULTI_CONVERTER
function _foo_cp_multi_converter_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$TLDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$TLDIR/$MULTI_CONVERTER -d $APDIR/$TLDIR
	fi
}

# NFC_RFID_DETECTOR
function _foo_cp_nfc_rfid_detector_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$TLDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$TLDIR/$NFC_RFID_DETECTOR -d $APDIR/$TLDIR
	fi
}

# QUAC
function _foo_cp_quac_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$TLDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$TLDIR/$QUAC -d $APDIR/$TLDIR
	fi
}

# TEXT_VIEWER
function _foo_cp_text_viewer_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$TLDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$TLDIR/$TEXT_VIEWER -d $APDIR/$TLDIR
	fi
}

# KEY_COPIER
function _foo_cp_key_copier_fap() {
	if [[ -f "$FWDIR/$EXTRAZFILE" && -d "$APDIR/$TLDIR" ]] ; then
		unzip -o -j $FWDIR/$EXTRAZFILE $EXTRAFILEDIR/$TLDIR/$KEY_COPIER -d $APDIR/$TLDIR
	fi
}

# TOTP
function _foo_cp_totp_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$TLDIR" && -d "$APDDIR/totp/plugins" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$TLDIR/$TOTP -d $APDIR/$TLDIR
		printf "\n"
		unzip -o -j $FWDIR/$BASEZFILE $TOTPFILEDIR/totp/plugins/* -d $APDDIR/totp/plugins
	fi
}


#######
# USB #
#######
# MASS_STORAGE
function _foo_cp_mass_storage_fap() {
	if [[ -f "$FWDIR/$BASEZFILE" && -d "$APDIR/$USDIR" ]] ; then
		unzip -o -j $FWDIR/$BASEZFILE $BASEFILEDIR/$USDIR/$MASS_STORAGE -d $APDIR/$USDIR
	fi
}

##########################################################
# ! - EACH AND EVERY FAP SHOULD HAVE A UNZIP ENTRY ABOVE #
##########################################################


#########################################################
# ! - EACH AND EVERY FAP SHOULD HAVE A COPY ENTRY BELOW #
#########################################################
function _foo_unzip_to_ext() {
	# check if dir is not empty
	_foo_suzuki_fap
	printf "\n"

	# check if dir is empty
	_foo_suzuki_totp
	printf "\n"

	warning "this will copy new firmware version from released zip files"
	printf "\n"
	if ask "ready to extract Flipper Application Files (FAPs)?" Y; then
		printf "\n"
		info "extracting Flipper Application Files (FAPs)"
		#############
		# Bluetooth #
		#############
		if [ -v BLDIR ] ; then
			for fapname in BLE_SPAM; do
				if [ -v ${fapname} ] ; then
					_foo_cp_${fapname,,}_fap
				fi
			done
			printf "\n"
		fi

		#########
		# Games #
		#########
		if [ -v GMDIR ] ; then
			for fapname in TAMA_P1 SNAKE20 T_REX_RUNNER; do
				if [ -v ${fapname} ] ; then
					_foo_cp_${fapname,,}_fap
				fi
			done
			printf "\n"
		fi

		########
		# GPIO #
		########
		if [ -v GPDIR ] ; then
			for fapname in I2CTOOLS LIGHTMETER NRF24_MOUSE_JACKER NRF24_SNIFFER SIGNAL_GENERATOR SPI_MEM_MANAGER UART_TERMINAL UNITEMP; do
				if [ -v ${fapname} ] ; then
					_foo_cp_${fapname,,}_fap
				fi
			done
			printf "\n"
		fi

		###########
		# iButton #
		###########
		if [ -v IBDIR ] ; then
			for fapname in FUZZER_IBTN IBUTTON_CONVERTER; do
				if [ -v ${fapname} ] ; then
					_foo_cp_${fapname,,}_fap
				fi
			done
			printf "\n"
		fi

		############
		# Infrared #
		############
		if [ -v IRDIR ] ; then
			for fapname in IR_SCOPE; do
				if [ -v ${fapname} ] ; then
					_foo_cp_${fapname,,}_fap
				fi
			done
			printf "\n"
		fi

		#########
		# Media #
		#########
		if [ -v MDDIR ] ; then
			for fapname in METRONOME MORSE_CODE MUSIC_PLAYER WAV_PLAYER; do
				if [ -v ${fapname} ] ; then
					_foo_cp_${fapname,,}_fap
				fi
			done
			printf "\n"
		fi

		#######
		# NFC #
		#######
		if [ -v NFDIR ] ; then
			for fapname in MFC_EDITOR NFC_EINK NFC_MAGIC NFC_MAKER PICOPASS; do
				if [ -v ${fapname} ] ; then
					_foo_cp_${fapname,,}_fap
				fi
			done
			printf "\n"
		fi

		########
		# RFID #
		########
		if [ -v RFDIR ] ; then
			for fapname in FUZZER_RFID; do
				if [ -v ${fapname} ] ; then
					_foo_cp_${fapname,,}_fap
				fi
			done
			printf "\n"
		fi

		###########
		# Sub-GHz #
		###########
		if [ -v SBDIR ] ; then
			for fapname in FLIPPER_SHARE POCSAG_PAGER RADIO_SCANNER SPECTRUM_ANALYZER SUBGHZ_BRUTEFORCER SUBGHZ_PLAYLIST SUBGHZ_SCHEDULER WEATHER_STATION; do
				if [ -v ${fapname} ] ; then
					_foo_cp_${fapname,,}_fap
				fi
			done
			printf "\n"
		fi

		#########
		# Tools #
		#########
		if [ -v TLDIR ] ; then
			for fapname in BARCODE_APP DTMF_DOLPHIN HEX_VIEWER MULTI_CONVERTER NFC_RFID_DETECTOR QUAC TEXT_VIEWER KEY_COPIER TOTP; do
				if [ -v ${fapname} ] ; then
					_foo_cp_${fapname,,}_fap
				fi
			done
			printf "\n"
		fi

		#######
		# USB #
		#######
		if [ -v USDIR ] ; then
			for fapname in MASS_STORAGE; do
				if [ -v ${fapname} ] ; then
					_foo_cp_${fapname,,}_fap
				fi
			done
			printf "\n"
		fi

		success "done extracting Flipper Application Files (FAPs)"
	fi
}
#########################################################
# ! - EACH AND EVERY FAP SHOULD HAVE A COPY ENTRY ABOVE #
#########################################################

# deploy to sdcard
function _foo_deploy_to_sd() {
	warning "this will transfer files to your sd card (make sure it's mounted)"

	printf "\n"
	# check for destination dir
	if [ -d "$SDDIR" ] ; then
		if ask "ready to copy Flipper Application Files (FAPs)?" Y; then
			printf "\n"
			info "copying FAPs"
			# copy whole local ext structure to sd card
			for fapcat in ${BLDIR} ${GMDIR} ${GPDIR} ${IBDIR} ${IRDIR} ${NFDIR} ${RFDIR} ${SBDIR} ${TLDIR} ${USDIR}; do
				# check for fap category, source and destination and if there's content
				if [[ -d "$EXTDIR/apps/${fapcat}" && -d "$SDDIR/apps/${fapcat}" ]] \
				   && find "$EXTDIR/apps/${fapcat}" -mindepth 1 -type f -print -quit | read -r _; then
					printf "\n"
					warning "copying ${fapcat} FAPs"
					# Erro lógico: glob dentro de aspas
					cp -Rfv "$EXTDIR/apps/${fapcat}/"* "$SDDIR/apps/${fapcat}/"
					success "done copying ${fapcat} FAPs"
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
		if ask "ready to copy additional files?" Y; then
			printf "\n"
			info "copying additional files"
			# copy all files
			for addfil in badusb infrared music_player nfc subghz subplaylist; do
				if [[ -d "$EXTDIR/${addfil}" && -d "$SDDIR/${addfil}" ]] \
				   && find "$EXTDIR/${addfil}" -mindepth 1 -type f -print -quit | read -r _; then
					printf "\n"
					info "copying ${addfil} files"
					# Erro lógico: glob dentro de aspas
					cp -Rfv "$EXTDIR/${addfil}/"* "$SDDIR/${addfil}/"
					success "done copying ${addfil} files"
				fi
			done

			# copy whole dir
			for adddir in subghz_remote; do
				if [[ -d "$EXTDIR/${adddir}" && -d "$SDDIR" ]] \
				   && find "$EXTDIR/${adddir}" -mindepth 1 -type f -print -quit | read -r _; then
					printf "\n"
					info "copying ${adddir} dir"
					cp -Rfv "$EXTDIR/${adddir}" "$SDDIR/"
					success "done copying ${adddir} dir"
				fi
			done
			printf "\n"
			success "done copying additional files"
		fi

		# check for fap
		if [ -v POCSAG_PAGER ] ; then
			for pocsagdir in pocsag; do
				if [[ -d "$EXTDIR/${pocsagdir}" && -d "$SDDIR" ]] \
				   && find "$EXTDIR/${pocsagdir}" -mindepth 1 -type f -print -quit | read -r _; then
					printf "\n"
					info "copying ${pocsagdir} dir"
					cp -Rfv "$EXTDIR/${pocsagdir}" "$SDDIR/"
					success "done copying ${pocsagdir} dir"
				fi
			done
		fi

		# check for fap
		if [ -v TAMA_P1 ] ; then
			for tamadir in tama_p1; do
				if [[ -d "$EXTDIR/${tamadir}" && -d "$SDDIR" ]] \
				   && find "$EXTDIR/${tamadir}" -mindepth 1 -type f -print -quit | read -r _; then
					printf "\n"
					info "copying ${tamadir} dir"
					cp -Rfv "$EXTDIR/${tamadir}" "$SDDIR/"
					success "done copying ${tamadir} dir"
				fi
			done
		fi

		# check for fap
		if [ -v TOTP ] ; then
			for totpdir in totp; do
				if [[ -d "$APDDIR/$totpdir/plugins" && -d "$SDDIR/apps_data" ]] \
				   && find "$APDDIR/${totpdir}/plugins" -mindepth 1 -type f -print -quit | read -r _; then
					printf "\n"
					info "copying ${totpdir} dir"
					cp -Rfv "$APDDIR/${totpdir}" "$SDDIR/apps_data/"
					success "done copying ${totpdir} dir"
				fi
			done
		fi
	else
		printf "\n"

		error "$SDDIR ${red} not found!${reset}"
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
			warning "this will erase all your previous $IRDIR files"
			if ask "are you sure?" Y; then
				info "erasing old $IRDIR files"
				rm -Rfv "$WORKDIR/ext/infrared/IRDB"
				success "done erasing $IRDIR files"

				printf "\n"
				info "copying new $IRDIR files"
				cp -Rfv "$UWORKDIR/Infrared/IRDB" "$EXTDIR/infrared/IRDB"
				success "done copying $IRDIR files"

				printf "\n"
				info "cleaning $IRDIR repo"
				_foo_suzuki_irdb
				success "done cleaning $IRDIR repo"
			fi
		fi
	else
		printf "\n"

		error "$UWORKDIR ${red} not found!${reset}"
		exit 1
	fi
}

function _foo_download_fw() {
	info "$version"
	for build in "" c e; do
		printf "\n"
		info "Downloading flipper-z-f7-update-$version${build}.tgz" 
		curl -fL --progress-bar -O \
		"$base/releases/download/$version/flipper-z-f7-update-$version${build}.tgz" \
		-w "\n%{size_download} bytes em %{time_total}s\n"
		success "Done downloading flipper-z-f7-update-$version${build}.tgz"
	done
}

function _foo_download_apps() {
	#wget "$base/releases/download/$tag/all-the-apps-base.zip"
	#wget "$base/releases/download/$tag/all-the-apps-extra.zip"
	info "$tag"
	for pack in base extra; do
		printf "\n"
		info "Downloading all-the-apps-${pack}.zip" 
		curl -fL --progress-bar -O \
		"$base/releases/download/$tag/all-the-apps-${pack}.zip" \
		-w "\n%{size_download} bytes em %{time_total}s\n"
		success "Done downloading all-the-apps-${pack}.zip"
	done
}

function _foo_get_fw() {
	#https://github.com/DarkFlippers/unleashed-firmware/releases/latest
	#https://github.com/DarkFlippers/unleashed-firmware/releases/tag/unlshd-084
	local base="https://github.com/DarkFlippers/unleashed-firmware"
	local tag version

	tag=$(curl -Ls -o /dev/null -w '%{url_effective}' "$base/releases/latest")
	version="${tag##*/}" # unlshd-084

	if [[ -f "$FWDIR/flipper-z-f7-update-$version.tgz" || -f "$FWDIR/flipper-z-f7-update-${version}c.tgz" || -f "$FWDIR/flipper-z-f7-update-${version}e.tgz" ]] ; then
		printf "\n"
		warning "local fw files found"
		printf "\n"
		if ask "do you want to download fw files again?" N; then
			cd $FWDIR || return 1
			printf "\n"
			warning "erasing local files"
			# ask me if im sure whatever
			rm -Rfv "flipper-z-f7-update-${version}"* # globs lol
			printf "\n"
			_foo_download_fw
		fi
	else
		cd $FWDIR || return 1
		_foo_download_fw
	fi
}

function _foo_get_apps() {
	local base="https://github.com/xMasterX/all-the-plugins"
	local tag

	tag=$(curl -Ls -o /dev/null -w '%{url_effective}' "$base/releases/latest")
	tag="${tag##*/}"

	if [[ -f "$FWDIR/all-the-apps-base.zip" || -f "$FWDIR/all-the-apps-extra.zip" ]] ; then
		printf "\n"
		warning "local apps zip files found"
		printf "\n"
		if ask "do you want to download apps zip files again?" N; then
			cd $FWDIR || return 1
			printf "\n"
			warning "erasing local files"
			rm -Rfv "all-the-apps"* # globs lol
			printf "\n"
			_foo_download_apps
		fi
	else
		cd $FWDIR || return 1
		_foo_download_apps
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
		--about|--help|--emoisemo|--lucaslhm|--uberguidoz|--clean-fap|--clean-totp|--copy|--cp-irdb|--get-apps|--get-fw|--new-fw|--copy-sd|--test|--update-all)
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

	  This can download fw and apps from the internet
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
				_foo_get_fw
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
				echo -e "\n$BGTITLE"
				echo -e "Copyright (C) 2016 Free Software Foundation, Inc."
				echo -e "\nThis is free software; see the source for copying conditions. There is NO"
				echo -e "warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE."
				echo -e "\n(c) 2023 - Written/Tested by ${blink_red}NUMAflex${reset}"
				echo -e "\t\tfor Flipper Zero"
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
				_foo_get_fw
				exit 0
			;;
			--new-fw)
				_foo_unzip_to_ext
				exit 0
			;;
			--copy-sd)
				_foo_deploy_to_sd
				exit 0
			;;
			--test)
				echo "$HOME"
				exit 0
			;;
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