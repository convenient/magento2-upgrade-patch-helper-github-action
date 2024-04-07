#!/usr/bin/env bash
set -Eeuxo pipefail
err_report() {
    echo "Error on line $1"
    exit 1;
}
trap 'err_report $LINENO' ERR
export GITHUB_WORKSPACE='/github/workspace'; # because we're manually handling these for deferred pulling of the image
# TODO alter -VVV running to stderr so we can capture it separately in the logs

change_to_magento_directory() {
    cd "$GITHUB_WORKSPACE"
    if [ -z "${WORKING_DIRECTORY-}" ]; then
        echo "WORKING_DIRECTORY is not set. Skipping directory change."
    else
        echo "Changing to $WORKING_DIRECTORY"
        cd "$WORKING_DIRECTORY" || exit 1
    fi
}

prerequisites() {
    # This expects that the should-we-execute dockerfile has executed already, as that configures some git repo prerequisites
    cd "$GITHUB_WORKSPACE"

    git config --global --add safe.directory "$GITHUB_WORKSPACE"

    change_to_magento_directory

    if [[ ! -e "composer.lock" ]]; then
        echo "Error: composer.lock does not exist."
        exit 1
    fi

    if [[ ! -e "composer.json" ]]; then
        echo "Error: composer.json does not exist."
        exit 1
    fi

    export COMPOSER_MEMORY_LIMIT=4G
    export COMPOSER_NPM_BRIDGE_DISABLE=1
    export COMPOSER_PATCHES_GRACEFUL=true

    for ini in /root/.phpenv/versions/*/etc/conf.d/xdebug.ini
    do
      [[ -e "$ini" ]] || break
      mv "$ini" "$ini.bak"
    done

    export PATH="/root/.phpenv/bin:$PATH"
    ln -s -f /root/.phpenv/versions/8.3.3/bin/php /root/.phpenv/bin/php
    which php
    php --version
    which composer2
    composer2 --version
}

install_patch_helper() {
    mkdir /patch-helper/
    cd /patch-helper/
    wget "$REPO_URL/archive/master.zip"
    unzip -q master.zip
    cd ampersand-magento2-upgrade-patch-helper-master
    composer2 install --no-dev --no-interaction
    export PATH="/patch-helper/ampersand-magento2-upgrade-patch-helper-master/bin:$PATH"
}

generate_vendor_orig() {
    change_to_magento_directory;
    git checkout "$GITHUB_BASE_REF"
    pick_php_and_composer

    if [ -z "${PHP_SECONDARY-}" ]; then
        $COMPOSER_VERS install --no-interaction --no-scripts --no-plugins --ignore-platform-reqs
    else
        if $COMPOSER_VERS install --no-interaction --no-scripts --no-plugins --ignore-platform-reqs; then
          echo "COMPOSER_INSTALL_WITH_PHP_PRIMARY=PASS"
        elif rm -rf vendor && ln -s -f /root/.phpenv/versions/"$PHP_SECONDARY"/bin/php /root/.phpenv/bin/php && $COMPOSER_VERS install --no-interaction --no-scripts --no-plugins --ignore-platform-reqs; then
          echo "COMPOSER_INSTALL_WITH_PHP_SECONDARY=PASS"
        else
          echo "COMPOSER_INSTALL_WITH_PHP_SECONDARY=FAIL"
          false
        fi
    fi

    mv vendor/ vendor_orig/
}

run_patch_helper() {
    change_to_magento_directory
    git checkout "$GITHUB_HEAD_REF"
    pick_php_and_composer

    if [ -z "${PHP_SECONDARY-}" ]; then
        $COMPOSER_VERS install --no-interaction --ignore-platform-reqs
    else
        if $COMPOSER_VERS install --no-interaction --ignore-platform-reqs; then
          echo "COMPOSER_INSTALL_WITH_PHP_PRIMARY=PASS"
        elif rm -rf vendor && ln -s -f /root/.phpenv/versions/"$PHP_SECONDARY"/bin/php /root/.phpenv/bin/php && $COMPOSER_VERS install --no-interaction --ignore-platform-reqs; then
          echo "COMPOSER_INSTALL_WITH_PHP_SECONDARY=PASS"
        else
          echo "COMPOSER_INSTALL_WITH_PHP_SECONDARY=FAIL"
          false
        fi
    fi

    # Diff them and generate a report
    diff -urN vendor_orig vendor > vendor.patch || true
    patch-helper.php analyse --show-info --sort-by-type . | tee ./patch-helper-output.txt

    if [[ ! -s "./patch-helper-output.txt" ]]; then
        echo "Error: ./patch-helper-output.txt is empty."
        exit 1
    fi

    export CURRENT_RUN_URL="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
    /root/.phpenv/versions/8.3.3/bin/php /generate-output.php > patch-helper-output-formatted.md

    $COMPOSER_VERS dump --classmap-authoritative
    /root/.phpenv/versions/8.3.3/bin/php -r "\$classmap=require_once('vendor/composer/autoload_classmap.php'); echo json_encode(\$classmap);" > classmap.json
}

pick_php_and_composer() {
    /root/.phpenv/versions/8.3.3/bin/php /pick-php-and-composer-versions.php "$(jq -r '.packages[] | select(.name | contains("magento/product-community-edition") or contains("magento/product-enterprise-edition")) | .version' ./composer.lock)"
    cat ./configure-env.sh
    # shellcheck source=/dev/null
    . ./configure-env.sh && rm ./configure-env.sh
    ln -s -f /root/.phpenv/versions/"$PHP_PRIMARY"/bin/php /root/.phpenv/bin/php
    $COMPOSER_VERS self-update # This will bring us to the latest 2.2, or latest 2.x depending on which bin was picked
    php --version
}
prerequisites
install_patch_helper
generate_vendor_orig
run_patch_helper
