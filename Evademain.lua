

-- example only
local circularSkillShots = {
["Lux"] = {spellName = "LuxQ", spellDelay = 250, projectileSpeed = 1700, range = 1050, radius = 90, type = "circular"}}

local lineSkillShots = {
["Ezrael"]{name = "MysticShot",spellDelay = 250, projectileSpeed = 2000, range = 1200,  radius = 80, type = "linear"}
}

--------------------- QUE -------------------------

local evadeSkillShotQue = {}

local evadeSkillShotObjectQue = {}

---------------------------------------------------

-- TO DO 

-- FLASH USAGE 

-- EXPAND HITBOX OF RADIUS CAUSEE ENDPOSITION IS ONLY MIDPOINT ( range + radius )

--------------------- OPTIONS ---------------------

-- Adds Percentag to Evade Distance
local evadeDistanceMultiplicator = 1.25
-- Humanizer Percentage per Second
local humanizerMultiplicator = 1
-- Danger Flash if damage would be higher then X percent of life
local dangerDamage = 0.6

---------------------------------------------------


--------------------- TEMP ------------------------

-- For Humanizer
local deltaTime = 0

---------------------------------------------------

function OnDraw()

     for i, skillshot in pairs(evadeSkillShotObjectQue) do
	     if(skillshot ~= nil) then
		     local skillshotElement = getSkillshotFromObjectQue(skillshot)
		         if(skillshotElement.type == "circular") then
	                 DrawCircle3D(skillshot.endPos.x,skillshot.endPos.y,skillshot.endPos.z)
		         else if skillshotElement.type == "linear" then
	                 DrawLineBorder3D(skillshot.startPos.x,skillshot.startPos.y,skillshot.startPos.z,skillshot.endPos.x,skillshot.endPos.y,skillshot.endPos.z,lastSpellRadius * 2,ARGB(255,255,255,255),1)
	             end
	         end
		 end
     end
end



function OnTick()

     if(getArrayLength(evadeSkillShotQue) >= 1) then

	     if deltaTime == 0 then
	         deltaTime = GetTickCount()
		 end
	     
		 -- Vielleicht in sec statt ms
		 if GetTickCount() == deltaTime * ( humanizerMultiplicator * 1000 ) then
		 if evadeSkillShotQue[1].type == "circular" then
             evadeCircularSkillshot(evadeSkillShotQue[1],evadeSkillShotObjectQue[1])
			 deltaTime = 0
	     else if evadeSkillShotQue[1].type == "linear" then
		  evadeLinearSkillshot(evadeSkillShotQue[1],evadeSkillShotObjectQue[1])
		  deltaTime = 0
		     end
			 end
		 end

     end
end



function OnDeleteObject(object)

local counter = 1

for i, skillshot in pairs(circularSkillShots) do

     if skillshot.name:find(object.spellName) then
	
	     evadeSkillShotQue[counter] = nil
		 evadeSkillShotObjectQue[counter] = nil
     

	 end
	 
	 counter = counter + 1
	 
end

end


function OnProcessSpell(unit,spell)

for i, skillshot in pairs(circularSkillShots) do

     if skillshot.name:find(spell.name) and unit ~= myHero then
	
	     local arrayLength = getArrayLength(evadeSkillShotQue)
	
         evadeSkillShotQue[arrayLength] = skillshot
		 evadeSkillShotObjectQue[arrayLength] = spell
	
	 end
end
end

-- evtl zusammenfassen
function evadeLinearSkillShot(skillshot,skillshotObject)

if hasToEvadeLinear(myHero,skillshot,skillshotObject) then

          evadeInformation = getDirectionToEvadeAndDistanceToEvadeAndVectorToEvadeLinear(myHero,skillshot,skillshotObject.startPos,skillshotObject.endPos)

          distance = evadeInformation[2]

          vector = evadeInformation[3]

		  -- Vielleicht nicht doppelt und bevor man stirbt
		  if(canEvadeInTime(myHero,skillshot,skillshotObject,distance)) then
                 moveTo(myHero,distance,vector)
		  else if (canEvadeInTime(myHero,skillshot,skillshotObject,distance) == false and damageHigherThenPercentOption() and isFlashReady())
		         flashTo(myHero,distance,vector,getFlashSlot(myHero))
		  end
		  else
		  PrintChat("Cant evade linear in time.")
		  end

     end


end


function evadeCircularSkillshot(skillshot,skillshotObject)

     if hasToEvadeCircular(myHero,skillshot,skillshotObject) then

          evadeInformation = getDirectionToEvadeAndDistanceToEvadeAndVectorToEvadeCircular(myHero,skillshot,skillshotObject.startPos,skillshotObject.endPos)

          distance = evadeInformation[2]

          vector = evadeInformation[3]

		  -- Vielleicht nicht doppelt und bevor man stirbt
		  if(canEvadeInTime(myHero,skillshot,skillshotObject,distance)) then
                 moveTo(myHero,distance,vector)
		  else if (canEvadeInTime(myHero,skillshot,skillshotObject,distance) == false and damageHigherThenPercentOption() and isFlashReady())
		         flashTo(myHero,distance,vector,getFlashSlot(myHero))
		  end
		  else
		  PrintChat("Cant evade circular in time.")
		  end

     end


end


-- vllt expanded und dafür weniger return in unterer function
function moveTo(unit,distance,vector)

     local extraDistance = distance * evadeDistanceMultiplicator
	 
     unit:MoveTo(vector.x * extraDistance, vector.z * extraDistance)
	 
end

-- vllt expanded und dafür weniger return in unterer function
function flashTo(unit,distance,vector,flashSlot)

     local extraDistance = distance * evadeDistanceMultiplicator
	 
     CastSpell(flashSlot,vector.x * extraDistance, vector.z * extraDistance)
	 
end


-- evtl statt + evade einfach umkehren mit - , nach oben checken
function getDirectionToEvadeAndDistanceToEvadeAndVectorToEvadeLinear(unit,skillshot,skillshotStart,skillShotEnd)

local points = getPointsFromRect(skillShotEnd.x,skillShotEnd.z,skillshotStart.x,skillshotStart.z,l1,l2)
 
local leftBot = points[3]
local leftTop = points[1]
local rightBot = points[4]
local rightTop = points[2]

local leftEvadeVector = Vector(p2[1] - p1[1], endVector.y,p2[2] - p1[2])
local rightEvadeVector = Vector(p1[1] - p2[1], endVector.y,p1[2] - p2[2])

local leftDistance = pointLineDistance(leftBot[1],leftBot[2],leftTop[1],leftTop[2],unit.x,unit.z)
local rightDistance = pointLineDistance(rightBot[1],rightBot[2],rightTop[1],rightTop[2],unit.x,unit.z)

local pointToCheckCollisionOnCircleWith
local decidedDistance = 0

local vectorToEvade

if leftDistance < rightDistance then
pointToCheckCollisionOnCircleWith = {unit.x + rightEvadeVector.x, unit.z + rightEvadeVector.z}
else
pointToCheckCollisionOnCircleWith = { unit.x + leftEvadeVector.x, unit.z + leftEvadeVector.z}
end

pointOnCircle = checklineCollisionPoint(unit.x,unit.z,pointToCheckCollisionOnCircleWith[1],pointToCheckCollisionOnCircleWith[2], unit.x, unit.z, getHitBoxRadius(unit))

if leftDistance <= rightDistance then
decidedDistance =  pointLineDistance(leftBot[1],leftBot[2],leftTop[1],leftTop[2],pointOnCircle[1],pointOnCircle[2])
vectorToEvade = leftEvadeVector
return { "left" , decidedDistance , vectorToEvade:normalized()}
else
decidedDistance = pointLineDistance(rightBot[1],rightBot[2],rightTop[1],rightTop[2],pointOnCircle[1],pointOnCircle[2])
vectorToEvade = rightEvadeVector
return { "right" , decidedDistance , vectorToEvade:normalized()}
end



end



-- evtl nur skillShotRadius oder nur SkillShotObjekt evtl ohne y ( noch kein nutzen )
function getDirectionToEvadeAndDistanceToEvadeAndVectorToEvadeCircular(unit,skillshot,skillshotStart,skillShotEnd)


local l1 = skillshot.radius * 2
local l2 = Vector(skillShotEnd.x - skillshotStart.x,skillShotEnd.y - skillshotStart.y,skillShotEnd.z - skillshotStart.z):len()

local points = getPointsFromRect(skillShotEnd.x,skillShotEnd.z,skillshotStart.x,skillshotStart.z,l1,l2)
 
local leftBot = points[3]
local leftTop = points[1]
local rightBot = points[4]
local rightTop = points[2]

local leftDistance = pointLineDistance(leftBot[1],leftBot[2],leftTop[1],leftTop[2],unit.x,unit.z)
local rightDistance = pointLineDistance(rightBot[1],rightBot[2],rightTop[1],rightTop[2],unit.x,unit.z)
local topDistance = pointLineDistance(leftTop[1],leftTop[2],rightTop[1],rightTop[2],unit.x,unit.z)

local leftVectorToOtherSide = expandVector(normalize2D({ leftBot[1] - leftTop[1], leftBot[2] - leftTop[2]}),l1)
local leftBotPoint = { leftVectorToOtherSide[1] + leftTop[1],leftVectorToOtherSide[2] + leftTop[2]}
local finalBotPoint = { leftBotPoint[1] + rightTop[1] - leftTop[1] , leftBotPoint[2] + rightTop[2] - leftTop[2]}
local botDistance = pointLineDistance(leftBotPoint[1],leftBotPoint[2],finalBotPoint[1],finalBotPoint[2],unit.x,unit.z)

local decidedDistance = math.min(leftDistance,rightDistance,topDistance,botDistance)
local vectorToEvade
local y = unit.y

if decidedDistance == leftDistance then

vectorToEvade = Vector(p2[1] - p1[1],y,p2[2] - p1[2])

return { "left", decidedDistance, vectorToEvade:normalized()}

else if decidedDistance == rightDistance then

vectorToEvade = Vector(p1[1] - p2[1],y,p1[2] - p2[2])

return { "right", decidedDistance, vectorToEvade:normalized()}

end
else if decidedDistance == topDistance then

y = skillshotStart.y - skillShotEnd.y
vectorToEvade = Vector(p3[1] - p1[1],y,p3[2] - p1[2])

return { "top", decidedDistance, vectorToEvade:normalized()}

end
else if decidedDistance == botDistance then

y = skillshotEnd.y - skillShotStart.y

vectorToEvade = Vector(p2[1] - p4[1],y,p2[2] - p4[2])

return { "bot", decidedDistance, vectorToEvade:normalized()}

end

end
end


function canEvadeInTime(unit,skillshot,skillshotObject,distanceToMove)

     local distanceUntilHit = getLengthVector2D(getVector2D(skillshotObject.startPos.x,skillshotObject.startPos.z,skillshotObject.endPos.x,skillshotObject.endPos.z))
     local timeUntilHit = distanceUntilHit / skillshot.projectileSpeed
	 
	 local distanceUnitCanTravelInTime = unit.ms * timeUntilHit
	 
	 if distanceUnitCanTravelInTime > distanceToMove then return true end
	 
end


function hasToEvadeLinear(unit,skillshot,skllshotObject)

local l1 = skillshot.radius * 2
local l2 = Vector(skllshotObject.endPos.x - skllshotObject.startPos.x,skllshotObject.endPos.y - skllshotObject.startPos.y,skllshotObject.endPos.z - skllshotObject.startPos.z):len()

local points = getPointsFromRect(skllshotObject.endPos.x,skllshotObject.endPos.z,skllshotObject.startPos.x,skllshotObject.startPos.z,l1,l2)
 
local leftBot = points[3]
local leftTop = points[1]
local rightBot = points[4]
local rightTop = points[2]


if checkLineCollision(leftTop[1],leftTop[2],leftBot[1],leftBot[2],unit.x,unit.z,getHitBoxRadius(unit)) or 
   checkLineCollision(rightTop[1],rightTop[2],rightBot[1],rightBot[2],unit.x,unit.z,getHitBoxRadius(unit))or 
   checkLineCollision(skllshotObject.startPos.x,skllshotObject.startPos.z,skllshotObject.endPos.x,skllshotObject.endPos.z,unit.x,unit.z,getHitBoxRadius(unit)) then
   
   return true  
 end
end

function hasToEvadeCircular(unit,skillshot,skillshotObject)

     local unitHitBoxSize = getHitBoxRadius(unit)

     local skillShotRadius = skillshot.radius

     if(circleCircleIntersect(unit.x,unit.z,unitHitBoxSize,skillshotObject.endPos.x,skillshotObject.endPos.z,skillShotRadius)) then
         
		 return true
		 
     end


end


-- MUST DO
function damageHigherThenPercentOption(unit,skillshot)

return false

end

-- MUST DO
function isFlashReady(unit)

return true

end

function getFlashSlot(unit)

-- evtl spellname
if(unit:GetSpellData(SUMMONER_1).name:find("flash")) then
return SUMMONER_1
else
return SUMMONER_2
end
end


function circleCircleIntersect(circle1x,circler1y,circle1r,circle2x,circle2y,circler)

     local lengthTreshold = circle1r + circle2r

     local distance = math.sqrt( (circle2x - circle1x)^2  + (circle2y - circle1y)^2)

     if( lengthTreshold > distance) then return true end

end


function getVector2D(p1x,p1y,p2x,p2y)

return { p2x - p1x , p2y - p1y}

end

function getLengthVector2D(vector)

return math.sqrt(vector[1]^2 + vector[2]^2)

end

function expandVector(vector,extraLength)

return {vector[1] * extraLength,vector[2] * extraLength}

end

function normalize2D(vector)

     local vlen = math.sqrt(vector[1]^2 - + vector[2]^2)
     local normalized = {vector[1] / vlen, vector[2] / vlen}
     return normalized
	 
end

-- x1 top . x2 bot . l1 length bottom/ top
function getPointsFromRect(x1,y1,x2,y2,l1,l2)
     local distanceV = {x2 - x1, y2 - y1}
     local vlen = math.sqrt(distanceV[1]^2 + distanceV[2]^2)
     local normalized = {distanceV[1] / vlen, distanceV[2] / vlen}
     local rotated = {-normalized[2], normalized[1]}
     local p1 = {x1 - rotated[1] * l1 / 2, y1 - rotated[2] * l1 / 2}
     local p2 = {p1[1] + rotated[1] * l1, p1[2] + rotated[2] * l1}
     local p3 = {p1[1] + normalized[1] * l2, p1[2] + normalized[2] * l2}
     local p4 = {p3[1] + rotated[1] * l1, p3[2] + rotated[2] * l1}
     local points = { p1 , p2 , p3 , p4}
     return points
end



function pointLineDistance(startx,starty,endx,endy,pointx,pointy)

local l2 =  (endx - startx)^2 + (endy - starty)^2
if l2 == 0 then return math.sqrt( (pointx - startx)^2 + (pointy - starty)^2 ) end
local scalar1 = {(pointx - startx), (pointy - starty)}
local scalar2 =  {(endx - startx), (endy - starty)}

local t = math.max(0,math.min(1,(scalar1[1] * scalar2[1] + scalar1[2] * scalar2[2]) / l2))
local projection = {   startx + t * ( endx - startx)  ,  starty + t * ( endy - starty) }

return math.sqrt( (projection[1] - pointx)^2 + (projection[2] - pointy)^2 )
end

function checklineCollisionPoint(x1,y1,x2,y2, circlex, circley, circler)
    for n=0,1,0.001 do
        local x = x1 + ((x2 - x1) * n)
        local y = y1 + ((y2 - y1) * n)
        local dist = math.sqrt((x - circlex)^2 + (y - circley)^2)
		local point = {x, y}
        if(dist <= circler) then return {x, y} end
    end
end

function checkLineCollision(x1,y1,x2,y2, circlex, circley, circler)
    for n=0,1,0.001 do
        local x = x1 + ((x2 - x1) * n)
        local y = y1 + ((y2 - y1) * n)
        local dist = math.sqrt((x - circlex)^2 + (y - circley)^2)
        if(dist <= circler) then return true end
    end
end


function getSkillshotFromObjectQue(object)

local counter = 1
 for i, skillshot in pairs(evadeSkillShotQue) do

     if(skillshot.name:find(object.name)) then
 
 return evadeSkillShotQue(counter)
 end
 counter = counter + 1
 end
end

function getArrayLength(array)

local counter = 1

for i, element in pairs(array) do

	 counter = counter + 1
	 
end

return counter

end


function getHitBoxRadius(target)
     return GetDistance(target.minBBox, target.maxBBox)/2
endd
