-- llpl lua lib bind YESSIRRrrr :) 
local lua_types = {
    file = "file",
}

apendVar("PATH", Path, vm.types.string)


-- lua io --

apendVar("lua_io_stdin", io.stdin, lua_types.file)
apendVar("lua_io_stdout", io.stdout, lua_types.file)
apendVar("lua_io_stderr", io.stderr, lua_types.file)

functions["lua_io_open"] = function(argc)   for _ = 1, argc-2 do pop() end   if argc >= 2 then
    local mode, filename = pop(), pop()
    -- print("io.open(\""..filename.."\", \""..mode.."\")")
    pop()
    push(lua_types.file, io.open(filename, mode))
else   for _ = 1, argc+1 do pop() end   end end
functions["lua_io_close"] = function(argc)   for _ = 1, argc-1 do pop() end   if argc >= 1 then
    local file, t = pop()
    pop()
    if t == lua_types.file then
        file:close()
    end
else   for _ = 1, argc+1 do pop() end   end end
functions["lua_io_read"] = function(argc)   for _ = 1, argc-1 do pop() end   if argc >= 1 then
    local file, t = pop()
    pop()
    if t == lua_types.file then
        push(vm.types.string, file:read('a'))
    end
else   for _ = 1, argc+1 do pop() end   end end
functions["lua_io_write"] = function(argc)   for _ = 1, argc-2 do pop() end   if argc >= 2 then
    local str = pop()
    local file, t = pop()
    pop()
    if t == lua_types.file then
        file:write(str)
    end
else   for _ = 1, argc+1 do pop() end   end end


-- lua math --

apendVar("lua_math_huge", math.huge, vm.types.number)
apendVar("lua_math_pi", math.pi, vm.types.number)
apendVar("lua_math_maxint", math.maxinteger, vm.types.number)
apendVar("lua_math_minint", math.mininteger, vm.types.number)

functions["lua_math_sin"] = function(argc)   for _ = 1, argc-1 do pop() end   if argc >= 1 then
    local n, t = pop()
    pop()
    if t == vm.types.number then
        push(vm.types.number, math.sin(n))
    end
else   for _ = 1, argc+1 do pop() end   end end
functions["lua_math_cos"] = function(argc)   for _ = 1, argc-1 do pop() end   if argc >= 1 then
    local n, t = pop()
    pop()
    if t == vm.types.number then
        push(vm.types.number, math.cos(n))
    end
else   for _ = 1, argc+1 do pop() end   end end
functions["lua_math_tan"] = function(argc)   for _ = 1, argc-1 do pop() end   if argc >= 1 then
    local n, t = pop()
    pop()
    if t == vm.types.number then
        push(vm.types.number, math.tan(n))
    end
else   for _ = 1, argc+1 do pop() end   end end

functions["lua_math_round"] = function(argc)   for _ = 1, argc-1 do pop() end   if argc >= 1 then
    local n, t = pop()
    pop()
    if t == vm.types.number then
        push(vm.types.number, math.floor(n + 0.5))
    end
else   for _ = 1, argc+1 do pop() end   end end
functions["lua_math_floor"] = function(argc)   for _ = 1, argc-1 do pop() end   if argc >= 1 then
    local n, t = pop()
    pop()
    if t == vm.types.number then
        push(vm.types.number, math.floor(n))
    end
else   for _ = 1, argc+1 do pop() end   end end
functions["lua_math_ceil"] = function(argc)   for _ = 1, argc-1 do pop() end   if argc >= 1 then
    local n, t = pop()
    pop()
    if t == vm.types.number then
        push(vm.types.number, math.ceil(n))
    end
else   for _ = 1, argc+1 do pop() end   end end

functions["lua_math_abs"] = function(argc)   for _ = 1, argc-1 do pop() end   if argc >= 1 then
    local n, t = pop()
    pop()
    if t == vm.types.number then
        push(vm.types.number, math.abs(n))
    end
else   for _ = 1, argc+1 do pop() end   end end
functions["lua_math_fmod"] = function(argc)   for _ = 1, argc-2 do pop() end   if argc >= 2 then
    local n, at = pop()
    local m, bt = pop()
    pop()
    if at == vm.types.number and bt == vm.types.number then
        push(vm.types.number, math.fmod(m, n))
    end
else   for _ = 1, argc+1 do pop() end   end end

functions["lua_math_max"] = function(argc)   if argc >= 2 then
    local a = {}
    for _ = 1, argc do
        local b, bt = pop()
        if bt == vm.types.number then
            table.insert(a, b)
        end
    end
    pop()
    if #a > 0 then
        push(vm.types.number, math.max(table.unpack(a)))
    end
else
    local a, at = pop()
    for _ = 1, argc do pop() end
    if at == vm.types.number then push(vm.types.number, a) end
end end
functions["lua_math_min"] = function(argc)   if argc >= 2 then
    local a = {}
    for _ = 1, argc do
        local b, bt = pop()
        if bt == vm.types.number then
            table.insert(a, b)
        end
    end
    pop()
    if #a > 0 then
        push(vm.types.number, math.min(table.unpack(a)))
    end
else
    local a, at = pop()
    for _ = 1, argc do pop() end
    if at == vm.types.number then push(vm.types.number, a) end
end end

-- functions["lua_math_modf"] = function(argc)   for _ = 1, argc-1 do pop() end   if argc >= 1 then
--     math.modf()
-- else   for _ = 1, argc+1 do pop() end   end end

-- functions["lua_math_random"] = function(argc)   for _ = 1, argc-1 do pop() end   if argc >= 1 then
--     math.random()
-- else   for _ = 1, argc+1 do pop() end   end end

-- functions["lua_math_randomseed"] = function(argc)   for _ = 1, argc-1 do pop() end   if argc >= 1 then
--     math.randomseed()
-- else   for _ = 1, argc+1 do pop() end   end end



-- functions["lua_math_"] = function(argc)   for _ = 1, argc-1 do pop() end   if argc >= 1 then
-- else   for _ = 1, argc+1 do pop() end   end end


-- lua dofile --

functions["lua_dofile"] = function(argc)   if argc >= 1 then
    local a = pop()
    pop()
    dofile(a)
else   pop()   end end


-- lua os exit --

functions["lua_exit"] = function(argc)
    local begin = (localSpaceEnterPosStack[#localSpaceEnterPosStack] or 0)+1
    table.remove(stack, begin)
    table.remove(typeStack, begin)
    print("lualib: forced exit by llpl") error("lua_exit")
end


-- lua string upper / lower

functions["lua_string_upper"] = function(argc)   if argc >= 1 then
    local a = {}
    for _ = 1, argc do
        local b, _ = pop()
        table.insert(a, string.upper(b))
    end
    pop()
    for _ = argc, 1, -1 do
        push(vm.types.string, table.remove(a))
    end
else   for _ = 1, argc+1, 1 do pop() end   end end
functions["lua_string_lower"] = function(argc)   if argc >= 1 then
    local a = {}
    for _ = 1, argc do
        local b, _ = pop()
        table.insert(a, string.lower(b))
    end
    pop()
    for _ = argc, 1, -1 do
        push(vm.types.string, table.remove(a))
    end
else   for _ = 1, argc+1, 1 do pop() end   end end