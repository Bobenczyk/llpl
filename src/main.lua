-- get entry file directory path as global Path
local ___r = string.reverse(arg[0])
local ___f = {___r:find(".+[/\\]")}
Path = (___f[1] and ___r:sub(___f[2]):reverse()) or ""


-- checking if there are more then 0 command line args
if #arg < 1 then   print("llpl: no file provided!") os.exit()   end
-- if #arg > 1 then   print("provided unneeded comand line input: \"".. table.concat(arg, ' ', 2) ..'"')   end

-- reading input file
local file = io.open(arg[1], "r")
if not file then   os.exit()   end

-- writing file contents to code var
local code = file:read("a")
file:close()


-- enum of different token types
tok = {
    number = "number",
    operator = "operator",
    name = "name",
    -- string = "string",        -- not implemented (yet i promise i will implement strings)

    unknown = "unknown",
}

-- list of different operators
operators = {
    '!', '@', '#', '$', '%', '^', '&', "&&", '*', '-', "--", '+', "++", '=',
    ':', ';', '|', "||", '\\',
    '<', '>', ',', '.', '?', '/', "//",
    
    "<<", ">>",
    "<=", ">=", "!=", "==",
    "-=", "+=", "/=", "*=",
    
    "..", "..=",
    
    '(', ')',
    '[', ']',
    '{', '}',
}



-- lexer output
local tokens = {}

function token(type, value)   table.insert(tokens, { type = type, value = value })   end

-- word buffer and its type
local buf, bufType = "", ""

-- some lexer helper funcs
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

-- analize function (used to detemit bufType and finally token type)
function analize(str)
    if string.len(str) > 0 then
            if tonumber(str)   then return tok.number
        elseif isOperator(str) then return tok.operator
        elseif isName(str)     then return tok.name
        elseif
            -- string.sub(str, 1, 1) == ';' or
            string.sub(str, 1, 1) == ')' or
            string.sub(str, 1, 1) == ']' or
            string.sub(str, 1, 1) == '}'
            then return tok.operator
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


-- tokenizer --

local i = 0
while i < string.len(code) do
    i = i + 1
    local c = string.sub(code, i, i)
    -- if end of the word clean word buffer and its type indicator and apend token to list of tokens
    if isWhiteSpace(c) then
        if string.len(buf) > 0 then
            token(analize(buf), buf)
        end
        buf = ""

        goto lexer_next
    end
    
    -- some lexer logic
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
    elseif
        (( buf:sub(1, 1) == ')' or buf:sub(1, 1) == ']' or buf:sub(1, 1) == '}' ) and c == ';')
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

local clock = os.clock()
-- print(("---"):rep(14)..'\n'..("   "):rep(5).."vm time!\n"..("---"):rep(14))
local clocktok = os.clock()
-- virtual machine

-- vm config? vm info? idk
vm = {}

-- enum of vm inside types
vm.types = {
    number = "number",
    operator = "operator",
    name = "name",
    string = "string",                                                                              -- not implemented (still no lexer support for strings. im lazy :) )

    block = "block",             -- { v = tokenValues: table, t = tokenTypes: table }
    list = "list",               -- { v = values: table, t = types: table, s? = size: number }

    func = "func",               -- { p = plramList: table, b = block: vm.types.block }             -- not implemented (just still workin' on it)

    unknown = "unknown",
}


-- llpl glob vars
local vars = {
}
-- llpl glob var types
local varTypes = {
}


-- stack and its type representive

stack = {}
typeStack = {}

-- idk just really useful
localSpaceEnterPosStack = {}         -- ()
local operationSpaceEnterPosStack = {}     -- []
local blockSpaceEnterPosStack = {}         -- {}

-- stack manipulation funcs

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
function pushBlock(block)
    if type(block) == "table" and block.t and block.v then
        table.insert(stack, block)
        table.insert(typeStack, vm.types.block)
    else
        print("pushBlock function failed!\n  (\""..tostring(block).."\": \""..tostring(vm.types.block).."\")")
    end
end
function pushFunc(block, paramList)
    if
        (type(block) == "table" and block.t and block.v) and
        (type(paramList) == "table")
        then
        table.insert(stack, {p = paramList, b = block})
        table.insert(typeStack, vm.types.func)
    else
        print("pushFunc function failed!\n  (\""..tostring(block).."\": \""..tostring(vm.types.block).."\")\n  (\""..tostring(paramList).."\": \"lua table? idk\")")
    end
end
---@return any value
---@return any type
function pop()
    return table.remove(stack), table.remove(typeStack)
end
function swap()
    local fv, ft = pop()
    local sv, st = pop()

    push(ft, fv)
    push(st, sv)
end

-- additional stacks funcs

-- ()
function goInLocalSpace()
    table.insert(localSpaceEnterPosStack, #stack)
end
function goOutLocalSpace()
    table.remove(localSpaceEnterPosStack)
end
-- []
function goInOperSpace()
    table.insert(operationSpaceEnterPosStack, #stack)
end
function goOutOperSpace()
    table.remove(operationSpaceEnterPosStack)
end
-- {}
function goInBlockSpace(tokPos)
    table.insert(blockSpaceEnterPosStack, tokPos)
end
function goOutBlockSpace()
    return ( table.remove(blockSpaceEnterPosStack) or 0 )
end

-- idk just look at name
function toBin(vtype, value)
    if vtype == vm.types.number then
        local a = tostring(value)
        if a and a ~= 0 then
            return vm.types.number, 0
        end
    end
    return vm.types.number, 1
end


-- IDEA: EXCEPTIONS  :thumbsup:

-- llpl funcs
luaOperations = {}
luaFunctions = {}

-- ops
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

-- funcs
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
        if argc >= 1 then
            for _ = 1, argc-2 do pop() end
            local spacer = ""
            if argc >= 2 then spacer = pop() end
            local list, at = {}, nil
            if argc >= 1 then list, at = pop() end
            if at == vm.types.list then
                local str = ""
                for _, v in ipairs(list.v) do
                    str = str .. spacer .. v
                end
                pop()
                str = string.sub(str, string.len(spacer)+1 )
                push(vm.types.string, str)
            else
                pop()
            end
        else
            pop()
        end
    end,

    ["do"] = function(argc)
        local blocks = {}
        for i = 1, argc do
            local a, at = pop()
            if at == vm.types.block then
                blocks[i] = a
            end
        end
        pop()
        for i = 1, #blocks do
            local j = #blocks-i+1
            -- print(j, blocks[j], (blocks[j].v) and #blocks[j].v or 0)   print(table.concat(blocks[j].v, ' '))
            vm_(blocks[j])
        end
    end,

    randseed = function(argc) for _ = 1, argc-1 do pop() end
        local a, at
        if argc == 1 then
            a, at = pop()
        end
        pop()
        if at ~= vm.types.number then
            a = nil
        end
        math.randomseed(a)
    end,

    rand = function(argc) if argc >= 2 then   for _ = 1, argc-2 do pop() end
        local a, at = pop()
        local b, bt = pop()
        pop()
        if at == vm.types.number and bt == vm.types.number then
            push(vm.types.number, math.random(b, a))
        end
    elseif argc == 1 then
        local a, at = pop()
        pop()
        if at == vm.types.number then
            push(vm.types.number, math.random(a))
        end
    else
        pop()
        push(vm.types.number, math.random())
    end end,

    -- if, while, for, 
}


-- support for args (converted to llpl list and shiped to vm) :smile:
if
false
then                    -- toglle if to pack lua arg to llpl (pl name)
    local args_list = { s = #arg-1, t={}, v={} }
    for i = 2, #arg do
        args_list.t[i-1] = vm.types.string
        args_list.v[i-1] = arg[i]
    end
    varTypes["args"] = vm.types.list
    vars["args"] = args_list
end

-- ohh heres the big boi :smiley:
function vm_(block)
    local block_checking = 0
    local i = 0
    while i < #block.v do
        i = i + 1
        local type, value = block.t[i], block.v[i]
        -- print(value, type, block_checking)
        if not type then goto vm_next end

        if type == tok.operator then

            if block_checking == 0 then

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
                -- elseif value == ");" then
                --     goOutLocalSpace()

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
                    -- print("0.{:", block_checking, #blockSpaceEnterPosStack)
                    block_checking = block_checking + 1
                    goInBlockSpace(i)
                elseif value == '}' then
                    -- print("0.}:", block_checking, #blockSpaceEnterPosStack)
                    block_checking = math.max(block_checking - 1, 0)
                    local toks, tokTypes = {}, {}
                    for j = 1, i-1 do
                        local token = tokens[j]
                        table.insert(toks, token.value)
                        table.insert(tokTypes, token.type)
                    end
                    pushBlock({t = tokTypes, v = toks})

                else
                    push(type, value)
                end

            else -- #blockSpaceEnterPosStack > 0

                if value == '{' then
                    -- print("1.{:", block_checking, #blockSpaceEnterPosStack)
                    block_checking = block_checking + 1
                elseif value == '}' then
                    -- print("1.}:", block_checking, #blockSpaceEnterPosStack)
                    block_checking = math.max(block_checking - 1, 0)
                    if block_checking+1 <= #blockSpaceEnterPosStack then
                        local blockOpenTokPos = goOutBlockSpace()
                        local toks, tokTypes = {}, {}
                        for j = blockOpenTokPos+1, i-1 do
                            local token = tokens[j]
                            table.insert(toks, token.value)
                            table.insert(tokTypes, token.type)
                        end
                        pushBlock({t = tokTypes, v = toks})
                    end

                end

            end

        else
            if block_checking == 0 then
                push(type, value)
            end
        end
        :: vm_next ::
    end
end


-- helper funcs
function apendVar(name, val, type)
    vars[name] = val
    varTypes[name] = type
end

-- space, newline
apendVar("SPACE", ' ', vm.types.string)
apendVar("NEWLINE", '\n', vm.types.string)

-- llpl lua lib bind YESSIRRrrr :) 
dofile("src/lualib.lua")



-- tokens -> llpl block
-- vm_ entry point Yessir
local toks, tokTypes = {}, {}
for i, tok in ipairs(tokens) do
    toks[i] = tok.value
    tokTypes[i] = tok.type
end
xpcall(
    vm_,
    function(msg)
        print("lua: "..msg)
    end,
    { v = toks, t = tokTypes }
)

local clockvm = os.clock()


-- Debug
local llplDebugFlag = true

if llplDebugFlag then
    -- debug start
    function printBlock(block, indent)
        print(indent.."size: "..tostring(block.s or math.max(#block.v, #block.t)))
        -- for j = 1, (block.s or math.max(#block.v, #block.t)) do
            print(table.concat(block.v, ' '))
            -- if block.t[j] == vm.types.block then
            --     printBlock(block.v[j], indent.."  ")
            -- end
        -- end
    end

    function printList(list, indent)
        print(indent.."size: "..tostring(list.s or "unknown"))
        for j = 1, (list.s or math.max(#list.v, #list.t)) do
            print(indent..j..": \""..tostring(list.v[j]).."\": \""..tostring(list.t[j]).."\"")
            if list.t[j] == vm.types.list then
                printList(list.v[j], indent.."  ")
            elseif list.t[j] == vm.types.block then
                printBlock(list.v[j], indent.."  ")
            end
        end
    end


    print("\nvars (+ types):")
    for k, v in pairs(vars) do
        print('"'..k.."\" = \""..tostring(v).."\": \""..tostring(varTypes[k]).."\"")
        if varTypes[k] == vm.types.list then
            printList(v, "  ")
        elseif varTypes[k] == vm.types.block then
            printBlock(v, "  ")
        end
    end

    print("\nstack (+ types):")
    for i = 1, math.max(#stack, #typeStack) do
        print(i..": \""..tostring(stack[i]).."\": \""..tostring(typeStack[i]).."\"")
        if typeStack[i] == vm.types.list then
            printList(stack[i], "  ")
        elseif typeStack[i] == vm.types.block then
            printBlock(stack[i], "  ")
        end
    end
    -- debug end
end

print("\ntime:")
print("  tok:", (clock*1000).."ms")
-- print("  info:", ((clocktok - clock)*1000).."ms")
print("  vm:", ((clockvm - clocktok)*1000).."ms")