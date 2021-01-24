local ThoughtBox = require "ThoughtBox"
local ThoughtIO = {}

function ThoughtIO.readThoughtsTitleAndTags(folder, thought_list)
    local thoughts = {}
    for i,thought in ipairs(thought_list) do
        local file = folder..thought..'.tb'
        io.input(file)
        local lines = {}
        for line in io.lines() do  
            table.insert(lines,line) 
        end
        local thought_content = ThoughtBox.parseThoughtContent(lines, thought)
        thoughts[thought] = {title=thought_content.title, tags=thought_content.tags, file=file}
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
