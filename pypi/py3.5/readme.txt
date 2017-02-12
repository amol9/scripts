pypi.py
-------

A python (3.5+) script to display download stats of python packages on PyPI. It uses the new async/await feature of python 3.5 to do this concurrently for multiple packages.


Usage
-----

The script expects a file, "packages.txt" to be present in the same directory. The file should contain the package names, one name on each line.

e.g.
> cat packages.txt
twisted
six
wallp
aiohttp

Running the script:
> python pypi.py

package             :     day    week   month

wallp               :       0       0       0
six                 :       0       0       0
Twisted             :       0       0       0
aiohttp             :       0       0       0


Dependencies
------------

1. aiohttp (> pip install aiohttp)

For making asynchronous http requests.
