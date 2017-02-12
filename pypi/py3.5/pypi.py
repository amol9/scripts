import asyncio
import aiohttp
import json


base_url                = 'https://pypi.python.org/pypi/%s/json'
loop                    = asyncio.get_event_loop()
client                  = aiohttp.ClientSession(loop=loop)
package_list_filename   = 'packages.txt'


async def get_pypi_json(package):
    url = base_url%package
    async with client.get(url) as response:
        return await response.read()


async def print_pypi_stats(package):
    json_b = await get_pypi_json(package)
    stats = parse_json(json_b.decode())
    print(stats)


def parse_json(json_str):
    jdata = json.loads(json_str)
    package = jdata['info']['name']
    downloads = jdata['info']['downloads']
    ld, lw, lm = downloads['last_day'], downloads['last_week'], downloads['last_month']
    return '%-20s: %7d %7d %7d'%(package, ld, lw, lm)


def get_package_list():
    with open(package_list_filename) as f:
        return f.read().splitlines()


def main():
    packages = get_package_list()
    print('\n%-20s: %7s %7s %7s\n'%('package', 'day', 'week', 'month'))

    coroutines = [print_pypi_stats(p) for p in packages]
    loop.run_until_complete(asyncio.gather(*coroutines, loop=loop))

    client.close()
    loop.close()

if __name__ == '__main__':
    main()
