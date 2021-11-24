#!/bin/bash

. spinner.sh

LOG_FILE="dev.log"

echo "" > $LOG_FILE

function main {

    # ensure we can sudo without being prompted
    # the first sudo will fail if a password is required and will restart the sudo timer otherwise
    # the second will prompt for a password and start the sudo timer
    sudo -nv 2> /dev/null || sudo true

    # spin "Updating APT..." "sudo apt-get update" $LOG_FILE

    # apt_install "System Packages" apt-transport-https ca-certificates software-properties-common python-is-python3 python3-pip curl wget jq zip

    # set_locale

    # set_timezone

    # install_aws_cli

    install_terraform

    install_php

}


function apt_install {

    spin "Installing $1..." "sudo apt-get install -y ${@:2}" $LOG_FILE

}

function set_locale {

    # $1 the locale to use, generally en_GB.UTF-8
    local LOCALE=${1:-"en_GB.UTF-8"}

    spinner start "Set Locale to ${LOCALE}..."
    sudo locale-gen ${LOCALE} >> $LOG_FILE 2>&1 && sudo update-locale LANG=${LOCALE} LC_ALL=${LOCALE} >> $LOG_FILE 2>&1
    spinner stop $?

}

function set_timezone {

    local TZ=${1:-"UTC"}

    spin "Set timezone to ${TZ}..." "sudo timedatectl set-timezone $TZ" $LOG_FILE

}

function install_aws_cli {

    spinner start "Installing AWS CLI..."

    aws --version > /dev/null 2>&1

    # only install if not available
    if [ $? -eq 0 ]; then
        spinner stop "${YELLOW}SKIP${NOCOLOUR}" "v$(aws --version | cut -d" " -f1 | cut -d"/" -f2) already installed"
        return
    fi

    # download the correct file for the current architecture, unzip it and run the installer
    wget -O "/tmp/aws-cli.zip" "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" >> $LOG_FILE 2>&1 \
        && unzip -o /tmp/aws-cli.zip -d /tmp >> $LOG_FILE 2>&1 \
        && sudo /tmp/aws/install >> $LOG_FILE 2>&1

    # clean up our downloaded file and the zip extract
    rm -f /tmp/aws-cli.zip > /dev/null 2>&1
    rm -rf /tmp/aws > /dev/null 2>&1

    # confirm that it's installed correctly
    aws --version >> $LOG_FILE 2>&1

    spinner stop $?

}

function install_terraform {

    # find latest terraform version
    local TF_LATEST=$(curl -fs https://api.github.com/repos/hashicorp/terraform/releases/latest | jq --raw-output '.tag_name' | cut -c 2-)

    # install either the specified version or the latest
    local TF_VERSION=${1:-$TF_LATEST}

    spinner start "Installing Terraform v${TF_VERSION}..."

    # check if we already have terraform installed
    local TF_CURRENT=$(terraform version 2> /dev/null | head -n 1 | cut -d'v' -f2)

    # check if the desired version is newer than the current version...
    if [ $(echo -e "${TF_VERSION}\n${TF_CURRENT}" | sort -rV | head -n1) = $TF_CURRENT ]; then
        spinner stop "${YELLOW}SKIP${NOCOLOUR}" "v${TF_CURRENT} already installed"
        return
    fi

    # check system architecture, default to x86_64
    local TF_ARCH=amd64
    if [ $(uname -m) = "aarch64" ]; then
        TF_ARCH=arm64
    fi

    wget -O "/tmp/terraform.zip" "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${TF_ARCH}.zip" >> $LOG_FILE 2>&1 \
        && unzip -o /tmp/terraform.zip -d /tmp >> $LOG_FILE 2>&1 \
        && sudo mv /tmp/terraform /usr/local/bin/terraform >> $LOG_FILE 2>&1

    # clean up
    rm -rf /tmp/terraform

    # confirm that it's installed correctly
    terraform version >> $LOG_FILE 2>&1

    spinner stop $?

}

function install_php {

    spinner start "Installing PHP 8..."

    sudo add-apt-repository -yu ppa:ondrej/php >> $LOG_FILE 2>&1 \
        && sudo apt-get update >> $LOG_FILE 2>&1 \
        && sudo apt-get install -y php8.0-cli php8.0-common php8.0-curl php8.0-mbstring php8.0-mysql \
            php8.0-odbc php8.0-opcache php8.0-pgsql php8.0-readline php8.0-sqlite3 php8.0-xml >> $LOG_FILE 2>&1

    spinner stop $?

}

main
