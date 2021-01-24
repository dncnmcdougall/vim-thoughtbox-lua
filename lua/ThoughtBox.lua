Utils = require "Utils"

local ThoughtBox = {}

function splitName(name)
    local _, last_dot = string.find(name, '.*%.')
    if last_dot ~= nil then
        name = string.sub(name, 0, last_dot-1)
    end
    local parts = {}
    local i = 0
    local j = 0
    local k = 1
    local len = string.len(name)
    i,j = string.find(name, '%a+')
    while j ~= nil do
        if k <= i-1 then table.insert(parts, string.sub(name, k,i-1)) end
        table.insert(parts, string.sub(name, i, j))
        k = j+1
        i,j = string.find(name, '%a+', k)
    end
    if k <= len then table.insert(parts, string.sub(name, k)) end
    return parts
end

function incPart(part)
    local code = string.byte(part,-1) 
    if code < 123 and code > 96 then
        local result = {}
        local len = string.len(part)
        local inc = true
        for j=1,len do
            code = string.byte(part,-j)
            if inc then code = code + 1 end
            if code == 123 then
                code = 97
                inc = true
            else
                inc = false
            end 
            table.insert(result, string.char(code))
        end
        if inc then
            table.insert(result, 'a')
        end
        return string.reverse(table.concat(result, ''))
    else
        return tostring(tonumber(part)+1)
    end
end



function compareParts(part1, part2)
    local len1 = string.len(part1)
    local len2 = string.len(part2)
    if len1 < len2 then 
        return -1
    elseif len1 > len2 then
        return 1
    end
    for i =1,len1 do
        if string.sub(part1, i,i) < string.sub(part2,i,i) then
            return -1
        elseif string.sub(part1, i,i) > string.sub(part2,i,i) then
            return 1
        end
    end
    return 0
end

function compareNameParts(name1_parts, name2_parts)
    local len1 = table.getn(name1_parts)
    local len2 = table.getn(name2_parts)
    local len_min = math.min(len1, len2)
    local comp = 0
    for i =1,len_min do
        comp = compareParts(name1_parts[i], name2_parts[i]) 
        if comp < 0 then
            return true
        elseif comp > 0 then
            return false
        end
    end
    if len1 < len2 then 
        return true
    elseif len1 > len2 then
        return false
    else 
        return false
    end
end

function splitAndSortNames(names)
    local name_parts = {}
    for i,name in pairs(names) do
        table.insert(name_parts, splitName(name))
    end
    table.sort(name_parts, compareNameParts)
    return name_parts
end

function ThoughtBox.sortNames(names)
    local name_parts = splitAndSortNames(names)
    local new_names = {}
    for i,name in pairs(name_parts) do
        table.insert(new_names, table.concat(name,''))
    end
    return new_names
end

function ThoughtBox.parseThoughtContent(lines, name)
    local res = {title=nil, content={}, tags={}, sources={}, links={}}
    local heading = nil
    for i,line in ipairs(lines) do
        if string.sub(line, 1,2) == '# ' then
            line = Utils.stripString(string.sub(line,3))
            if heading == nil then
                heading = 'content'
                res.title = line
            else
                heading = line
            end
        elseif  res[heading] ~= nil then
            table.insert(res[heading], line)
        else
            print('Warning did not understand heading '..heading..' in '..name)
        end
    end
    local tag = nil
    local res_tags = {}
    for i,line in ipairs(res.tags) do
        line = Utils.stripString(line)
        if string.len(line) > 0 then 
            local tags = Utils.splitString(Utils.stripString(line),',%s*')
            for i,tag in ipairs(tags) do
                tag = Utils.stripString(tag)
                if string.len(tag) > 0 then
                    table.insert(res_tags, tag)
                end
            end
        end
    end
    res.tags = res_tags
    local link = nil
    for i,line in ipairs(res.content) do
        local matches = string.gmatch(line, '%[%[.*%]%]')
        for m in matches do
            link = string.sub(m,3,-3)
            table.insert(res.links, link)
        end
    end
    return res
end


function ThoughtBox.findNextName(split_names, name) 
    local name_parts = splitName(name)
    local len = #name_parts

    if len == 0 or string.find(name_parts[len],'%a') ~= nil then
        table.insert(name_parts,'1')
    else
        table.insert(name_parts,'a')
    end

    for i=1,#split_names do
        local fparts = split_names[i]
        local lengths_match = #fparts >= len+1
        local parts_match = true
        for j=1,(len+1) do
            if fparts[j] ~= name_parts[j] then
                parts_match = false
                break
            end
        end
        if lengths_match and parts_match and fparts[len+1] == name_parts[len+1] then
            name_parts[len+1]  =incPart(name_parts[len+1])
        end
    end

    return table.concat(name_parts, '')
end

function ThoughtBox.sortAndFindNextName(names, name)
    local split_names = splitAndSortNames(names)
    return ThoughtBox.findNextName(split_names, name)
end

function ThoughtBox.newThoughtTemplate()
    return {'# <+title+>',
            '',
            '# sources',
            '',
            '# tags',
            ''}
end

function ThoughtBox.test()
    print('Begin memory')
    local memory = [=[# title

    content 1
    content 2
    content with [[link 1]]
    content with [[link 2]]

    # sources
    source 1
    source 2

    # tags
    tag1_1, tag1_2, tag with spaces, tag1_4,
    tag2_1, tag2_2, tag. with. dots, tag2_4
    ]=]

    local lines = Utils.splitStringIntoLines(memory)

    print('Begin incs')
    print(incPart('1'))
    print(incPart('10'))
    print(incPart('9'))
    print(incPart('19'))
    print(incPart('99'))
    print(incPart('b'))
    print(incPart('bb'))
    print(incPart('z'))
    print(incPart('az'))
    print(incPart('zz'))

    print('Begin parse incs')

    ThoughtBox.parseThoughtContent(lines, '1a')

    print('Begin names')
    local names = { 'bb','ba','b','a','aa','ab','1','3','2', '1a','1b','10', '10a','10b', '1a2', '1a1'}
    Utils.aprint(names)

    print('Begin sort')
    local sorted_names = ThoughtBox.sortNames(names)

    Utils.aprint(sorted_names)

    print('Begin next name')
    local sorted_names = { '1', '2', '3a', '3b', '3c', '4a1', '4a2', '4a3'}
    local split_names = splitAndSortNames(sorted_names)
    print(Utils.assertEqual(ThoughtBox.findNextName(split_names, ''), '5'))
    print(Utils.assertEqual(ThoughtBox.findNextName(split_names, '1'), '1a'))
    print(Utils.assertEqual(ThoughtBox.findNextName(split_names, '1a'), '1a1'))
    print(Utils.assertEqual(ThoughtBox.findNextName(split_names, '3'), '3d'))
    print(Utils.assertEqual(ThoughtBox.findNextName(split_names, '4'), '4b'))
    print(Utils.assertEqual(ThoughtBox.findNextName(split_names, '4a'), '4a4'))
    print(Utils.assertEqual(ThoughtBox.findNextName(split_names, '4a1'), '4a1a'))
end

return ThoughtBox

