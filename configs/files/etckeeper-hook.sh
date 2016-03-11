[ `id -u` -eq 0 ] || return

_USER=""
_HOSTNAME=`hostname`
if [ -n "$SUDO_USER" ]; then
    _USER="$SUDO_USER"
else
    # try to check tty ownership, in case user su'd to root
    _TTY="$(tty 2>/dev/null || true)"
    if [ -n "$_TTY" ] && [ -c "$_TTY" ]; then
        _USER="$(find "$_TTY" -printf "%u")"
    fi
fi

_etckeeper()
{
    if [ -x /usr/bin/git ] && [ -d /etc/.git ]; then
        (
        cd /etc

        if [ $(git status --porcelain | wc -l) -eq 0 ] ; then
            return 0
        fi

        if ! git add --all; then
            echo "warning: git add --all" >&2
        fi

        git commit -m "Automated commit at exit"
        )
    fi
}

if [ -n "$_USER" ]; then
    if [ -z "$GIT_AUTHOR_NAME" ]; then
        [ -f /home/$_USER/.gitconfig ] && GIT_AUTHOR_NAME=$(git config -f /home/$_USER/.gitconfig --get user.name)
        [ -z "$GIT_AUTHOR_NAME" ] && GIT_AUTHOR_NAME="$_USER"
        export GIT_AUTHOR_NAME
    fi

    if [ -z "$GIT_AUTHOR_EMAIL" ]; then
        [ -f /home/$_USER/.gitconfig ] && GIT_AUTHOR_EMAIL=$(git config -f /home/$_USER/.gitconfig --get user.email)
        [ -z "$GIT_AUTHOR_EMAIL" ] && GIT_AUTHOR_EMAIL="$_USER@$_HOSTNAME"
        export GIT_AUTHOR_EMAIL
    fi

    if [ -z "$GIT_COMMITTER_EMAIL" ]; then
        export GIT_COMMITTER_EMAIL=`whoami`"@$_HOSTNAME"
    fi


    trap _etckeeper EXIT
fi
