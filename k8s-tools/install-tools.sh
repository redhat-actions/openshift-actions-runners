#!/usr/bin/env bash

INSTALLER_TMP=/tmp/tool-installer/
INSTALL_TARGET_DIR=/usr/local/bin/

if [[ -n $DEV_INSTALL_TARGET_DIR ]]; then
    # Use this for testing the script without installing into your system dirs
    echo "Using override install target $DEV_INSTALL_TARGET_DIR"
    INSTALL_TARGET_DIR=$DEV_INSTALL_TARGET_DIR
fi

die() {
    echo >&2 "Error: $1"
    exit 1
}

assert_env_var() {
    local var=$1
    local value=$(eval echo "\$$var")
    echo "${var}=${value}"
    if [[ -z $value ]]; then
        die "$var not specified in environment"
    fi
}

extract() {
    extract_result=""

    local archive_name=$1
    local executable_name=$2
    local extract_dir=${INSTALLER_TMP}${executable_name}

    mkdir -vp $extract_dir

    if [[ $archive_name == *.tar* ]]; then
        echo "Extracting $archive_name"
        # -o is required due to https://discuss.circleci.com/t/tar-cannot-change-ownership/28766
        tar -axvof $archive_name -C $extract_dir
    elif [[ $archive_name =~ *\.zip ]]; then
        echo "Extracting $archive_name"
        unzip $archive_name -d $extract_dir
    else
        die "Unrecognized zip file '$archive_name'"
        exit 1
    fi

    # Return using global var
    extract_result=$(find $extract_dir -type f -iname "$executable_name*")

    if [[ -z $extract_result ]]; then
        die "Could not find $executable_name in $extract_dir after extraction"
    fi
}

move_executable() {
    local executable_path=$1
    local executable_name=$2
    chmod a+x $executable_path
    mv -v $executable_path $INSTALL_TARGET_DIR$executable_name

    echo "Installed $executable_name to $INSTALL_TARGET_DIR"
}

install() {
    local executable_name=$1
    local url=$2
    local download_filename=$(basename $url)
    echo "Downloading $2 to $download_filename ..."
    curl -fLsSO $url

    local extname=${download_filename#*.}

    if [[ $extname == $download_filename ]]; then
        # if extname == download_filename then there is no extension, we got just the executable
        if [[ $download_filename != $executable_name ]]; then
            mv -v $download_filename $executable_name
        fi
        local executable_path=$executable_name
    else
        # otherwise, we have to extract it
        extract $download_filename $executable_name

        # Global extract_result is the set in extract
        local executable_path=$extract_result

        if [[ $executable_name == "oc" ]]; then
            # special case for oc targz which also contains kubectl
            local oc_path=$extract_result

            extract $download_filename "kubectl"
            local kubectl_path=$extract_result
            move_executable $kubectl_path "kubectl"

            # Reset
            extract_result=$oc_path
        fi
    fi

    move_executable $executable_path $executable_name
    rm -fv $download_filename

    echo
    echo "========================================"
}

# set -x
set -eEu -o pipefail

MIRROR="https://mirror.openshift.com/pub/openshift-v4/x86_64/clients"

mkdir -vp $INSTALLER_TMP

assert_env_var "HELM_VERSION"
install helm ${MIRROR}/helm/${HELM_VERSION}/helm-linux-amd64.tar.gz

assert_env_var "KN_VERSION"
install kn ${MIRROR}/serverless/${KN_VERSION}/kn-linux-amd64-${KN_VERSION}.tar.gz

assert_env_var "OC_VERSION"
install oc ${MIRROR}/ocp/${OC_VERSION}/openshift-client-linux.tar.gz

assert_env_var "TKN_VERSION"
install tkn ${MIRROR}/pipeline/${TKN_VERSION}/tkn-linux-amd64-${TKN_VERSION}.tar.gz

assert_env_var "YQ_VERSION"
install yq https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64.tar.gz

echo "Removing $INSTALLER_TMP"
rm -rf $INSTALLER_TMP
