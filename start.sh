useradd --shell /bin/sh --create-home $USERNAME -s /bin/bash
echo "$USERNAME:$PASSWORD" |chpasswd

/usr/sbin/sshd -D
