<?php
set_error_handler(function ($severity, $message, $file, $line) {
    throw new \ErrorException($message, $severity, $severity, $file, $line);
});

if (!isset($argv[1])) {
    $version = '9.9.9-could-not-find-mage-version-in-composer-lock';
} else {
    $version = $argv[1];
}

echo "Identifying PHP and composer versions for $version" . PHP_EOL;

$phpPrimary = $phpSecondary = null;
$composer = null;

/*
 * These match the composer versions and the php versions in the dockerfile
 */
if (version_compare($version, '2.4.1', '<')) {
    $phpPrimary = '7.4.33';
    $composer = 'composer1';
} elseif (version_compare($version, '2.4.4', '<')) {
    $phpPrimary = '7.4.33';
    $composer = 'composer1';
} elseif (version_compare($version, '2.4.6', '<')) {
    $phpPrimary = '8.1.6';
    $composer = 'composer22';
} elseif (version_compare($version, '2.4.7', '<')) {
    $phpPrimary = '8.2.16';
    $phpSecondary = '8.1.6';
    $composer = 'composer22';
} else {
    $phpPrimary = '8.3.3';
    $phpSecondary = '8.2.16';
    $composer = 'composer2';
}

file_put_contents('configure-env.sh', "export COMPOSER_VERS=$composer " . PHP_EOL);
file_put_contents('configure-env.sh', "export PHP_PRIMARY=$phpPrimary " . PHP_EOL, FILE_APPEND);
if ($phpSecondary) {
    file_put_contents('configure-env.sh', "export PHP_SECONDARY=$phpSecondary " . PHP_EOL, FILE_APPEND);
} else {
    file_put_contents('configure-env.sh', "unset PHP_SECONDARY " . PHP_EOL, FILE_APPEND);
}

echo "Generated configure-env.sh" . PHP_EOL;
echo file_get_contents('configure-env.sh') . PHP_EOL;