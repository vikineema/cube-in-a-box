#!/usr/bin/env bash

install_docker_ubuntu() {
  # Copied from : https://docs.docker.com/engine/install/ubuntu/
  sudo apt-get remove -y docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc

  # Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update

  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  sudo service docker start
}

install_docker_fedora() {
  # Copied from: https://docs.docker.com/engine/install/fedora/
  sudo dnf remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
  sudo dnf -y install dnf-plugins-core

  sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

  sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl enable docker.service
  sudo systemctl enable containerd.service
  sudo systemctl start docker
}

install_docker_macos() {
  curl https://desktop.docker.com/mac/stable/amd64/Docker.dmg?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-mac-amd64 -O ~/Downloads/Docker.dmg
  hdiutil attach ~/Downloads/Docker.dmg
  echo "Install the Docker from the new Drive that is on the Desktop..."
  read -p "Press enter to continue... "
}

case "$OSTYPE" in
  linux-gnu)
    osname="$(grep '^ID=' /etc/os-release | cut -d'=' -f2)"
    case "$osname" in
      fedora) install_docker_fedora ;;
      ubuntu) install_docker_ubuntu ;;
      *) echo "We currently do not support your OS" ;;
    esac
    ;;
  darwun*) install_docker_macos ;;
  *) echo "We currently do not support your OS" ;;
esac
