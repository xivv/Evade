
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
	
	PrintChat("<font color=\"#64FE2E\" >Starting calculating for spell: </font>" .. dodgeElement.spellinformation.spellName)
	
	local evasionElement = isLinearIntersect(dodgeElement)
	
	if  evasionElement ~= nil then 
	PrintChat("<font color=\"#B40404\" >Starting calculating for [LINEAR] spell: </font>" .. dodgeElement.spellinformation.spellName) 
	getShortestLinearEscape(evasionElement)
	PrintChat("<font color=\"#B40404\" >Finished calculating [SHORTEST ESCAPE] for [LINEAR] spell: </font>" .. dodgeElement.spellinformation.spellName) 
	else

	end
	
	PrintChat("<font color=\"#B40404\" >Finished calculating for spell: </font>" .. dodgeElement.spellinformation.spellName)
	table.remove(dodgeList,i)
	PrintChat("<font color=\"#000000\" >Removed spell [MANUALLY]: </font>" .. dodgeElement.spellinformation.spellName)
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
	  
	  -- Ingore if too far away
	  if(GetDistance(unit) > spellelement.range * 2) then 	  PrintChat("<font color=\"#000000\" >Spell registerd [OUT OF RANGE]: </font>" .. spellelement.spellName)return end
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

------------------------------------------------------------------------- WORKFLOW ---------------------------------------------------------------------------


function isLinearIntersect(dodgeElement)

local rectPoints = getPointsFromRect(dodgeElement.endPos.x,
                                     dodgeElement.endPos.z,
									 dodgeElement.startPos.x,
									 dodgeElement.startPos.z,
									 dodgeElement.spellinformation.radius * 2,
									 dodgeElement.spellinformation.radius + dodgeElement.spellinformation.range)

if(isPointInRect(myHero.x,
                 myHero.z,
				 rectPoints.leftBottom[1],
				 rectPoints.leftBottom[2],
				 dodgeElement.spellinformation.radius * 2,
				 dodgeElement.spellinformation.radius + dodgeElement.spellinformation.range)) then 
				 return {isIntersection = true,rectPoints = rectPoints,endPos = dodgeElement.endPos,startPos = dodgeElement.startPos,spellinformation = dodgeElement.spellinformation} end

if(getLineCircleCollisionPoint(rectPoints.leftBottom[1],
                               rectPoints.leftBottom[2],
							   rectPoints.leftTop[1],
							   rectPoints.leftTop[2],
							   myHero.x, myHero.z, getHitBoxRadius(myHero))) then return {type = "linear",rectPoints = rectPoints,endPos = dodgeElement.endPos,startPos = dodgeElement.startPos,spellinformation = dodgeElement.spellinformation} end

if(getLineCircleCollisionPoint(rectPoints.leftBottom[1],
                               rectPoints.leftBottom[2],
							   rectPoints.rightBottom[1],
							   rectPoints.rightBottom[2],
							   myHero.x, myHero.z, getHitBoxRadius(myHero))) then return {type = "linear",rectPoints = rectPoints,endPos = dodgeElement.endPos,startPos = dodgeElement.startPos,spellinformation = dodgeElement.spellinformation} end

if(getLineCircleCollisionPoint(rectPoints.rightBottom[1],
                               rectPoints.rightBottom[2],
							   rectPoints.rightTop[1],
							   rectPoints.rightTop[2],
							   myHero.x, myHero.z, getHitBoxRadius(myHero))) then return {type = "linear",rectPoints = rectPoints,endPos = dodgeElement.endPos,startPos = dodgeElement.startPos,spellinformation = dodgeElement.spellinformation} end

if(getLineCircleCollisionPoint(rectPoints.leftTop[1],
                               rectPoints.leftTop[2],
							   rectPoints.rightTop[1],
							   rectPoints.rightTop[2],
							   myHero.x, myHero.z, getHitBoxRadius(myHero))) then return {type = "linear",rectPoints = rectPoints,endPos = dodgeElement.endPos,startPos = dodgeElement.startPos,spellinformation = dodgeElement.spellinformation} end
							   
end


function getShortestLinearEscape(intersectElement)

local rectPoints = intersectElement.rectPoints

local leftDistance = pointLineDistance(rectPoints.leftBottom[1],
                                       rectPoints.leftBottom[2],
							           rectPoints.leftTop[1],
							           rectPoints.leftTop[2],
							           myHero.x, myHero.z)

local rightDistance = pointLineDistance(rectPoints.rightBottom[1],
                                        rectPoints.rightBottom[2],
                                        rectPoints.rightTop[1],
                                        rectPoints.rightTop[2],
                                        myHero.x, myHero.z)		
										
local topDistance = pointLineDistance(rectPoints.leftTop[1],
                                      rectPoints.leftTop[2],
							          rectPoints.rightTop[1],
							          rectPoints.rightTop[2],
							          myHero.x, myHero.z)

local bottomDistance = pointLineDistance(rectPoints.leftBottom[1],
                                      rectPoints.leftBottom[2],
							          rectPoints.rightBottom[1],
							          rectPoints.rightBottom[2],
							          myHero.x, myHero.z)

local smallestDistance = math.min(leftDistance,rightDistance,topDistance,bottomDistance)

if(smallestDistance == leftDistance) then return {direction = "left",distance = "smallestDistance"}
elseif (smallestDistance == rightDistance) then return {direction = "right",distance = "smallestDistance"}
elseif (smallestDistance == topDistance) then return {direction = "top",distance = "smallestDistance"}
elseif (smallestDistance == bottomDistance) then return {direction = "bottom",distance = "smallestDistance"}
end
end




------------------------------------------------------------------------- HELPER ---------------------------------------------------------------------------

function getLineCircleCollisionPoint(x1,y1,x2,y2, circlex, circley, circler)
		for n=0,1,0.001 do
			local x = x1 + ((x2 - x1) * n)
			local y = y1 + ((y2 - y1) * n)
			local dist = math.sqrt((x - circlex)^2 + (y - circley)^2)
			local point = {x, y}
			if(dist <= circler) then return point end
		end
end

function pointLineDistance(startx,starty,endx,endy,pointx,pointy)

	local cn = { pointx - startx, pointy - starty}
	local bn = { endx - startx, endy - starty}

	local angle = math.atan2(bn[2],bn[1]) - math.atan2(cn[2],cn[1])
	local abLength = math.sqrt(bn[1] * bn[1] + bn[2] * bn[2])

	return math.sqrt((math.sin(angle)*abLength)^2)
end

function getPointsFromRect(x1,y1,x2,y2,l1,l2)
	distanceV = {x2 - x1, y2 - y1}
	vlen = math.sqrt(distanceV[1]^2 + distanceV[2]^2)
	normalized = {distanceV[1] / vlen, distanceV[2] / vlen}
	rotated = {-normalized[2], normalized[1]}
	p1 = {x1 - rotated[1] * l1 / 2, y1 - rotated[2] * l1 / 2}
	p2 = {p1[1] + rotated[1] * l1, p1[2] + rotated[2] * l1}
	p3 = {p1[1] + normalized[1] * l2, p1[2] + normalized[2] * l2}
	p4 = {p3[1] + rotated[1] * l1, p3[2] + rotated[2] * l1}
	return { leftTop = p1 , rightTop = p2 , leftBottom = p3 , rightBottom = p4}
end

function isPointInRect(x1,y1,rectx,recty,rectwidth,rectheight)

return x1 > rectx and x1 < rectx + rectwidth and 
       y1 > recty and y1 < recty + rectheight

end

function getHitBoxRadius(target)
		return GetDistance(target.minBBox, target.maxBBox)/2
end
