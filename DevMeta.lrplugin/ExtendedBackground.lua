--[[
        ExtendedBackground.lua
--]]

local ExtendedBackground, dbg, dbgf = Background:newClass{ className = 'ExtendedBackground' }



--- Constructor for extending class.
--
--  @usage      Although theoretically possible to have more than one background task,
--              <br>its never been tested, and its recommended to just use different intervals
--              <br>for different background activities if need be.
--
function ExtendedBackground:newClass( t )
    return Background.newClass( self, t )
end



--- Constructor for new instance.
--
--  @usage      Although theoretically possible to have more than one background task,
--              <br>its never been tested, and its recommended to just use different intervals
--              <br>for different background activities if need be.
--
function ExtendedBackground:new( t )
    local interval
    local minInitTime
    local idleThreshold
    if app:getUserName() == '_RobCole_' then
        interval = .1
        idleThreshold = 1
        minInitTime = 3
    else
        interval = .1 -- was .5 unil 5/Feb/2014 6:53
        idleThreshold = 1 -- was 2 unil 5/Feb/2014 6:53
        -- default min-init-time is 10-15 seconds or so.
    end
    local o = Background.new( self, { interval=interval, minInitTime=minInitTime, idleThreshold=idleThreshold } )
    o.lastEditTime = {}
    return o
end



--- Initialize background task.
--
--  @param      call object - usually not needed, but its got the name, and context... just in case.
--
function ExtendedBackground:init( call )
    local s, m = true, nil -- initialize stuff common to on-demand services as well as background task.
    if s then    
        self.initStatus = true
        -- this pref name is not assured nor sacred - modify at will.
        if not app:getPref( 'background' ) then -- check preference that determines if background task should start.
            self:quit() -- indicate to base class that background processing should not continue past init.
        end
    else
        self.initStatus = false
        app:logError( "Unable to initialize due to error: " .. str:to( m ) )
        app:show( { error="Unable to initialize." } )
    end
end



--- Perform processing when Lr/plugin seems more-or-less idle.
--
function ExtendedBackground:idleProcess( target, call )
    self:process( call, target ) -- be careful to avoid infinite recursion.
end



--- Background processing method.
--
--  @param      call object - usually not needed, but its got the name, and context... just in case.
--
function ExtendedBackground:process( call, target )

    local photo
    if not target then
        photo = catalog:getTargetPhoto() -- most-selected.
        if photo == nil then
            self:considerIdleProcessing( call )
            return
        end
    else
        photo = target
    end
    
    local pcallStatus, pcallResult
    local lastEditTime = photo:getRawMetadata( 'lastEditTime' )
    local photoPath = photo:getRawMetadata( 'path' )
    local id = photo:getRawMetadata( 'uuid' )
    -- until 22/Sep/2011 18:05 - local lastUpdateTime = catalog:getPropertyForPlugin( _PLUGIN, id ) -- each id is associated with the single property of last-update-time.
    local lastUpdateTime = cat:getPropertyForPlugin( id ) -- each id is associated with the single property of last-update-time.
    --dbg( "last-update-time:", LrDate.timeToUserFormat( lastUpdateTime, "%Y-%m-%d %H:%M:%S" ) )
    --dbg( "last-update-time:", lastUpdateTime )
    local fmt = photo:getRawMetadata( 'fileFormat' )
    if ( fmt ~= 'VIDEO' ) and ( (lastUpdateTime == nil) or (lastEditTime > lastUpdateTime) ) then -- this test only works when catalog gate returned between updates.
        --dbg( "last-edit-time:", LrDate.timeToUserFormat( lastEditTime, "%Y-%m-%d %H:%M:%S" ) )
        dbg( "last-edit-time:", lastEditTime )
        dbg( "Auto-updating photo: " .. photoPath )
        local chgs = 0
        pcallStatus, pcallResult = LrTasks.pcall( catalog.withPrivateWriteAccessDo, catalog, function( context ) -- not wrapped in catalog retry method, since best to take one shot, then try again later if fails.
            chgs = devMeta:updatePhoto( photo, call ) -- updates last-update-time in catalog
        end )
        if pcallStatus then
            local lastEditTime = photo:getRawMetadata( 'lastEditTime' ) -- only valid after returning from cat-write func.
            --pcallStatus = LrTasks.pcall( catalog.withWriteAccessDo, catalog, "Update last edit time in catalog", function( context ) -- not wrapped in catalog retry method, since best to take one shot, then try again later if fails.
                -- until 22/Sep/2011 17:19 - catalog:setPropertyForPlugin( _PLUGIN, id, lastEditTime ) -- not reliable with only private write access.
                -- Note: manual update forces change detection, regardless of last-edit-time - background task is the one that may hold off based on last-edit-time.
                local s, m = cat:setPropertyForPlugin( id, lastEditTime )
                if s then
                    -- good
                else
                    app:logVerbose( "Unable to set last-edit-time in background task: ^1", m )
                end
            --end )
            --if pcallStatus then
            --    dbg( 'Updated, changes:', chgs )
            --else
            --    dbg( "Not updated" ) 
            --end
        else -- may have been blocked. don't trip, it'll be updated next time, unless there is a fatal error, which there shouldn't be, once released..
            dbgf( "Unable to update metadata for ^1, error message: ^2", photoPath, pcallResult  )
        end
    else
        dbg( 'Not Updated', photoPath )
        if not target then -- avoid infinite recursion
            self:considerIdleProcessing( call )
            return
        end
    end
    
end



return ExtendedBackground
