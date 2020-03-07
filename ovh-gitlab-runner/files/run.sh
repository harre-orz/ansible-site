#!/usr/bin/env bash

# /opt/lxd-executor/prepare.sh

currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${currentDir}/base.sh # Get variables from base.

set -eo pipefail

# trap any error, and mark it as a system failure.
trap "exit $SYSTEM_FAILURE_EXIT_CODE" ERR

start_container () {
    if lxc info "$CONTAINER_ID" >/dev/null 2>/dev/null ; then
        echo 'Found old container, deleting'
        lxc delete -f "$CONTAINER_ID"
    fi

    # Container image is harcoded at the moment, since Custom executor
    # does not provide the value of `image`. See
    # https://gitlab.com/gitlab-org/gitlab-runner/issues/4357 for
    # details.
    lxc launch "$CONTAINER_IMAGE" "$CONTAINER_ID"

    # Wait for container to start, we are using systemd to check this,
    # for the sake of brevity.
    for i in $(seq 1 10); do
        if lxc exec "$CONTAINER_ID" -- sh -c "systemctl isolate multi-user.target" >/dev/null 2>/dev/null; then
            break
        fi

        if [ "$i" == "10" ]; then
            echo 'Waited for 10 seconds to start container, exiting..'
            # Inform GitLab Runner that this is a system failure, so it
            # should be retried.
            exit "$SYSTEM_FAILURE_EXIT_CODE"
        fi

        sleep 1s
    done
}

install_dependencies () {
    # Install Git and base packages for same distributions.
    case $CONTAINER_DISTRO in
        alpine)
            lxc exec "$CONTAINER_ID" /bin/sh <<EOF
apk add git sudo
EOF
            ;;
        archlinux)
            lxc exec "$CONTAINER_ID" /bin/sh <<EOF
yes | pacman -Sy git sudo
EOF
            ;;
        centos|fedora)
            lxc exec "$CONTAINER_ID" /bin/sh <<EOF
yum install -y git sudo
EOF
            ;;
        debian|ubuntu)
            lxc exec "$CONTAINER_ID" /bin/sh <<EOF
apt-get update
apt-get install -y git sudo
EOF
            ;;
    esac

    # Create gitlab-runner user.
    lxc exec "$CONTAINER_ID" /bin/sh <<EOF
useradd -d /var/lib/gitlab-runner -s /bin/bash gitlab-runner
mkdir -p /var/lib/gitlab-runner
chown -R gitlab-runner:gitlab-runner /var/lib/gitlab-runner
echo 'gitlab-runner ALL = NOPASSWD: ALL' > /etc/sudoers.d/gitlab-runner
EOF

    # Install gitlab-runner binary since we need for cache/artifacts.
    lxc file -q push "$(which gitlab-runner)" "$CONTAINER_ID"/usr/local/bin/gitlab-runner
}

echo "Running in $CONTAINER_ID"

start_container

install_dependencies
[arch@vps671490 lxd-executor]$ cat run.sh
#!/usr/bin/env bash

# /opt/lxd-executor/run.sh

currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${currentDir}/base.sh # Get variables from base.

sed -i -e '2a su - gitlab-runner <<EOF' -e '$a EOF' -e '$a exit $?' ${1}
lxc exec "$CONTAINER_ID" /bin/bash < "${1}"
if [ $? -ne 0 ]; then
    # Exit using the variable, to make the build as failure in GitLab
    # CI.
    exit $BUILD_FAILURE_EXIT_CODE
fi
