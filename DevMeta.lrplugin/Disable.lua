--[[
        Disable.lua
--]]

-- under unusual circumstances, app may not yet created when this is called.
if app then
    app:call( Call:new{ name='Disable', async=false, guard=App.guardSilent, main=function( call )
        app:log( "^1 is disabled - it must be enabled for menu, metadata, and/or export functionality...", app:getAppName() ) -- unintrusive, but if user is having problems,
            -- and reads the log file, the answer is there...
        -- show-info ends up being called multiple times - not cool.
    end } )
end
