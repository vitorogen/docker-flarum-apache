#!/bin/sh
set -e

update_phpini() {
    sed -i "s/^memory_limit.*/memory_limit = $PHP_MEMORY_LIMIT/" $PHP_INI_DIR/php.ini
    sed -i "s/^upload_max_filesize.*/upload_max_filesize = $UPLOAD_MAX_SIZE/" $PHP_INI_DIR/php.ini
}

update_phpini

exec "$@"