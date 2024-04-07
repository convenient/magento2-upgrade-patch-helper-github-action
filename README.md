# magento2-upgrade-patch-helper-github-action

This github action handles the running of https://github.com/AmpersandHQ/ampersand-magento2-upgrade-patch-helper

This will give you an actionable list of things to review when upgrading a Magento instance, or a magento module/library/theme. 

For example, if you have overridden theme files which need to be updated based on the new `vendor/some/module/file.phtml` then this will be listed in the report.

## Example output

![Screenshot 2024-04-07 at 15 52 09](https://github.com/convenient/magento2-upgrade-patch-helper-github-action/assets/600190/c8a44603-a8d3-4e18-acad-63cc9c6ded43)

## Prerequisites

### Frontend themes 

For a complete scan to be completed it must be possible to run `bin/magento setup:static-content:deploy` when no database connection is present. 

Ensure the websites/stores and themes [are dumped](https://experienceleague.adobe.com/en/docs/commerce-operations/configuration-guide/cli/configuration-management/export-configuration) into `app/etc/config.php` 

### Repository Authentication

This github action handles no authentication with repo.magento.com or any other packagist repository.

Prior to running this action ensure an `auth.json` has been created, for example

```diff
    - name: Checkout repository
      uses: actions/checkout@v4
    
+   - name: Generate auth.json
+     env:
+       USERNAME: ${{ secrets.PACKAGIST_USERNAME }}
+       PASSWORD: ${{ secrets.PACKAGIST_PASSWORD }}
+     run: |
+       printf '{\n    "http-basic": {\n        "repo.packagist.com": {\n            "username": "${USERNAME}",\n            "password": "${PASSWORD}"\n        }\n    }\n}' > auth.json

    - name: Run magento2 upgrade patch helper
      uses: convenient/magento2-upgrade-patch-helper-github-action@1.0.0
```

# Configuration

```yml
  - name: Run magento2 upgrade patch helper
    uses: convenient/magento2-upgrade-patch-helper-github-action@1.0.0
    with:
      # Optional: Upload artifacts for use with https://github.com/elgentos/magento2-upgrade-gui
      with-gui-artifacts: true
      # Optional: The subdirectory Magento is stored in                  
      working-dir: 'some_subdir'                
      # Optional: Pipe separated list of vendors that will not trigger the tool
      vendor-filter: 'some/package|some_vendor' 
```

## Examples

### Triggered by a github label

If you would like to run this tool on demand, you can trigger it with a github label.

```yml
name: Magento2 Upgrade Patch Helper

on:
  pull_request:
    types: [labeled]

jobs:
  magento2-upgrade-patch-helper:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
    steps:

      - name: Remove RunUpgradePatchHelper Label
        if: github.event.label.name == 'RunUpgradePatchHelper'
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.removeLabel({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              name: 'RunUpgradePatchHelper'
            });

      - name: Checkout repository
        if: github.event.label.name == 'RunUpgradePatchHelper'
        uses: actions/checkout@v4

      - name: Run magento2 upgrade patch helper
        if: github.event.label.name == 'RunUpgradePatchHelper'
        uses: convenient/magento2-upgrade-patch-helper-github-action@1.0.0
```

### Triggered by a opened pull request

If you would like this tool to run on every pull request that touches `composer.lock` you can configure it like so.

```yml
name: Magento2 Upgrade Patch Helper

on:
  pull_request:
    paths:
      - 'composer.lock'
    types: [opened, synchronize]

jobs:
  magento2-upgrade-patch-helper:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
    steps:

      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Run magento2 upgrade patch helper
        uses: convenient/magento2-upgrade-patch-helper-github-action@1.0.0
```
