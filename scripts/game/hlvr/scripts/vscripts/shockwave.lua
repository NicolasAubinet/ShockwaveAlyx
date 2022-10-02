-- This is the script to integrate Shockwave suit with Half-Life Alyx

require "utils.class"
require "utils.library"
require "utils.vscriptinit"
require "core.coreinit"
require "utils.utilsinit"
require "framework.frameworkinit"
require "framework.entities.entitiesinit"
require "game.globalsystems.timeofday_init"
require "game.gameinit"

local unarmedList = {  "npc_antlion",
"npc_barnacle_tongue_tip",
"npc_antlionguard",
"npc_clawscanner",
"npc_concussiongrenade",
"npc_cscanner",
"npc_fastzombie",
"npc_headcrab",
"npc_headcrab_armored",
"npc_headcrab_black",
"npc_headcrab_fast",
"npc_headcrab_runner",
"npc_manhack",
"npc_poisonzombie",
"npc_zombie",
"npc_zombie_blind",
"npc_zombine",

"xen_foliage_bloater", --armored headcrab zombie

"env_explosion",
"env_fire",
"env_laser",
"env_physexplosion",
"env_physimpact",
"env_spark"
  }

local enemyList = {  
"npc_combine",
"npc_combine_s",
"npc_combinedropship",
"npc_combinegunship",
"npc_heli_nobomb",
"npc_helicopter",
"npc_helicoptersensor",
"npc_metropolice",
"npc_sniper",
"npc_strider",
"npc_hunter",
"npc_hunter_invincible",
"npc_turret_ceiling",
"npc_turret_ceiling_pulse",
"npc_turret_citizen",
"npc_turret_floor",

"xen_foliage_turret",
"xen_foliage_turret_projectile"
}

local weaponList = {
"hlvr_weapon_crowbar",
"hlvr_weapon_crowbar_physics",
"hlvr_weapon_energygun",
"hlvr_weapon_rapidfire",
"hlvr_weapon_shotgun"
}

local propPhysicsList = {


}

local twoHandMode = 0
local menuOpen = 1
local lastPlayerHealth = 100
local mouthClosed = 0
local coughing = 0

local function starts_with(str, start)
   return str:sub(1, #start) == start
end

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end


local function getDistance(a, b)
    local x, y, z = a.x-b.x, a.y-b.y, a.z-b.z;
    return x*x+y*y+z*z;
end

local function WriteToFile(line) 
  Msg("[Shockwave] " .. line)
end

local function GetAngleOfItem(itemClassName, pos, maxDistance)
  local angles = Entities:GetLocalPlayer():GetAngles()

    local closestPosition = pos
    local closestHandDist = maxDistance*maxDistance + 1

    local gloveEntities = Entities:FindAllByClassnameWithin(itemClassName, pos, maxDistance)
    for k,v in pairs(gloveEntities) do    

      local dist = getDistance(pos, v:GetCenter())

      if dist < closestHandDist then

        closestHandDist = dist
        closestPosition = v:GetCenter()
      end      
    end

  if closestHandDist == maxDistance*maxDistance+1 then
    return -1
  end

  local playerAngle = angles.y

  if playerAngle < 0 then
    playerAngle = (-1*playerAngle)+180    
  else 
     playerAngle = 180 - playerAngle    
  end

  local angle = (((math.atan2(closestPosition.y - pos.y, closestPosition.x - pos.x) - math.atan2(1, 0)) * (180/math.pi))*-1) + 90
  if (angle < 0) then
		angle = angle + 360;
  end

  angle = angle - playerAngle;

  angle = 360 - angle

  if angle < 0 then
    angle = angle + 360;
  elseif angle > 360 then
    angle = angle - 360;
  end  

  return angle;
end


function OnPlayerHurt(dmginfo)
  local center = Entities:GetLocalPlayer():GetCenter()
  local angles = Entities:GetLocalPlayer():GetAngles()

  local closestDistance = 2500000000
  local closestEntityClass = "unknown"
  local closestEntityName = "unknown"
  local closestEntityDebugName = "unknown"


  local closestPosition = center;

  local allEntities = Entities:FindAllInSphere(center, 100000)
  for k,v in pairs(allEntities) do    
    local entpos = v:GetCenter()
    local dist = getDistance(center, entpos)

    if v:IsAlive() == true then

      if has_value(enemyList, v:GetClassname()) or ( has_value(unarmedList, v:GetClassname()) and dist < 15000 ) or (starts_with(v:GetClassname(), "npc_antlion") and dist < 40000) or ((v:GetModelName() == nil or v:GetModelName() == "") and (string.match(v:GetClassname(), "item_hlvr_grenade") or string.match(v:GetClassname(), "npc_grenade") or string.match(v:GetClassname(), "npc_roller") or string.match(v:GetClassname(), "npc_concussiongrenade")) and dist < 50000) then 
        if dist < closestDistance then
          closestEntityClass = v:GetClassname()
          closestEntityName = v:GetName()
          closestEntityDebugName = v:GetDebugName()
          closestDistance = dist
          closestPosition = entpos
        end  
      end        
    end
  end

--  local attackerEntity = PlayerInstanceFromIndex(dmginfo["attacker"])
--  local attackerPosition = attackerEntity:getCenter()
--  local attackerDistance = getDistance(center, attackerPos)
--  local attackerEntityClass = attackerEntity:GetClassname()
--  local attackerEntityName = attackerEntity:GetName()
--  local attackerEntityDebugName = attackerEntity:GetDebugName()

  local playerAngle = angles.y

  if playerAngle < 0 then
    playerAngle = (-1*playerAngle)+180    
  else 
     playerAngle = 180 - playerAngle    
  end

  local angle = (((math.atan2(closestPosition.y - center.y, closestPosition.x - center.x) - math.atan2(1, 0)) * (180/math.pi))*-1) + 90
  if (angle < 0) then
		angle = angle + 360;
  end

  angle = angle - playerAngle;

  angle = 360 - angle

  if angle < 0 then
    angle = angle + 360;
  elseif angle > 360 then
    angle = angle - 360;
  end

  --Msg("Player angle: " .. tostring(playerAngle) .. " HeadingAngle: " .. tostring(angle) .. "\n")

  WriteToFile("{PlayerHurt|" .. tostring(dmginfo["health"]) .. "|" .. tostring(closestEntityClass) .. "|" .. tostring(math.floor(angle)) .. "|" .. tostring(closestEntityName) .. "|" .. tostring(closestEntityDebugName) .. "}\n")

end 


function OnPlayerShootWeapon(shootinfo)

  WriteToFile("{PlayerShootWeapon|" .. tostring(lastWeapon) .. "}\n")
  local pos = Entities:GetLocalPlayer():EyePosition()

  local closestEntityClass = "unknown"  
  if lastWeapon == "unknown" then
    -- Check entities to find weapon on hand.

    local closestDistance = 1000000
    local closestPosition = pos;

    local allEntities = Entities:FindAllInSphere(pos, 50)
    for k,v in pairs(allEntities) do    
      if v:IsAlive() == true then
        local entpos = v:GetCenter()
        if has_value(weaponList, v:GetClassname()) then 
          local dist = getDistance(pos, entpos)
          if dist < closestDistance then
            closestEntityClass = v:GetClassname()
            closestDistance = dist
            closestPosition = entpos
          end  
          --Msg(" -> Entity " .. tostring(k) .. ": " .. " Class: " .. tostring(v:GetClassname()) .. " Distance: " .. tostring(dist) .. " Pos: " .. tostring(entpos.x) .. " " .. tostring(entpos.y) .. " " .. tostring(entpos.z) .. "\n")
        end        
      end
    end 

    lastWeapon = closestEntityClass
  end


end 

function OnGrabbityGlovePull(gginfo)
	--Msg("Grabbity Glove Pull\n")
  WriteToFile("{PlayerGrabbityPull|" .. tostring((gginfo["hand_is_primary"])) .. "}\n")

end 

function OnGrabbityGloveLockStart(gginfo)
	--Msg("Grabbity Glove Lock Start\n")
  WriteToFile("{PlayerGrabbityLockStart|" .. tostring((gginfo["hand_is_primary"])) .. "}\n")

end 

function OnGrabbityGloveLockStop(gginfo)
	--Msg("Grabbity Glove Lock Start\n")
  WriteToFile("{PlayerGrabbityLockStop|" .. tostring((gginfo["hand_is_primary"])) .. "}\n")

end 

function OnGrabbedByBarnacle(gbinfo)
	--Msg("Player is grabbed by barnacle\n")
    WriteToFile("{PlayerGrabbedByBarnacle}\n")

end 

function OnReleasedByBarnacle(rbinfo)
	--Msg("Player is released by barnacle\n")
    WriteToFile("{PlayerReleasedByBarnacle}\n")
end 



function OnWeaponSwitch(weaponInfo)
  --Msg("Weapon switched to: " .. tostring(weaponInfo.item) .. "\n")
  lastWeapon = tostring(weaponInfo.item)
end

function OnGameNewMap(newMap)
  Msg("New map loading: " .. newMap.mapname .. "\n")  
end

function OnEntityKilled(info)
  if info["entindex_killed"] == 1 then  
      WriteToFile("{PlayerDeath|" .. tostring(info["damagebits"]) .. "}\n")
  end 
end


function 	OnItemPickup	(param) 

  --Msg("Item picked up: " .. tostring(param["item"]) .. "\n")

  if param["item"] == "item_hlvr_crafting_currency_large" or param["item"] == "item_hlvr_crafting_currency_small" then
    local pos = Entities:GetLocalPlayer():EyePosition()

    local angle = GetAngleOfItem("hl_prop_vr_hand", pos, 19)

    if (angle > 45 and angle < 135) or (angle > 225 and angle < 315) then
      local leftShoulder = 1

      if angle > 180 then
        leftShoulder = 0
      end 

      WriteToFile("{ItemPickup|" .. tostring(param["item"]) .. "|" .. tostring(leftShoulder) .. "}\n") 
    end
  end

end

function 	OnItemReleased	(param) 

  --Msg("Item released: " .. tostring(param["item"]) .. "\n")

  if param["item"] == "item_hlvr_prop_battery" then
    local center = Entities:GetLocalPlayer():GetCenter()

    local closestDistance = 100000
    local closestPosition = center;

    local batteryStationEntities = Entities:FindAllByClassnameWithin("info_particle_system", center, 300)
    for k,v in pairs(batteryStationEntities) do 
      if  string.match(v:GetDebugName(), "battery_hologram")  then 
        local dist = getDistance(center, v:GetCenter())
        --Msg(" -> Entity " .. tostring(k) .. ": " .. " Distance: " .. tostring(dist) .. "\tClass: " .. tostring(v:GetClassname()) ..  "|" .. tostring(v:GetName()) .. "|" .. tostring(v:GetDebugName()) .. "|" .. tostring(v:GetModelName()) .. "\n")

        if dist < closestDistance then          
          closestDistance = dist
          closestPosition = v:GetCenter()
        end
      end
    end

    if closestDistance ~= 100000 then      
      local leftHandUsed = 0
      local hmd_avatar = Entities:GetLocalPlayer():GetHMDAvatar()

      local leftHand= hmd_avatar:GetVRHand(0)
      local leftHandPos = leftHand:GetCenter()

      local rightHand= hmd_avatar:GetVRHand(1)
      local rightHandPos = rightHand:GetCenter()

      local distLeftHandToBatteryStation = getDistance(leftHandPos, closestPosition)
      local distRightHandToBatteryStation = getDistance(rightHandPos, closestPosition)

      --Msg("Left Hand dist to station: " .. tostring(distLeftHandToBatteryStation) .."\n")
      --Msg("Right Hand dist to station: " .. tostring(distRightHandToBatteryStation) .."\n")


      if distRightHandToBatteryStation < 400 or distLeftHandToBatteryStation < 400 then
        if distRightHandToBatteryStation > distLeftHandToBatteryStation then
          leftHandUsed = 1
        end

        WriteToFile("{ItemReleased|" .. tostring(param["item"]) .. "|" .. tostring(leftHandUsed) .. "}\n") 
      end
    end
  end
end
function 	OnGrabbityGloveCatch	(param) WriteToFile("{GrabbityGloveCatch|" .. tostring(param["hand_is_primary"]) .. "}\n") end
--function 	OnPlayerPickedUpWeaponOffHand	(param) WriteToFile("{PlayerPickedUpWeaponOffHand}\n") end
--function 	OnPlayerPickedUpWeaponOffHandCrafting	(param) WriteToFile("{PlayerPickedUpWeaponOffHandCrafting}\n") end
--function 	OnPlayerEjectClip	(param) WriteToFile("{PlayerEjectClip}\n") end
--function 	OnPlayerArmedGrenade	(param) WriteToFile("{PlayerArmedGrenade}\n") end
--function 	OnPlayerHealthPenPrepare	(param) WriteToFile("{PlayerHealthPenPrepare}\n") end
--function 	OnPlayerHealthPenRetract	(param) WriteToFile("{PlayerHealthPenRetract}\n") end
function 	OnPlayerPistolClipInserted	(param) WriteToFile("{PlayerPistolClipInserted}\n") end
--function 	OnPlayerPistolEmptyChamber	(param) WriteToFile("{PlayerPistolEmptyChamber}\n") end
function 	OnPlayerPistolChamberedRound	(param) WriteToFile("{PlayerPistolChamberedRound}\n") end
--function 	OnPlayerPistolSlideLock	(param) WriteToFile("{PlayerPistolSlideLock}\n") end
--function 	OnPlayerPistolBoughtLasersight	(param) WriteToFile("{PlayerPistolBoughtLasersight}\n") end
--function 	OnPlayerPistolToggleLasersight	(param) WriteToFile("{PlayerPistolToggleLasersight}\n") end
--function 	OnPlayerPistolBoughtBurstfire	(param) WriteToFile("{PlayerPistolBoughtBurstfire}\n") end
--function 	OnPlayerPistolToggleBurstfire	(param) WriteToFile("{PlayerPistolToggleBurstfire}\n") end
--function 	OnPlayerPistolPickedupChargedClip	(param) WriteToFile("{PlayerPistolPickedupChargedClip}\n") end
--function 	OnPlayerPistolArmedChargedClip	(param) WriteToFile("{PlayerPistolArmedChargedClip}\n") end
--function 	OnPlayerPistolClipChargeEnded	(param) WriteToFile("{PlayerPistolClipChargeEnded}\n") end


function 	OnPlayerRetrievedBackpackClip	(param) 
  local pos = Entities:GetLocalPlayer():EyePosition()

  local angle = GetAngleOfItem("hl_prop_vr_hand", pos, 30)

  local leftShoulder = 1

  if angle > 180 then
    leftShoulder = 0
  end

  WriteToFile("{PlayerRetrievedBackpackClip|" .. tostring(leftShoulder) .. "}\n") 

end


function 	OnPlayerDropAmmoInBackpack	(param) 

  local pos = Entities:GetLocalPlayer():EyePosition()

  local angle = GetAngleOfItem("hl_prop_vr_hand", pos, 30)

  local leftShoulder = 1

  if angle > 180 then
    leftShoulder = 0
  end

  WriteToFile("{PlayerDropAmmoInBackpack|" .. tostring(leftShoulder) .. "}\n") 


end
function 	OnPlayerDropResinInBackpack	(param) 

  local pos = Entities:GetLocalPlayer():EyePosition()

  local angle = GetAngleOfItem("hl_prop_vr_hand", pos, 30)

  local leftShoulder = 1

  if angle > 180 then
    leftShoulder = 0
  end

  WriteToFile("{PlayerDropResinInBackpack|" .. tostring(leftShoulder) .. "}\n")   
end


function OnPlayerHealthPenUsed(hpinfo)
	--Msg("Player has used health pen\n")
  local pos = Entities:GetLocalPlayer():GetCenter()

  local angle = GetAngleOfItem("item_healthvial", pos, 100)


  WriteToFile("{PlayerHeal|" .. tostring(math.floor(angle)) .. "}\n")

  local playerHealth = Entities:GetLocalPlayer():GetHealth()

  if playerHealth ~= nil then

    if playerHealth ~= lastPlayerHealth then
      lastPlayerHealth = playerHealth

      WriteToFile("{PlayerHealth|" .. tostring(playerHealth) .. "}\n")    
    end
  end
end 

function 	OnPlayerUsingHealthstation	(param) 

  local pos = Entities:GetLocalPlayer():GetCenter()

  local leftHandUsed = 0
  local hmd_avatar = Entities:GetLocalPlayer():GetHMDAvatar()

  local leftHand= hmd_avatar:GetVRHand(0)
  local leftHandPos = leftHand:GetCenter()

  local rightHand= hmd_avatar:GetVRHand(1)
  local rightHandPos = rightHand:GetCenter()

  local closestHealthStationPos; 
  local closestDist= 1000000;

  local healthStationEntities = Entities:FindAllByClassnameWithin("item_health_station_charger", pos, 1000)
  for k,v in pairs(healthStationEntities) do 
    local dist = getDistance(pos, v:GetCenter())

    if dist < closestDist then

      closestDist = dist
      closestHealthStationPos = v:GetCenter()
    end
  end

  local distLeftHandToHealthStation = getDistance(leftHandPos, closestHealthStationPos)
  local distRightHandToHealthStation = getDistance(rightHandPos, closestHealthStationPos)

  if distRightHandToHealthStation > distLeftHandToHealthStation then
    leftHandUsed = 1
  end

  WriteToFile("{PlayerUsingHealthstation|" .. tostring(leftHandUsed) .. "}\n") 

  local playerHealth = Entities:GetLocalPlayer():GetHealth()
  if playerHealth ~= nil then  
      lastPlayerHealth = playerHealth
      WriteToFile("{PlayerHealth|" .. tostring(playerHealth) .. "}\n")
  end
end

local function PlayerCoughFunc()
  local pos = Entities:GetLocalPlayer():EyePosition()

  local poisonous = false
  local allEntities = Entities:FindAllInSphere(pos, 50)
  for k,v in pairs(allEntities) do    
    local dist = getDistance(pos, v:GetCenter())

    if string.match(v:GetClassname(), "trigger") and string.match(v:GetName(), "cough_volume") then
      --Msg(" -> Entity " .. tostring(k) .. ": " .. " Class: " .. tostring(v:GetClassname()) .. " Distance: " .. tostring(dist) .. " Name: " .. tostring(v:GetName()) .. " DebugName: " .. tostring(v:GetDebugName()) .. "\n")
      if dist < 2100 then
        poisonous = true 
      end
    end
  end

  if poisonous == true then
    local newMouthClosed = mouthClosed

    if newMouthClosed == 1 then

      local hmd_avatar = Entities:GetLocalPlayer():GetHMDAvatar()

      local leftHand= hmd_avatar:GetVRHand(0)
      local leftHandPos = leftHand:GetCenter()

      local rightHand= hmd_avatar:GetVRHand(1)
      local rightHandPos = rightHand:GetCenter()

      local distLeftHandToEye = getDistance(leftHandPos, pos)
      local distRightHandToEye = getDistance(rightHandPos, pos)

      if distLeftHandToEye > 100 and distRightHandToEye > 100 then
        newMouthClosed = 0
      end  
    end

    if newMouthClosed == 0 then
      local allstuff = Entities:FindAllByClassnameWithin("prop_physics", pos, 10)
      for k,v in pairs(allstuff) do    
        if string.match(v:GetModelName(), "respirator") then
          local dist = getDistance(pos, v:GetCenter())
          if dist < 17 then
            newMouthClosed = 1
          end
        end
      end
    end

    mouthClosed = newMouthClosed

    if mouthClosed == 0 then
      if coughing == 0 then
        coughing = 1
        WriteToFile("{PlayerCoughStart}\n") 
      end
    else
      if coughing == 1 then
        coughing = 0
        WriteToFile("{PlayerCoughEnd}\n") 
      end
    end  
  else
    if coughing == 1 then
      coughing = 0
      WriteToFile("{PlayerCoughEnd}\n") 
    end
  end
end

function 	OnPlayerShotgunShellLoaded	(param) WriteToFile("{PlayerShotgunShellLoaded}\n") end
--function 	OnPlayerShotgunStateChanged	(param) WriteToFile("{PlayerShotgunStateChanged|" .. tostring(param["shotgun_state"]) .. "}\n") end
function 	OnPlayerShotgunUpgradeGrenadeLauncherState	(param) WriteToFile("{PlayerShotgunUpgradeGrenadeLauncherState|" .. param["state"] .. "}\n") end -- state 0: grenade launched - state 1: grenade attached - state 2: grenade ready -> Check and wait for 2 to 0
function 	OnPlayerShotgunAutoloaderState	(param) WriteToFile("{PlayerShotgunAutoloaderState|" .. tostring(param["state"]) .. "}\n") end
function 	OnPlayerShotgunAutoloaderShellsAdded	(param) WriteToFile("{PlayerShotgunAutoloaderShellsAdded}\n") end
--function 	OnPlayerShotgunUpgradeQuickfire	(param) WriteToFile("{PlayerShotgunUpgradeQuickfire}\n") end
--function 	OnPlayerShotgunIsReady	(param) WriteToFile("{PlayerShotgunIsReady}\n") end
--function 	OnPlayerShotgunOpen	(param) WriteToFile("{PlayerShotgunOpen}\n") end
function 	OnPlayerShotgunLoadedShells	(param) WriteToFile("{PlayerShotgunLoadedShells}\n") end
--function 	OnPlayerShotgunUpgradeGrenadeLong	(param) WriteToFile("{PlayerShotgunUpgradeGrenadeLong}\n") end
--function 	OnPlayerRapidfireCapsuleChamberEmpty	(param) WriteToFile("{PlayerRapidfireCapsuleChamberEmpty}\n") end
function 	OnPlayerRapidfireCycledCapsule	(param) WriteToFile("{PlayerRapidfireCycledCapsule}\n") end
--function 	OnPlayerRapidfireMagazineEmpty	(param) WriteToFile("{PlayerRapidfireMagazineEmpty}\n") end
function 	OnPlayerRapidfireOpenedCasing	(param) WriteToFile("{PlayerRapidfireOpenedCasing}\n") end
function 	OnPlayerRapidfireClosedCasing	(param) WriteToFile("{PlayerRapidfireClosedCasing}\n") end
function 	OnPlayerRapidfireInsertedCapsuleInChamber	(param) WriteToFile("{PlayerRapidfireInsertedCapsuleInChamber}\n") end
function 	OnPlayerRapidfireInsertedCapsuleInMagazine	(param) WriteToFile("{PlayerRapidfireInsertedCapsuleInMagazine}\n") end
--function 	OnPlayerRapidfireUpgradeSelectorCanUse	(param) WriteToFile("{PlayerRapidfireUpgradeSelectorCanUse}\n") end
--function 	OnPlayerRapidfireUpgradeSelectorUsed	(param) WriteToFile("{PlayerRapidfireUpgradeSelectorUsed}\n") end
--function 	OnPlayerRapidfireUpgradeCanCharge	(param) WriteToFile("{PlayerRapidfireUpgradeCanCharge}\n") end
--function 	OnPlayerRapidfireUpgradeCanNotCharge	(param) WriteToFile("{PlayerRapidfireUpgradeCanNotCharge}\n") end
--function 	OnPlayerRapidfireUpgradeFullyCharged	(param) WriteToFile("{PlayerRapidfireUpgradeFullyCharged}\n") end
--function 	OnPlayerRapidfireUpgradeNotFullyCharged	(param) WriteToFile("{PlayerRapidfireUpgradeNotFullyCharged}\n") end
function 	OnPlayerRapidfireUpgradeFired	(param) WriteToFile("{PlayerRapidfireUpgradeFired}\n") end
--function 	OnPlayerRapidfireEnergyBallCanCharge	(param) WriteToFile("{PlayerRapidfireEnergyBallCanCharge}\n") end
--function 	OnPlayerRapidfireEnergyBallFullyCharged	(param) WriteToFile("{PlayerRapidfireEnergyBallFullyCharged}\n") end
--function 	OnPlayerRapidfireEnergyBallNotFullyCharged	(param) WriteToFile("{PlayerRapidfireEnergyBallNotFullyCharged}\n") end
--function 	OnPlayerRapidfireEnergyBallCanPickUp	(param) WriteToFile("{PlayerRapidfireEnergyBallCanPickUp}\n") end
--function 	OnPlayerRapidfireEnergyBallPickedUp	(param) WriteToFile("{PlayerRapidfireEnergyBallPickedUp}\n") end
--function 	OnPlayerRapidfireStunGrenadeReady	(param) WriteToFile("{PlayerRapidfireStunGrenadeReady}\n") end
--function 	OnPlayerRapidfireStunGrenadeNotReady	(param) WriteToFile("{PlayerRapidfireStunGrenadeNotReady}\n") end
--function 	OnPlayerRapidfireStunGrenadePickedUp	(param) WriteToFile("{PlayerRapidfireStunGrenadePickedUp}\n") end
--function 	OnPlayerRapidfireExplodeButtonReady	(param) WriteToFile("{PlayerRapidfireExplodeButtonReady}\n") end
--function 	OnPlayerRapidfireExplodeButtonNotReady	(param) WriteToFile("{PlayerRapidfireExplodeButtonNotReady}\n") end
function 	OnPlayerRapidfireExplodeButtonPressed	(param) WriteToFile("{PlayerRapidfireExplodeButtonPressed}\n") end
function 	OnPlayerStarted2hLevitate	(param) WriteToFile("{PlayerStarted2hLevitate}\n") end

local function GetItemHolderCloseToHand()
  local leftHolder = 0
  local hmd_avatar = Entities:GetLocalPlayer():GetHMDAvatar()

  local leftHand= hmd_avatar:GetVRHand(0)
  local leftHandPos = leftHand:GetCenter()
  --Msg(" -> LeftHand Class: " .. tostring(leftHand:GetClassname()) .. " Pos: " .. tostring(leftHandPos.x) .. " " .. tostring(leftHandPos.y) .. " " .. tostring(leftHandPos.z) .. "\n")
  local rightHand= hmd_avatar:GetVRHand(1)
  local rightHandPos = rightHand:GetCenter()
  --Msg(" -> RightHand Class: " .. tostring(rightHand:GetClassname()) .. " Pos: " .. tostring(rightHandPos.x) .. " " .. tostring(rightHandPos.y) .. " " .. tostring(rightHandPos.z) .. "\n")

  local leftItemHolderPos;
  local rightItemHolderPos;
  local holderEntities = Entities:FindAllByClassname("hlvr_hand_item_holder")
  for k,v in pairs(holderEntities) do        
    local itemHolderPos = v:GetCenter()
    if v:GetDebugName() == "item_holder_l" then
      leftItemHolderPos =  v:GetCenter()
    elseif v:GetDebugName() == "item_holder_r" then
      rightItemHolderPos = v:GetCenter()
    end
  end

  local distLeftHandToRightHolder = getDistance(leftHandPos, rightItemHolderPos)
  local distRightHandToLeftHolder = getDistance(rightHandPos, leftItemHolderPos)

  if distRightHandToLeftHolder < distLeftHandToRightHolder then
    leftHolder = 1
  end

  return leftHolder
end

function 	OnPlayerStoredItemInItemholder	(param) 

  local leftHolder = GetItemHolderCloseToHand()

  WriteToFile("{PlayerStoredItemInItemholder|" .. tostring(leftHolder) .. "}\n")   

end

function 	OnPlayerRemovedItemFromItemholder	(param) 

  local leftHolder = GetItemHolderCloseToHand()

  WriteToFile("{PlayerRemovedItemFromItemholder|" .. tostring(leftHolder) .. "}\n")   

end

--function 	OnPlayerAttachedFlashlight	(param) WriteToFile("{PlayerAttachedFlashlight}\n") end
function 	OnHealthPenTeachStorage	(param) WriteToFile("{HealthPenTeachStorage}\n") end
function 	OnHealthVialTeachStorage	(param) WriteToFile("{HealthVialTeachStorage}\n") end
function 	OnPlayerCoveredMouth	(param) 
  mouthClosed = 1 
  coughing = 0
  WriteToFile("{PlayerCoveredMouth}\n") 
end
--function 	OnPlayerUpgradedWeapon	(param) WriteToFile("{PlayerUpgradedWeapon}\n") end
function 	OnTripmineHackStarted	(param) WriteToFile("{TripmineHackStarted}\n") end
function 	OnTripmineHacked	(param) WriteToFile("{TripmineHacked}\n") end
function 	OnPrimaryHandChanged	(param) WriteToFile("{PrimaryHandChanged|" .. tostring((param["is_primary_left"])) .."}\n") end
function 	OnSingleControllerModeChanged	(param) WriteToFile("{SingleControllerModeChanged|" .. tostring((param["is_primary_left"])) .."}\n") end
function 	OnMovementHandChanged	(param) WriteToFile("{MovementHandChanged}\n") end
function 	OnCombineTankMovedByPlayer	(param) WriteToFile("{CombineTankMovedByPlayer}\n") end
function 	OnPlayerContinuousJumpFinish	(param) WriteToFile("{PlayerContinuousJumpFinish}\n") end
function 	OnPlayerContinuousMantleFinish	(param) WriteToFile("{PlayerContinuousMantleFinish}\n") end
function 	OnPlayerGrabbedLadder	(param) 
--  local center = Entities:GetLocalPlayer():GetCenter()

--  local everyEntities = Entities:FindAllInSphere(center, 400)
--  for k,v in pairs(everyEntities) do    
--      local entpos = v:GetCenter()
--      Msg(" -> Entity " .. tostring(k) .. ": " .. " Class: " .. tostring(v:GetClassname()) .. " DebugName: " .. tostring(v:GetDebugName()) .." Distance: " .. tostring(getDistance(center, entpos)) .. " Pos: " .. tostring(entpos.x) .. " " .. tostring(entpos.y) .. " " .. tostring(entpos.z) .. "\n")              

--  end


--  WriteToFile("{PlayerGrabbedLadder}\n") 

end

function 	OnTwoHandStart	(param)
  if twoHandMode == 0 then
    twoHandMode = 1
    WriteToFile("{TwoHandStart}\n") 
  end
  mouthClosed = 0

  if Entities:GetLocalPlayer() ~= nil then
    local playerHealth = Entities:GetLocalPlayer():GetHealth()
    if playerHealth ~= nil then

      if playerHealth ~= lastPlayerHealth then
        lastPlayerHealth = playerHealth
        if lastPlayerHealth <=30 then
          WriteToFile("{PlayerHealth|" .. tostring(playerHealth) .. "}\n")
        end
      end
    end
  end
end
function 	OnTwoHandEnd	(param) 
  if twoHandMode == 1 then
    twoHandMode = 0
    WriteToFile("{TwoHandEnd}\n") 
  end  
--  local center = Entities:GetLocalPlayer():GetCenter()

--  local allEntities = Entities:FindAllInSphere(center, 2000)
--  for k,v in pairs(allEntities) do    
--      local entpos = v:GetCenter()
--      local dist = getDistance(center, entpos)

--      if dist <5000 then        
--        Msg(" -|-|-> Entity " .. tostring(k) .. ": " .. " Distance: " .. tostring(dist) .. "\tClass: " .. tostring(v:GetClassname()) ..  "|" .. tostring(v:GetName()) .. "|" .. tostring(v:GetDebugName()) ..  "|" .. tostring(v:GetModelName()) .. "\n")

--      end
--  end

  PlayerCoughFunc()

  if lastWeapon == "unknown" then
    -- Check entities to find weapon on hand.
    local closestEntityClass = "unknown"  

    local pos = Entities:GetLocalPlayer():GetCenter()
    local closestDistance = 1000000
    local closestPosition = pos;

    local allEntities = Entities:FindAllInSphere(pos, 1000)
    for k,v in pairs(allEntities) do    
      if v:IsAlive() == true then
        local entpos = v:GetCenter()
        if has_value(weaponList, v:GetClassname()) then 
          local dist = getDistance(pos, entpos)
          if dist < closestDistance then
            closestEntityClass = v:GetClassname()
            closestDistance = dist
            closestPosition = entpos
          end  
          --Msg(" -> Entity " .. tostring(k) .. ": " .. " Class: " .. tostring(v:GetClassname()) .. " Distance: " .. tostring(dist) .. " Pos: " .. tostring(entpos.x) .. " " .. tostring(entpos.y) .. " " .. tostring(entpos.z) .. "\n")
        end        
      end
    end 

    lastWeapon = closestEntityClass
  end

  if Entities:GetLocalPlayer() ~= nil then
    local playerHealth = Entities:GetLocalPlayer():GetHealth()
    if playerHealth ~= nil then

      if playerHealth ~= lastPlayerHealth then
        lastPlayerHealth = playerHealth
        if lastPlayerHealth <=30 then
          WriteToFile("{PlayerHealth|" .. tostring(playerHealth) .. "}\n")
        end
      end
    end
  end

end

function 	OnPlayerOpenedGameMenu	(param) 
  if menuOpen == 0 then
    menuOpen = 1
    WriteToFile("{PlayerOpenedGameMenu}\n") 
  end
end


function 	OnPlayerClosedGameMenu	(param) 
  if menuOpen ~= 0 then
    menuOpen = 0

    WriteToFile("{PlayerClosedGameMenu}\n") 
  end   
end

  ListenToGameEvent('player_spawn', function(info)
--    local included = DoIncludeScript("user/playerEntity.lua", Entities:GetLocalPlayer():GetOrCreatePrivateScriptScope())
--    local included2 = DoIncludeScript("user/playerEntity.lua", Entities:GetLocalPlayer():GetOrCreatePublicScriptScope())
--    local ent_table = {
--        origin = Entities:GetLocalPlayer():EyePosition(),
--        vscripts = "user/playerEntity.lua"
--    }
--    ent = SpawnEntityFromTableSynchronous("prop_physics", ent_table)
--    if ent ~= nil then
--      ent:SetParent(Entities:GetLocalPlayer(), "")
--    end    

    Msg("------> Player spawned: " .. tostring(info["userid"]) .. "\n")    
    WriteToFile("{Reset}\n")   
end, nil)

function 	OnPlayerTeleportStart	(param) 

  PlayerCoughFunc()

  if Entities:GetLocalPlayer() ~= nil then

    local playerHealth = Entities:GetLocalPlayer():GetHealth()
    if playerHealth ~= nil then

      if playerHealth ~= lastPlayerHealth then
        lastPlayerHealth = playerHealth
        WriteToFile("{PlayerHealth|" .. tostring(playerHealth) .. "}\n")       
      end
    end
  end

  if lastWeapon == "unknown" then
    -- Check entities to find weapon on hand.
    local closestEntityClass = "unknown"  

    local pos = Entities:GetLocalPlayer():GetCenter()
    local closestDistance = 1000000
    local closestPosition = pos;

    local allEntities = Entities:FindAllInSphere(pos, 1000)
    for k,v in pairs(allEntities) do    
      if v:IsAlive() == true then
        local entpos = v:GetCenter()
        if has_value(weaponList, v:GetClassname()) then 
          local dist = getDistance(pos, entpos)
          if dist < closestDistance then
            closestEntityClass = v:GetClassname()
            closestDistance = dist
            closestPosition = entpos
          end  
          --Msg(" -> Entity " .. tostring(k) .. ": " .. " Class: " .. tostring(v:GetClassname()) .. " Distance: " .. tostring(dist) .. " Pos: " .. tostring(entpos.x) .. " " .. tostring(entpos.y) .. " " .. tostring(entpos.z) .. "\n")
        end        
      end
    end 

    lastWeapon = closestEntityClass
  end
end
function 	OnPlayerTeleportFinish	(param) 

  PlayerCoughFunc()

  if Entities:GetLocalPlayer() ~= nil then
    local playerHealth = Entities:GetLocalPlayer():GetHealth()
    if playerHealth ~= nil then

      if playerHealth ~= lastPlayerHealth then
        lastPlayerHealth = playerHealth
        WriteToFile("{PlayerHealth|" .. tostring(playerHealth) .. "}\n")
      end
    end
  end

  if lastWeapon == "unknown" then
    -- Check entities to find weapon on hand.
    local closestEntityClass = "unknown"  

    local pos = Entities:GetLocalPlayer():GetCenter()
    local closestDistance = 1000000
    local closestPosition = pos;

    local allEntities = Entities:FindAllInSphere(pos, 1000)
    for k,v in pairs(allEntities) do    
      if v:IsAlive() == true then
        local entpos = v:GetCenter()
        if has_value(weaponList, v:GetClassname()) then 
          local dist = getDistance(pos, entpos)
          if dist < closestDistance then
            closestEntityClass = v:GetClassname()
            closestDistance = dist
            closestPosition = entpos
          end  
          --Msg(" -> Entity " .. tostring(k) .. ": " .. " Class: " .. tostring(v:GetClassname()) .. " Distance: " .. tostring(dist) .. " Pos: " .. tostring(entpos.x) .. " " .. tostring(entpos.y) .. " " .. tostring(entpos.z) .. "\n")
        end        
      end
    end 

    lastWeapon = closestEntityClass
  end
end

if IsServer() then   

  -- Stop listening to the events if we're already listening to them (this is so we can safely reload the script)
  if onplayershoot_event ~= nil then
    StopListeningToGameEvent(onplayershootweapon_event)

    StopListeningToGameEvent(onplayerhurt_event)

    StopListeningToGameEvent(onplayergrabbityglovepull_event)
    StopListeningToGameEvent(onplayergrabbedbybarnacle_event)
    StopListeningToGameEvent(onplayerreleasedbybarnacle_event)
    StopListeningToGameEvent(onplayerhealthpenused_event)
    StopListeningToGameEvent(onweaponswitch_event)    
    StopListeningToGameEvent(ongamenewmap_event)        
    StopListeningToGameEvent(onplayerspawn_event)    
    StopListeningToGameEvent(onentity_killed_event)   
    StopListeningToGameEvent(onentity_hurt_event)    



StopListeningToGameEvent(	onplayer_teleport_start_event	)
StopListeningToGameEvent(	onplayer_teleport_finish_event	)

StopListeningToGameEvent(	onitem_pickup_event	)
StopListeningToGameEvent(	onitem_released_event	)
StopListeningToGameEvent(	ongrabbity_glove_catch_event	)
StopListeningToGameEvent(	onplayer_picked_up_weapon_off_hand_event	)
StopListeningToGameEvent(	onplayer_picked_up_weapon_off_hand_crafting_event	)
StopListeningToGameEvent(	onplayer_eject_clip_event	)
StopListeningToGameEvent(	onplayer_armed_grenade_event	)
StopListeningToGameEvent(	onplayer_health_pen_prepare_event	)
StopListeningToGameEvent(	onplayer_health_pen_retract_event	)
StopListeningToGameEvent(	onplayer_pistol_clip_inserted_event	)
StopListeningToGameEvent(	onplayer_pistol_empty_chamber_event	)
StopListeningToGameEvent(	onplayer_pistol_chambered_round_event	)
StopListeningToGameEvent(	onplayer_pistol_slide_lock_event	)
StopListeningToGameEvent(	onplayer_pistol_bought_lasersight_event	)
StopListeningToGameEvent(	onplayer_pistol_toggle_lasersight_event	)
StopListeningToGameEvent(	onplayer_pistol_bought_burstfire_event	)
StopListeningToGameEvent(	onplayer_pistol_toggle_burstfire_event	)
StopListeningToGameEvent(	onplayer_pistol_pickedup_charged_clip_event	)
StopListeningToGameEvent(	onplayer_pistol_armed_charged_clip_event	)
StopListeningToGameEvent(	onplayer_pistol_clip_charge_ended_event	)
StopListeningToGameEvent(	onplayer_retrieved_backpack_clip_event	)
StopListeningToGameEvent(	onplayer_drop_ammo_in_backpack_event	)
StopListeningToGameEvent(	onplayer_drop_resin_in_backpack_event	)
StopListeningToGameEvent(	onplayer_using_healthstation_event	)
StopListeningToGameEvent(	onhealth_station_open_event	)
StopListeningToGameEvent(	onplayer_looking_at_wristhud_event	)
StopListeningToGameEvent(	onplayer_shotgun_shell_loaded_event	)
StopListeningToGameEvent(	onplayer_shotgun_state_changed_event	)
StopListeningToGameEvent(	onplayer_shotgun_upgrade_grenade_launcher_state_event	)
StopListeningToGameEvent(	onplayer_shotgun_autoloader_state_event	)
StopListeningToGameEvent(	onplayer_shotgun_autoloader_shells_added_event	)
StopListeningToGameEvent(	onplayer_shotgun_upgrade_quickfire_event	)
StopListeningToGameEvent(	onplayer_shotgun_is_ready_event	)
StopListeningToGameEvent(	onplayer_shotgun_open_event	)
StopListeningToGameEvent(	onplayer_shotgun_loaded_shells_event	)
StopListeningToGameEvent(	onplayer_shotgun_upgrade_grenade_long_event	)
StopListeningToGameEvent(	onplayer_rapidfire_capsule_chamber_empty_event	)
StopListeningToGameEvent(	onplayer_rapidfire_cycled_capsule_event	)
StopListeningToGameEvent(	onplayer_rapidfire_magazine_empty_event	)
StopListeningToGameEvent(	onplayer_rapidfire_opened_casing_event	)
StopListeningToGameEvent(	onplayer_rapidfire_closed_casing_event	)
StopListeningToGameEvent(	onplayer_rapidfire_inserted_capsule_in_chamber_event	)
StopListeningToGameEvent(	onplayer_rapidfire_inserted_capsule_in_magazine_event	)
StopListeningToGameEvent(	onplayer_rapidfire_upgrade_selector_can_use_event	)
StopListeningToGameEvent(	onplayer_rapidfire_upgrade_selector_used_event	)
StopListeningToGameEvent(	onplayer_rapidfire_upgrade_can_charge_event	)
StopListeningToGameEvent(	onplayer_rapidfire_upgrade_can_not_charge_event	)
StopListeningToGameEvent(	onplayer_rapidfire_upgrade_fully_charged_event	)
StopListeningToGameEvent(	onplayer_rapidfire_upgrade_not_fully_charged_event	)
StopListeningToGameEvent(	onplayer_rapidfire_upgrade_fired_event	)
StopListeningToGameEvent(	onplayer_rapidfire_energy_ball_can_charge_event	)
StopListeningToGameEvent(	onplayer_rapidfire_energy_ball_fully_charged_event	)
StopListeningToGameEvent(	onplayer_rapidfire_energy_ball_not_fully_charged_event	)
StopListeningToGameEvent(	onplayer_rapidfire_energy_ball_can_pick_up_event	)
StopListeningToGameEvent(	onplayer_rapidfire_energy_ball_picked_up_event	)
StopListeningToGameEvent(	onplayer_rapidfire_stun_grenade_ready_event	)
StopListeningToGameEvent(	onplayer_rapidfire_stun_grenade_not_ready_event	)
StopListeningToGameEvent(	onplayer_rapidfire_stun_grenade_picked_up_event	)
StopListeningToGameEvent(	onplayer_rapidfire_explode_button_ready_event	)
StopListeningToGameEvent(	onplayer_rapidfire_explode_button_not_ready_event	)
StopListeningToGameEvent(	onplayer_rapidfire_explode_button_pressed_event	)
StopListeningToGameEvent(	onplayer_started_2h_levitate_event	)
StopListeningToGameEvent(	onplayer_stored_item_in_itemholder_event	)
StopListeningToGameEvent(	onplayer_removed_item_from_itemholder_event	)
StopListeningToGameEvent(	onplayer_attached_flashlight_event	)
StopListeningToGameEvent(	onhealth_pen_teach_storage_event	)
StopListeningToGameEvent(	onhealth_vial_teach_storage_event	)
StopListeningToGameEvent(	onplayer_pickedup_storable_clip_event	)
StopListeningToGameEvent(	onplayer_pickedup_insertable_clip_event	)
StopListeningToGameEvent(	onplayer_covered_mouth_event	)
StopListeningToGameEvent(	onplayer_upgraded_weapon_event	)
StopListeningToGameEvent(	ontripmine_hack_started_event	)
StopListeningToGameEvent(	ontripmine_hacked_event	)
StopListeningToGameEvent(	onprimary_hand_changed_event	)
StopListeningToGameEvent(	onsingle_controller_mode_changed_event	)
StopListeningToGameEvent(	onmovement_hand_changed_event	)
StopListeningToGameEvent(	oncombine_tank_moved_by_player_event	)
StopListeningToGameEvent(	onplayer_continuous_jump_finish_event	)
StopListeningToGameEvent(	onplayer_continuous_mantle_finish_event	)
StopListeningToGameEvent(	onplayer_grabbed_ladder_event	)

StopListeningToGameEvent(	ontwo_hand_pistol_grab_start_event	)
StopListeningToGameEvent(	ontwo_hand_pistol_grab_end_event	)
StopListeningToGameEvent(	ontwo_hand_rapidfire_grab_start_event	)
StopListeningToGameEvent(	ontwo_hand_rapidfire_grab_end_event	)
StopListeningToGameEvent(	ontwo_hand_shotgun_grab_start_event	)
StopListeningToGameEvent(	ontwo_hand_shotgun_grab_end_event	)





  end

  if ongamenewmap_event ~= nil then
    StopListeningToGameEvent(ongamenewmap_event)    
  end

  if ongamenewmap_event == nil then
    ongamenewmap_event = ListenToGameEvent("game_newmap", OnGameNewMap, nil)
  end

  if onplayershootweapon_event == nil then
    onplayershootweapon_event = ListenToGameEvent("player_shoot_weapon", OnPlayerShootWeapon, nil)
  end

  if onplayerhurt_event == nil then
    onplayerhurt_event = ListenToGameEvent("player_hurt", OnPlayerHurt, nil)
  end


  if onplayergrabbityglovepull_event == nil then
    onplayergrabbityglovepull_event = ListenToGameEvent("grabbity_glove_pull", OnGrabbityGlovePull, nil)
  end

  if onplayergrabbityglovelockstart_event == nil then
    onplayergrabbityglovelockstart_event = ListenToGameEvent("grabbity_glove_locked_on_start", OnGrabbityGloveLockStart, nil)
  end

  if onplayergrabbityglovelockstop_event == nil then
    onplayergrabbityglovelockstop_event = ListenToGameEvent("grabbity_glove_locked_on_stop", OnGrabbityGloveLockStop, nil)
  end

  if onplayergrabbedbybarnacle_event == nil then
    onplayergrabbedbybarnacle_event = ListenToGameEvent("player_grabbed_by_barnacle", OnGrabbedByBarnacle, nil)
  end

  if onplayerreleasedbybarnacle_event == nil then
    onplayerreleasedbybarnacle_event = ListenToGameEvent("player_released_by_barnacle", OnReleasedByBarnacle, nil)
  end

  if onplayerhealthpenused_event == nil then
    onplayerhealthpenused_event = ListenToGameEvent("player_health_pen_used", OnPlayerHealthPenUsed, nil)
  end

  if onweaponswitch_event == nil then
    onweaponswitch_event = ListenToGameEvent("weapon_switch", OnWeaponSwitch, nil)
  end

  if onentity_killed_event == nil then
    onentity_killed_event = ListenToGameEvent("entity_killed", OnEntityKilled, nil)
  end

if onplayer_teleport_start_event == nil then onplayer_teleport_start_event=ListenToGameEvent("player_teleport_start",OnPlayerTeleportStart, nil) end
if onplayer_teleport_finish_event == nil then onplayer_teleport_finish_event=ListenToGameEvent("player_teleport_finish",OnPlayerTeleportFinish, nil) end

if onitem_pickup_event == nil then onitem_pickup_event=ListenToGameEvent("item_pickup",OnItemPickup, nil) end
if onitem_released_event == nil then onitem_released_event=ListenToGameEvent("item_released",OnItemReleased, nil) end
if onweapon_switch_event == nil then onweapon_switch_event=ListenToGameEvent("weapon_switch",OnWeaponSwitch, nil) end
if ongrabbity_glove_pull_event == nil then ongrabbity_glove_pull_event=ListenToGameEvent("grabbity_glove_pull",OnGrabbityGlovePull, nil) end
if ongrabbity_glove_catch_event == nil then ongrabbity_glove_catch_event=ListenToGameEvent("grabbity_glove_catch",OnGrabbityGloveCatch, nil) end
if ongrabbity_glove_locked_on_start_event == nil then ongrabbity_glove_locked_on_start_event=ListenToGameEvent("grabbity_glove_locked_on_start",OnGrabbityGloveLockedOnStart, nil) end
if ongrabbity_glove_locked_on_stop_event == nil then ongrabbity_glove_locked_on_stop_event=ListenToGameEvent("grabbity_glove_locked_on_stop",OnGrabbityGloveLockedOnStop, nil) end
--if onplayer_gestured_event == nil then onplayer_gestured_event=ListenToGameEvent("player_gestured",OnPlayerGestured, nil) end
if onplayer_picked_up_weapon_off_hand_event == nil then onplayer_picked_up_weapon_off_hand_event=ListenToGameEvent("player_picked_up_weapon_off_hand",OnPlayerPickedUpWeaponOffHand, nil) end
if onplayer_picked_up_weapon_off_hand_crafting_event == nil then onplayer_picked_up_weapon_off_hand_crafting_event=ListenToGameEvent("player_picked_up_weapon_off_hand_crafting",OnPlayerPickedUpWeaponOffHandCrafting, nil) end
--if onplayer_eject_clip_event == nil then onplayer_eject_clip_event=ListenToGameEvent("player_eject_clip",OnPlayerEjectClip, nil) end
--if onplayer_armed_grenade_event == nil then onplayer_armed_grenade_event=ListenToGameEvent("player_armed_grenade",OnPlayerArmedGrenade, nil) end
--if onplayer_health_pen_prepare_event == nil then onplayer_health_pen_prepare_event=ListenToGameEvent("player_health_pen_prepare",OnPlayerHealthPenPrepare, nil) end
--if onplayer_health_pen_retract_event == nil then onplayer_health_pen_retract_event=ListenToGameEvent("player_health_pen_retract",OnPlayerHealthPenRetract, nil) end
if onplayer_health_pen_used_event == nil then onplayer_health_pen_used_event=ListenToGameEvent("player_health_pen_used",OnPlayerHealthPenUsed, nil) end
if onplayer_pistol_clip_inserted_event == nil then onplayer_pistol_clip_inserted_event=ListenToGameEvent("player_pistol_clip_inserted",OnPlayerPistolClipInserted, nil) end
--if onplayer_pistol_empty_chamber_event == nil then onplayer_pistol_empty_chamber_event=ListenToGameEvent("player_pistol_empty_chamber",OnPlayerPistolEmptyChamber, nil) end
if onplayer_pistol_chambered_round_event == nil then onplayer_pistol_chambered_round_event=ListenToGameEvent("player_pistol_chambered_round",OnPlayerPistolChamberedRound, nil) end
--if onplayer_pistol_slide_lock_event == nil then onplayer_pistol_slide_lock_event=ListenToGameEvent("player_pistol_slide_lock",OnPlayerPistolSlideLock, nil) end
--if onplayer_pistol_bought_lasersight_event == nil then onplayer_pistol_bought_lasersight_event=ListenToGameEvent("player_pistol_bought_lasersight",OnPlayerPistolBoughtLasersight, nil) end
--if onplayer_pistol_toggle_lasersight_event == nil then onplayer_pistol_toggle_lasersight_event=ListenToGameEvent("player_pistol_toggle_lasersight",OnPlayerPistolToggleLasersight, nil) end
--if onplayer_pistol_bought_burstfire_event == nil then onplayer_pistol_bought_burstfire_event=ListenToGameEvent("player_pistol_bought_burstfire",OnPlayerPistolBoughtBurstfire, nil) end
--if onplayer_pistol_toggle_burstfire_event == nil then onplayer_pistol_toggle_burstfire_event=ListenToGameEvent("player_pistol_toggle_burstfire",OnPlayerPistolToggleBurstfire, nil) end
--if onplayer_pistol_pickedup_charged_clip_event == nil then onplayer_pistol_pickedup_charged_clip_event=ListenToGameEvent("player_pistol_pickedup_charged_clip",OnPlayerPistolPickedupChargedClip, nil) end
--if onplayer_pistol_armed_charged_clip_event == nil then onplayer_pistol_armed_charged_clip_event=ListenToGameEvent("player_pistol_armed_charged_clip",OnPlayerPistolArmedChargedClip, nil) end
--if onplayer_pistol_clip_charge_ended_event == nil then onplayer_pistol_clip_charge_ended_event=ListenToGameEvent("player_pistol_clip_charge_ended",OnPlayerPistolClipChargeEnded, nil) end
if onplayer_retrieved_backpack_clip_event == nil then onplayer_retrieved_backpack_clip_event=ListenToGameEvent("player_retrieved_backpack_clip",OnPlayerRetrievedBackpackClip, nil) end
if onplayer_drop_ammo_in_backpack_event == nil then onplayer_drop_ammo_in_backpack_event=ListenToGameEvent("player_drop_ammo_in_backpack",OnPlayerDropAmmoInBackpack, nil) end
if onplayer_drop_resin_in_backpack_event == nil then onplayer_drop_resin_in_backpack_event=ListenToGameEvent("player_drop_resin_in_backpack",OnPlayerDropResinInBackpack, nil) end
if onplayer_using_healthstation_event == nil then onplayer_using_healthstation_event=ListenToGameEvent("player_using_healthstation",OnPlayerUsingHealthstation, nil) end
--if onhealth_station_open_event == nil then onhealth_station_open_event=ListenToGameEvent("health_station_open",OnHealthStationOpen, nil) end
if onplayer_shotgun_shell_loaded_event == nil then onplayer_shotgun_shell_loaded_event=ListenToGameEvent("player_shotgun_shell_loaded",OnPlayerShotgunShellLoaded, nil) end
--if onplayer_shotgun_state_changed_event == nil then onplayer_shotgun_state_changed_event=ListenToGameEvent("player_shotgun_state_changed",OnPlayerShotgunStateChanged, nil) end
if onplayer_shotgun_upgrade_grenade_launcher_state_event == nil then onplayer_shotgun_upgrade_grenade_launcher_state_event=ListenToGameEvent("player_shotgun_upgrade_grenade_launcher_state",OnPlayerShotgunUpgradeGrenadeLauncherState, nil) end
if onplayer_shotgun_autoloader_state_event == nil then onplayer_shotgun_autoloader_state_event=ListenToGameEvent("player_shotgun_autoloader_state",OnPlayerShotgunAutoloaderState, nil) end
if onplayer_shotgun_autoloader_shells_added_event == nil then onplayer_shotgun_autoloader_shells_added_event=ListenToGameEvent("player_shotgun_autoloader_shells_added",OnPlayerShotgunAutoloaderShellsAdded, nil) end
if onplayer_shotgun_upgrade_quickfire_event == nil then onplayer_shotgun_upgrade_quickfire_event=ListenToGameEvent("player_shotgun_upgrade_quickfire",OnPlayerShotgunUpgradeQuickfire, nil) end
--if onplayer_shotgun_is_ready_event == nil then onplayer_shotgun_is_ready_event=ListenToGameEvent("player_shotgun_is_ready",OnPlayerShotgunIsReady, nil) end
--if onplayer_shotgun_open_event == nil then onplayer_shotgun_open_event=ListenToGameEvent("player_shotgun_open",OnPlayerShotgunOpen, nil) end
if onplayer_shotgun_loaded_shells_event == nil then onplayer_shotgun_loaded_shells_event=ListenToGameEvent("player_shotgun_loaded_shells",OnPlayerShotgunLoadedShells, nil) end
--if onplayer_shotgun_upgrade_grenade_long_event == nil then onplayer_shotgun_upgrade_grenade_long_event=ListenToGameEvent("player_shotgun_upgrade_grenade_long",OnPlayerShotgunUpgradeGrenadeLong, nil) end
--if onplayer_rapidfire_capsule_chamber_empty_event == nil then onplayer_rapidfire_capsule_chamber_empty_event=ListenToGameEvent("player_rapidfire_capsule_chamber_empty",OnPlayerRapidfireCapsuleChamberEmpty, nil) end
--if onplayer_rapidfire_cycled_capsule_event == nil then onplayer_rapidfire_cycled_capsule_event=ListenToGameEvent("player_rapidfire_cycled_capsule",OnPlayerRapidfireCycledCapsule, nil) end
--if onplayer_rapidfire_magazine_empty_event == nil then onplayer_rapidfire_magazine_empty_event=ListenToGameEvent("player_rapidfire_magazine_empty",OnPlayerRapidfireMagazineEmpty, nil) end
if onplayer_rapidfire_opened_casing_event == nil then onplayer_rapidfire_opened_casing_event=ListenToGameEvent("player_rapidfire_opened_casing",OnPlayerRapidfireOpenedCasing, nil) end
if onplayer_rapidfire_closed_casing_event == nil then onplayer_rapidfire_closed_casing_event=ListenToGameEvent("player_rapidfire_closed_casing",OnPlayerRapidfireClosedCasing, nil) end
if onplayer_rapidfire_inserted_capsule_in_chamber_event == nil then onplayer_rapidfire_inserted_capsule_in_chamber_event=ListenToGameEvent("player_rapidfire_inserted_capsule_in_chamber",OnPlayerRapidfireInsertedCapsuleInChamber, nil) end
if onplayer_rapidfire_inserted_capsule_in_magazine_event == nil then onplayer_rapidfire_inserted_capsule_in_magazine_event=ListenToGameEvent("player_rapidfire_inserted_capsule_in_magazine",OnPlayerRapidfireInsertedCapsuleInMagazine, nil) end
--if onplayer_rapidfire_upgrade_selector_can_use_event == nil then onplayer_rapidfire_upgrade_selector_can_use_event=ListenToGameEvent("player_rapidfire_upgrade_selector_can_use",OnPlayerRapidfireUpgradeSelectorCanUse, nil) end
--if onplayer_rapidfire_upgrade_selector_used_event == nil then onplayer_rapidfire_upgrade_selector_used_event=ListenToGameEvent("player_rapidfire_upgrade_selector_used",OnPlayerRapidfireUpgradeSelectorUsed, nil) end
--if onplayer_rapidfire_upgrade_can_charge_event == nil then onplayer_rapidfire_upgrade_can_charge_event=ListenToGameEvent("player_rapidfire_upgrade_can_charge",OnPlayerRapidfireUpgradeCanCharge, nil) end
--if onplayer_rapidfire_upgrade_can_not_charge_event == nil then onplayer_rapidfire_upgrade_can_not_charge_event=ListenToGameEvent("player_rapidfire_upgrade_can_not_charge",OnPlayerRapidfireUpgradeCanNotCharge, nil) end
--if onplayer_rapidfire_upgrade_fully_charged_event == nil then onplayer_rapidfire_upgrade_fully_charged_event=ListenToGameEvent("player_rapidfire_upgrade_fully_charged",OnPlayerRapidfireUpgradeFullyCharged, nil) end
--if onplayer_rapidfire_upgrade_not_fully_charged_event == nil then onplayer_rapidfire_upgrade_not_fully_charged_event=ListenToGameEvent("player_rapidfire_upgrade_not_fully_charged",OnPlayerRapidfireUpgradeNotFullyCharged, nil) end
if onplayer_rapidfire_upgrade_fired_event == nil then onplayer_rapidfire_upgrade_fired_event=ListenToGameEvent("player_rapidfire_upgrade_fired",OnPlayerRapidfireUpgradeFired, nil) end
--if onplayer_rapidfire_energy_ball_can_charge_event == nil then onplayer_rapidfire_energy_ball_can_charge_event=ListenToGameEvent("player_rapidfire_energy_ball_can_charge",OnPlayerRapidfireEnergyBallCanCharge, nil) end
--if onplayer_rapidfire_energy_ball_fully_charged_event == nil then onplayer_rapidfire_energy_ball_fully_charged_event=ListenToGameEvent("player_rapidfire_energy_ball_fully_charged",OnPlayerRapidfireEnergyBallFullyCharged, nil) end
--if onplayer_rapidfire_energy_ball_not_fully_charged_event == nil then onplayer_rapidfire_energy_ball_not_fully_charged_event=ListenToGameEvent("player_rapidfire_energy_ball_not_fully_charged",OnPlayerRapidfireEnergyBallNotFullyCharged, nil) end
--if onplayer_rapidfire_energy_ball_can_pick_up_event == nil then onplayer_rapidfire_energy_ball_can_pick_up_event=ListenToGameEvent("player_rapidfire_energy_ball_can_pick_up",OnPlayerRapidfireEnergyBallCanPickUp, nil) end
--if onplayer_rapidfire_energy_ball_picked_up_event == nil then onplayer_rapidfire_energy_ball_picked_up_event=ListenToGameEvent("player_rapidfire_energy_ball_picked_up",OnPlayerRapidfireEnergyBallPickedUp, nil) end
--if onplayer_rapidfire_stun_grenade_ready_event == nil then onplayer_rapidfire_stun_grenade_ready_event=ListenToGameEvent("player_rapidfire_stun_grenade_ready",OnPlayerRapidfireStunGrenadeReady, nil) end
--if onplayer_rapidfire_stun_grenade_not_ready_event == nil then onplayer_rapidfire_stun_grenade_not_ready_event=ListenToGameEvent("player_rapidfire_stun_grenade_not_ready",OnPlayerRapidfireStunGrenadeNotReady, nil) end
--if onplayer_rapidfire_stun_grenade_picked_up_event == nil then onplayer_rapidfire_stun_grenade_picked_up_event=ListenToGameEvent("player_rapidfire_stun_grenade_picked_up",OnPlayerRapidfireStunGrenadePickedUp, nil) end
--if onplayer_rapidfire_explode_button_ready_event == nil then onplayer_rapidfire_explode_button_ready_event=ListenToGameEvent("player_rapidfire_explode_button_ready",OnPlayerRapidfireExplodeButtonReady, nil) end
--if onplayer_rapidfire_explode_button_not_ready_event == nil then onplayer_rapidfire_explode_button_not_ready_event=ListenToGameEvent("player_rapidfire_explode_button_not_ready",OnPlayerRapidfireExplodeButtonNotReady, nil) end
if onplayer_rapidfire_explode_button_pressed_event == nil then onplayer_rapidfire_explode_button_pressed_event=ListenToGameEvent("player_rapidfire_explode_button_pressed",OnPlayerRapidfireExplodeButtonPressed, nil) end
if onplayer_started_2h_levitate_event == nil then onplayer_started_2h_levitate_event=ListenToGameEvent("player_started_2h_levitate",OnPlayerStarted2hLevitate, nil) end
if onplayer_stored_item_in_itemholder_event == nil then onplayer_stored_item_in_itemholder_event=ListenToGameEvent("player_stored_item_in_itemholder",OnPlayerStoredItemInItemholder, nil) end
if onplayer_removed_item_from_itemholder_event == nil then onplayer_removed_item_from_itemholder_event=ListenToGameEvent("player_removed_item_from_itemholder",OnPlayerRemovedItemFromItemholder, nil) end
--if onplayer_attached_flashlight_event == nil then onplayer_attached_flashlight_event=ListenToGameEvent("player_attached_flashlight",OnPlayerAttachedFlashlight, nil) end
if onhealth_pen_teach_storage_event == nil then onhealth_pen_teach_storage_event=ListenToGameEvent("health_pen_teach_storage",OnHealthPenTeachStorage, nil) end
if onhealth_vial_teach_storage_event == nil then onhealth_vial_teach_storage_event=ListenToGameEvent("health_vial_teach_storage",OnHealthVialTeachStorage, nil) end
--if onplayer_pickedup_storable_clip_event == nil then onplayer_pickedup_storable_clip_event=ListenToGameEvent("player_pickedup_storable_clip",OnPlayerPickedupStorableClip, nil) end
--if onplayer_pickedup_insertable_clip_event == nil then onplayer_pickedup_insertable_clip_event=ListenToGameEvent("player_pickedup_insertable_clip",OnPlayerPickedupInsertableClip, nil) end
if onplayer_covered_mouth_event == nil then onplayer_covered_mouth_event=ListenToGameEvent("player_covered_mouth",OnPlayerCoveredMouth, nil) end
--if onplayer_upgraded_weapon_event == nil then onplayer_upgraded_weapon_event=ListenToGameEvent("player_upgraded_weapon",OnPlayerUpgradedWeapon, nil) end
if ontripmine_hack_started_event == nil then ontripmine_hack_started_event=ListenToGameEvent("tripmine_hack_started",OnTripmineHackStarted, nil) end
if ontripmine_hacked_event == nil then ontripmine_hacked_event=ListenToGameEvent("tripmine_hacked",OnTripmineHacked, nil) end
if onprimary_hand_changed_event == nil then onprimary_hand_changed_event=ListenToGameEvent("primary_hand_changed",OnPrimaryHandChanged, nil) end
if onsingle_controller_mode_changed_event == nil then onsingle_controller_mode_changed_event=ListenToGameEvent("single_controller_mode_changed",OnSingleControllerModeChanged, nil) end
if onmovement_hand_changed_event == nil then onmovement_hand_changed_event=ListenToGameEvent("movement_hand_changed",OnMovementHandChanged, nil) end
if oncombine_tank_moved_by_player_event == nil then oncombine_tank_moved_by_player_event=ListenToGameEvent("combine_tank_moved_by_player",OnCombineTankMovedByPlayer, nil) end
if onplayer_continuous_jump_finish_event == nil then onplayer_continuous_jump_finish_event=ListenToGameEvent("player_continuous_jump_finish",OnPlayerContinuousJumpFinish, nil) end
if onplayer_continuous_mantle_finish_event == nil then onplayer_continuous_mantle_finish_event=ListenToGameEvent("player_continuous_mantle_finish",OnPlayerContinuousMantleFinish, nil) end
if onplayer_grabbed_ladder_event == nil then onplayer_grabbed_ladder_event=ListenToGameEvent("player_grabbed_ladder",OnPlayerGrabbedLadder, nil) end

if ontwo_hand_pistol_grab_start_event == nil then ontwo_hand_pistol_grab_start_event=ListenToGameEvent("two_hand_pistol_grab_start",OnTwoHandStart, nil) end
if ontwo_hand_pistol_grab_end_event == nil then ontwo_hand_pistol_grab_end_event=ListenToGameEvent("two_hand_pistol_grab_end",OnTwoHandEnd, nil) end
if ontwo_hand_rapidfire_grab_start_event == nil then ontwo_hand_rapidfire_grab_start_event=ListenToGameEvent("two_hand_rapidfire_grab_start",OnTwoHandStart, nil) end
if ontwo_hand_rapidfire_grab_end_event == nil then ontwo_hand_rapidfire_grab_end_event=ListenToGameEvent("two_hand_rapidfire_grab_end",OnTwoHandEnd, nil) end
if ontwo_hand_shotgun_grab_start_event == nil then ontwo_hand_shotgun_grab_start_event=ListenToGameEvent("two_hand_shotgun_grab_start",OnTwoHandStart, nil) end
if ontwo_hand_shotgun_grab_end_event == nil then ontwo_hand_shotgun_grab_end_event=ListenToGameEvent("two_hand_shotgun_grab_end",OnTwoHandEnd, nil) end


  lastWeapon = "unknown"

  Msg("Listeners registered. " .. _VERSION .. " \n")

else

  if onplayer_opened_game_menu_event ~= nil then
    StopListeningToGameEvent(	onplayer_opened_game_menu_event	)
    StopListeningToGameEvent(	onplayer_closed_game_menu_event	)
  end

  if onplayer_opened_game_menu_event == nil then onplayer_opened_game_menu_event=ListenToGameEvent("player_opened_game_menu",OnPlayerOpenedGameMenu, nil) end
  if onplayer_closed_game_menu_event == nil then onplayer_closed_game_menu_event=ListenToGameEvent("player_closed_game_menu",OnPlayerClosedGameMenu, nil) end

end
