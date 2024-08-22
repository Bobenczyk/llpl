-- get entry file directory path as global Path
Path = (arg[0]:match(".+[\\/]") or ""):sub(1, -2):match(".+[\\/]") or ""

-- checking if there are more then 0 command line args
if #arg < 1 then   print("llpl: no file provided!") os.exit()   end

-- reading input file
local file = io.open(arg[1], "r")
if not file then   print("llpl: error reading provided file!") os.exit()   end

-- writing file contents to code var
local code = file:read("a")
file:close()

dofile(Path.."src/lexer/tokens.lua")
dofile(Path.."src/lexer/lexer.lua")

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
        else return tok.unknown     -- a error case where there's an unrecogizable token type
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
    end
    
    -- print("buffer: \""..buf..'"')

    :: lexer_next ::
end
token(analize(buf), buf)

local clock = os.clock()
-- print(("---"):rep(14)..'\n'..("   "):rep(5).."vm time!\n"..("---"):rep(14))
local clocktok = os.clock()
-- virtual machine --

-- vm config? vm info? idk
vm = {}

dofile(Path.."src/vm/types.lua")


-- llpl glob vars
vars = {
}
-- llpl glob var types
varTypes = {
}


-- local vars? i think so
vmStack = {}

dofile(Path.."src/vm/stack.lua")


-- idk just look at name
function toBin(vtype, value)
    if vtype == vm.types.number then
        local a = tonumber(value)
        if a and a ~= 0 then
            return vm.types.number, 1
        end
    end
    return vm.types.number, 0
end

---@param n integer
function mapStack(n)
    local a, at = {}, {}
    for _ = 1, n do
        local b, bt = pop()
        table.insert(a, b)
        table.insert(at, bt)
    end
    return a, at
end

---@param a table<string>
---@param at table<string>
---@param f function<any, any, number>: any, any
function unmapStack(a, at, f)
    if f then
        for i = 1, #a do
            -- f(type, value): type, value
            push(
                f(
                    table.remove(at),
                    table.remove(a),
                    i
                )
            )
        end
    else
        for _ = 1, #a do
            push(
                table.remove(at),
                table.remove(a)
            )
        end
    end
end


-- IDEA: EXCEPTIONS  :thumbsup: :fire::fire::fire: :100:
dofile(Path.."src/debug.lua")


-- llpl funcs
operations = {}
functions = {}

-- ops
dofile("src/vm/ops.lua")

-- funcs
dofile("src/vm/funcs.lua")


-- support for args (converted to llpl list and shiped to vm) :smile:
if
false
then
    local args_list = { s = #arg-1, t={}, v={} }
    for i = 2, #arg do
        args_list.t[i-1] = vm.types.string
        args_list.v[i-1] = arg[i]
    end
    varTypes["args"] = vm.types.list
    vars["args"] = args_list
end


-- vm info printing point func
function vmInfoPoint()
    print("VM uptime:", ((os.clock() - clocktok)*1000).."ms")

    printLocVars()

    printVars()
    printStack()
end


-- ohh heres the big boi :smiley:
function vm_(block, locVars, locVarTypes)
    table.insert(vmStack, { vars = locVars, varTypes = locVarTypes })
    printLocVars()
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
                elseif value == ')' then
                    local begin = localSpaceEnterPosStack[#localSpaceEnterPosStack] or 0
                    local argc = #stack - begin       -- end - begin = difference

                    if argc > 0 then

                        if typeStack[begin+1] == vm.types.name then
                            local funcName = stack[begin+1]
                            if functions[funcName] then
                                -- print(funcName, argc-1)
                                -- printStack()
                                local result = functions[funcName](argc-1)
                                if result == false then
                                    for _ = 1, argc do pop() end
                                    -- cause/throw Exception maybe or smth idk 3
                                end

                            else
                                -- cause/throw Exception maybe or smth idk
                                print("error: lua funcion \""..funcName.."\" was not found!")
                            end
                        end

                    end

                    goOutLocalSpace()
                -- elseif value == ");" then
                --     goOutLocalSpace()

                elseif value == '[' then
                    goInOperSpace()
                elseif value == ']' then
                    local begin = operationSpaceEnterPosStack[#operationSpaceEnterPosStack] or 0
                    local argc = #stack - begin       -- end - begin = difference

                    if argc > 0 then

                        if typeStack[#typeStack] == vm.types.operator then
                            local oper = stack[#stack]
                            pop()
                            if operations[oper] then
                                -- print(oper, argc-1)
                                operations[oper](argc-1)
                            else
                                -- cause/throw Exception maybe or smth idk 2
                                print("error: lua operation \""..oper.."\" was not found!")
                            end
                        else
                            -- cheacky list operatio
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
                        -- cheacky list operatio 2
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
    printLocVars()
    table.remove(vmStack)
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
dofile(Path.."src/lualib.lua")



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
        print("lua: "..tostring(msg))
    end,
    { v = toks, t = tokTypes },
    {}, {}
)

local clockvm = os.clock()


-- Debug
local llplDebug_Flag  = true
local llplDebug_Vars  = true
local llplDebug_stack = true
local llplDebug_ShowTime = true

-- debug start
if llplDebug_Flag and (llplDebug_Vars or llplDebug_stack) then

    print("\n(program ended) Debug:")

    if llplDebug_Vars then   printVars()   end

    if llplDebug_stack then   printStack()   end

end
-- debug end

if llplDebug_ShowTime then
    print("\ntime:")
    print("  tok:", (clock*1000).."ms")
    -- print("  info:", ((clocktok - clock)*1000).."ms")
    print("  vm:", ((clockvm - clocktok)*1000).."ms")
end