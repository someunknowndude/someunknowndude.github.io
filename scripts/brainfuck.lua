brainfuck_env = {
    outputstack = "",
    outputstring = ""
}
return function(src)
    src = src:gsub("%s+","")
    outputstack = ""
    outputstring = ""
    local char_map = {
        [">"] = "i = i+1;";
        ["<"] = "i = i-1;";
        ["+"] = "t[i] = t[i]+1;";
        ["-"] = "t[i] = t[i]-1;";
        [","] = "t[i] = outputstack:byte();";
        ["."] = "brainfuck_env.outputstack = tostring(string.char(tostring(t[i])));brainfuck_env.outputstring ..= brainfuck_env.outputstack;";
        ["["] = "while t[i] ~= 0 do ";
        ["]"] = "end;";
    }
    local str = ""
    for i= 1, #src do 
        str ..= char_map[src:sub(i,i)] 
    end
    loadstring("local i,t=1,setmetatable({},{__index=function() return 0 end});"..str)()
    return brainfuck_env.outputstring
end
