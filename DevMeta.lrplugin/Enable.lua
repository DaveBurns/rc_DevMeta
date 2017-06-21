--[[
        Enable.lua
--]]

-- under unusual circumstances, app may not yet created when this is called.
if app then
    app:call( Call:new{ name='Enable', async=false, guard=App.guardSilent, main=function( call )
        app:log( "^1 is enabled. Its menu, metadata, and/or export functions should be accessible.", app:getAppName() )
    end } )
end
