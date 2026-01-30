return function(s: (LocalScript | ModuleScript)?, strict: boolean, ...)
    local consts = {...};

    if s and not s.Parent then return false; end;

    if filtergc then
        local res: ((...any) -> (...any)) | boolean = filtergc("function", {
            Constants = consts,
            IgnoreExecutor = true
        }, s == nil);
        
        if not res or not s then return res or false; end;
        
        if type(res) == "function" then res = {res}; end;
        
        for _, v in next, res do
            if isfunctionhooked and isfunctionhooked(v) then
                restorefunction(v);
            end;

            if rawget(getfenv(v), "script") == s then
                return v;
            end;
        end;
    else
        local hasConsts = function(f: (...any) -> (...any))
            local _, _consts = pcall(debug.getconstants, f);
            if not _ or not _consts or (strict and (#consts ~= #_consts) or false) then return false; end;
            
            for v in consts do
                if not table.find(_consts, v) then
                    return false;
                end;
            end;
            return true;
        end;

        for _, v in next, getgc() do
            if type(v) == "function" and not isexecutorclosure(v) then
                if isfunctionhooked and isfunctionhooked(v) then
                    restorefunction(v);
                end;

                if s and (rawget(getfenv(v), "script") == s) or true then
                    if hasConsts(v) then
                        return v;
                    end;
                end;
            end;
        end;
    end;
    
    return false;
end;
