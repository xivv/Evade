
local objectList = {

["Lux"] = {charName = "Lux", skillshots = {
["Light Binding"] =  {name = "LightBinding", spellName = "LuxLightBinding", spellDelay = 250, projectileName = "LuxLightBinding_mis.troy", projectileSpeed = 1200, range = 1300, radius = 80, type = "line"},
["Lux Malice Cannon"] =  {name = "LuxMaliceCannon", spellName = "LuxMaliceCannon", spellDelay = 1375, projectileName = "LuxMaliceCannon_cas.troy", projectileSpeed = 50000, range = 3500, radius = 190, type = "line"},
}},
["Blitzcrank"] = {charName = "Blitzcrank", skillshots = {
["Rocket Grab"] = {name = "RocketGrab", spellName = "RocketGrabMissile", spellDelay = 250, projectileName = "FistGrab_mis.troy", projectileSpeed = 1800, range = 1050, radius = 70, type = "line"},
}},
["Mundo"] = {charName = "DrMundo", skillshots = {
["Infected Cleaver"] = {name = "InfectedCleaver", spellName = "InfectedCleaverMissile", spellDelay = 250, projectileName = "dr_mundo_infected_cleaver_mis.troy", projectileSpeed = 2000, range = 1050, radius = 75, type = "line"},
}},
["Morgana"] = {charName = "Morgana", skillshots = {
["Dark Binding Missile"] = {name = "DarkBinding", spellName = "DarkBindingMissile", spellDelay = 250, projectileName = "DarkBinding_mis.troy", projectileSpeed = 1200, range = 1300, radius = 80, type = "line"},
}},
["Ezreal"] = {charName = "Ezreal", skillshots = {
["Mystic Shot"]             = {name = "MysticShot",      spellName = "EzrealMysticShot",      spellDelay = 250, projectileName = "Ezreal_mysticshot_mis.troy",  projectileSpeed = 2000, range = 1200,  radius = 80,  type = "line"},
["Essence Flux"]            = {name = "EssenceFlux",     spellName = "EzrealEssenceFlux",     spellDelay = 250, projectileName = "Ezreal_essenceflux_mis.troy", projectileSpeed = 1500, range = 1050,  radius = 80,  type = "line"},
["Mystic Shot (Pulsefire)"] = {name = "MysticShot",      spellName = "EzrealMysticShotPulse", spellDelay = 250, projectileName = "Ezreal_mysticshot_mis.troy",  projectileSpeed = 2000, range = 1200,  radius = 80,  type = "line"},
["Trueshot Barrage"]        = {name = "TrueshotBarrage", spellName = "EzrealTrueshotBarrage", spellDelay = 1000, projectileName = "Ezreal_TrueShot_mis.troy",    projectileSpeed = 2000, range = 20000, radius = 160, type = "line"},
}}
};	

local dodgeList = {};

function getSpellInformation(spellName)

for i, charElement in pairs(objectList) do 

for i, spellElement in pairs(charElement.skillshots) do 

if(spellElement.spellName == spellName) then return spellElement end

end
end
end

function OnLoad()

PrintChat("<font color=\"#61EE2E\" >LOADED</font>")
AddDrawCallback(function()DrawLine3D(myHero.x, myHero.y, myHero.z, myHero.endPath.x, myHero.endPath.y, myHero.endPath.z, 3, 0xFFFFFFFF);end)
end


function OnDraw()


DrawCircle3D(myHero.x,myHero.y,myHero.z,getHitBoxRadius(myHero),3,ARGB(255,255,255,255))

for i, dodgeElement in pairs(dodgeList) do 

local radius = getSpellInformation(dodgeElement.spellinformation.spellName).radius

DrawLineBorder3D(dodgeElement.startPos.x,
                 dodgeElement.startPos.y, 
				 dodgeElement.startPos.z, 
				 dodgeElement.endPos.x, 
				 dodgeElement.endPos.y, 
				 dodgeElement.endPos.z, 
				 radius * 2,
				 ARGB(255,255,255,255),3)
end
end

function OnTick()

	-- We iterate trough our dodgelist
	for i, dodgeElement in pairs(dodgeList) do 
	
	--PrintChat("<font color=\"#64FE2E\" >Starting calculating for spell: </font>" .. dodgeElement.spellinformation.spellName)
	
	
	
	--PrintChat("<font color=\"#B40404\" >Finished calculating for spell: </font>" .. dodgeElement.spellinformation.spellName)
	--table.remove(dodgeList,i)
	--PrintChat("<font color=\"#000000\" >Removed spell: </font>" .. dodgeElement.spellinformation.spellName)
	end
	
	
end

function OnProcessSpell(unit,spell)

	-- We prevent to evade our teams skillshots
	if myHero.team == unit.team then return end

	-- if unit.charName == "x" then PrintChat(spell.name) end
	-- We iterate trough our objectlist to see if we have information about that spell

	for i, charelement in pairs(objectList) do 

	if(unit.charName == charelement.charName) then
	
	for a, spellelement in pairs(charelement.skillshots) do 
	  if(spell.name == spellelement.spellName) then
	  
	  PrintChat("<font color=\"#FE9A2E\" >Spell registerd: </font>" .. spellelement.spellName)
	  -- We add the casted spell to our Que and save all the data we need
	  table.insert(dodgeList,{endPos = Vector(spell.endPos),startPos = Vector(spell.startPos), spellinformation = spellelement})
	  end
	  

	end
	
	end
end
end


function OnDeleteObj(obj)

for i, dodgeElement in pairs(dodgeList) do 

if(obj.spellName:find(dodgeElement.spellinformation.spellName)) then


table.remove(dodgeList,i)
PrintChat("<font color=\"#000000\" >Removed spell: </font>" .. obj.spellName)


end
end
end

function getHitBoxRadius(target)
		return GetDistance(target.minBBox, target.maxBBox)/2
end
