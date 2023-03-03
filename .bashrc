#!/usr/bin/bash

# .bashrc startup script for login shells

umask 002;

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=  #ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=5000
HISTFILESIZE=10000000

# Path to file to store history in 
HISTORY_FILE="/home/gconan/.history.txt";

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
# [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

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


# My shortcut/convenience aliases
alias clip="clip.exe";
alias l="ls -A";
alias ll="ls -alF";
alias wudo="python /mnt/c/Users/gconan/OneDrive/Documents/wsl-sudo/wsl-sudo.py";

# Remove default aliases so I can overwrite them with my own preferred aliases
unalias lll 2>/dev/null;
unalias python3 2>/dev/null;

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

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Using WSL 2? Then use this
export DISPLAY="$(/sbin/ip route | awk '/default/ { print $3 }'):0"


# Shortcut functions

begin() {
	# If the wrong "date" function (without sub-second precison) is installed, then install the correct one
	if is_valid_whole_number $(trim_zeroes $(date +"%s.%N")); then
        	echo "Reinstalling coreutils to give the date command sub-second precision.";
	        apt-get install coreutils;
	fi

        export MSYS_NO_PATHCONV=1;

        # Define path to utilities/etc. 
        export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/wsl/lib:/mnt/c/Users/gconan/AppData/Local/Temp/Mxt230/bin:/mnt/c/Windows/:/mnt/c/Windows/system32/:/mnt/c/Windows/system32:/mnt/c/Windows:/mnt/c/Windows/System32/Wbem:/mnt/c/Windows/System32/WindowsPowerShell/v1.0/:/home/gconan/miniconda3/:/home/gconan/miniconda3/bin/:/mnt/c/Users/gconan/AppData/Local/Microsoft/WindowsApps:/mnt/c/Users/gconan/AppData/Local/Programs/'Microsoft VS Code'/bin:/mnt/c/Windows/sysnative/:/snap/bin:/mnt/c/Users/gconan/AppData/Local/Temp/Mxt230/bin/:/mnt/c/'Program Files (x86)'/'Unix Tools'/bin/;

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

convert_path() {  # Given a function to modify real paths and a list of paths,
                  # apply that modification to each path and echo it
        local converter=${1};
        shift;
        if [ $# -ne 0 ]; then
                for eacharg in "$@"; do
                        if  [ -f "$eacharg" ]  || [ -d "$eacharg" ]; then
                                $converter "$eacharg"
                        else
                                echo "Error: ${eacharg} not found." >> /dev/stderr;
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
	bash ~/.decrypt.sh ${@};
}

encrypt(){
	bash ~/.encrypt.sh ${@};
}

escape_special_chars() {
        sed -E 's| |\\ |g' "${@}" | sed 's|(|\\(|g' | sed 's|)|\\)|g'; # 's| |\\ |g';
}

findblanks() {  # Print the line number(s) of blank line(s) in a file
        grep -E --line-number --with-filename '^\s*$' $1
}

fullpath() {
        local in_path="$(echo "${@}" | sed 's|/home/mobaxterm/MyDocuments|/mnt/c/Users/gconan/OneDrive - Cisco/Documents|g')";
        echo "${in_path}" | sed 's|/home/mobaxterm|/mnt/c/Users/gconan/OneDrive - Cisco/Documents/MobaXTerm-Home|';
}

has_type() {  # Return 0 if the input ${1} is something with a type; else return 1
        type "${1}" >/dev/null 2>&1; return ${?};
}

i_am_online() {  # Return 0 if the current terminal is able to access/ping the web; else return 1
	ping -q -w 1 -c 1 8.8.8.8 > /dev/null && return 0 || return 1;
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
        echo "${what_it_is}"
}

initconda() {
        # >>> conda initialize >>>
        # !! Contents within this block are managed by 'conda init' !!
        __conda_setup="$('/home/gconan/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
        if [ $? -eq 0 ]; then
	        eval "$__conda_setup"
        else
	        if [ -f "/home/gconan/miniconda3/etc/profile.d/conda.sh" ]; then
        	        . "/home/gconan/miniconda3/etc/profile.d/conda.sh"
	        else
        	        export PATH="/home/gconan/miniconda3/bin:$PATH"
	        fi
        fi
        unset __conda_setup
        # <<< conda initialize <<<

	env_choice="base";
	if [ ${#} -gt 0 ] && is_substring_of "$(conda env list | grep "${1}")" "${1}"; then
		env_choice="${1}";
	fi
	conda activate ${env_choice};

	alias python3='python';
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

lines() {  # Count how many lines are in some file(s)
        for eacharg in "$@"; do
		if [ ! -f $eacharg ]; then
			echo "Error: No file found at ${eacharg}" >> /dev/stderr;
		elif [ ! -r $eacharg ]; then
			echo "Error: Cannot read file at ${eacharg}" >> /dev/stderr;
		else
                        echo "$(cat $eacharg | wc -l) lines in ${eacharg}";
                fi
        done
}

lll() {  # Show how many files/dirs/etc are in the current (or given) directory
        local dirpath;
        if [ $# -eq 0 ]; then
                dirpath="$(pwd -P)";
        else
                dirpath="${1}";
        fi

        # Use Feczko's readdir command to get the amount quickly
        local amount=$(($(~/read_dir.pl "${dirpath}" | wc -l) + 1));  # "${dirpath}" 2>&1 | wc -l

        # For a small amount, just use LS, especially because using readdir cannot distinguish 0 and 1
        if [ $amount -lt 3 ]; then
                amount=$(ls "${dirpath}" | wc -l);
        fi
        echo $amount
}

mygroups(){
        echo $(id -nG);
}

recall() {  # Search through my entire command history

        # Default values for input arguments
        local to_show=10;     # -n
        local to_check='all'; # -d
        local search_for=();  # List of terms to search through command history for
        local filter_out=();  # List of terms to exclude from search results
        local search_fn=$(which tail);  # By default, show the NEWEST (MOST RECENT) commands

        # Help/usage message to explain this function to the user
        local help_msg="Usage: recall SEARCH_TERM_1 [SEARCH_TERM_2...] -x EXCLUDE_TERM_1 [-x EXCLUDE_TERM_2...] [-n lines] [-d depth] [-i]
Search through entire command history to find specific term(s) in past commands,
and then echo the most recent commands using the term(s).
Options:
        -d, --depth:            Number of commands in command history to check. Must be a positive integer or the word 'all'. Default: ${to_check}
        -i, --initial, --head:  Include this flag to search OLDEST commands. Otherwise, will search NEWEST.
        -n, --lines:            Number of lines to echo in output. Must be a positive integer or the word 'all'. Default: ${to_show}
        -x, --not, --exclude:   Search term(s) to filter out.
";

        # If user gave no input arguments, then show the help message and exit
        if [ ${#} -eq 0 ]; then
                echo "${help_msg}";
                return 0;
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
                -v | -x | --exclude) # Term to exclude from search results
                        shift
                        filter_out=(${filter_out[@]} "${1}");
                        ;;
                -i | --initial | --head)  # Show OLDEST commands
                        search_fn=$(which head)
                        ;;
                -h | --help)
                        echo "${help_msg}";
                        return 1
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
		result="$(cat ${HISTORY_FILE})";
	else
		verify_whole_number $to_check;
        	result="$(${search_fn} ${HISTORY_FILE} -n ${to_check})";
	fi

        # Filter for each search term
        : '
        for each_term in ${search_for[@]}; do
                result="$(echo "${result}" | grep ${each_term})"
        done '
        local to_search="${search_for[0]}";
        if [ "${to_search}" != "" ]; then
                for each_term in ${search_for[@]:1}; do
                        to_search="${to_search}/ && /${each_term}";
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

uniques() {  # Given a text file, only return the unique lines; do not sort. From stackoverflow.com/a/618454
        cat $1 | perl -ne 'if (!defined $x{$_}) { print $_; $x{$_} = 1; }'
}

verify_whole_number(){
        if ! $(is_valid_whole_number $1); then
                echo "Error: ${1} is not a positive integer." >> /dev/stderr;
                exit 1;
        fi
}

vpn_is_offline() {
	[ "$(route.exe PRINT interface | grep Cisco)" = "" ]; return ${?};
}

shpath() {
	# Get the right function to convert a Windows path to a bash path
	local converter;
	if is_name wslpath; then
		converter="wslpath";  # "${@}";
	elif is_name cygpath; then
		converter="cygpath";  # "${@}";
	else
		echo "No Windows-path-to-Unix-path converter found" >> /dev/stderr;
		return 1;
	fi

	# Convert the path and echo it with all special characters escape'd
        # escape_special_chars "${@}" 
        ${converter} "${@}" | escape_special_chars

}

winpath() {
        convert_path winpath_convert "${@}";
}

winpath_convert() {
        local out_path="$(fullpath "${@}")";
        local out_path="$(realpath "${out_path}" | sed -E 's+^/drives/(.{1})+\1:+' | sed 's+:$+:/+1' | sed 's+/+\\+g')";
        echo "'${out_path^}'";
}

# begin;

# Automatically save every command into a text file to save history. Necessary for 'recall' function
touch ${HISTORY_FILE};
export PROMPT_COMMAND='history -a; history -r; echo "[$(date +"%Y-%m-%d %H:%M:%S")] $(history | tail -n 1)" >> ${HISTORY_FILE}'

# export PROMPT_COMMAND="history -a; history -c; history -r;"
