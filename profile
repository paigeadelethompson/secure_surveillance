# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH for RaspberryPi userland files in /opt/vc/bin if they exist
if [ -d "/opt/vc/bin" ] ; then
    PATH="$PATH:/opt/vc/bin"
fi
