#!/usr/bin/env bash

installer_tmp=/tmp/tool-installer/
install_target=/usr/local/bin/

# create and use .bin/ for testing the script
# install_target=.bin/

die() {
    echo >&2 $1
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
    local extract_dir=${installer_tmp}${executable_name}

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
    extract_result=$(find $extract_dir -type f -iname $executable_name)
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
    fi

    chmod a+x $executable_path
    mv -v $executable_path $install_target
    rm -rfv $download_filename

    echo "Installed $executable_name to $install_target"
    echo
    echo "========================================"
}

# set -x
set -eEu -o pipefail

mkdir -vp $installer_tmp

assert_env_var "HELM_VERSION"
install helm https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz

assert_env_var "KN_VERSION"
install kn https://github.com/knative/client/releases/download/v${KN_VERSION}/kn-linux-amd64

assert_env_var "KUBECTL_VERSION"
install kubectl https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl

assert_env_var "OC_VERSION"
install oc https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OC_VERSION}/openshift-client-linux.tar.gz

assert_env_var "TKN_VERSION"
install tkn https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz

echo "Removing $installer_tmp"
rm -rf $installer_tmp
