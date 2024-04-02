<?php
set_error_handler(function ($severity, $message, $file, $line) {
    throw new \ErrorException($message, $severity, $severity, $file, $line);
});

$fileContent = file_get_contents('patch-helper-output.txt');

$lines = array_filter(explode("\n", $fileContent));

function getTable($lines, $type) {
    $data = array_filter($lines, function ($line) use ($type) {
        return (str_contains($line, " $type ") || str_contains($line, ' Level ') || str_contains($line, '-----'));
    });

    $header = [];
    $content = [];
    foreach ($data as $line) {
        if (str_contains($line, 'Level') && str_contains($line, 'To Check')) {
            $parts = array_filter(explode('|', $line));
            array_shift($parts);
            $header = $parts;
            continue;
        }
        if (str_contains($line, $type)) {
            $parts = array_filter(explode('|', $line));
            array_shift($parts);
            $content[] = $parts;
            continue;
        }
    }

    $table = [];

    $table[] = '| '.  implode(' | ', $header) . '|' . PHP_EOL;
    $divider = '| ';
    for ($i=0; $i<count($header); $i++) {
        $divider .= '-------|';
    }
    $divider .= PHP_EOL;
    $table[] = $divider;

    foreach ($content as $entry) {
        $table[] = '| '.  implode(' | ', $entry) . '|' . PHP_EOL;
    }


    return PHP_EOL . implode('', $table) . PHP_EOL . PHP_EOL;

}

function getWarnCount($lines) {
    foreach ($lines as $line) {
        if (str_contains($line, 'WARN count:')) {
            return $line;
        }
    }
    return '';
}

function getInfoCount($lines) {
    foreach ($lines as $line) {
        if (str_contains($line, 'INFO count:')) {
            return $line;
        }
    }
    return '';
}

$output = "## magento2-upgrade-patch-helper" . PHP_EOL . PHP_EOL;
$output .= getWarnCount($lines) . PHP_EOL;
$output .= getInfoCount($lines) . PHP_EOL . PHP_EOL;
$output .= "Navigate to download [vendor_files_to_check.patch](" . getenv('CURRENT_RUN_URL') . ")" . PHP_EOL;
$output .= "Github action powered by [convenient/magento2-upgrade-patch-helper-github-action](https://github.com/convenient/magento2-upgrade-patch-helper-github-action)" . PHP_EOL;
$output .= "For docs on each check see [CHECKS_AVAILABLE.md](https://github.com/AmpersandHQ/ampersand-magento2-upgrade-patch-helper/blob/master/docs/CHECKS_AVAILABLE.md)" . PHP_EOL . PHP_EOL;
$output .= "<details>" . PHP_EOL .
    "<summary>metadata</summary>" .
    'upgrade_patch_helper_metadata_do_not_reproduce_this_string_in_another_comment_or_it_will_confuse_matters' . PHP_EOL .
    'BRANCH_TO:' . getenv('GITHUB_HEAD_REF') . PHP_EOL  .  PHP_EOL.
    'BRANCH_FROM:' . getenv('GITHUB_BASE_REF') . PHP_EOL . PHP_EOL .
    "</details>"
    . PHP_EOL . PHP_EOL;
$output .= "## Warnings" . PHP_EOL . PHP_EOL;
$output .= getTable($lines, 'WARN');
$output .= "## Information" .  PHP_EOL;
$info  = getTable($lines, 'INFO');
$output .= "<details>" . PHP_EOL . "<summary>Click to see INFO</summary>" . PHP_EOL . PHP_EOL .$info . PHP_EOL . "</details>";
$output .= PHP_EOL;

echo $output;
