A BASH script to print download statistics for PyPI packages.

Usage:

1. If called without an argument, it gets statistics for all packages in the list (variable in the script).
 e.g. > ./pypi.sh

2. If called with a package name as the first argument, it gets statistics for that package only.
 e.g. > ./pypi.sh six

3. If variable, 'do_parallel' is true, curl requests are made in parallel using gnu parallel. Else, requests are made serially.


