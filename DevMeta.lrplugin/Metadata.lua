--[[
        Metadata.lua
--]]



--============================================================================--

--[[
        Synopsis:           Return table of metadata fields.
        
        Notes:              - id:           unique identifier for internal reference.
                            - title:        what's shown in the UI.
                            - version:      primarily used for updating schema.
                            - data-type:    nil, string, enum, or url. If absent, field behaves like a string - I wish there was a 'number' type so that ranges could be defined.
--]]
return {

    metadataFieldsForPhotos = {

        { id='lastUpdate', title='DevMeta Updated', version=3, dataType='string', searchable=true, browsable=true },
        -- { id='lastUpdate', title='Last Updateee', version=6, searchable=true, browsable=true },
        
        -- Camera Calibration
        { id='ProcessVersion', title='Process Version', version=5, dataType='enum', values= { { value='5.0', title="2003" }, { value='5.7', title="2010" }, { value='6.6', title="2012 (Beta)" }, { value='6.7', title="2012 (Current)" }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },
        --{ id='ProcessVersionString', title='Process Version String', version=4, dataType='string' } --, searchable=true, browsable=false },
        { id='CameraProfile', title='Camera Profile', version=2, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='ShadowTint', title='Shadow Tint', version=5, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='rgbColorMods', title='RGB Color', version=3, dataType='enum', values = { { value='yes', title="Adjusted" }, { value='no', title="No Adjustments" }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },

        -- Basic
        { id='WhiteBalance', title='White Balance', version=2, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='Temperature', title='Temperature', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='Tint', title='Tint', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },

        -- PV2012
        { id='Exposure2012', title='Exposure 2012', version=2, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='Contrast2012', title='Contrast 2012', version=2, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='Highlights2012', title='Highlights 2012', version=2, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='Shadows2012', title='Shadows 2012', version=2, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='Whites2012', title='Whites 2012', version=2, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='Blacks2012', title='Blacks 2012', version=2, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='Clarity2012', title='Clarity 2012', version=3, dataType='string', readOnly=true, searchable=true, browsable=true }, -- clarity12 giving catalog update problems - value must be string.

        { id='Vibrance', title='Vibrance', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='Saturation', title='Saturation', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },
        
        -- PV03/10
        { id='Exposure', title='Exposure', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='HighlightRecovery', title='Highlight Recovery', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='FillLight', title='Fill Light', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='Shadows', title='Black Point', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='Brightness', title='Brightness', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='Contrast', title='Contrast', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='Clarity', title='Clarity', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },
        
        -- Tone/Point Curve(s)
        { id='ToneCurveName', title='Tone Curve Name', version=2, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='toneCurveParamMods', title='Parametric Shape', version=2, dataType='enum', values={ { value='yes', title="Adjusted" }, { value='no', title="No Adjustments" }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },
        { id='toneCurvePointMods', title='Point Curve', version=2, dataType='enum', values={ { value='yes', title="Adjusted" }, { value='no', title="No Adjustments" }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },
        { id='channelCurveMods', title='Channel Curves', version=1, dataType='enum', values = { { value='yes', title="Adjusted" }, { value='no', title="No Adjustments" }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },
        
        -- HSL / B&W
        { id='colorType', title='Color Type', version=2, dataType='enum', values={ { value='color', title="Color" }, { value='bw', title="Black & White" }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },
        { id='colorMods', title='Color Mix', version=2, dataType='enum', values={ { value='yes', title="Adjusted" }, { value='no', title="No Adjustments" }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },
        
        -- Split Toning
        { id='splitToning', title='Split Toning', version=2, dataType='enum', values={ { value='yes', title="Present" }, { value='no', title="None" }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },

        -- Detail
        { id='Sharpness', title='Sharpening Amount', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='SharpenRadius', title='Sharpen Radius', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='SharpenDetail', title='Sharpen Detail', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='SharpenEdgeMasking', title='Sharpen Masking', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },

        -- Lum-NR
        { id='LuminanceSmoothing', title='Luminance NR', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='LuminanceNoiseReductionDetail', title='Lum. NR Detail', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='LuminanceNoiseReductionContrast', title='Lum. NR Contrast', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },
                
        -- Color-NR
        { id='ColorNoiseReduction', title='Color NR', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='ColorNoiseReductionDetail', title='Color NR Detail', version=3, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='ColorNoiseReductionSmoothness', title='Color NR Smoothness', version=1, dataType='string', readOnly=true, searchable=true, browsable=true },

        -- Lens corrections
        { id='lensDistortion', title='Lens Distortion', version=2, dataType='enum', values={ { value='both', title="Profile + Manual" }, { value='profile', title='Profile Only' }, { value='manual', title='Manual Only' }, { value='none', title='None' }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },
        { id='lensVignetting', title='Lens Vignetting', version=2, dataType='enum', values={ { value='both', title="Profile + Manual" }, { value='profile', title='Profile Only' }, { value='manual', title='Manual Only' }, { value='none', title='None' }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },
        { id='lensCa', title='Chromatic Aberration', version=3, dataType='enum', values={ { value='auto', title="Auto" }, { value='both', title="Profile + Manual" }, { value='profile', title='Profile Only' }, { value='manual', title='Manual Only' }, { value='none', title='None' }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },
        { id='perspective', title='Perspective', version=2, dataType='enum', values={ { value='yes', title="Present" }, { value='no', title="None" }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },
        
        -- Effects
        { id='postCropVignette', title='Post Crop Vignette', version=2, dataType='enum', values={ { value='yes', title="Present" }, { value='no', title="None" }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },
        { id='grain', title='Grain', version=2, dataType='enum', values={ { value='yes', title="Present" }, { value='no', title="None" }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },
        
        -- Crop & Locals
        { id='CropWidth', title='Cropped Width', version=2, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='CropHeight', title='Cropped Height', version=2, dataType='string', readOnly=true, searchable=true, browsable=true },
        { id='retouched', title='Spot Removal', version=2, dataType='enum', values={ { value='yes', title="Present" }, { value='no', title="None" }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },
        { id='redeye', title='Red-Eye Corrections', version=2, dataType='enum', values={ { value='yes', title="Present" }, { value='no', title="None" }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },
        { id='gradients', title='Gradients', version=2, dataType='enum', values={ { value='yes', title="Present" }, { value='no', title="None" }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },
        { id='radGradients', title='Radial Gradients', version=1, dataType='enum', values={ { value='yes', title="Present" }, { value='no', title="None" }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },
        { id='brushes', title='Brushes', version=2, dataType='enum', values={ { value='yes', title="Present" }, { value='no', title="None" }, { value=nil, title="Undefined" } }, readOnly=true, searchable=true, browsable=true },
       
        -- Non Develop & Derived Metadata
        { id='stackPos', title='Stack Position', version=3, dataType='string', readOnly=true, searchable=true, browsable=true }, -- data-type?
        { id='stackCount', title='Stack Count', version=2, dataType='string', readOnly=true, searchable=true, browsable=true }, -- might as well declare type as it is being used today,
            -- if tomorrow numeric types are supported, I will re-release with bumped version number and schema conversion routine.
        { id='pixelCount', title='Pixel Count', version=3, dataType = 'string', readOnly=true, searchable=true, browsable=true },
        { id='aspectRatio', title='Aspect Ratio', version=3, dataType = 'string', readOnly=true, searchable=true, browsable=true },
        
    },

    -- Schema version history:
    --      1        First released schema.
    --      2-6      Test schema: never released.
    --      7        Second released schema: changed 'true'/'false' enums to 'yes'/'no' to work-around bug in enum metadata display.
    --      8        Added crop-width/height (version 1).
    --      X        Added rad-gradient (version 1) - no schema bump.
    schemaVersion = 8,
    
    -- the manual update function will forever-more be called instead of auto-updating.
    noAutoUpdate = true,
    
    
    -- When the plug-in is first installed, previousSchemaVersion is nil.
    -- This function is pre-wrapped by catalog:withPrivateWriteAccessDo
    updateFromEarlierSchemaVersion = function( catalog, previousSchemaVersion, progressScope )

        -- Not sure if this check is necessary, but I don't think it will hurt:
        if previousSchemaVersion == nil then
            return
        end
    
        if previousSchemaVersion < 7 then -- generally it will be 1 (or was it 2?) for all users except me.
            local pluginId = _PLUGIN.id -- 'com.robcole.lightroom.metadata.DevMeta'
            local photosToMigrate = catalog:getAllPhotos()
            local total = #photosToMigrate
            local function update( photo, name )
                local oldValue = photo:getPropertyForPlugin( pluginId, name )
                local newValue
                if oldValue == 'true' then
                    newValue = 'yes'
                elseif oldValue == 'false' then
                    newValue = 'no'
                end
                if newValue then
                    photo:setPropertyForPlugin( _PLUGIN, name, newValue )
                end
            end
            for i, photo in ipairs( photosToMigrate ) do
                update( photo, 'rgbColorMods' )
                update( photo, 'toneCurveParamMods' )
                update( photo, 'toneCurvePointMods' )
                update( photo, 'colorMods' )
                update( photo, 'splitToning' )
                update( photo, 'perspective' )
                update( photo, 'postCropVignette' )
                update( photo, 'grain' )
                -- update( photo, 'cropped' ) - not sure why this was there - seems croppage boolean is supported in lr proper.
                update( photo, 'retouched' )
                update( photo, 'redeye' )
                update( photo, 'gradients' )
                -- note: radGradients was added 3/Dec/2014 21:15, but schema version not bumped. I don't *think* schema version needs to be bumped just because an item was added - only if a schema conversion is required.
                update( photo, 'brushes' )
                progressScope:setPortionComplete( i, total )
            end
        elseif previousSchemaVersion <= 8 then
            -- must be a metadata item version trigger(?)
            --[[for i, photo in ipairs( catalog:getAllPhotos() ) do
                for j, v in ipairs ( metadataFieldsForPhotos ) do
                    local val = photo:getPropertyForPlugin( _PLUGIN, v.id )
                    photo:setPropertyForPlugin( _PLUGIN, v.id, str:to( val ) )
                end
            end--]]
        else
            error( "can not convert metadata from schema version " .. tostring( previousSchemaVersion ) )
        end
    end,
    
}
