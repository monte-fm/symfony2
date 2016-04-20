if [ -e /etc/bash_completion.d/symfony2-autocomplete.bash ]; then
	. /etc/bash_completion.d/symfony2-autocomplete.bash
fi

alias ll='ls -la'
force_color_prompt=yes
export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'
export PHP_IDE_CONFIG=serverName=localhost
