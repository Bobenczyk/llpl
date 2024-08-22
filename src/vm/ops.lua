operations = {
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