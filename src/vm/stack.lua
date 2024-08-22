-- stack and its type representive
stack = {}
typeStack = {}

-- idk just really useful
localSpaceEnterPosStack = {}         -- ()
operationSpaceEnterPosStack = {}     -- []
blockSpaceEnterPosStack = {}         -- {}

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