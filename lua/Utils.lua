local Utils = {}

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

function Utils.aprint(thing)
    if type(thing) == 'table' then
        print('{')
        aprint_help(thing, '')
    else
        print(thing)
    end
end

function Utils.stripString(str)
    str,_ = string.gsub(str, '^%s*','')
    str,_ = string.gsub( str, '%s*$','')
    return str
end

function Utils.splitString(str, delim)
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

function Utils.splitStringIntoLines(str)
    local lines = {}

    local i = 0
    while i ~= nil do
        local j = string.find(str, '\n',i+1)
        local line = string.gsub(string.sub(str, i, j), '\n','')
        table.insert(lines,line)
        i = j
    end

    return lines
end

function Utils.assertEqual(thing1, thing2)
    local type1 = type(thing1)
    if type1 ~= type(thing2) then
        return false, 'The types do not match: '..type1..' ~= '.. type(thing2)
    elseif type1 == 'table' then
        local len1 = table.getn(thing1)
        if len1 ~= table.getn(thing2) then
            return false, 'The number of items in the tables do not match: '..len1..' ~= '.. table.getn(thing2)
        else
            for k,v in pairs(thing1) do
                local r,e = assertEqual(thing1[k], thing2[k])
                if not r then
                    return false, e
                end
            end
            return true, 'tables match in length and elements'
        end
    else
        if thing1 ~= thing2 then
            return false, 'They do not match: '..tostring(thing1)..' ~= '.. tostring(thing2)
        end
        return true, tostring(thing1)..' == '..tostring(thing2)
    end
end

function Utils.test()
    print('Begin asserts')
    print(Utils.assertEqual('1','1'))
    print(Utils.assertEqual(1,1))
    print(Utils.assertEqual('1','2'))
    print(Utils.assertEqual('1',1))
    print(Utils.assertEqual({1,2,3},1))
    print(Utils.assertEqual({1,2,3},{1,2,3}))
    print(Utils.assertEqual({1,2,3},{1,2}))
    print(Utils.assertEqual({1,2,3},{1,2,'3'}))
end

return Utils
