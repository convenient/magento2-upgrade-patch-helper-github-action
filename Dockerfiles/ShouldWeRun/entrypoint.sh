#!/bin/ash
# shellcheck shell=dash
set -Eeu

prerequisites() {
    if [ -z "${WORKING_DIRECTORY-}" ]; then
        echo "WORKING_DIRECTORY is not set. Skipping directory change."
    else
        echo "Changing to $WORKING_DIRECTORY"
        cd "$WORKING_DIRECTORY" || exit 1
    fi

    if [ ! -e "composer.lock" ]; then
        echo "Error: composer.lock does not exist."
        exit 1
    fi

    cp /output-not-needed.md output-not-needed.md
    cp /output-see-previous-comment.md output-see-previous-comment.md
}

prepare_git_repo() {
    echo "Setting $GITHUB_WORKSPACE as a git safe directory"
    git config --global --add safe.directory "$GITHUB_WORKSPACE"
    echo "Creating a branch for $GITHUB_HEAD_REF"
    git checkout -b "$GITHUB_HEAD_REF"              # Create a branch to go back to from the current ref
    echo "Fetching shallow origin for $GITHUB_BASE_REF"
    git fetch origin "$GITHUB_BASE_REF" --depth 1   # Fetch the target branch
}

run() {
    if ! grep -q '"name": "magento/framework"' "./composer.lock"; then
        echo "composer.lock does not contain magento"
        exit 1
    fi

    git show origin/"$GITHUB_BASE_REF":./composer.lock > composer.lock.original

    if ! grep -q '"name": "magento/framework"' "./composer.lock.original"; then
        echo "composer.lock.original does not contain magento"
        exit 1
    fi

    echo "Getting versions and packages for the current branch"
    jq -r '.packages[] | select(.type == "magento2-library" or .type == "magento2-module" or .type == "magento2-theme") | "\(.name)@\(.version)"' composer.lock          | sort > packages-current.list
    echo "Getting versions and packages for the target branch"
    jq -r '.packages[] | select(.type == "magento2-library" or .type == "magento2-module" or .type == "magento2-theme") | "\(.name)@\(.version)"' composer.lock.original | sort > packages-original.list

    if ! grep -q 'magento/framework' "./packages-current.list"; then
        echo "packages-current.list does not contain magento"
        exit 1
    fi

    if ! grep -q 'magento/framework' "./packages-original.list"; then
        echo "packages-original.list does not contain magento"
        exit 1
    fi

    if [ -z "${VENDOR_FILTER-}" ]; then
        echo "VENDOR_FILTER is not set. Skipping filtering."
    else
        echo "VENDOR_FILTER is set as $VENDOR_FILTER"
        grep -Ev "$VENDOR_FILTER" packages-original.list > packages-original.list.tmp
        grep -Ev "$VENDOR_FILTER" packages-current.list > packages-current.list.tmp
        mv packages-original.list.tmp packages-original.list
        mv packages-current.list.tmp packages-current.list
    fi

    echo "Comparing packages-original.list to packages-current.list"
    if ! diff -u packages-original.list packages-current.list; then
        echo "Setting SHOULD_RUN_UPGRADE_HELPER=yes"
        echo "SHOULD_RUN_UPGRADE_HELPER=yes" >> "$GITHUB_ENV"
    else
        echo "Setting SHOULD_RUN_UPGRADE_HELPER=no"
        echo "SHOULD_RUN_UPGRADE_HELPER=no" >> "$GITHUB_ENV"
    fi
}

prerequisites
prepare_git_repo
run
