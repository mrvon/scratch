local lfs = require "lfs"
local md5 = require "md5"

local NEW_IMAGE_LIBRARY = "./new_image_library/"
local OLD_IMAGE_LIBRARY = "./old_image_library/"

local COMPRESSED_LIBRARY = "./compressed_library"

local EXPORT_COMPRESSED_PATH = "./export_compressed"
local EXPORT_UNCOMPRESS_PATH = "./export_uncompress"

local DIR_SEPARATOR = "/"

function filename_filter(filename)
    if filename == "." or filename == ".." then
        return false
    end

    return true
end

function traverse(path)
    for filename in lfs.dir(path) do
        if filename_filter(filename) then
            local absolute_filename = path .. DIR_SEPARATOR .. filename

            local file_attribute = lfs.attributes(absolute_filename)
            assert(type(file_attribute) == "table")

            if file_attribute.mode == "directory" then
                traverse(absolute_filename)
            else
                diff(absolute_filename)
            end
        end
    end
end

function add_root_path(absolute_filename, root_path)
    return root_path .. absolute_filename
end

function remove_root_path(absolute_filename, root_path)
    local pattern = string.format("^%s", root_path)
    local new_path = string.gsub(absolute_filename, pattern, "")
    return new_path
end

function change_root_path(filename, old_root, new_root)
    return add_root_path(remove_root_path(filename, old_root), new_root)
end

function aux_mkdir(dir, start)
    if start then
        lfs.mkdir(dir)
    end
end

function recursive_mkdir(dir, start)
    local index = string.find(dir, DIR_SEPARATOR, start)
    if index then
        aux_mkdir(string.sub(dir, 1, index), start)
        recursive_mkdir(dir, index + 2)
    end
end

function mkdir(dir)
    recursive_mkdir(dir)
end

-- mkdir("./Hello/World")
-- mkdir("E:/Foo/Goo/Too/")

function copy_file(source_filename, target_filename)
    mkdir(target_filename)

    local s_file = assert(io.open(source_filename, "r"))
    local s_content = s_file:read("*a")
    s_file:close()

    local t_file = assert(io.open(target_filename, "a"))
    t_file:write(s_content)
    t_file:flush()
    t_file:close()
end

function diff(absolute_filename)
    local diff_filename = change_root_path(absolute_filename, NEW_IMAGE_LIBRARY, OLD_IMAGE_LIBRARY)

    local a_file = assert(io.open(absolute_filename, "r"))
    local a_content = a_file:read("*a")
    io.close(a_file)

    local d_file = assert(io.open(diff_filename, "r"))
    local d_content = d_file:read("*a")
    io.close(d_file)

    if a_content == d_content then
        local compressed_filename = change_root_path(absolute_filename, NEW_IMAGE_LIBRARY, EXPORT_COMPRESSED_PATH)
        copy_file(absolute_filename, compressed_filename)
    else
        local uncompress_filename = change_root_path(absolute_filename, NEW_IMAGE_LIBRARY, EXPORT_UNCOMPRESS_PATH)
        copy_file(absolute_filename, uncompress_filename)
    end
end

traverse(NEW_IMAGE_LIBRARY)
