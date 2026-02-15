return function(s: (LocalScript | ModuleScript)?, strict: boolean, ...)
    local consts = {...};

    if s and not s.Parent then return false; end;

    if filtergc then
        local res: ((...any) -> (...any)) | boolean = filtergc("function", {
            Constants = consts,
            IgnoreExecutor = true
        }, s == nil);
        
        if not res then return false; end;
        
        if type(res) == "function" then res = {res}; end;
        
        for _, v in next, res do
            if isfunctionhooked and restorefunction and isfunctionhooked(v) then
                restorefunction(v);
            end;

            if not s or rawget(getfenv(v), "script") == s then
                return v;
            end;
        end;
    elseif getgc then
        local hasConsts = function(f: (...any) -> (...any))
            local _, _consts = pcall(debug.getconstants, f);
            if not _ or not _consts then return false; end;

            if strict and (#consts ~= #_consts) then return false; end;
            
            for v in consts do
                if not table.find(_consts, v) then
                    return false;
                end;
            end;
            return true;
        end;

        for _, v in next, getgc() do
            if type(v) == "function" and not (isexecutorclosure and isexecutorclosure(v)) then
                if isfunctionhooked and restorefunction and isfunctionhooked(v) then
                    restorefunction(v);
                end;

                if not s or rawget(getfenv(v), "script") == s then
                    if hasConsts(v) then
                        return v;
                    end;
                end;
            end;
        end;
    end;
    
    return false;
end;
