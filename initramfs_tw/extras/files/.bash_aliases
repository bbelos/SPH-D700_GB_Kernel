# /data/local/.bash_aliases
#

# aliases
#
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
# NOTE:: !! not sure this works in android
#alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Set up some aliases to cover toolbox with the nice busybox equivalents of its commands
#
alias cat='busybox cat'
alias chmod='busybox chmod'
alias chown='busybox chown'
alias cp='busybox cp'
alias df='busybox df'
alias insmod='busybox insmod'
alias ls='busybox ls --color=auto'
alias l='busybox ls -CF --color=auto'
alias la='busybox ls -A --color=auto'
alias ll='busybox ls -AlF --color=auto'
alias ln='busybox ln'
alias lsmod='busybox lsmod'
alias mkdir='busybox mkdir'
alias more='busybox more'
alias mount='busybox mount'
alias mv='busybox mv'
alias rm='busybox rm'
alias rmdir='busybox rmdir'
alias rmmod='busybox rmmod'
alias su='su -c bash'
alias umount='busybox umount'
alias vi='busybox vi'
alias top='busybox top'

extract() {     # Handy Extract Program.

     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   busybox tar xvjf $1     ;;
             *.tar.gz)    busybox tar xvzf $1     ;;
             *.bz2)       bunzip2 $1      ;;
             *.rar)       unrar x $1      ;;
             *.gz)        gunzip $1       ;;
             *.tar)       busybox tar xvf $1      ;;
             *.tbz2)      busybox tar xvjf $1     ;;
             *.tgz)       busybox tar xvzf $1     ;;
             *.zip)       unzip $1        ;;
             *.Z)         uncompress $1   ;;
             *.7z)        7z x $1         ;;
             *)           echo "'$1' cannot be extracted via >extract<" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}
__shopt () {
	if ! [ -z "$BASH" ]; then
		local i
		for i in "$@"; do
			shopt -s $i
		done
	fi
}
hist () {
	history | grep "$@" | uniq -f 2 -u
}
# do something in the background
bg () {
	( "$@" ) &
}
# view processes.
pg () {
	ps aux | grep "$@" | grep -v "$( echo grep "$@" )"
}
pid () {
	pg "$@" | awk '{print $2}'
}
# do something very quietly.
quiet () {
	( "$@" ) &>/dev/null
}
ip () {
	OS=`uname`
	IO="" # store IP
	case $OS in
	   Linux) IP=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`;;
	   FreeBSD|OpenBSD|Darwin) IP=`ifconfig  | grep -E 'inet.[0-9]' | grep -v '127.0.0.1' | awk '{ print $2}'` ;;
	   SunOS) IP=`ifconfig -a | grep inet | grep -v '127.0.0.1' | awk '{ print $2} '` ;;
	   *) IP="Unknown";;
	esac
	echo "$IP"
}


# Show the IP addresses of this machine, with each interface that the address is on.
ips () {
	local interface=""
	local types='vmnet|en|eth|vboxnet'
	local i
	for i in $(
		ifconfig \
		| egrep -o '(^('$types')[0-9]|inet (addr:)?([0-9]+\.){3}[0-9]+)' \
		| egrep -o '(^('$types')[0-9]|([0-9]+\.){3}[0-9]+)' \
		| grep -v 127.0.0.1
	); do
		if ! [ "$( echo $i | perl -pi -e 's/([0-9]+\.){3}[0-9]+//g' )" == "" ]; then
			interface="$i":
		else
			if [ $1 == 'ip' ] ; then
				echo $i
				break
			else
				echo $interface $i
			fi
		fi
	done
}
# Like the ips function, but for mac addrs.
macs () {
	local interface=""
	local i
	local types='vmnet|en|eth|vboxnet'
	for i in $(
		ifconfig \
		| egrep -o '(^('$types')[0-9]:|ether ([0-9a-f]{2}:){5}[0-9a-f]{2})' \
		| egrep -o '(^('$types')[0-9]:|([0-9a-f]{2}:){5}[0-9a-f]{2})'
	); do
		if [ ${i:(${#i}-1)} == ":" ]; then
			interface=$i
		else
			echo $interface $i
		fi
	done
}

__editor () {
	# Favorite editors, by preference. __set_editor bbedit mate pico nano ed
	__edit_cmd="$( __get_edit_cmd "$@" )"
	alias edit="${__edit_cmd}"
	alias e="${__edit_cmd} ."
	alias suedit="su -c ${__edit_cmd}"
	export EDITOR="$( choose_first ${__edit_cmd}_wait ${__edit_cmd} )"
	export VISUAL="$EDITOR"
}
__statsmotd () {
	#set initial title
	#xtitle "$(whoami)@$HOSTNAME $PWD"

	#Fri, September 10 2010   (W 36 / D 253)      01:12:09 AM CDT(-0500)
	prettydate="$(date +%a,\ %B\ %e\ %Y\ \ \ \(W:%W\ /\ D:%j\)\ \ \ \ \ \ %r\ %Z\(%z\))"

	STRSTAT1="\033[00mloading \033[1mbash extras v$BASHEXTRASVERSION\033[00m..."
	STRSTAT2="\033[1;97;100m Kernel: \033[0;97m$(uname -smr)"
	STRSTAT21="\033[1;97;100m Bash: \033[0;97mv$BASH_VERSION [$(which bash)]"
	STRSTAT3="\033[1;97;100m Uptime: \033[0;97m$(uptime)"
	STRSTAT4="\033[1;97;100m Now: \033[0;97m$prettydate"
	STRSTAT5="\033[1;36;100m Tip: \033[0;36mTo remount /system, run: remount [ro|rw|status]"
	#STRSTAT5="\033[00m"
	#STRSTAT5=$(echo -ne "\033[1;97;100m  Last Login: \033[0;97;100m$(last -1 )")

	#echo -ne "$STRSTAT1"
	echo -ne "$STRSTAT2\n"
	echo -ne "$STRSTAT21\n"
	echo -ne "$STRSTAT3\n"
	echo -ne "$STRSTAT4\n"
	echo -ne "$STRSTAT5\n"
	#__fillline "$STRSTAT5"
	echo -ne "\033[00m\n"
}

	#SET FAVORITE EDITOR FROM LIST
	__editor pico nano vim vi ed


	# SET SHOPT OPTS see http://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html#The-Shopt-Builtin
	__shopt histappend histverify histreedit cdspell expand_aliases cmdhist \
	hostcomplete no_empty_cmd_completion nocaseglob dotglob autocd
	shopt -u mailwarn

	unset MAILCHECK

	#SHOW OWN MOTD
	clear
	__statsmotd
