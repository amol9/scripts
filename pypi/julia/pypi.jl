import Requests: get, json

base_url = "https://pypi.python.org/pypi/"
package_list_file = "packages.txt"

make_pypi_url = p::String -> string(base_url, p, "/json")

function parse_json(j::Dict)::Tuple{Int, Int, Int}
    dls = j["info"]["downloads"]
    dls["last_day"], dls["last_week"], dls["last_month"]
end

function get_stats()
    packages = strip.(read_package_list())
    @printf("%-15s: %7s %7s %7s\n", "package", "day", "week", "month")

    @sync begin         # will wait for all enclosed async tasks to complete
        for package in packages
            @async begin
                j = json(get(make_pypi_url(package)))
                d, w, m = parse_json(j)
                o = @sprintf("%-15s: %7d %7d %7d", package, d, w, m)
                println(o)          # have to sprintf to a string and then println to avoid intermingled output
            end
        end
    end
end

function read_package_list()::Array{String}
    try
        readlines(open(package_list_file))
    catch e
        println("error opening packages.txt")
        quit()
    end
end

function main()
    get_stats()
end

main()
