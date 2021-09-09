local ThoughtBox = require "ThoughtBox"
local ThoughtIO = {}

function ThoughtIO.lookupTitleAndTagsAndLinks(folder, name, read_cmd)
    local file = folder..name..'.tb'
    if read_cmd ~= nil then
        local pfile = io.popen(read_cmd..' -m '..name)
        local name = ''
        local content = ''
        local res = {title=nil, tags={}, links={}, file=file}
        local parts = {}
        local line = ''
        for line in pfile:lines() do
            parts = Utils.splitString(line,':',1)
            if parts[1] == 'tags' then
                local tags = Utils.splitString(parts[2],',%s*')
                for i,tag in ipairs(tags) do
                    tag = Utils.stripString(tag)
                    if string.len(tag) > 0 then
                        table.insert(res.tags, tag)
                    end
                end

            elseif parts[1] == 'links' then
                local links = Utils.splitString(parts[2],',%s*')
                for i,link in ipairs(links) do
                    link = Utils.stripString(link)
                    if string.len(link) > 0 then
                        table.insert(res.links, link)
                    end
                end
            elseif parts[1] == 'back links' then
                -- Do nothing
            else 
                res.title = Utils.stripString(parts[2])
            end
        end
        pfile:close()
        return res
    else
        io.input(file)
        local lines = {}
        for line in io.lines() do  
            table.insert(lines,line) 
        end

        local thought_content = ThoughtBox.parseThoughtContent(lines, name)
        return {title=thought_content.title, tags=thought_content.tags, links=thought_content.links, file=file}
    end
end

function ThoughtIO.readThoughtsTitleAndTags(folder, name_list, read_cmd)
    local thoughts = {}
    if false and read_cmd ~= nil then
        local pfile = io.popen(read_cmd..' -d')
        local name = ''
        local content = ''
        local parts = {}
        local line = ''
        local current = ''
        local file = ''
        for line in pfile:lines() do
            parts = Utils.splitString(line,':',1)
            if parts[1] == 'tags' then
                local tags = Utils.splitString(parts[2],',%s*')
                for i,tag in ipairs(tags) do
                    tag = Utils.stripString(tag)
                    if string.len(tag) > 0 then
                        table.insert(thoughts[current].tags, tag)
                    end
                end

            elseif parts[1] == 'links' then
                local links = Utils.splitString(parts[2],',%s*')
                for i,link in ipairs(links) do
                    link = Utils.stripString(link)
                    if string.len(link) > 0 then
                        table.insert(thoughts[current].links, link)
                    end
                end
            elseif parts[1] == 'back links' then
                -- Do nothing
            else 
                current = parts[1]
                local file = folder..current..'.tb'
                thoughts[current] = {title=nil, tags={}, links={}, file=file}
                thoughts[current].title = Utils.stripString(parts[2])
            end
        end
        pfile:close()

    else
        for i,name in ipairs(name_list) do
            thoughts[name] = ThoughtIO.lookupTitleAndTagsAndLinks(folder, name, read_cmd)
        end
    end
    return thoughts
end

function compareTags(tag1, tag2)
    return string.lower(tag1) < string.lower(tag2)
end

function ThoughtIO.groupByTags(thoughts)
    local result = {}
    for k,thought in pairs(thoughts) do
        for j,tag in ipairs(thought.tags) do
            if result[tag] == nil then
                result[tag] = {}
            end
            table.insert(result[tag],k)
        end
    end
    local sorted_keys = {}
    for k,v in pairs(result) do
        table.insert(sorted_keys, k)
    end
    table.sort(sorted_keys, compareTags)
    return {result, sorted_keys}
end


return ThoughtIO
