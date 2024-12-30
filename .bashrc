#!/bin/bash

# Greg Conan's .bashrc startup script for login shells
# Updated 2024-12-30

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Shortcut functions

begin() {
	# Set your umask.
	# umask 077     # -- private, only you have access to your files
	# umask 022     # -- anyone can read and execute your files
	# umask 027     # -- only members of your group can read/execute your files
	umask 002       # -- members of my group can read/write/execute my files

	# Set the prompt.
	PS1="\u@\h [\w] % "

	# Uncomment the if statement below to enable bash completion.
	# if [ -f /etc/bash_completion ]; then
	#  source /etc/bash_completion
	# fi

	export HISTORY_FILE="${HOME}/.history.txt" # Store command history here for recall function
	export USERNAME="${USERNAME:-${USER}}"     # Make $USER interchangeable with $USERNAME
	export XAUTHORITY="${HOME}/.Xauthority";

	# My shortcut/convenience aliases
	alias l="ls -A --color=always";
	alias ll="ls -alF --color=always";

	# Remove default aliases so I can overwrite them with my own preferred aliases
	unalias lll 2>/dev/null;
	# unalias python3 2>/dev/null;

	# Add an "alert" alias for long running commands.  Use like so:
	#   sleep 10; alert
	alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

	# Other alias definitions
	# You may want to put all your additions into a separate file like
	# ~/.bash_aliases, instead of adding them here directly.
	# See /usr/share/doc/bash-doc/examples in the bash-doc package.
	if [ -f ~/.bash_aliases ]; then
	    . ~/.bash_aliases
	fi
}

beginCisco() {
	beginWSL;

	# don't put duplicate lines in the history. See bash(1) for more options
	# ... or force ignoredups and ignorespace
	# HISTCONTROL=  #ignoredups:ignorespace

	# append to the history file, don't overwrite it
	# shopt -s histappend

	# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
	# HISTSIZE=5000
	# HISTFILESIZE=10000000

	# Path to file to store history in 
	# HISTORY_FILE="/home/${USERNAME}/.history.txt";

	# check the window size after each command and, if necessary,
	# update the values of LINES and COLUMNS.
	# shopt -s checkwinsize

	# If set, the pattern "**" used in a pathname expansion context will
	# match all files and zero or more directories and subdirectories.
	# shopt -s globstar

	# make less more friendly for non-text input files, see lesspipe(1)
	# [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

	# set variable identifying the chroot you work in (used in the prompt below)
	# if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	# 	debian_chroot=$(cat /etc/debian_chroot)
	# fi

	# Activate conda environment
	initconda data-broker;

	# Enable online access through Cisco VPN Tunnel
	# frakkingsweet.com/automatic-dns-configuration-with-wsl-and-anyconnect-client
	# frakkingsweet.com/work-around-for-anyconnect-client-and-windows-subsystem-for-linux-2
	if vpn_is_offline; then
		echo "Warning: Please enable Cisco VPN, and then use /bin/vpn-dns.sh to access the web from this terminal.";
	elif ! i_am_online; then
		echo "Connecting to the web through Cisco VPN..."
		sudo chmod 777 /mnt/wsl/resolv.conf;
		sudo /bin/vpn-dns.sh;
		wudo /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command 'Get-NetAdapter | Where-Object {$_.InterfaceDescription -like "*Cisco*" } |Set-NetIPInterface -InterfaceMetric 6000';
	fi
}

beginVM(){
	if ! i_am_online; then
		sudo bash -c 'if [ "$(cat /etc/resolv.conf | grep 8.8.8.8)" = "" ]; then echo "
nameserver 8.8.8.8" >> /etc/resolv.conf; fi; if [ "$(cat /etc/resolv.conf | grep 75.75.75.75)" = "" ]; then echo "
nameserver 75.75.75.75" >> /etc/resolv.conf; fi';
	fi
	# initconda data-broker
}

beginWSL() {
	begin;
	enable_terminal_colors;

	# Using WSL 2? Then use this
	current_ip="$(myip)"
	export DISPLAY="${current_ip}:0"

	# If the wrong "date" function (without sub-second precison) is installed, then install the correct one
	if is_valid_whole_number $(trim_zeroes $(date +"%s.%N")); then
		echo "Reinstalling coreutils to give the date command sub-second precision.";
		apt-get install coreutils;
	fi

	export MSYS_NO_PATHCONV=1;

        # Constants: Paths to utilities used by multiple functions
	alias cmd="cmd.exe";
	alias slurm="slurmd";
	alias read_dir="~/read_dir.pl"

	# Conda constants
	export CONDA_DIR="/home/${USERNAME}/miniconda3";  # "/mnt/c/ProgramData/miniconda3";
	export CONDABIN="${CONDA_DIR}/condabin";
	export CONDA="${CONDABIN}/conda.bat";
	# alias conda="${CONDA}";  # "/mnt/c/ProgramData/miniconda3/_conda.exe";

	# Define path to utilities/etc. 
	export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/wsl/lib:/mnt/c/Users/${USERNAME}/AppData/Local/Temp/Mxt230/bin:/mnt/c/Windows/:/mnt/c/Windows/system32/:/mnt/c/Windows/system32:/mnt/c/Windows:/mnt/c/Windows/System32/Wbem:/mnt/c/Windows/System32/WindowsPowerShell/v1.0/:/home/${USERNAME}/.local/bin/:/home/${USERNAME}/.local/pipx/:${CONDABIN}/:/home/${USERNAME}/miniconda3/:/home/${USERNAME}/miniconda3/bin/:/mnt/c/Users/${USERNAME}/AppData/Local/Microsoft/WindowsApps:/mnt/c/Users/${USERNAME}/AppData/Local/Programs/'Microsoft VS Code'/bin:/mnt/c/Windows/sysnative/:/snap/bin:/mnt/c/Users/${USERNAME}/AppData/Local/Temp/Mxt230/bin/:/mnt/c/'Program Files (x86)'/'Unix Tools'/bin/:/mnt/c/'Program Files'/PostgreSQL/14/bin;

	# My shortcut/convenience aliases
	alias clip="clip.exe";
	alias wudo="python /mnt/c/Users/${USERNAME}/OneDrive/Documents/wsl-sudo/wsl-sudo.py";

	# Finish pipx setup
	eval "$(register-python-argcomplete3 pipx)";

	# Other env vars
	export USERPROFILE="/home/${USERNAME}";

}

condense_file() {  # Convert an entire file's worth of code into one line
	# Variables depending on file type (language): comment delimiters
	local delim_long_start;
	local delim_long_end;

	# Default values for input arguments
	local output_file='; ';  # -o
	local input_file="";    # -f

	# File extensions of all file types this function can support
	local valid_exts=("js" "py");

	# Help/usage message to explain this function to the user
	local help_msg="Usage: condense_file -f FILE_PATH [-o OUTPUT_CODE_DELIMITER] [-i INPUT_COMMENT_DELIMITER]
Convert an entire file's worth of code into one line.
Required Paths:
	-i, -in, --input-file:   Valid path to a file to read code from. File extensions currently supported include: ${valid_exts[@]}
	-o, -out, --output-file: Valid path to a file to write code to.
";

	# If user gave no input arguments, then show the help message and exit
	if [ ${#} -eq 0 ]; then
		echo "${help_msg}";
		return 1;
	fi

	# Otherwise, collect and organize all input arguments
	while [ "${1}" != "" ]; do
		case ${1} in
			-i | -in | --input-file)
				shift
				input_file="${1}"
				;;
			-o | -out | --output-file) 
				shift
				output_file="${1}"
				;;
			-h | --help)
				echo "${help_msg}";
				return 0
				;;
			*)
				echo "${1} is not a valid argument for this function";
		esac
		shift
	done

	# Validate that $input_file exists and is readable
	if [ ! -f "${input_file}" ]; then
		echo "Error: No file found at ${input_file}" 1>&2; # >> /dev/stderr;
		return 1;
	else  # TODO verify that output_file value is writeable
		# Read input file and remove any lines with only whitespace
		local file_contents="$(cat ${input_file} | grep -v '^\s*$')";
	fi

	# Clear output file
	truncate -s 0 $output_file;

	# Set/validate comment delimiters
	if [[ ${input_file} = *".js" ]]; then
		delim_long_start="/*";
		delim_long_end="*/";
	elif [[ ${input_file} = *".py" ]]; then
		delim_long_start="\"\"\"";           # TODO Account for the fact that triple quotes are just long strings
		delim_long_end="$delim_long_start";  # TODO Also, account for """ and ''' both working as multiline comment delimiters
	else 
		echo "File type must be '.py' or '.js'.";
		return 1;
	fi

	# Add each nonempty line of $input_file, minus its comments,
	# to the end of a string
	local fullstr="";
	local in_multi_line_comment=false; 
	while read -r line; do
		local line_so_far="$(trim_whitespace_from "${line}")"
		if [ "${line_so_far}" != "" ]; then

			# Ignore everything before the end of a multiline comment
			if $in_multi_line_comment; then
				local before_long_delim="${line_so_far%"${delim_long_end}"*}";
				if [ "${before_long_delim}" != "${line_so_far}" ]; then
					in_multi_line_comment=false;
					line_so_far="${line_so_far##*"${delim_long_end}"}";
				else 
					line_so_far="";
				fi
			else
				# Remove inline comment delimiter
				line_so_far="$(remove_inline_JS_comment_from "${line_so_far}")";  # TODO make it work for python too
				line_so_far="$(trim_whitespace_from "${line_so_far}")";
				if [ "${line_so_far}" != "" ]; then

					# Ignore everything after the beginning of a multiline comment
					local after_long_delim="${line_so_far#*"${delim_long_start}"}";
					if [ "${after_long_delim}" != "${line_so_far}" ]; then
						in_multi_line_comment=true;
						line_so_far="${line_so_far%%"${delim_long_start}"*}";
					fi
				fi
			fi
			if [ "${line_so_far}" != "" ]; then
				fullstr="${fullstr} $(trim_whitespace_from "${line_so_far}")";
			fi
		fi
	done < ${input_file}

	# Write the now-condensed string to the output file
	echo "${fullstr}" > ${output_file};
	echo "Condensed contents of ${input_file} and wrote them to ${output_file} as one line.";
}

remove_inline_JS_comment_from() {
	
	local delim="//";
	local line=$(trim_whitespace_from "${@}");

	# Remove inline comment delimiter
	local before_1st_delim="${line%%${delim}*}";
	# echo "Before: ${before_1st_delim}";

	# Account for properly-escaped comment-delimiter inside of string
	if [[ ! -z "$(trim_whitespace_from "${before_1st_delim}")" ]]; then
		if [[ "${line}" != "${before_1st_delim}" ]]; then
			local after_1st_delim="${line#*${delim}}";
			# echo "After: ${after_1st_delim}";

			local inside_1quote=false;  # not inside of a single-quoted string yet
			local inside_2quote=false;  # not inside of a double-quoted string yet
			local escaped=false;        # proceeding character is not escaped yet
			while read -N1 character; do
				case ${character} in
					"\\")
						if $escaped; then 
							escaped=false;
						else
							escaped=true;
						fi
						;;  # Escape character means that we ignore what's next
					'"')
						if ! $escaped && ! $inside_1quote; then
							if $inside_2quote; then
								inside_2quote=false;
							else
								inside_2quote=true;
							fi
						fi  # Open or close DOUBLE-quoted string on finding a 
						;;  # non-escaped double-quote character
					"'")
						if ! $escaped && ! $inside_2quote; then
							if $inside_1quote; then
								inside_1quote=false;
							else
								inside_1quote=true;
							fi
						fi  # Open or close SINGLE-quoted string on finding a 
						;;  # non-escaped single-quote character
				esac
			done < <(echo -n "${before_1st_delim}")

			# If we are still inside of a quoted string, then we keep the 
			# delimiter and check the rest of the string
			local after_quote;			
			echo -n "${before_1st_delim}";
			
			if $inside_1quote; then
				echo -n "${delim}${after_1st_delim%%\'*}'"; # rest of quote
				remove_inline_JS_comment_from "${after_1st_delim#*\'}";  # remove inline comments after quote
			elif $inside_2quote; then
				echo -n "${delim}${after_1st_delim%%\"*}\""; # rest of quote
				remove_inline_JS_comment_from "${after_1st_delim#*\"}";  # remove inline comments after quote
			fi
		else
			echo -n "${line}";
		fi
	fi
}

trim_whitespace_from() {
	echo -n "$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'<<<"${@}")";
}

common_lines() {  # Only show lines present in both files. Opposite of `diff`
	if [ ${#} -eq 2 ] && [ -f ${1} ] && [ -f ${2} ]; then
		perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/' ${1} ${2}
	else
		echo "Usage: common_lines FILE_1_PATH FILE_2_PATH";
	fi
}  # From stackoverflow.com/a/17703442/21206695 or stackoverflow.com/q/17552789/21206695

convert_path() {  # Given a function to modify real paths and a list of paths,
		  # apply that modification to each path and echo it
	local converter=${1};
	shift;
	if [ $# -ne 0 ]; then
		for eacharg in "$@"; do
			if  [ -f "$eacharg" ]  || [ -d "$eacharg" ]; then
				$converter "$eacharg"
			else
				echo "Error: ${eacharg} not found." 1>&2; # >> /dev/stderr;
			fi
		done
	else
		$converter "$(pwd -P)";
	fi
}

datetime(){
	export today=$(date +"%Y-%m-%d");
	export now=$(date +"%H-%M");
	export nowseconds=$(date +"%s");
}

decrypt(){
	bash /home/${USERNAME}/.crypt/.decrypt.sh ${@};
}

encrypt(){
	bash /home/${USERNAME}/.crypt/.encrypt.sh ${@};
}

env_missing_reqs() {  # List every package in a requirements text file that 
		      # IS NOT installed in a specific conda environment
	local env_name="${1:-${CONDA_DEFAULT_ENV}}";   # Conda environment name
	local reqs_fpath="${2:-requirements.txt}";  # Requirements text file

	if [ ${#} -lt 3 ]; then  # if [ ${#} -eq 0 ] || [ ${#} -eq 2 ]; then 

		# Get list of names of packages in requirements text file minus
		# the list of names of packages installed in the given conda env
		comm -2 -3 <(cat ${reqs_fpath}  | grep -Eo '^[^=^>^<]*' \
			     | tr '[:upper:]' '[:lower:]' | sort) \
			   <(conda list -n ${env_name} | get_col1  \
			     | exclude_empties | tr '[:upper:]' '[:lower:]' | sort);
	else
		echo "Usage: env_missing_reqs [ENV_NAME] [REQS_FILE_PATH]";
	fi
}

envs_w_reqs() {
	local reqs_fpath="${1:-requirements.txt}";  # Text file listing required packages
	local valid_envs=(); # List of virtual environments that meet all requirements
	local invalid_envs=();
	local inaccessibles=();

	# Check the packages installed in every conda virtual environment
	
	echo -n "
Now checking which Conda environments have all packages listed in ${reqs_fpath} ";
	
	for env_name in $(conda env list | get_col1 | exclude_empties); do
		# echo -n "${env_name}? ";		  # TODO REMOVE LINE?
		# local env_name=${CONDA_DEFAULT_ENV}; # TODO REMOVE LINE

		# If the environment cannot be accessed due to permissions,
		# then just mark it as inaccessible
		if [ "${env_name}" != "base" ] && [ "$(touch ${CONDA_DIR}/envs/${env_name}/conda-meta/*.json 2>&1)" != "" ]; then
			# echo "Inaccessible. ";
			inaccessibles+=("${env_name}");
		else
		
			# If every package in the requirements.txt file is already 
			# installed in the named conda environment, save the env name
			local missing_pkgs=($(env_missing_reqs ${env_name} ${reqs_fpath} 2>/dev/null));
			if [[ ${#missing_pkgs[@]} -eq 0 ]]; then
				valid_envs+=("${env_name}");
				# echo "Yes. "; # "${env_name}, ";
			else		     # TODO REMOVE LINE?
				# echo "No. ";  # TODO REMOVE LINE?
				invalid_envs+=("${env_name}")
			fi
		fi
		echo -n ".";
	done

	echo;
	echo "
Valid envs: ${valid_envs[@]}

Invalid envs: ${invalid_envs[@]}

Inaccessible envs: ${inaccessibles[@]}
"
}

enable_terminal_colors() {
	# set a fancy prompt (non-color, unless we know we "want" color)
	case "$TERM" in
		xterm-color|*-256color) color_prompt=yes;;
	esac

	# uncomment for a colored prompt, if the terminal has the capability; turned
	# off by default to not distract the user: the focus in a terminal window
	# should be on the output of commands, not on the prompt
	#force_color_prompt=yes

	if [ -n "$force_color_prompt" ]; then
		if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
		else
		color_prompt=
		fi
	fi

	if [ "$color_prompt" = yes ]; then
		PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
	else
		PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
	fi
	unset color_prompt force_color_prompt

	# If this is an xterm set the title to user@host:dir
	case "$TERM" in
	xterm*|rxvt*)
		PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
		;;
	*)
		;;
	esac

	# enable color support of ls and also add handy aliases
	if [ -x /usr/bin/dircolors ]; then
		test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
		alias ls='ls --color=auto'
		#alias dir='dir --color=auto'
		#alias vdir='vdir --color=auto'

		alias grep='grep --color=auto'
		alias fgrep='fgrep --color=auto'
		alias egrep='egrep --color=auto'
	fi

	# colored GCC warnings and errors
	#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
}

escape_special_chars() {
	sed -E 's| |\\ |g' "${@}" | sed 's|(|\\(|g' | sed 's|)|\\)|g'; # 's| |\\ |g';
}

exclude_empties() {
	local piped_in="";
	while read -r in_data; do
		piped_in+="
${in_data}";
	done
	echo "${piped_in}" | grep -v '^$' | grep -v '\#';
}

findblanks() {  # Print the line number(s) of blank line(s) in a file
	grep -E --line-number --with-filename '^\s*$' $1
}

get_col1() {
	# read piped_in;
	# local piped_in=();
	local piped_in="";
	while read -r in_data; do
		piped_in+="
${in_data}";
		# piped_in+=("${in_data}");
		# printf "%s" "$data"
	done
	echo "${piped_in}" | tr -s ' ' | cut -d ' ' -f 1;
}

get_n_sacct_jobs() {
	act_txt="${1}";
	title=${2};
	echo "$act_txt" | grep $title | grep -v -F .ba+ | grep -v -F .ex+ | grep -v -F .b+ | grep -v -F .e+ | grep -v -F .0 | wc -l
}

has_type() {  # Return 0 if the input ${1} is something with a type; else return 1
	type "${1}" >/dev/null 2>&1; return ${?};
}

homepath() {
	if [ $# -ne 0 ]; then
		for eacharg in "$@"; do
			if [ -f $eacharg ]  || [ -d $eacharg ]; then
				homepath_convert $eacharg
			else
				echo "Error: ${eacharg} not found." 1>&2; # >> /dev/stderr;
			fi
		done
	else
		homepath_convert ${PWD};
	fi
}

homepath_convert() {
	inpath=${1};
	abs_inpath=$(realpath ${inpath});
	if [ "$(echo $abs_inpath | grep /panfs/ | grep /groups/)" = ""  ]; then
		echo $abs_inpath
	else
		echo /home/${abs_inpath#*panfs/*/groups/*?/}
	fi
}

i_am_online() {  # Return 0 if the current terminal is able to access/ping the web; else return 1
	ping -q -w 1 -c 1 8.8.8.8 2>&1 >/dev/null && return 0 || return 1;  # ping -q -w 1 -c 1 google.com #...
	# wget --spider -q http://google.com; return ${?};  # This works too, but is ~2x slower (0.67s vs. 0.34s via timeit -n 100)
}

identify() {  # Check what the input ${1} is and classify/describe it

	# If there is nothing to identify, then end the function
	if [ -z "${@}" ]; then
		return 1;
	fi

	# Is it an alias, builtin, keyword, or function?
	local what_it_is;
	local its_type="$(typeof "${@}")";
	if [ "${its_type}" != "" ]; then  
		what_it_is="${its_type}";

	# Is it a file or directory?
	elif [ -f "${@}" ]; then
		what_it_is="${@} is a file";
	elif [ -d "${@}" ]; then
		what_it_is="${@} is a directory";

	# Is it a variable?
	elif is_var_name "${@}"; then
		if [ "${!@}" ]; then
			what_it_is="${@} is a nonempty variable";
		else
			what_it_is="${@} is an empty variable";
		fi
	else
		return 1;
	fi
	echo "${what_it_is}";
}

initconda() {
	# >>> conda initialize >>>
	# !! Contents within this block are managed by 'conda init' !!
	__conda_setup="$(${CONDA} 'shell.bash' 'hook' 2> /dev/null)"
	if [ $? -eq 0 ]; then
	    eval "$__conda_setup"
	else
	    if [ ! -f "${CONDA_DIR}/etc/profile.d/conda.sh" ]; then
                 "${CONDA_DIR}/etc/profile.d/conda.sh";  # commented out by conda initialize
	    # else
		export PATH="${CONDA_DIR}/bin:$PATH";
	    fi	
	fi
	unset __conda_setup
	# <<< conda initialize <<<

	env_choice="base";
	env_arg=$(echo $1 | sed 's./..g');
	if [ ${#} -gt 0 ] && is_substring_of "$(conda env list | grep "${env_arg}")" "${env_arg}"; then
		env_choice="${env_arg}";
	fi
	conda activate ${env_choice};

	export PATH="${CONDA_DIR}/bin/:${PATH}";
	if [ "${env_choice}" != "base" ]; then
		export PATH="${CONDA_DIR}/envs/${env_choice}/bin/:${PATH}";
	fi

	# alias python="${CONDA_DIR}/bin/python";
	# alias python3="${CONDA_DIR}/bin/python3";

	export CLASSPATH=${CLASSPATH}:/${HOME}/
	export ORACLE_HOME=/${HOME}/
}

is_alias() {
	[[ "$(type ${1})" = *"alias"* ]]; return ${?};
}

is_name() {  # Return 0 if the input text $1 names any variable or function; else return 0
	[ "${1}" != "" ] && { is_var_name "${1}" || has_type "${1}" || [ -z "${1}" ]; };
	return ${?}
}

is_valid_var_name() {  # Return 0 if the input COULD BE a variable name; else return 1
	echo "${@}" | grep -q '^[_[:alpha:]][_[:alpha:][:digit:]]*$'; return ${?};
}  # Taken from stackoverflow.com/a/75140476/21206695

is_valid_whole_number() {  # Test whether a given input is a positive integer
	[[ "${1}" =~ ^[0-9]+$ ]]; return ${?};
}

is_var_name() {  # Return 0 if the input is the name of a variable; else return 1
	is_valid_var_name "${@}" && [ "${!1:-not a var}" != "not a var" ] 2>/dev/null; return ${?};
}

is_substring_of() {  # Return 0 if ${1} is a substring contained in the string ${2}; else return 1
	[[ "${1}" == *"${2}"* ]]; return ${?};
}

iterlines() {
	local to_iter="$(</dev/stdin)";
	# if [ ${#} -eq 0 ]; then
	# to_iter="$(</dev/stdin)";
	if [ ${#} -ne 1 ]; then # elif -gt 1
		echo "Error: Please provide exactly one argument naming a function." 1>&2; # >> /dev/stderr; # a quoted string." >> /dev/stderr;
	fi
		
		# if [ ${#} -eq 0 ]; then
		#	echo "$(</dev/stdin)";
		# fi
	# else
	#	to_iter="${1}";
	# fi
	# local to_iter="${@}";
	# fi
	while read line; do
		echo "$line";
	done <<< "${to_iter}" #to_iter}";
	# while read -r data; do printf "%s" "$data"; done  #This gets piped input, but any input piped in already had its newlines conflated w/ spaces as IFS
		
}

join_by() {  # Taken from stackoverflow.com/a/17841619/21206695
	local IFS="${1}";
	shift;
	echo "$*";
}

lines() {  # Count how many lines are in some file(s)
	for eacharg in "$@"; do
		if [ ! -f "${eacharg}" ]; then
			echo "Error: No file found at ${eacharg}" 1>&2; # >> /dev/stderr;
		elif [ ! -r "${eacharg}" ]; then
			echo "Error: Cannot read file at ${eacharg}" 1>&2; # >> /dev/stderr;
		else
			echo "$(cat "$eacharg" | wc -l) lines in ${eacharg}";
		fi
	done
}

list_empties() {
	# ls -lA ${@}  | tr -s ' ' | cut -d ' ' -f 5,9 | grep '^0 ' | awk '{print $NF}'
	find ${@} -maxdepth 1 -empty;
}

lll() {  # Show how many files/dirs/etc are in the current (or given) directory
	local dirpath;
	if [ $# -eq 0 ]; then
		dirpath="$(pwd -P)";
	else
		dirpath="${1}";
	fi

	# Use Feczko's readdir command to get the amount quickly
	local amount=$(($(read_dir "${dirpath}" | wc -l) + 1));  # "${dirpath}" 2>&1 | wc -l

	# For a small amount, just use LS, especially because using readdir cannot distinguish 0 and 1
	if [ $amount -lt 3 ]; then
		amount=$(l "${dirpath}" | wc -l);
	fi
	echo $amount
}

login(){
	if [ "$1" = "mesabi" ]; then
		username=${USERNAME}
		port=$2
	else
		username=conan
		port=$1
	fi
	ssh -Y -p ${port} ${username}@localhost
}

loginagate(){
	if [ "$(route PRINT interface | grep Cisco)" = "" ]; then
		echo "Error: Please enable Cisco VPN before connecting." >&2;
		return 1;
	else
		moba -bookmark MSI-Agate;
	fi
	# echo -n "Enter Password: "
	# read -s password;
	# echo $password > clip 
	# ~/.agate.sh &
	# moba -newtab "moba -bookmark MSI-Agate" &
	# moba -newtab "~/.agate.sh ${password}" &
	execute_expect="
		spawn ssh -N -L 8642:agate:22 ${USERNAME}@agate.msi.umn.edu &
		expect 'assword:'
		send \"${password}\\r\"
		expect 'asscode or option'
		send \"1\\r\"
		expect 'SSH-Browser: Password:'
		send \"${password}\\r\"
		interact
	";
	# ~/.agate.sh ${password} &
	# expect -c "{execute_expect}" &
	# moba -newtab "~/.agate.sh ${password}" &
	# sleep 10
	# ssh -Y -p 8666 ${USERNAME}@localhost
	# moba -bookmark MSI-Agate -newtab "~/.agate.sh ${password}"
	# moba -newtab "sleep 10; ssh -Y -p 8642 ${USERNAME}@localhost"
	# moba -newtab "expect -c '${execute_expect}'"
	# echo "\n\n${execute_expect}\n\n";
	# expect -c "${execute_expect}" &
	# sleep 1;
	# moba -bookmark MSI-Agate; 
	
}

loginmesabi(){
	# moba -newtab "sleep 8; ~/.umn.sh";
	moba -bookmark MSI-Mesabi;
	~/.mesabi.sh &
	# sleep 5;
	# ~/umn.sh
	# moba -newtab "ssh -N -L 8280:mesabi:22 ${USERNAME}@mesabi.msi.umn.edu & ~/mesabi.sh" &
	# sleep 2;
	# ~/umn.sh
	# exit
}

matvars(){
	matlab -nosplash -nodisplay -e | sort | grep \= | grep -v 'if\ \['
}

# Define function to get version, for use in myip() function below
my_version() {  # Echoes "CYGWIN", "Linux", or "WSL" [?]
	uname -s | cut -d '_' -f 1;  # uname -a | cut -d ' ' -f 1 | cut -d '_' -f 1;
}

# Define function to get my IP address, then use that function to set $DISPLAY
myip() {
	local help_msg="Usage: myip [-a] [-h]
Show my IP address(es).
Options:
	-a, --all: Show all IP addresses using route() and cURL. Otherwise, by default, this function will show only one IP address using cURL. 
	-h, --help: Show this help message and quit.
";
	local will_show_all=0;
	local ip_to_show="";

	# Collect and organize all input arguments
	while [ "${1}" != "" ]; do
		case ${1} in
			-a | --all)  # Number of results to echo in output
				shift
				will_show_all=1
				;;
			-h | --help)
				echo "${help_msg}";
				return 0
				;;
		esac
		shift
	done

	case "$(my_version)" in
		CYGWIN)
			ip_to_show="$(ipconfig | grep efault)";
			ip_to_show="${ip_to_show##* }"
			;;
		Linux)
			for eachterm in $(route | cut -d ' ' -f 1); do
				if [[ "${eachterm}" =~ ^[0-9.]+$ ]]; then
					ip_to_show="${ip_to_show}
${eachterm}"
				fi;
			done
			if [ "${ip_to_show}" = "" ]; then
				ip_to_show="$(curl -s ifconfig.me)";
			fi
			if [ "${ip_to_show}" = "" ]; then
				ip_to_show="$(/sbin/ip route | awk '/default/ { print $3 }')";
			fi
			if [ "${ip_to_show}" = "" ]; then
				ip_to_show="$(curl api.ipify.org)";
			fi
			;;
		*)
			echo "Error: Unsure how to get IP address for ${my_version}" 1>&2; # >> /dev/stderr;
			return 1
			;;
	esac

	ip_to_show="$(echo "${ip_to_show}" | grep -v -e '^$')";  # Remove blank lines
	if [ $will_show_all -eq 0 ]; then
		ip_to_show="$(echo "${ip_to_show}" | head -n 1)"; 
	fi
	echo "${ip_to_show}" # | xargs; 
}

mygroups(){
	echo $(id -nG);
}

poetry_activate(){  # Activate a Python-Poetry virtual environment
	case $# in 
		1)
			# Ensure that only 1 input argument is given; otherwise show usage
			;;
		*)
			echo "Usage: poetry_activate [Python Poetry project/environment name]
Activates an existing Python-Poetry project and its virtual environment.";
			return 0
			;;
	esac
	local virtual_envs="${HOME}/.cache/pypoetry/virtualenvs";
	local venvs_found_msg="python-poetry virtual environment(s) called '${1}' found in the '${virtual_envs}' directory";
	local activators=($(ls ${virtual_envs}/*${1}*-????????-py3.??/bin/activate));
	local n_activators=${#activators[@]};
	case ${n_activators} in
		0)
			echo "Error: No ${venvs_found_msg}." 1>&2;
			return 1
			;;
		1)
			poetry_activate_venv "${activators}"
			;;
		*)
			echo "Multiple ${venvs_found_msg}:";
			for ((i=0;i<n_activators;i++)); do
				echo "[$((i+1))]: ${activators[${i}]}";
			done

			echo -n "Enter the number of the environment to activate, or anything else to cancel: ";
			read venv_num;
			if is_valid_whole_number ${venv_num} && [[ ${venv_num} -gt 0 ]] \
					&& [[ ${venv_num} -le ${n_activators} ]]; then
				poetry_activate_venv "${activators[$((venv_num-1))]}";
			else
				return 0;
			fi
			;;
	esac

}

poetry_activate_venv(){      # Activate a Python-Poetry virtual environment
	local activator="${1}";  # by running the specified /activate file
	. "${activator}";
	local project="${activator#*virtualenvs/}";
	project="${project%-????????-*}";
	local project_dir="${HOME}/${project}";
	if [[ "$(ls -d ${project_dir} | wc -l)" -eq 1 ]]; then
		cd ${project_dir};
	fi
}

recall() {  # Search through my entire command history

	# Default values for input arguments
	local hist_file="${HISTORY_FILE}"; # -f
	local to_show=10;     # -n
	local to_check='all'; # -d
	local search_for=();  # List of terms to search through command history for
	local filter_out=();  # List of terms to exclude from search results
	local search_fn=$(which tail);  # By default, show the NEWEST (MOST RECENT) commands

	# Help/usage message to explain this function to the user
	local help_msg="Usage: recall SEARCH_TERM_1 [SEARCH_TERM_2...] -x EXCLUDE_TERM_1 [-x EXCLUDE_TERM_2...] [-n lines] [-d depth] [-f filepath] [-i]
Search through entire command history to find specific term(s) in past commands,
and then echo the most recent commands using the term(s).
Options:
	-d, --depth:		Number of commands in command history to check. Must be a positive integer or the word 'all'. Default: ${to_check}
	-f, --from, --file:	Path to the file containing history to search. Default: '${hist_file}'
	-i, --init, --head:	Include this flag to search OLDEST commands. Otherwise, will search NEWEST.
	-n, --lines:		Number of lines to echo in output. Must be a positive integer or the word 'all'. Default: ${to_show}
	-x, -v, --not:	  	Search term(s) to filter out.
";

	# If user gave no input arguments, then show the help message and exit
	if [ ${#} -eq 0 ]; then
		echo "${help_msg}";
		return 1;
	fi

	# Otherwise, collect and organize all input arguments
	while [ "${1}" != "" ]; do
		case ${1} in
	        -n | --lines)  # Number of results to echo in output
	            shift
	            to_show=${1}
	            ;;
	        -d | --depth)  # Number of commands in history to check
	            shift
	            to_check=${1}
	            ;;
	        -f | --from | --file)  # History file to search
	            shift
	            hist_file="${1}"
	            ;;
	        -v | -x | --exclude | --not) # Term to exclude from search results
	            shift
	            filter_out=(${filter_out[@]} "${1}")
	            ;;
	        -i | --init | --head)  # Show OLDEST commands
	            search_fn=$(which head)
	            ;;
	        -h | --help)
	            echo "${help_msg}";
	            return 0
	            ;;
	        *)
	            search_for=(${search_for[@]} "${1}");
		esac
		shift
	done

	: '
	# Type validation: Ensure that -n and -d are integers or "all"
	for eachinput in $to_show $to_check; do
		if [ "${eachinput}" != "all" ]; then
			verify_whole_number $eachinput;
		fi
	done
	';

	# Get contents of command-history text file
	local result;
	if [ "${to_check}" = 'all' ]; then
		result="$(cat "${hist_file}")";
	else
		verify_whole_number $to_check;
		result="$(${search_fn} "${hist_file}" -n ${to_check})";
	fi

	# Filter for each search term
	: '
	for each_term in ${search_for[@]}; do
		result="$(echo "${result}" | grep ${each_term})"
	done '
	local escaped_term;
	local to_search="$(echo "${search_for[0]}" | sed 's`/`\\/`g')";
	if [ "${to_search}" != "" ]; then
		for each_term in ${search_for[@]:1}; do
			escaped_term="$(echo "${each_term}" | sed 's`/`\\/`g')"
			to_search="${to_search}/ && /${escaped_term}";
		done
		result="$(echo "${result}" | awk "/${to_search}/")";
	fi 

	# Filter out each excluded search term
	: '
	for each_term in ${filter_out[@]}; do
		result="$(echo "${result}" | grep -v ${each_term})"
	done  '
	local grep_exclude="${filter_out[0]}";
	if [ "${grep_exclude}" != "" ]; then
		for exclude_term in ${filter_out[@]:1}; do
			# to_search="${to_search}/ && ! /${each_term}"; 
			grep_exclude="${grep_exclude}|${exclude_term}";
		done
		result="$(echo "${result}" | grep -v -E "${grep_exclude}")";
	fi

	# Display the result
	if [ "${to_show}" != 'all' ]; then 
		echo "${result}" | ${search_fn} -n ${to_show};
	else
		echo "${result}";
	fi
}

remove_redundants_in_PATH() {
	export PATH="$(join_by : $(awk '!a[$0]++' <(echo -e "${PATH//:/\\n}")))";
}

rerun() {
	local prev_cmd=($(recall -x rerun -n 1 ${@} | tr -s ' '));
	local cmd_num="${prev_cmd[2]}"
	local to_rerun="${prev_cmd[@]:3}"; # "$(recall -n 1 ${@} | tr -s ' ' | cut  -d ' ' -f 4-)";
	local user_resp;
	echo "Press Enter to rerun the command below:

${to_rerun}";
	read -s -n 1 user_resp;
	if [[ "${user_resp}" = "" ]]; then
		# bash -c "${to_rerun}";
		eval "${to_rerun}";
		echo "$(date +"%Y-%m-%d %H:%M")   ${cmd_num}  ${to_rerun}" >> ${HISTORY_FILE};
	fi
}

show_updates() {
	if [ $# -eq 0 ] || [ $# -gt 2 ] || [ "${1}" = "-h" ]; then
		echo "Usage: show_updates [FILENAME] [WAIT_DURATION]";
	elif [ ! -f "${1}" ]; then
		echo "Error: Cannot read file at ${1}" 1>&2; # >> /dev/stderr;
	else
		local fpath="$(realpath "${1}")";
		local secs_to_wait;
		if [ $# -eq 2 ]; then
			verify_whole_number ${2};
			secs_to_wait=${2};
		else
			secs_to_wait=30;  # Check every 30 seconds by default
		fi
	fi
	local prevtail="";
	local nexttail;
	while [ true ]; do
		nexttail="$(tail "${fpath}")";
		if [ "${prevtail}" != "${nexttail}" ]; then
			echo "${nexttail}";
			prevtail="${nexttail}";
		fi;
		sleep 30;
	done;
}

shpath() {
	# Get the right function to convert a Windows path to a bash path
	local converter;
	if is_name wslpath; then
		converter="wslpath";  # "${@}";
	elif is_name cygpath; then
		converter="cygpath";  # "${@}";
	else
		echo "No Windows-path-to-Unix-path converter found" 1>&2; # >> /dev/stderr;
		return 1;
	fi

	# Convert the path and echo it with all special characters escape'd
	# escape_special_chars "${@}" 
	#  echo "\'${1}\'" | sed  -e 's`\\\\wsl.localhost\\Ubuntu-22.04\\`/`g' | sed -e 's`\\`/`g';
	${converter} "${@}" | escape_special_chars

}

status(){
	act_txt="$(sacct)";
	q_txt="$(squeue --me -al)";  # q_txt="$(squeue -al | grep $(id -un))";
	header_txt="\n| QUEUED | PENDING | RUNNING | CANCELLED | FAILED | SUCCEEDED |\n+--------+---------+---------+-----------+--------+-----------+\n| %6s | %7s | %7s | %9s | %6s | %9s |\n\n";
	printf "${header_txt}" \
		"$(echo "$q_txt" | grep -v '' | wc -l)" \
		"$(($(get_n_sacct_jobs "$act_txt" PENDING)+$(get_n_sacct_jobs "$act_txt" REVOKED)+$(echo "$q_txt" | grep 'REVOKED' | wc -l)))" \
		"$(get_n_sacct_jobs "$act_txt" RUNNING)" \
		"$(get_n_sacct_jobs "$act_txt" CANCELLED)" \
		"$(($(get_n_sacct_jobs "$act_txt" FAILED)+$(get_n_sacct_jobs "$act_txt" OUT_OF_ME)+$(get_n_sacct_jobs "$act_txt" TIMEOUT)))" \
		"$(get_n_sacct_jobs "$act_txt" COMPLETED)";
}

# strip_lines() {	echo "$@" | sed -e '/^$/d' }

timeit() {  # Check how long a command takes to run on average with nanosecond precision
	local n_loops=1;
	if [ $# -eq 0 ] || [ "${1}" = "-h" ]; then  # Display help message
		echo "Usage: timeit [-h] [-n LOOPS] [ANY_COMMAND]
Run a command, suppressing its output, and echo how long it took in seconds with nanosecond precision.
Options:
	-h:     Display this help message.
	-n:     Number of times to run the command. Default: ${n_loops}";
		return 0;
	elif [ $1 = "-n" ]; then
		shift;
		verify_whole_number ${1};
		n_loops=${1};
		shift;
	fi

	local running_total=0;
	local ix=0;
	local time_taken;
	while [ $ix -lt $n_loops ]; do
		let ix++;
		time_taken="$(timeit_once ${@})";
		echo "Run ${ix} took $(trim_zeroes ${time_taken}) seconds."
		running_total=$(echo "${time_taken} + ${running_total}" | bc -l);
	done
	echo "
Average: $(trim_zeroes "0$(echo "${running_total} / $((${n_loops}))" | bc -l)") seconds.";

	# echo "${seconds}";
	# let nanosec=$(echo "${running_total} // ${n_loops}" | bc);
	# echo "${seconds}.${nanosec}"
	# echo $(echo "${running_total} / ${n_loops}" | bc)
}

timeit_once() { 
	local starttime=$(date +"%s.%N");
	${@} > /dev/null;
	echo "$(date +"%s.%N")-${starttime}" | bc;   
}

trim_zeroes() {
	local trimmed;
	while [ $# -gt 0 ]; do
		trimmed="$(echo "${1}" | sed '/\./ s/\.\{0,1\}0\{1,\}$//')";
		trimmed="$(echo $trimmed | sed 's/^0*//')";
		if [ "${trimmed::1}" = "." ]; then
			trimmed="0${trimmed}";
		fi
		echo $trimmed;
		shift;
	done
}

typeof() {
	# Iff a type description exists, get its first line
	local type_output="$(type "${@}" 2>/dev/null | head -n 1)";

	# Either show that first-line plus a newline or show nothing
	if [ "${type_output}" != "" ]; then
		type_output+="
";
	fi
	echo -n "${type_output}"
}

tunnel(){
	local email;
	if [ "$1" = "mesabi" ]; then
		email=${USERNAME}@login.msi.umn.edu
	else
		email=conan@acc.ohsu.edu
	fi
	ssh -N -L ${2}:${1}:22 $email;
}

uniques() {  # Given text, only return the unique lines; do not sort. From stackoverflow.com/a/618454
	# cat $1  # Given a text file,
	perl -ne 'if (!defined $x{$_}) { print $_; $x{$_} = 1; }'
}

verify_whole_number(){
	if ! $(is_valid_whole_number $1); then
		echo "Error: ${1} is not a positive integer." 1>&2; # >> /dev/stderr;
		exit 1;
	fi
}

vpn_is_offline() {

	local my_route;
	if [ "$(which route.exe)" != "" ]; then
		my_route="$(route.exe PRINT interface)";
	elif [ "$(route --version)" = "$(route)" ]; then
		my_route="$(route PRINT interface)";
	else
		my_route="";  # TODO Figure out how to check for Cisco VPN from Linux
	fi

	# local route_file="$(which route)";
	# route_file=${route_cmd:-route.exe};
	
	# local my_route="$(${route_cmd} PRINT interface 2>/dev/null)";
	# my_route=${my_route:-}
	# route_cmd=${route_cmd:-route.exe}
	[ "$(echo "${my_route}" | grep Cisco)" = "" ]; return ${?};
}

waiting() {  # Stand by, without letting connection close, by echoing a message every X seconds indefinitely until user cancels
	local times=0;
	local wait_secs;
	if [ ${#} -eq 0 ]; then
		wait_secs=120;
	elif [ ${#} -eq 1 ]; then
		verify_whole_number ${1};
		wait_secs=${1};
	else
		echo "nah" 1>&2; # >> /dev/stderr;
	fi

	echo Started waiting.
	while [ true ]; do
		sleep $wait_secs;
		let times++;
		echo "Waited $(($times*$wait_secs/60)) minutes so far";
	done
}


beginWSL;

# Automatically save every command into a text file to save history. Necessary for 'recall' function
PROMPT_COMMAND='echo "$(date +"%Y-%m-%d %H:%M") $(history 1)" >> ~/.history.txt';  # TODO Replace "~/.history.txt" with the ${HISTORY_FILE} variable declared near the top of this file

# Created by `pipx` on 2024-07-12 20:03:36
export PATH="$PATH:/home/${USERNAME}/.local/bin"
