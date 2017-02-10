import re
from os.path import join as joinpath, exists
import os

import httplib2
from redcmd.api import maincmd, execute_commandline


@maincmd
def main(album, dest='.'):
    ''' Downloads upto first 10 images from an imgur album.
    album : imgur album id
    dest: destination folder
    '''

    http = httplib2.Http()
    (_, c) = http.request("http://imgur.com/a/" + album)

    rx = re.compile(r'/.{7}\.jpg')
    mt = set(rx.findall(str(c)))

    if not exists(dest):
        os.makedirs(dest)

    print ('gettimg images: ', end='', flush=True)
    for i, m in enumerate(mt):
        print('%02d, '%i, end='', flush=True)
        (_, c) = http.request('http://i.imgur.com' + m)
        ext = m.split('.')[-1]
        with open(joinpath(dest, '%02d.'%i + ext), 'wb') as f:
            f.write(c)
        f.close()

    print('done')

execute_commandline()
