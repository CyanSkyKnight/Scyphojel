require "/scripts/neb-colourmatchingfunctions.lua"

--Hook it to other scripts, to allow for compatibility to any file
local Nebcolourmatching_init = init
function init(...)
  Nebcolourmatching_init(...)
  self.obtainedSkinColour = false
end

local Nebcolourmatching_update = update
function update(dt, ...)
  Nebcolourmatching_update(dt,...)
  
  if not self.obtainedSkinColour then
    self.obtainedSkinColour = true
    
	local result = world.entityPortrait(activeItem.ownerEntityId(),"full")
    local i = 1
    local done = 0
    while i < 12 do
	  if string.find(sb.printJson(result[i].image), "body") ~= nil then
        local skinColour = sb.printJson(result[i].image)
        skinColour = skinColour:sub(2,-2)
        local splited = skinColour:split("?")
		--Set the skinColour Tag
        animator.setGlobalTag("skinColour", "?" .. splited[2])
		--Apply the effect to projectiles too
        adaptColourToAbility("?" .. splited[2])

        done = done + 1
      end
        
	  if string.find(sb.printJson(result[i].image), "head") ~= nil then
        local eyeColour = sb.printJson(result[i].image)
        eyeColour = eyeColour:sub(2,-2)
        local splited = eyeColour:split("?")
		--Set the eyeColour Tag
        animator.setGlobalTag("eyeColour", "?" .. splited[3])
		--Apply the effect to projectiles too
        adaptColourToAbility("?" .. splited[3])
        local split = splited[3]:split(";")
        split = split[3]:sub(8)
		
		--Set the light colour for muzzleflashes
		if animator.hasTransformationGroup("muzzle") then
          animator.setLightColor("muzzleFlash", {tonumber("0x"..split:sub(1,2))/1.5, tonumber("0x"..split:sub(3,4))/1.5, tonumber("0x"..split:sub(5,6))/1.5, (tonumber("0x"..split:sub(7,8)) or 255)/1.5})
		end
		if config.getParameter("activeTime") then
          animator.setLightColor("glow", {tonumber("0x"..split:sub(1,2))/1.5, tonumber("0x"..split:sub(3,4))/1.5, tonumber("0x"..split:sub(5,6))/1.5, (tonumber("0x"..split:sub(7,8)) or 255)/1.5})
		end

        done = done + 1
      end

      if done == 2 then
        i = 13
      end
		
      i = i + 1
    end
  end
end

--Adapts the colour to projectiles in both abilities
function adaptColourToAbility(process)
  local primaryAbility = self.weapon.abilities[1]
  local altAbility = self.weapon.abilities[2]
  --Primary Adaptation
  if primaryAbility and primaryAbility.projectileParameters then
    util.mergeTable(primaryAbility, {projectileParameters = {processing = (primaryAbility.projectileParameters.processing or "") .. process}})
  end
  --Alt Adaptation
  if altAbility and altAbility.projectileParameters then
    util.mergeTable(altAbility, {projectileParameters = {processing = (altAbility.projectileParameters.processing or "") .. process}})
  end
end

local Nebcolourmatching_uninit = uninit
function uninit(...)
  self.obtainedSkinColour = false
  Nebcolourmatching_uninit(...)
end