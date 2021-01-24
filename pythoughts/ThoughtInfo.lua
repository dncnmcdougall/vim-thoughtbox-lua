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

function assertEqual(thing1, thing2)
    local type1 = type(thing1)
    if type1 ~= type(thing2) then
        print('The types do not match: '..type1..' ~= '.. type(thing2))
        return false
    elseif type1 == 'table' then
        local len1 = table.getn(thing1)
        if len1 ~= table.getn(thing2) then
            print('The number of items in the tables do not match: '..len1..' ~= '.. table.getn(thing2))
            return false
        else
            for k,v in pairs(thing1) do
                if not assertEqual(thing1[k], thing2[k]) then
                    return false
                end
            end
            return true
        end
    else
        if thing1 ~= thing2 then
            print('They do not match: '..tostring(thing1)..' ~= '.. tostring(thing2))
            return false
        end
        return true
    end
end


local lines = {}

local i = 0
while i ~= nil do
    local j = string.find(memory, '\n',i+1)
    local line = string.gsub(string.sub(memory, i, j), '\n','')
    table.insert(lines,line)
    i = j
end


function aprint_help(thing, indent)
    if type(thing) == 'table' then
        for k,v in pairs(thing) do
            if type(v) == 'table' then
                print(indent..' '..tostring(k)..': {')
                aprint_help(v, indent..' ')
            else
                print(indent..' '..tostring(k)..': '..tostring(v))
            end
        end
        print(indent..'}')
    else
        print(indent..thing)
    end
end

function aprint(thing)
    if type(thing) == 'table' then
        print('{')
        aprint_help(thing, '')
    else
        print(thing)
    end
end

function stripString(str)
    str,_ = string.gsub(str, '^%s*','')
    str,_ = string.gsub( str, '%s*$','')
    return str
end

function splitString(str, delim)
    local result = {}
    local i, j = string.find(str,delim)
    local k =1
    while j ~= nil do
        table.insert(result, string.sub(str,k,i-1))
        k = j+1
        i, j = string.find(str,delim,k)
    end
    table.insert(result, string.sub(str,k))
    return result
end

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

function parseThoughtContent(lines, name)
    local res = {title=nil, content={}, tags={}, sources={}, links={}}
    local heading = nil
    for i,line in ipairs(lines) do
        if string.sub(line, 1,2) == '# ' then
            line = stripString(string.sub(line,3))
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
        line = stripString(line)
        if string.len(line) > 0 then 
            local tags = splitString(stripString(line),',%s*')
            for i,tag in ipairs(tags) do
                tag = stripString(tag)
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

function sortNames(names)
    local name_parts = splitAndSortNames(names)
    local new_names = {}
    for i,name in pairs(name_parts) do
        table.insert(new_names, table.concat(name,''))
    end
    return new_names
end

print('Begin asserts')
print(assertEqual('1','1'))
print(assertEqual(1,1))
print(assertEqual('1','2'))
print(assertEqual('1',1))
print(assertEqual({1,2,3},1))
print(assertEqual({1,2,3},{1,2,3}))
print(assertEqual({1,2,3},{1,2}))
print(assertEqual({1,2,3},{1,2,'3'}))

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

parseThoughtContent(lines, '1a')

print('Begin names')
local sorted_names = { 'bb','ba','b','a','aa','ab','1','3','2', '1a','1b','10', '10a','10b', '1a2', '1a1'}
aprint(sorted_names)


print('Begin sort')
local new_names = sortNames(sorted_names)


aprint(new_names)

