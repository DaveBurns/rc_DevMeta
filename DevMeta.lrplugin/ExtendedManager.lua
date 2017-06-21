--[[
        ExtendedManager.lua
--]]


local ExtendedManager, dbg, dbgf = Manager:newClass{ className='ExtendedManager' }



--[[
        Constructor for extending class.
--]]
function ExtendedManager:newClass( t )
    return Manager.newClass( self, t )
end



--[[
        Constructor for new instance object.
--]]
function ExtendedManager:new( t )
    return Manager.new( self, t )
end



--- Static function to initialize plugin preferences (not framework preferences) - both global and non-global.
--
function ExtendedManager:_initGlobalPrefs()
    Manager._initGlobalPrefs( self )
end



--- Static function to initialize plugin preferences (not framework preferences) - both global and non-global.
--
function ExtendedManager:_initPrefs( presetName )
    app:initPref( 'background', false, presetName ) -- change to true to support on-going background processing, after async init.
    app:initPref( 'processTargetPhotosInBackground', false, presetName ) -- change default to true, if desired.
    app:initPref( 'processAllPhotosInBackground', false, presetName ) -- ditto.
    app:initPref( 'backgroundPeriod', .1, presetName ) -- ditto.
    app:initPref( 'idleThreshold', 1, presetName )
    --app:initPref( 'nonDevMetaEna', true, presetName ) -- for backward compat.
    Manager._initPrefs( self, presetName )
end



--- Start of plugin manager dialog.
-- 
function ExtendedManager:startDialogMethod( props )
    Manager.startDialogMethod( self, props ) -- adds observer to all props.
end



--- Preference change handler.
--
--  @usage      Handles preference changes.
--              <br>Preferences not handled are forwarded to base class handler.
--  @usage      Handles changes that occur for any reason, one of which is user entered value when property bound to preference,
--              <br>another is preference set programmatically - recursion guarding is essential.
--
function ExtendedManager:prefChangeHandlerMethod( _id, _prefs, key, value )
    Manager.prefChangeHandlerMethod( self, _id, _prefs, key, value )
end



--- Property change handler.
--
--  @usage      Properties handled by this method, are either temporary, or
--              should be tied to named setting preferences.
--
function ExtendedManager:propChangeHandlerMethod( props, name, value, call )
    if app.prefMgr and (app:getPref( name ) == value) then -- eliminate redundent calls.
        -- Note: in managed cased, raw-pref-key is always different than name.
        -- Note: if preferences are not managed, then depending on binding,
        -- app-get-pref may equal value immediately even before calling this method, in which case
        -- we must fall through to process changes.
        return
    end
    -- *** Instructions: strip this if not using background processing:
    if name == 'background' then
        app:setPref( 'background', value )
        if value then
            local started = background:start()
            if started then
                app:show( "Auto-update started." )
            else
                app:show( "Auto-update already started." )
            end
        elseif value ~= nil then
            app:call( Call:new{ name = 'Stop Background Task', async=true, guard=App.guardVocal, main=function( call )
                local stopped
                repeat
                    stopped = background:stop( 10 ) -- give it some seconds.
                    if stopped then
                        app:logVerbose( "Auto-update was stopped by user." )
                        app:show( "Auto-update is stopped." ) -- visible status wshould be sufficient.
                    else
                        if dialog:isOk( "Auto-update stoppage not confirmed - try again? (auto-check should have stopped - please report problem; if you cant get it to stop, try reloading plugin)" ) then
                            -- ok
                        else
                            break
                        end
                    end
                until stopped
            end } )
        end
    else
        -- Note: preference key is different than name.
        Manager.propChangeHandlerMethod( self, props, name, value, call )
    end
end



--- Sections for bottom of plugin manager dialog.
-- 
function ExtendedManager:sectionsForBottomOfDialogMethod( vf, props)

    local appSection = {}
    if app.prefMgr then
        appSection.bind_to_object = props
    else
        appSection.bind_to_object = prefs
    end
    
	appSection.title = app:getAppName() .. " Settings"
	appSection.synopsis = bind{ key='presetName', object=prefs }

	appSection.spacing = vf:label_spacing()
	
    -- *** Instructions: tweak labels and titles and spacing and provide tooltips, delete unsupported background items,
    --                   or delete this whole clause if never to support background processing...
    -- PS - One day, this may be handled as a conditional option in plugin generator.

    appSection[#appSection + 1] =
        vf:row {
            bind_to_object = props,
            vf:static_text {
                title = "Auto-update control",
                width = share 'label_width',
            },
            vf:checkbox {
                title = "Automatically check most selected photo.",
                value = bind( 'background' ),
				--tooltip = "",
                width = share 'data_width',
            },
        }
    appSection[#appSection + 1] =
        vf:row {
            bind_to_object = props,
            vf:static_text {
                title = "Auto-update selected photos",
                width = share 'label_width',
            },
            vf:checkbox {
                title = "Automatically check selected photos.",
                value = bind( 'processTargetPhotosInBackground' ),
                enabled = bind( 'background' ),
				-- tooltip = "",
                width = share 'data_width',
            },
        }
    appSection[#appSection + 1] =
        vf:row {
            bind_to_object = props,
            vf:static_text {
                title = "Auto-update whole catalog",
                width = share 'label_width',
            },
            vf:checkbox {
                title = "Automatically check all photos in catalog.",
                value = bind( 'processAllPhotosInBackground' ),
                enabled = bind( 'background' ),
				-- tooltip = "",
                width = share 'data_width',
            },
        }
    appSection[#appSection + 1] =
        vf:row {
            vf:static_text {
                title = "Auto-update status",
                width = share 'label_width',
            },
            vf:static_text {
                bind_to_object = prefs,
                title = app:getGlobalPrefBinding( 'backgroundState' ),
                width_in_chars = 70, -- ok I guess.
                tooltip = 'auto-update status',
            },
        }
    appSection[#appSection + 1] =
        vf:row {
            vf:static_text {
                title = "Auto-update interval",
                width = share 'label_width',
            },
            vf:edit_field {
                value = bind 'backgroundPeriod',
                width_in_chars = 10,
                precision = 2,
                min = .01,
                max = 5,
                tooltip = 'If auto-updating too slow, decrease this number; if auto-update consuming too much CPU and/or impacting Lr performance, try increasing this number. Default @5/Feb/2014 is .1 (before that it was .5)',
            },
            vf:static_text {
                title = "seconds."
            },
        }
    appSection[#appSection + 1] =
        vf:row {
            vf:static_text {
                title = "Auto-update idle threshold",
                width = share 'label_width',
            },
            vf:edit_field {
                value = bind 'idleThreshold',
                width_in_chars = 10,
                precision = 0,
                min = 1,
                max = 5,
                tooltip = 'Another (more escoteric) performance tuning value - defines number of beats skipped before doing the more leisurely updating - set this to 1 for fastest updating of selected photos and whole-catalog, up to 5 for more leisurely updating. - hint: if you have interval set really low, you may need to set this to 2 or 3, if you have interval set higher, then you should probably set this to 1. Also, if you make a lot of multi-photo adjustements (e.g. via quick-dev or auto-sync), you may want to set this to 2 or 3+ instead of 1. Default @5/Feb/2014 is 1 (before that it was 2).',
            },
            vf:static_text {
                title = "times."
            },
        }
        
    --[[ *** really need to deep-6 the metadata items if not updating them.
    appSection[#appSection + 1] =
        vf:row {
            vf:static_text {
                title = "Enable non-dev metadata",
                width = share 'label_width',
            },
            vf:checkbox {
                title = "Deprecated in favor of Metadata Extensions.",
                value = bind 'nonDevMetaEna',
                width = share 'data_width',
                tooltip = "Uncheck this if you're not using non-dev metadata, or your non-dev metadata is covered by Metadata Extensions... - it's checked by default in the interest of backward compatibility, but should be unchecked if not necessary...",
            },
            --vf:static_text {
            --    title = "times."
            --},
        }
    --]]
    
    if not app:isRelease() then
    	appSection[#appSection + 1] = vf:spacer{ height = 20 }
    	appSection[#appSection + 1] = vf:static_text{ title = 'For plugin author only below this line:' }
    	appSection[#appSection + 1] = vf:separator{ fill_horizontal = 1 }
    	appSection[#appSection + 1] = 
    		vf:row {
    			vf:edit_field {
    				value = bind( "testData" ),
    			},
    			vf:static_text {
    				title = str:format( "Test data" ),
    			},
    		}
    	appSection[#appSection + 1] = 
    		vf:row {
    			vf:push_button {
    				title = "Test",
    				action = function( button )
    				    app:call( Call:new{ name='Test', async=true, main = function( call )
                            --app:show( { info="^1: ^2" }, str:to( app:getGlobalPref( 'presetName' ) or 'Default' ), app:getPref( 'testData' ) )
                            
                            local s = catalog:getTargetPhoto():getDevelopSettings()
                            app:show{ info="You got 5 seconds." }
                            LrTasks.sleep( 5 )
                            local t = catalog:getTargetPhoto():getDevelopSettings()
                            app:show{ info = str:to( tab:isEquivalent( s, t ) ) }
                                
                            
                        end } )
    				end
    			},
    			vf:static_text {
    				title = str:format( "Perform tests." ),
    			},
    		}
    end
		
    local sections = Manager.sectionsForBottomOfDialogMethod ( self, vf, props ) -- fetch base manager sections.
    if #appSection > 0 then
        tab:appendArray( sections, { appSection } ) -- put app-specific prefs after.
    end
    return sections
end



return ExtendedManager
-- the end.