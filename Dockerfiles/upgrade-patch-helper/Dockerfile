# Based on ../PHP/Dockerfile, was having docker caching issues with the multi php builds so separating into a different
# image is a sure set way of preventing the additional build time
FROM convenient/magento2-upgrade-patch-helper-github-action:php-2024-04-07

COPY entrypoint.sh /entrypoint.sh
COPY generate-output.php /generate-output.php
COPY pick-php-and-composer-versions.php /pick-php-and-composer-versions.php

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
