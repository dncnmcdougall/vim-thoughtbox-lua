
local tags = {}
---Return whether this source is available in the current context or not (optional).
---@return boolean
function tags:is_available()
    return true
end
---Return the debug name of this source (optional).
---@return string
function tags:get_debug_name()
    return 'debug name'
end
---Return LSP's PositionEncodingKind.
---@NOTE: If this method is ommited, the default value will be `utf-16`.
---@return lsp.PositionEncodingKind
function tags:get_position_encoding_kind()
    return 'utf-16'
end
---Return the keyword pattern for triggering completion (optional).
---If this is ommited, nvim-cmp will use a default keyword pattern. See |cmp-config.completion.keyword_pattern|.
---@return string
function tags:get_keyword_pattern()
    return [[\k\+]]
end
---Return trigger characters for triggering completion (optional).
function tags:get_trigger_characters()
    return { '#' }
end
---Invoke completion (required).
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function tags:complete(params, callback)


    callback({
        { label = 'January' },
        { label = 'February' },
        { label = 'March' },
        { label = 'April' },
        { label = 'May' },
        { label = 'June' },
        { label = 'July' },
        { label = 'August' },
        { label = 'September' },
        { label = 'October' },
        { label = 'November' },
        { label = 'December' },
    })
end
---Resolve completion item (optional). This is called right before the completion is about to be displayed.
---Useful for setting the text shown in the documentation window (`completion_item.documentation`).
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function tags:resolve(completion_item, callback)
    callback(completion_item)
end
---Executed after the item was selected.
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function tags:execute(completion_item, callback)
    callback(completion_item)
end
---Register your source to nvim-cmp.
require('cmp').register_source('thoughtbox-tags', tags)
