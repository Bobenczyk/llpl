function printBlock(block, indent)
    print(indent.."size: "..tostring(block.s or math.max(#block.v, #block.t)))
    print(table.concat(block.v, ' '))
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


function printLocVars(posBackwords)
    local pos = #vmStack-(posBackwords or 0)
    print("\nlocal vars (+ types) ("..pos.."):")
    print("size: ".. #vmStack)
    if #vmStack >= pos then
        local loc = vmStack[pos]
        for k, v in pairs(loc.vars) do
            print('"'..k.."\" = \""..tostring(v).."\": \""..tostring(loc.varTypes[k]).."\"")
            if loc.varTypes[k] == vm.types.list then
                printList(v, "  ")
            elseif loc.varTypes[k] == vm.types.block then
                printBlock(v, "  ")
            end
        end
    end
end


function printVars() 
    print("\nvars (+ types):")
    for k, v in pairs(vars) do
        print('"'..k.."\" = \""..tostring(v).."\": \""..tostring(varTypes[k]).."\"")
        if varTypes[k] == vm.types.list then
            printList(v, "  ")
        elseif varTypes[k] == vm.types.block then
            printBlock(v, "  ")
        end
    end
end

function printStack()
    print("\nstack (+ types):")
    for i = 1, math.max(#stack, #typeStack) do
        print(i..": \""..tostring(stack[i]).."\": \""..tostring(typeStack[i]).."\"")
        if typeStack[i] == vm.types.list then
            printList(stack[i], "  ")
        elseif typeStack[i] == vm.types.block then
            printBlock(stack[i], "  ")
        end
    end
end
