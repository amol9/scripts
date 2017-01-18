Vdo-Wallp

A powershell cmdlet to extract an image frame from a video file on disk or from a gif/webm/video url.

Usage:

> Vdo-Wallp -url https://gfycat.com/SomeTripleCombination -time 00:00:03
> Vdo-Wallp -url http://somesite.com/interesting.gif
> Vdo-Wallp -url c:\cool.mp4

Try out wallpapers by advancing through the video 1 second at a time.

> Vdo-Wallp -url https://gfycat.com/SomeTripleCombination -play


Note:

1. Gfycat urls are processed so that a direct link to a gif or a webm file is not needed.
2. Downloaded files are cached for faster access in user's home directory in vdo_wallp\cache.


Dependencies:

1. wallp (wallpaper utility written in python). It is needed to auto calculate the wallpaper style. If not present, wallpaper will change, but without auto style adjustment.
