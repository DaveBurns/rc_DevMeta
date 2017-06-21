--[[
        DevMeta.lua
--]]

local DevMeta, dbg, dbgf = Object:newClass{ className = "DevMeta", register = true }



local arFmt -- aspect ratio format string ('C' syntax).



--- Constructor for extending class.
--
function DevMeta:newClass( t )
    return Object.newClass( self, t )
end


--- Constructor for new instance.
--
function DevMeta:new( t )
    local o = Object.new( self, t )
    return o
end


--  process one setting (not necessarily numeric) - put's setting as "plugin property" (custom metadata), if its changed.
--
--  @return 0 if not changed, 1 if changed.
-- 
function DevMeta:_processValue( photo, name, _value )

    local value

    if _value == nil then
        value = nil
    else
        value = tostring( _value )
    end
    
    local oldVal = photo:getPropertyForPlugin( _PLUGIN, name ) -- this will always yield a string in the future, but not the past - unless I forced an update schema...
    if oldVal ~= nil then
        oldVal = tostring( oldVal )
    end
    
    if value == oldVal then
        return 0
    else
        app:logVerbose( "^1 changing from '^2' to '^3'", name, str:to( oldVal ), str:to( value ) )
        photo:setPropertyForPlugin( _PLUGIN, name, value )
        return 1
    end    
    
end



--  translates raw metadata field into photo property, as formatted by to-string func.
--
function DevMeta:_updateRawMetadata( photo, path, name, toStringFunc )

    if not toStringFunc then
        toStringFunc = tostring
    end

    local chg = 0
    local meta = photo:getRawMetadata( name )
    if meta then
        meta = toStringFunc( meta )
        local metaPrev = photo:getPropertyForPlugin( _PLUGIN, name ) -- will always read string (or nil), since its always written string.
        if meta ~= metaPrev then
            photo:setPropertyForPlugin( _PLUGIN, name, meta )
            chg = 1
            app:logVerbose( "Updated property ^1 for ^2 from ^3 to ^4", name, path, metaPrev or 'nil', meta )
        else
            app:logVerbose( "Property ^1 unchanged for ^2, still ^3", name, path, meta )
        end
    else
        app:logWarning( "Metadata not found: " .. ( name or 'nil' ) )
    end
    return chg
    
end



--[[
        Synopsis:           Updates one photo's develop metadata, and maybe develop setting.
        
        Notes:              Reads photo's dev settings, then consolidates metadata, and checks for hot-edits.
        
        Returns:            number of changed items.
--]]        
function DevMeta:updatePhoto( photo, call )

    if arFmt == nil then
        local arDigits = num:numberFromString( app:getPref( "aspectRatioPrecision" ) ) -- this works even if value is already a number, and won't croak regardless.
        if arDigits == nil then
            arDigits = 2
        end
        arFmt = str:fmt( "%.^1f", arDigits )
    end

    local s = photo:getDevelopSettings()
    
    local path = photo:getRawMetadata( 'path' )
    local fileFormat = photo:getRawMetadata( 'fileFormat' )
            
    local chg = 0

    --   C A M E R A   C A L I B R A T I O N

    -- ProcessVersion
    local pv = nil
    if s.ProcessVersion == nil then
        app:log( "No process version in photo settings for: " .. path ) -- this happens a fair amount for jpegs for some reason.
    elseif s.ProcessVersion == '5.0' then -- 2003
        pv = s.ProcessVersion
    elseif s.ProcessVersion == '5.7' then -- 2010
        pv = s.ProcessVersion
    elseif s.ProcessVersion == '6.6' then -- 2012 beta
        pv = s.ProcessVersion
    elseif s.ProcessVersion == '6.7' then -- 2012 final
        pv = s.ProcessVersion
    else
        app:logError( "Unrecognized process version, plugin may need updating for new process version: " .. s.ProcessVersion .. ", photo: " .. path )
    end
    chg = chg + self:_processValue( photo, 'ProcessVersion', pv ) -- enum type wouldn't understand value not on list.


    chg = chg + self:_processValue( photo, 'CameraProfile', s.CameraProfile )
    
    
    chg = chg + self:_processValue( photo, 'ShadowTint', s.ShadowTint )

   
    if s.RedHue ~= 0 or s.RedSaturation ~= 0 or s.GreenHue ~= 0 or s.GreenSaturation ~= 0 or s.BlueHue ~= 0 or s.BlueSaturation ~= 0 then
        chg = chg + self:_processValue( photo, 'rgbColorMods', 'yes' )
    else
        chg = chg + self:_processValue( photo, 'rgbColorMods', 'no' )
    end
    
    if not s.EnableCalibration then
        app:logVerbose( "Camera calibration is disabled." )
    end
    

    --   B A S I C        
    
    chg = chg + self:_processValue( photo, 'WhiteBalance', s.WhiteBalance ) -- this line causing problems @Lr4.0 (Lr4b was OK).

    local temp
    local tint
    if fileFormat == 'RAW' or fileFormat == 'DNG' then -- note: DNGs may not be raw, but usually are - not catastrophic if wrong treatment of DNG.
        temp = s.Temperature
        tint = s.Tint
    else
        temp = s.IncrementalTemperature
        tint = s.IncrementalTint
    end
    if (s.WhiteBalance == 'Custom') then
        if temp ~= nil then -- incremental temp & tint not supported hot-edit-wise.
            chg = chg + self:_processValue( photo, 'Temperature', temp )
        end
        if tint ~= nil then
            chg = chg + self:_processValue( photo, 'Tint', tint )
        end
    else -- the checks for nil were added for this clause when there were some other problems, presumably unrelated.
        if temp ~= nil then
            chg = chg + self:_processValue( photo, 'Temperature', temp )
        end
        if tint ~= nil then
            chg = chg + self:_processValue( photo, 'Tint', tint )
        end
    end
    
    chg = chg + self:_processValue( photo, 'Exposure', s.Exposure )
    chg = chg + self:_processValue( photo, 'HighlightRecovery', s.HighlightRecovery )
    chg = chg + self:_processValue( photo, 'FillLight', s.FillLight )
    chg = chg + self:_processValue( photo, 'Shadows', s.Shadows )
    chg = chg + self:_processValue( photo, 'Brightness', s.Brightness )
    chg = chg + self:_processValue( photo, 'Contrast', s.Contrast )
    chg = chg + self:_processValue( photo, 'Clarity', s.Clarity )
    chg = chg + self:_processValue( photo, 'Vibrance', s.Vibrance )
    chg = chg + self:_processValue( photo, 'Saturation', s.Saturation )


    --   P V 2 0 1 2
    
    -- basics
    chg = chg + self:_processValue( photo, 'Exposure2012', s.Exposure2012 )
    chg = chg + self:_processValue( photo, 'Contrast2012', s.Contrast2012 )
    chg = chg + self:_processValue( photo, 'Highlights2012', s.Highlights2012 )
    chg = chg + self:_processValue( photo, 'Shadows2012', s.Shadows2012 )
    chg = chg + self:_processValue( photo, 'Whites2012', s.Whites2012 )
    chg = chg + self:_processValue( photo, 'Blacks2012', s.Blacks2012 )
    chg = chg + self:_processValue( photo, 'Clarity2012', s.Clarity2012 )
    
    -- new curves
    
    --ToneCurvePV2012
    --ToneCurvePV2012Green

    Debug.lognpp( s )

   
    --Debug.lognpp( s.ToneCurveName2012 ) -- linear (this is used in Lr4.0).
    --Debug.lognpp( s.ToneCurvePV2012 ) -- nil: perhaps never used in Lr4.0 (I think I got this from Lr4b).
    --Debug.lognpp( s.ToneCurve ) -- nil
    --Debug.lognpp( s.ToneCurvePV2012Green ) -- 0,0,255,255


    --   T O N E   C U R V E    

    -- when tone curve is disabled, it just sets the name to "linear".
    -- parametric:
    if s.ParametricShadows ~= 0 or s.ParametricDarks ~= 0 or s.ParametricLights ~= 0 or s.ParametricHighlights ~= 0 then
        chg = chg + self:_processValue( photo, 'toneCurveParamMods', 'yes' )
    else
        chg = chg + self:_processValue( photo, 'toneCurveParamMods', 'no' )
    end
    -- point
    if pv == '6.7' or pv == '6.6' then -- PV2012
        chg = chg + self:_processValue( photo, 'ToneCurveName', s.ToneCurveName2012 )
        local t = s.ToneCurvePV2012
        if t ~= nil then
            if type( t ) == 'table' then
                if t[1] ~= nil and t[2] ~= nil then
                    Debug.logn( "Got PV2012 point curve." )
                    if s.ToneCurveName2012 == 'Custom' then
                        chg = chg + self:_processValue( photo, 'toneCurvePointMods', 'yes' )
                        -- app:logWarning( "PV12 tone curve point mods" )
                    else
                        chg = chg + self:_processValue( photo, 'toneCurvePointMods', 'no' )
                        -- app:logWarning( "No PV12 tone curve point mods" )
                    end
                else
                    -- chg = chg + self:_processValue( photo, 'toneCurvePointMods', nil )
                    Debug.logn( "No points in 2012 tone curve." )
                end
            else
                Debug.logn( "2012 tone curve not table." )
            end
        else -- version of ACR precedes point-curve.
            --chg = chg + self:_processValue( photo, 'toneCurvePointMods', nil )
            Debug.logn( "No 2012 tone curve." )
        end
        local ch = 'no'
        local function doy( curve, name )
            if type( curve ) == 'table' then
                if curve[1] ~= nil and curve[2] ~= nil then
                    Debug.logn( "Got PV2012 point curve.", name )
                    if curve[1] == 0 and curve[2] == 0 and curve[3] == 255 and curve[4] == 255 then
                        --return false                        
                        -- app:logWarning( "PV12 tone curve point mods" )
                    else
                        ch = 'yes'
                        --return true
                    end
                else
                    -- chg = chg + self:_processValue( photo, 'toneCurvePointMods', nil )
                    Debug.logn( "No points in 2012 tone curve.", name )
                end
            else
                Debug.logn( "2012 tone curve not table.", name )
            end
        end
        doy( s.ToneCurvePV2012Red, "Red" )
        doy( s.ToneCurvePV2012Green, "Green" )
        doy( s.ToneCurvePV2012Blue, "Blue" )
        chg = chg + self:_processValue( photo, 'channelCurveMods', ch )
        
    elseif pv == "5.7" then -- PV2010
        chg = chg + self:_processValue( photo, 'ToneCurveName', s.ToneCurveName )
        local t = s.ToneCurve
        if t ~= nil then 
            if type( t ) == 'table' then
                if t[1] ~= nil and t[2] ~= nil then -- point curve requires at least one point to be considered "valid".
                    Debug.logn( "Found reglar point curve" )
                    if s.ToneCurveName == 'Custom' then
                        chg = chg + self:_processValue( photo, 'toneCurvePointMods', 'yes' )
                    else
                        chg = chg + self:_processValue( photo, 'toneCurvePointMods', 'no' )
                    end
                else -- version of ACR precedes point-curve.
                    chg = chg + self:_processValue( photo, 'toneCurvePointMods', nil )
                end
            else
                app:logWarning( "Tone curve not table." )
            end
        else
            Debug.logn( "No 2010 tone curve." )
        end
    elseif pv == "5.0" then -- PV2003
        chg = chg + self:_processValue( photo, 'ToneCurveName', s.ToneCurveName )
        chg = chg + self:_processValue( photo, 'toneCurvePointMods', nil ) -- PV2003 did not have point curve.
    else
        chg = chg + self:_processValue( photo, 'ToneCurveName', nil )
        chg = chg + self:_processValue( photo, 'toneCurvePointMods', nil ) -- all bets off, point-curve-wise.
        app:logWarning( "PV unrecognized." )
    end    

    
    --   C O L O R S
    
    if s.ConvertToGrayscale then
        photo:setPropertyForPlugin( _PLUGIN, 'colorType', 'bw' )
        if s.GrayMixerRed ~= 0 or s.GrayMixerOrange ~= 0 or s.GrayMixerYellow ~= 0 or s.GrayMixerGreen ~= 0 or s.GrayMixerAqua ~= 0 or s.GrayMixerBlue ~= 0 or s.GrayMixerPurple ~= 0 or s.GrayMixerMagenta ~= 0 then
            chg = chg + self:_processValue( photo, 'colorMods', 'yes' )
            if not s.EnableGrayscaleMix then
                app:logVerbose( "B & W adjustments are defined but disabled." )
            end
        else
            chg = chg + self:_processValue( photo, 'colorMods', 'no' )
        end
    else
        chg = chg + self:_processValue( photo, 'colorType', 'color' )
        if s.HueAdjustmentRed ~= 0 or s.HueAdjustmentOrange ~= 0 or s.HueAdjustmentYellow ~= 0 or s.HueAdjustmentGreen ~= 0 or s.HueAdjustmentAqua ~= 0 or s.HueAdjustmentBlue ~= 0 or s.HueAdjustmentPurple ~= 0 or s.HueAdjustmentMagenta ~= 0 or
           s.SaturationAdjustmentRed ~= 0 or s.SaturationAdjustmentOrange ~= 0 or s.SaturationAdjustmentYellow ~= 0 or s.SaturationAdjustmentGreen ~= 0 or s.SaturationAdjustmentAqua ~= 0 or s.SaturationAdjustmentBlue ~= 0 or s.SaturationAdjustmentPurple ~= 0 or s.SaturationAdjustmentMagenta ~= 0 or
           s.LuminanceAdjustmentRed ~= 0 or s.LuminanceAdjustmentOrange ~= 0 or s.LuminanceAdjustmentYellow ~= 0 or s.LuminanceAdjustmentGreen ~= 0 or s.LuminanceAdjustmentAqua ~= 0 or s.LuminanceAdjustmentBlue ~= 0 or s.LuminanceAdjustmentPurple ~= 0 or s.LuminanceAdjustmentMagenta ~= 0 then
            chg = chg + self:_processValue( photo, 'colorMods', 'yes' )
            if not s.EnableColorAdjustments then
                app:logVerbose( "Color adjustments are defined but disabled." )
            end
        else
            chg = chg + self:_processValue( photo, 'colorMods', 'no' )
        end
    end
    
    --   S P L I T   T O N I N G
    
    if s.SplitToningHighlightSaturation ~= 0 or s.SplitToningShadowSaturation ~= 0 then
        chg = chg + self:_processValue( photo, 'splitToning', 'yes' )
        if not s.EnableSplitToning then
            app:logVerbose( "Split toning is defined but disabled." )
        end
    else
        chg = chg + self:_processValue( photo, 'splitToning', 'no' )
    end
    
    if not s.EnableDetail then
        app:logVerbose( "Detail is disabled." )
    end
        
        
    --   D E T A I L    
    
    -- Sharpening
    chg = chg + self:_processValue( photo, 'Sharpness', s.Sharpness )
    chg = chg + self:_processValue( photo, 'SharpenRadius', s.SharpenRadius )
    chg = chg + self:_processValue( photo, 'SharpenDetail', s.SharpenDetail )
    chg = chg + self:_processValue( photo, 'SharpenEdgeMasking', s.SharpenEdgeMasking )
    
    -- Lum-NR
    chg = chg + self:_processValue( photo, 'LuminanceSmoothing', s.LuminanceSmoothing )
    chg = chg + self:_processValue( photo, 'LuminanceNoiseReductionDetail', s.LuminanceNoiseReductionDetail )
    chg = chg + self:_processValue( photo, 'LuminanceNoiseReductionContrast', s.LuminanceNoiseReductionContrast )
    
    -- Color-NR
    chg = chg + self:_processValue( photo, 'ColorNoiseReduction', s.ColorNoiseReduction )
    chg = chg + self:_processValue( photo, 'ColorNoiseReductionDetail', s.ColorNoiseReductionDetail )
    chg = chg + self:_processValue( photo, 'ColorNoiseReductionSmoothness', s.ColorNoiseReductionSmoothness )
    
    --   L E N S   C O R R E C T I O N S
    
    local lensCorrFlg = false
    if (s.LensProfileEnable ~= nil) and (s.LensProfileEnable == 1) then -- not true/false for some reason.
        -- distortion
        if s.LensProfileDistortionScale ~= 0 then
            lensCorrFlg = true
            if s.LensManualDistortionAmount ~= 0 then
                chg = chg + self:_processValue( photo, 'lensDistortion', 'both' )
            else
                chg = chg + self:_processValue( photo, 'lensDistortion', 'profile' )
            end
        else
            if s.LensManualDistortionAmount ~= 0 then
                chg = chg + self:_processValue( photo, 'lensDistortion', 'manual' )
                lensCorrFlg = true
            else
                chg = chg + self:_processValue( photo, 'lensDistortion', 'none' )
            end
        end
        -- vignetting
        if s.LensProfileVignettingScale ~= 0 then
            lensCorrFlg = true
            if s.VignetteAmount ~= 0 then
                chg = chg + self:_processValue( photo, 'lensVignetting', 'both' )
            else
                chg = chg + self:_processValue( photo, 'lensVignetting', 'profile' )
            end
        else
            if s.VignetteAmount ~= 0 then
                chg = chg + self:_processValue( photo, 'lensVignetting', 'manual' )
                lensCorrFlg = true
            else
                chg = chg + self:_processValue( photo, 'lensVignetting', 'none' )
            end
        end
        -- CA
        if s.AutoLateralCA == 1 then
            chg = chg + self:_processValue( photo, 'lensCa', 'auto' )
            lensCorrFlg = true
        elseif s.ProcessVersion ~= '6.6' and s.processVersion ~= '6.7' then        
            if s.LensProfileChromaticAberrationScale ~= 0 then
                lensCorrFlg = true
                if s.ChromaticAberrationR ~= 0 or s.ChromaticAberrationB ~= 0 then
                    chg = chg + self:_processValue( photo, 'lensCa', 'both' )
                else
                    chg = chg + self:_processValue( photo, 'lensCa', 'profile' )
                end
            else
                if s.ChromaticAberrationR ~= 0 or s.ChromaticAberrationB ~= 0 then
                    chg = chg + self:_processValue( photo, 'lensCa', 'manual' )
                    lensCorrFlg = true
                else
                    chg = chg + self:_processValue( photo, 'lensCa', 'none' )
                end
            end
        else
            chg = chg + self:_processValue( photo, 'lensCa', 'none' )
        end
    else -- profile not enabled
        if s.AutoLateralCA == 1 then
            chg = chg + self:_processValue( photo, 'lensCa', 'auto' )
            lensCorrFlg = true
        elseif s.ProcessVersion ~= '6.6' and s.processVersion ~= '6.7' then        
            if s.LensProfileChromaticAberrationScale ~= 0 then
                lensCorrFlg = true
                if s.ChromaticAberrationR ~= 0 or s.ChromaticAberrationB ~= 0 then
                    chg = chg + self:_processValue( photo, 'lensCa', 'both' )
                else
                    chg = chg + self:_processValue( photo, 'lensCa', 'profile' )
                end
            else
                if s.ChromaticAberrationR ~= 0 or s.ChromaticAberrationB ~= 0 then
                    chg = chg + self:_processValue( photo, 'lensCa', 'manual' )
                    lensCorrFlg = true
                else
                    chg = chg + self:_processValue( photo, 'lensCa', 'none' )
                end
            end
        else
            chg = chg + self:_processValue( photo, 'lensCa', 'none' )
        end
        -- distortion
        if s.LensManualDistortionAmount ~= 0 then
            chg = chg + self:_processValue( photo, 'lensDistortion', 'manual' )
            lensCorrFlg = true
        else
            chg = chg + self:_processValue( photo, 'lensDistortion', 'none' )
        end
        if s.VignetteAmount ~= 0 then
            chg = chg + self:_processValue( photo, 'lensVignetting', 'manual' )
            lensCorrFlg = true
        else
            chg = chg + self:_processValue( photo, 'lensVignetting', 'none' )
        end
    end
    
    -- perspective
    if s.PerspectiveVertical ~= nil then
        if s.PerspectiveVertical ~= 0 or s.PerspectiveHorizontal ~= 0 or s.PerspectiveRotate ~= 0 or s.PerspectiveScale ~= 100 then
            chg = chg + self:_processValue( photo, 'perspective', 'yes' )
            lensCorrFlg = true
        else
            chg = chg + self:_processValue( photo, 'perspective', 'no' )
        end
    else
        chg = chg + self:_processValue( photo, 'perspective', nil )
    end
        
    if lensCorrFlg and not s.EnableLensCorrections then
        app:logVerbose( "Lens corrections are defined but disabled." )
    end

    -- post-crop vignette
    if s.PostCropVignetteAmount ~= 0 then -- this may be nil if photo originated in Lr1? Or catalog upgrade assigns 0?
        chg = chg + self:_processValue( photo, 'postCropVignette', 'yes' )
        if not s.EnableEffects then
            app:logVerbose( "Post-crop vignette is defined but effects are disabled." )
        end
    else
        chg = chg + self:_processValue( photo, 'postCropVignette', 'no' )
    end
       
    -- grain
    if s.GrainAmount ~= nil then 
        if s.GrainAmount ~= 0 then
            chg = chg + self:_processValue( photo, 'grain', 'yes' )
            if not s.EnableEffects then
                app:logVerbose( "Grain is defined but effects are disabled." )
            end
        else
            chg = chg + self:_processValue( photo, 'grain', 'no' )
        end
    else
        chg = chg + self:_processValue( photo, 'grain', nil )
    end
    
    -- Reminder: up 'til 2011/05/25, 'cropped' boolean was supported in dev-meta, but now it's in Lr proper, so support dropped (may have just burned the Lr3 users(?) - oh well, @12/Oct/2013 - nobody has complained.
    --[[ *** save til 2015 - if no complaints, then remove.
    if (s.CropLeft == 0) and (s.CropRight <= 1) and (s.CropTop == 0) and (s.CropBottom <= 1) then -- not sure why, but I get right & bottom =1 for no crop - strange!
        -- I hope left and top are always 0 for no-crop(?)
        chg = chg + self:_processValue( photo, 'cropped', 'no' )
    else
        chg = chg + self:_processValue( photo, 'cropped', 'yes' )
    end
    --]]
    -- 3/Dec/2014 21:43 - just realized that crop-boolean is supported natively in smart collections, but NOT lib filters, so still has value as custom metadata,
    -- oh well, it's in metadata-extensions now, so good enough..

    -- spot removal.
    local nInfo = s.RetouchInfo and #s.RetouchInfo or 0 -- ever since Lr2..
    local nArea = ( app:lrVersion() >=5 and s.RetouchAreas ) and #s.RetouchAreas or 0 -- squiggles supported @Lr5.
    if nInfo > 0 or nArea > 0 then -- spots or squiggles
        chg = chg + self:_processValue( photo, 'retouched', 'yes' )
    else
        chg = chg + self:_processValue( photo, 'retouched', 'no' )
    end
    
    -- gradients
    if tab:isEmpty(s.GradientBasedCorrections) then
        chg = chg + self:_processValue( photo, 'gradients', 'no' )
    else
        chg = chg + self:_processValue( photo, 'gradients', 'yes' )
    end
    
    -- radial gradients
    if tab:isEmpty(s.CircularGradientBasedCorrections) then
        chg = chg + self:_processValue( photo, 'radGradients', 'no' )
    else
        chg = chg + self:_processValue( photo, 'radGradients', 'yes' )
    end
    
    -- brushes
    if tab:isEmpty(s.PaintBasedCorrections) then
        chg = chg + self:_processValue( photo, 'brushes', 'no' )
    else
        chg = chg + self:_processValue( photo, 'brushes', 'yes' )
    end
    
    -- redeye
    if tab:isEmpty(s.RedEyeInfo) then
        chg = chg + self:_processValue( photo, 'redeye', 'no' )
    else
        chg = chg + self:_processValue( photo, 'redeye', 'yes' )
    end
    
    
    
    --   M I S C
    -- (note: there is some overlap/dup here with metadata extensions plugin, oh well).
    
    -- stack-pos, stack-count
    local stackPos, stackCount
    if photo:getRawMetadata( "isInStackInFolder" ) then
        stackPos = photo:getRawMetadata( "stackPositionInFolder" )
        stackCount = photo:getRawMetadata( "countStackInFolderMembers" )
    else
        stackPos = 1 -- process-value converts all to string
        stackCount = 0
    end
    chg = chg + self:_processValue( photo, 'stackPos', stackPos )
    chg = chg + self:_processValue( photo, 'stackCount', stackCount )
    
    
    -- pixel-count & crop dims.
    local dim = photo:getRawMetadata( "croppedDimensions" )
    if dim and dim.width and dim.height then
        chg = chg + self:_processValue( photo, 'CropWidth', dim.width )
        chg = chg + self:_processValue( photo, 'CropHeight', dim.height )
        local pixCnt = tostring( dim.width * dim.height )
        local pixCntPrev = photo:getPropertyForPlugin( _PLUGIN, "pixelCount" ) -- string
        if pixCntPrev then
            pixCntPrev = tostring( pixCntPrev )
        end
        if pixCnt ~= pixCntPrev then
            photo:setPropertyForPlugin( _PLUGIN, "pixelCount", pixCnt )
            chg = chg + 1
            app:logVerbose( "Updated pixel count for: " .. path )
        else
            app:logVerbose( "Pixel count unchanged: " .. path ) -- ditto
        end
    -- else probably a video.
    end

    -- aspect-ratio
    chg = chg + self:_updateRawMetadata( photo, path, 'aspectRatio', function( value )
        return string.format( arFmt, value )
    end )

    -- last (but not least) update
    local dateTime = LrDate.currentTime()
    local dateTimeFormatted = LrDate.timeToUserFormat( dateTime, "%Y-%m-%d %H:%M:%S" )
    local prevUpdate = photo:getPropertyForPlugin( _PLUGIN, 'lastUpdate' )
    if chg > 0 or not str:is( prevUpdate ) then
        app:log( path .. " updated " .. dateTimeFormatted )
        photo:setPropertyForPlugin( _PLUGIN, 'lastUpdate', dateTimeFormatted )
    end
    
    return chg
    
end



--  Serves m-update-selected menu item - updates develop settings metadata for selected photos.    
--
function DevMeta:updateSelected()

    app:call( Service:new{ name="Update Develop Metadata", async=true, progress=true, guard=App.guardVocal, main=function( service )
    
        local s, m = background:pause()
        if not s then
            app:show( { error="Unable to update, error message: ^1" }, m )
            return
        end
        assert( background.state ~= 'running', "how running?" )

        local pcallStatus, changeCount
        local enough
       
        local photos = dia:promptForTargetPhotos{ prefix="Update metadata of", call=service } -- includes caption of progress indicator.
        if service:isQuit() then
            return
        end
        
        local nToDo = #photos
        local photos2 = {} -- to-do in 2nd phase.
        
        service.nUpdated = 0
        service.nChanged = 0
        
        app:log( "^1 to do.", str:plural( nToDo, "photo", true ) )
        
        local index
        local limit = 100
        
        local rawMeta
        
        -- catalog func
        local updateFunc = function( context, phase )
            local yc = 0
            local i1 = ( phase - 1 ) * limit + 1
            local i2 = math.min( phase * limit, #photos )
            app:logVerbose( "Updating photos from ^1 to ^2", i1, i2 )
            for i = i1, i2 do
                service:setPortionComplete( i - 1, #photos )                
                yc = app:yield( yc )
                local photo = photos[i]
                local fmt = rawMeta[photo].fileFormat
                if fmt ~= 'VIDEO' then
                    local photoPath = rawMeta[photo].path
                    local name = LrPathUtils.leafName( photoPath )
                    local nErrors = app:getErrorCount()
                    if nErrors == 0 then
                        service:setCaption( str:fmt( "File #^1: ^2", i, name ) )
                    else
                        service:setCaption( str:fmt( "Errors: ^3, File #^1: ^2", i, name, nErrors ) )
                    end
                    pcallStatus, changeCount = LrTasks.pcall( DevMeta.updatePhoto, self, photo, service ) -- don't kill entire update due to a problem with a single photo.
                    if pcallStatus then
                        photos2[#photos2 + 1] = photo -- save to update edit/upd-time below.
                        service.nUpdated = service.nUpdated + 1
                        if changeCount > 0 then
                            service.nChanged = service.nChanged + 1
                            app:log( "^1 changed, photo: ^2:", str:plural( changeCount, "dev metadata item", true ), photoPath ) -- catalog read-access not required @3.0.
                        else
                            app:log( "^1 - no changes", photoPath ) -- catalog read-access not required @3.0.
                        end
                    else
                        app:logErr( "Unable to update metadata for " .. photoPath .. ", error message: " .. str:to( changeCount ) )
                    end
                end
                if service:isQuit() then
                    return true
                end
            end
            if i2 < #photos then
                return false -- continue next phase.
            else
                service:setPortionComplete( 1 )                
            end
        end -- end-of-function-definition.

        local rawMeta2
        
        -- post catalog func
        local updateFunc2 = function( context )
            local count = 0
            local yc = 0
            for i, photo in ipairs( photos2 ) do
                service:setPortionComplete( i - 1, #photos2 )
                yc = app:yield( yc )
                local id = rawMeta[photo].uuid
                local tm = rawMeta2[photo].lastEditTime
                -- until 22/Sep/2011 17:16: catalog:setPropertyForPlugin( _PLUGIN, id, tm ) -- note: same field used by background task for idle processing support.
                local s, m = LrTasks.pcall( cat.setPropertyForPlugin, cat, id, tm ) -- note: same field used by background task for idle processing support.
                if s then
                    -- good
                else
                    app:logWarning( "Unable to save last-edit-time as catalog property, error message: ^1", m )
                end
                if service:isQuit() then
                    return
                end
            end
            service:setPortionComplete( 1 )
        end
        
        rawMeta = catalog:batchGetRawMetadata( photos, { 'uuid', 'path', 'fileFormat' } )            
        local sts, other = cat:updatePrivate( 15, updateFunc )
        if sts then
            Debug.logn( "processed good" )
        elseif sts == false then
            error( other or 'nil' )
        else
            error( "no sts" ) -- should never happen.
        end
        if sts and not service:isQuit() then
            service.scope:setCaption( "Finalizing..." )
            rawMeta2 = catalog:batchGetRawMetadata( photos2, { 'lastEditTime' } ) -- I think improvement is based on number of photos, not number of metadata items.
            updateFunc2() -- no longer requires catalog access.
        end
        if not sts then
            error( other )
        end
        
        -- log stat
        app:log( "^1 of ^2 had dev metadata changes.", service.nChanged, str:plural( service.nUpdated, 'photo', true ) )
        
    end, finale=function( service, status, message )
        background:continue()    
    end } )

end


return DevMeta