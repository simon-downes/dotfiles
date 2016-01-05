#!/bin/bash
#
# Run the PHP linter for any PHP files in the current directory and below
#
function lint {
    find $1 -name "*.php" -exec php -l {} \;
}
