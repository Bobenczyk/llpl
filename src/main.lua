-- get entry file directory path as global Path
local ___r = string.reverse(arg[0])
local ___f = {___r:find(".+[/\\]")}
Path = (___f[1] and ___r:sub(___f[2]):reverse()) or ""


if #arg < 1 then   os.exit()   end
if #arg > 1 then   print("provided unneeded comand line input: \"".. table.concat(arg, ' ', 2) ..'"')   end

local file = io.open(arg[1], "r")
if not file then   os.exit()   end

local code = file:read("a")
file:close()


tok = {
    number = "number",
    operator = "operator",
    name = "name",
    -- string = "string",        -- not implemented

    unknown = "unknown",
}

operators = {
    '!', '@', '#', '$', '%', '^', '&', "&&", '*', '(', ')', '-', "--", '+', "++", '=',
    '{', '}', '[', ']',
    ':', ';', '|', "||", '\\',
    '<', '>', ',', '.', '?', '/', "//",

    "<<", ">>",
    "<=", ">=", "!=", "==",
    "-=", "+=", "/=", "*=",

    "..", "..=",
}




local tokens = {}

function token(type, value)   table.insert(tokens, { type = type, value = value })   end


local buf, bufType = "", ""

function isWhiteSpace(c)   return ( c == ' ' or c == '\n' or c == '\t' )   end
function isDigit(c)   local a = string.byte(c, 1, 1)   return ( a >= 48 and a <= 57 )   end

function isName(str)
    local i = 0
    while i < string.len(str) do
        i = i + 1
        local a = string.byte(str, i, i)
        if
            a >= 65 and a <= 90                       -- A-Z
            or
            a >= 97 and a <= 122                      -- a-z
        then
        elseif a == 95 then                           -- _
        elseif i > 1 and a >= 48 and a <= 57 then     -- 0-9
        else return false
        end
    end
    return true   end
function isOperator(str)   return #{(table.concat(operators, ' ')..' '):find(str..' ', nil, true)} > 0   end

function analize(str)
    if string.len(str) > 0 then
            if tonumber(str)   then return tok.number
        elseif isOperator(str) then return tok.operator
        elseif isName(str)     then return tok.name
        else return tok.unknown     -- a error case where there's a unrecogizable token type
        end
    end
end


-- comment removing pre-processor --

local keepGoing = true
while keepGoing do
    local first = {string.find(code, "///", nil, true)}
    if first[1] then
        local newline = {string.find(code, "\n", first[2], true)}
        if newline[1] then
            code = string.sub(code, 1, math.max(0, first[1]-1))..string.sub(code, newline[1])
        else
            code = string.sub(code, 1, math.max(1, first[1]-1))
        end
    else
        keepGoing = false
    end
end

-- io.open("no_comments_"..arg[1], "w"):write(code):close()
-- print("code:\n\""..code..'"')

-- tokenizer --

local i = 0
while i < string.len(code) do
    i = i + 1
    local c = string.sub(code, i, i)
    if isWhiteSpace(c) then
        if string.len(buf) > 0 then
            token(analize(buf), buf)
        end
        buf = ""

        goto lexer_next
    end
    
    if string.len(buf) == 0 then
        bufType = analize(c)
        buf = c
        -- print("  IF", buf)
    elseif
        bufType == tok.operator and isOperator(buf..c) or
        bufType == tok.name and isName(buf..c) or
        (buf:sub(1, 1) == '-' or bufType == tok.number) and isDigit(c)
        then
        buf = buf .. c
    else
        token(analize(buf), buf)
        bufType = analize(c)
        buf = c
        -- print("  ELSE", buf)
    end
    
    -- print("buffer: \""..buf..'"')

    :: lexer_next ::
end
token(analize(buf), buf)



-- for i,tok in ipairs(tokens) do
    -- print(i..": {type=\""..tostring(tok.type).."\", value=\""..tostring(tok.value).."\"}")
-- end


-- local values = {}    for i,tok in ipairs(tokens) do  values[i] = tok.value  end    print(table.concat(values, "  "))




vm = {}

vm.types = {
    number = "number",
    operator = "operator",
    name = "name",
    string = "string",           -- not implemented

    block = "block",             -- not implemented
    list = "list",               -- not implemented

    unknown = "unknown",
}



local vars = {
    space = ' ',
    newline = '\n',
}
local varTypes = {
    space = vm.types.string,
    newline = vm.types.string,
}


local stack = {}
local typeStack = {}


local localSpaceEnterPosStack = {}         -- ()
local operationSpaceEnterPosStack = {}     -- []
local blockSpaceEnterPosStack = {}         -- {}



function push(vtype, value)
    if not (type(value) == "string" and value:len() == 0) then
        table.insert(stack, value)
        table.insert(typeStack, (vtype or ""))
    else
        print("push function failed!\n  (\""..tostring(value).."\": \""..tostring(vtype).."\")")
    end
end
function pushList(vtype, list)
    if type(list) == "table" and list.t and list.v then
        table.insert(stack, list)
        table.insert(typeStack, (vtype or ""))
    else
        print("pushList function failed!\n  (\""..tostring(list).."\": \""..tostring(vtype).."\")")
    end
end
function pop()
    return table.remove(stack), table.remove(typeStack)
end
function swap()
    local fv, ft = pop()
    local sv, st = pop()

    push(ft, fv)
    push(st, sv)
end


function goInLocalSpace()
    table.insert(localSpaceEnterPosStack, #stack)
end
function goOutLocalSpace()
    table.remove(localSpaceEnterPosStack)
end

function goInOperSpace()
    table.insert(operationSpaceEnterPosStack, #stack)
end
function goOutOperSpace()
    table.remove(operationSpaceEnterPosStack)
end

function goInBlockSpace()
    table.insert(blockSpaceEnterPosStack, #stack)
end
function goOutBlockSpace()
    table.remove(blockSpaceEnterPosStack)
end


function toBin(vtype, value)
    if vtype == vm.types.number then
        local a = tostring(value)
        if a and a ~= 0 then
            return vm.types.number, 0
        end
    end
    return vm.types.number, 1
end


-- IDEA: exeptions

luaOperations = {}
luaFunctions = {}

local operations = {}
luaOperations = {
    ["+"] = function(argc)                  -- plus
        local sum = 0
        for _ = 1, argc do
            sum = sum + pop()
        end

        push(vm.types.number, tostring(sum))
    end,
    ["-"] = function(argc)                  -- minus
        local sum = 0
        if argc > 1 then
            local a = {}
            for _ = 1, argc do
                local b, _ = pop()
                table.insert(a, b)
            end
            sum = a[#a]
            for i = argc-1, 1, -1 do
                sum = sum - a[i]
            end
        elseif argc == 1 then
            local a, _ = pop()
            sum = -a
        end

        push(vm.types.number, tostring(sum))
    end,

    ["*"] = function(argc)                  -- multiply
        local sum = pop()
        for _ = 2, argc do
            sum = sum * pop()
        end

        push(vm.types.number, tostring(sum))
    end,
    ["/"] = function(argc)                  -- divide
        local sum = 0
        if argc > 1 then
            local a = {}
            for _ = 1, argc do
                local b, _ = pop()
                table.insert(a, b)
            end
            sum = a[#a]
            for i = argc-1, 1, -1 do
                sum = sum / a[i]
            end
        elseif argc == 1 then
            sum = pop()
        end

        push(vm.types.number, tostring(sum))
    end,

    ["//"] = function(argc)                 -- floor divide
        local sum = 0
        if argc > 1 then
            local a = {}
            for _ = 1, argc do
                local b, _ = pop()
                table.insert(a, b)
            end
            sum = a[#a]
            for i = argc-1, 1, -1 do
                sum = sum // a[i]
            end
        elseif argc == 1 then
            sum = pop()
        end

        push(vm.types.number, tostring(sum))
    end,


    ["#"] = function(argc)                  -- lenght operator (gets lenght of: strings, lists, etc...)
    end,

    ["!"] = function(argc)                  -- bin not
    end,
    ["||"] = function(argc)                 -- bin or
    end,
    ["&&"] = function(argc)                 -- bin and
    end,

    ["=="] = function(argc)
    end,

}

local functions = {}
luaFunctions = {
    set = function(argc)                    -- set global var
        if argc > 1 then
            for _ = 1, argc-2 do pop() end
            local vv, vt = pop()
            local nv, _ = pop()
            vars[nv] = vv
            varTypes[nv] = vt
        else
            for _ = 1, argc do pop() end
        end
        pop()
    end,

    get = function(argc)                    -- get global var
        for _ = 1, argc-1 do pop() end
        if argc > 0 then
            local nv, _ = pop()
            pop()
            if varTypes[nv] and vars[nv] then
                push(varTypes[nv], vars[nv])
            end
        end
    end,

    func = function(argc)                   -- = "main (params) {block}"
        for _ = 1, argc-3 do pop() end
        local fBlock, bt = pop()
        if bt == vm.types.block then
            local argList, argListTypes   -- { values }, { types }
            if argc == 3 then
                argList, argListTypes = pop()
                for _, t in ipairs(argListTypes) do
                    if t ~= vm.types.name then
                        print("smth 1") -- rise exeption here
                    end
                end
            end
            local name, nameT = pop()
            if nameT == vm.types.name then
                print("yieepe")
            else
                print("smth 2") -- rise exeption here
            end
            pop()
        else
            print("smth 3") -- rise exeption here
            pop()
        end
    end,

    pop = function(argc)                    -- pop number of indeces from stack
        for _ = 1, argc-1 do pop() end
        local value = 1
        if argc > 0 then value = pop() end
        pop()
        for _ = 1, value do pop() end
    end,

    swap = function(argc)                   -- swap 2 indeces places number of indeces back
        for _ = 1, argc-1 do pop() end
        local howBack = 0
        if argc > 0 then
            howBack = pop()
        end
        pop()
        local a, at = {}, {}
        for _ = 1, howBack do
            local b, bt = pop()
            table.insert(a, b)
            table.insert(at, bt)
        end
        swap()
        for _ = 1, howBack do
            push(table.remove(at), table.remove(a))
        end
    end,

    copy = function(argc)                   -- copy many stack indeces number of times
        local a, at = {}, {}
        for _ = 1, argc-1 do
            local b, bt = pop()
            table.insert(a, b)
            table.insert(at, bt)
        end
        local howMuch = 1
        if argc > 0 then
            howMuch = pop()
        end
        pop()
        for _ = 1, howMuch + 1 do
            for j = 1, argc-1 do
                push(at[#at-j+1], a[#a-j+1])
            end
        end
    end,

    print = function(argc)                  -- print and pop out stack indeces
        local str = ""
        for _ = 1, argc do
            str = ' ' .. pop() .. str
        end
        pop()
        print(string.sub(str, 2))
    end,

    type = function(argc)                   -- return value from typeStack
        local str = ""
        for _ = 1, argc do
            local _, t = pop()
            str = ' ' .. t .. str
        end
        pop()
        push(vm.types.string, string.sub(str, 2))
    end,

    printtype = function(argc)                   -- return value from typeStack
        local str = ""
        for _ = 1, argc do
            local _, t = pop()
            str = ' ' .. t .. str
        end
        pop()
        print(string.sub(str, 2))
    end,
    
    list = function(argc)                   -- original list function
        local a, at = {}, {}
        for _ = 1, argc do
            local b, bt = pop()
            table.insert(a, 1, b)
            table.insert(at, 1, bt)
        end
        pop()
        pushList(vm.types.list, { s = argc, v = a, t = at })
    end,

    stringify = function(argc)              -- changes indeces typeStack value to one of vm.types.string if posible
        local a, at = {}, {}
        for _ = 1, argc do
            local b, bt = pop()
            table.insert(a, b)
            table.insert(at, bt)
        end
        pop()
        for _ = 1, argc do
            local b = table.remove(at)
            if b == vm.types.list or b == vm.types.block then
                push(b, table.remove(a))
            else
                push(vm.types.string, table.remove(a))
            end
        end
    end,

    concat = function(argc)
        for _ = 1, argc-2 do pop() end
        local spacer = ""
        if argc == 2 then spacer = pop() end
        local list = pop()
        local str = ""
        for _, v in ipairs(list.v) do
            str = str .. spacer .. v
        end
        pop()
        str = string.sub(str, string.len(spacer)+1 )
        push(vm.types.string, str)
    end,
}


function a(i)
    if #localSpaceEnterPosStack > 1 and localSpaceEnterPosStack[#localSpaceEnterPosStack]+1 > 0 then
        print(' S'..(" "):rep(#localSpaceEnterPosStack*2-1).. table.concat(stack, ' ', localSpaceEnterPosStack[#localSpaceEnterPosStack-1]+1, localSpaceEnterPosStack[#localSpaceEnterPosStack-1]+1))
    elseif localSpaceEnterPosStack[#localSpaceEnterPosStack] and localSpaceEnterPosStack[#localSpaceEnterPosStack]+1 > 0 then
        print(' S'..(" "):rep(#localSpaceEnterPosStack*2-1).. table.concat(stack, ' ', localSpaceEnterPosStack[#localSpaceEnterPosStack]+1))
    else
        print(' S'..(" "):rep(#localSpaceEnterPosStack*2-1).. table.concat(stack, ' '))
    end
    print('eS'..(" "):rep(#localSpaceEnterPosStack*2-1).. table.concat(stack, ' '))
    print('lS'..(" "):rep(#localSpaceEnterPosStack*2-1).. table.concat(localSpaceEnterPosStack, ' '))
    print('cS'..(" "):rep(#localSpaceEnterPosStack*2-1).. table.concat(operationSpaceEnterPosStack, ' '))
    print(" ^ "..i..'\n')
end


if false then                    -- toglle if to pack lua arg to llpl (pl name)
    local args_list = { s = #arg-1, t={}, v={} }
    for i = 2, #arg do
        args_list.t[i-1] = vm.types.string
        args_list.v[i-1] = arg[i]
    end
    varTypes["args"] = vm.types.list
    vars["args"] = args_list
end


local i = 0
while i < #tokens do
    i = i + 1
    local token = tokens[i]
    local type, value = token.type, token.value

    if type == tok.operator then

        if value == '(' then
            goInLocalSpace()
            -- a(i)
        elseif value == ')' then
            -- a(i)
            local begin = localSpaceEnterPosStack[#localSpaceEnterPosStack] or 0
            local argc = #stack - begin       -- end - begin = difference

            -- print(' C'..(" "):rep(#localSpaceEnterPosStack*2-1).. argc)

            if argc > 0 then

                if typeStack[begin+1] == vm.types.name then
                    local funcName = stack[begin+1]
                    if luaFunctions[funcName] then
                        -- print(funcName, argc-1)
                        luaFunctions[funcName](argc-1)
                    else
                        print("error: lua funcion \""..funcName.."\" was not found!")
                    end

                -- else
                --     local a, at = {}, {}
                --     for _ = 1, argc do
                --         local b, bt = pop()
                --         table.insert(a, 1, b)
                --         table.insert(at, 1, bt)
                --     end
                --     pushList(vm.types.list, { s = argc, v = a, t = at })
                
                -- (nwm co z tym zrobic btw)

                end
            end

            goOutLocalSpace()

        elseif value == '[' then
            goInOperSpace()
            -- a(i)
        elseif value == ']' then
            -- a(i)
            local begin = operationSpaceEnterPosStack[#operationSpaceEnterPosStack] or 0
            local argc = #stack - begin       -- end - begin = difference

            -- print(' C'..(" "):rep(#localSpaceEnterPosStack*2-1).. argc)

            if argc > 0 then

                if typeStack[#typeStack] == vm.types.operator then
                    local oper = stack[#stack]
                    pop()
                    if luaOperations[oper] then
                        -- print(oper, argc-1)
                        luaOperations[oper](argc-1)
                    else
                        print("error: lua operation \""..oper.."\" was not found!")
                    end
                else
                    local a, at = {}, {}
                    for _ = 1, argc do
                        local b, bt = pop()
                        table.insert(a, 1, b)
                        table.insert(at, 1, bt)
                    end
                    pushList(vm.types.list, { s = argc, v = a, t = at })
                end
            else
                --     coped from above ^^^
                local a, at = {}, {}
                for _ = 1, argc do
                    local b, bt = pop()
                    table.insert(a, 1, b)
                    table.insert(at, 1, bt)
                end
                pushList(vm.types.list, { s = argc, v = a, t = at })
            end

            goOutOperSpace()

        elseif value == '{' then
            goInBlockSpace()
            -- a(i)
        elseif value == '}' then
            -- a(i)
            pushList(vm.types.block, {t = {}, v = {}})
            goOutBlockSpace()

        else
            push(type, value)
        end

    else
        push(type, value)
    end
end


function printList(list, indent)
    print("  size: "..tostring(list.s or "unknown"))
    for j = 1, (list.s or math.max(#list.v, #list.t)) do
        print(indent..j..": \""..tostring(list.v[j]).."\": \""..tostring(list.t[j]).."\"")
        if list.t[j] == vm.types.list then
            printList(list.v[j], indent.."  ")
        end
    end
end

print("\nvars (+ types):")
for k, v in pairs(vars) do
    print('"'..k.."\" = \""..tostring(v).."\": \""..tostring(varTypes[k]).."\"")
    if varTypes[k] == vm.types.list then
        printList(v, "  ")
    end
end

print("\nstack (+ types):")
for i = 1, math.max(#stack, #typeStack) do
    print(i..": \""..tostring(stack[i]).."\": \""..tostring(typeStack[i]).."\"")
    if typeStack[i] == vm.types.list then
        printList(stack[i], "  ")
    end
end
