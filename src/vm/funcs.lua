functions = {
    setg = function(argc)                    -- set global var
        if argc > 1 then
            for _ = 1, argc-2 do pop() end
            local vv, vt = pop()
            local nv, _ = pop()
            vars[nv] = vv
            varTypes[nv] = vt
        elseif argc == 1 then
            pop()
        end
        pop()
    end,

    getg = function(argc)                    -- get global var
        for _ = 1, argc-1 do pop() end
        if argc > 0 then
            local nv, _ = pop()
            pop()
            if varTypes[nv] and vars[nv] then
                push(varTypes[nv], vars[nv])
            end
        end
    end,

    getl = function(argc)                    -- get local var
        local vmStackLen = #vmStack
        if vmStackLen > 0 then
            for _ = 1, argc-1 do pop() end
            if argc > 0 then
                local nv, _ = pop()
                pop()
                local at, a = vmStack[vmStackLen].varTypes[nv], vmStack[vmStackLen].vars[nv]
                if a and at then
                    push(at, a)
                end
            end
        else
            return false
        end
    end,

    set = function(argc)                    -- set local var
        local vmStackLen = #vmStack
        -- print("SET "..vmStackLen)
        if vmStackLen > 0 then
            if argc > 1 then
                for _ = 1, argc-2 do pop() end
                local vv, vt = pop()
                local nv, _ = pop()
                -- print(vv)
                vmStack[vmStackLen].vars[nv] = vv
                vmStack[vmStackLen].varTypes[nv] = vt
            elseif argc == 1 then
                local nv, _ = pop()
                vmStack[vmStackLen].vars[nv] = nil
                vmStack[vmStackLen].varTypes[nv] = nil
            end
            pop()
        else
            return false
        end
    end,

    get = function(argc)                    -- get local var if exists else get local var
        for _ = 1, argc-1 do pop() end
        if argc > 0 then
            local nv, _ = pop()
            pop()
            local at, a
            local vmStackLen = #vmStack
            if vmStackLen > 0 then
                for i = vmStackLen, 1, -1 do
                    at, a = vmStack[i].varTypes[nv], vmStack[i].vars[nv]
                    if at then
                        goto b
                    end
                end
            end
            if vmStackLen == 0 or not at then
                at, a = varTypes[nv], vars[nv]
            end
            ::b::
            if a and at then
                push(at, a)
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
            -- local at, a = (vmStack[#vmStack].varTypes or {}), (vmStack[#vmStack].vars or {})
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

    -- if, while, for, fori
}