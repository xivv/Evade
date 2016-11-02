

-- They are all linear
local objectList = {
["Morgana"] = {spellName = "DarkBindingMissile", spellDelay = 250, projectileSpeed = 1200, range = 1300, radius = 80, type = "linear"},
["Karma"] = {spellName = "KarmaQ", spellDelay = 250, projectileSpeed = 1700, range = 1050, radius = 90, type = linear},
["Blitzcrank"] = {spellName = "RocketGrab", spellDelay = 250, projectileSpeed = 1800, range = 1050, radius = 70, type = "linear"},
["Ezrael"]{name = "MysticShot",spellDelay = 250, projectileSpeed = 2000, range = 1200,  radius = 80, type = "linear"}
};	

local dodgeList = {};


function OnTick()

-- If our dodgeList is not empty
if( getArrayLength(dodgeList) >= 1) then

-- We iterate trough our dodgelist
for i, spell in pairs(dodgeList) do 

-- We only want to handle linear for now
if(spell.spellinformation.type = "linear") then

-- We create all the information that we need
local isLinearSkillshotCollidingObject = isLinearSkillshotColliding(spell)
local shortestWayObject = shortestWay(isLinearSkillshotCollidingObject)
local canEvade = canEvadeInTime(shortestWayObject)
local evadePoint

-- If canEvade is true we start the evading process by moving our hero to the destinated point
-- else we do nothing and let our hero get hit, but we logg it to the console 
   if(canEvade) then
   
     evadePoint = getEvadePoint(shortestWayObject,1.1)

	 myHero:MoveTo(evadePoint)
	 
     PrintChat("Can evade in time " .. spell.spellinformation.name)

     else

     PrintChat("Can't evade in time " .. spell.spellinformation.name)

     end
end
end
end
end

function OnProcessSpell(unit,spell)

-- We prevent to evade our teams skillshots
if myHero.team == unit.team then return end

-- We iterate trough our objectlist to see if we have information about that spell

for i, spellelement in pairs(objectList) do 

  if(spell.name == spellelement.spellName) then
  
  -- We add the casted spell to our Que and save all the data we need
  dodgeList[getArrayLength(dodgeList) + 1] = {owner = unit,spell = spell, spellinformation = spellelement}
  
  end
  

end

end

function isLinearSkillshotColliding(spell)

-- This method only works if our heroes hitbox is smaller than the radius of the spell
if (getHitBoxRadius(myHero)*2 <= spell.spellinformation.radius) then return end

-- We get the Hitbox from our formular with the endPos, startPos, width and height
local hitboxPoints = getPointsFromRect(spell.spell.endPos.x,
                                       spell.spell.endPos.z,
									   spell.spell.startPos.x,
									   spell.spell.startPos.z,
									   spell.spellinformation.radius *2,
									   spell.spellinformation.range + spell.spellinformation.radius)
						
-- We define the order of the points
						
local leftBottom = hitboxPoints[3]
local rightBottom = hitboxPoints[4]
local leftTop = hitboxPoints[1]
local rightTop = hitboxPoints[2]

-- We create the edgeVectors we want to make further calculations	 
local leftEdgeVector = Vector(leftTop[1]-leftBottom[1],
                              spell.spell.endPos.y - spell.spell.startPos.y,
							  leftTop[2]-leftBottom[2])

local middleVector = spell.spell.endPos - spell.spell.startPos

local rightEdgeVector = Vector(rightTop[1]-rightBottom[1],
                              spell.spell.endPos.y - spell.spell.startPos.y,
							  rightTop[2-rightBottom[2)
							  
local collisionPoint

-- We check if the heroes hitbox collides with one of the lines
-- Then we return {isColliding,collidingDirection,collidingWhere,vector,spellinformation}

if ((collisionPoint = checkLineCollisionPoint(leftBottom[1],
                                              leftBottom[2],
											  leftTop[1],
											  leftTop[2],
											  myHero.x,myHero.y,getHitBoxRadius(myHero))) ~= nil) then 

											  return {true,"left",collisionPoint,leftEdgeVector,middleVector,rightEdgeVector,hitboxPoints,spell}

end

if ((collisionPoint = checkLineCollisionPoint(rightBottom[1],
                                              rightBottom[2],
											  rightTop[1],
											  rightTop[2],
											  myHero.x,myHero.y,getHitBoxRadius(myHero))) ~= nil) then 
											  
											  return {true,"right",collisionPoint,leftEdgeVector,middleVector,rightEdgeVector,hitboxPoints,spell}

end

if ((collisionPoint = checkLineCollisionPoint(spell.spell.startPos.x,
                                              spell.spell.startPos.z,
											  spell.spell.endPos.x,
											  spell.spell.endPos.z,
											  myHero.x,myHero.y,getHitBoxRadius(myHero))) ~= nil) then 

											  return {true,"middle",collisionPoint,leftEdgeVector,middleVector,rightEdgeVector,hitboxPoints,spell}

end

return {false,"nil",nil,nil,spell}

end

-- We calculate which way is faster
function shortestWay(lineSkillShotCollidingObject)

local hitboxPoints = lineSkillShotCollidingObject[7]

local leftBottom = hitboxPoints[3]
local rightBottom = hitboxPoints[4]
local leftTop = hitboxPoints[1]
local rightTop = hitboxPoints[2]

local leftDistance = pointLineDistancePerformance(leftBottom[1],
                                 leftBottom[2],
								 leftTop[1],
								 leftTop[2],
								 myHero.x,myHero.z)
								 
local rightDistance = pointLineDistancePerformance(rightBottom[1],
                                 rightBottom[2],
								 rightTop[1],
								 rightTop[2],
								 myHero.x,myHero.z)

if ( leftDistance <= rightDistance) then

return {"left",leftDistance,lineSkillShotCollidingObject}

else

return {"right",rightDistance,lineSkillShotCollidingObject}
end

end

-- We now are getting the Point we want to move our hero to and add a percentage so we move a bit further
-- example extra = 1.1 
function getEvadePoint(shortestWayObject,extra)

local distanceToMove = getHitBoxRadius(myHero) - shortestWayObject[2]
local lineSkillShotCollidingObject = shortestWayObject[3]
local collisionPoint = lineSkillShotCollidingObject[3]

local directionVector = Vector(myHero.x - collisionPoint[1],myHero.y,myHero.z - collisionPoint[2])

local lenghtendVector = directionVector:normalized() * ( distanceToMove * extra )

return myHero.pos + lenghtendVector

end

function canEvadeInTime(shortestWayObject)

local distanceToMove = getHitBoxRadius(myHero) - shortestWayObject[2]
local lineSkillShotCollidingObject = shortestWayObject[3]
local collisionPoint = lineSkillShotCollidingObject[3]
local hitboxPoints = lineSkillShotCollidingObject[7]
local spellinformation = lineSkillShotCollidingObject[8].spellinformation
local spellPoint
local distanceFromSkillShot

local edge = shortestWayObject[1]

if (edge == "left" then)
spellPoint = hitboxPoints[3]
else
spellPoint = hitboxPoints[4]
end

-- Distance between two points
distanceFromSkillShot = sqrt((collisionPoint[1] - spellPoint[1])^2 + (collisionPoint[2] - spellPoint[2])^2)

return distanceFromSkillShot / spellinformation.projectileSpeed >= distanceToMove / myHero.ms

end


function getHitBoxRadius(target)
    return GetDistance(target.minBBox, target.maxBBox)/2
end

-- sqrt and ^2 can be heavy calculations wasting time when we only need to compare
function pointLineDistancePerformance(startx,starty,endx,endy,pointx,pointy)

local cn = { pointx - startx, pointy - starty}
local bn = { endx - startx, endx - starty}

local angle = math.atan2(bn[2],bn[1]) - math.atan2(cn[2],cn[1])
local abLength = math.sqrt(bn[1] * bn[1] + bn[2] * bn[2])

return math.sin(angle)*abLength
end

function pointLineDistance(startx,starty,endx,endy,pointx,pointy)

local cn = { pointx - startx, pointy - starty}
local bn = { endx - startx, endx - starty}

local angle = math.atan2(bn[2],bn[1]) - math.atan2(cn[2],cn[1])
local abLength = math.sqrt(bn[1] * bn[1] + bn[2] * bn[2])

return math.sqrt((math.sin(angle)*abLength)^2)
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

-- x1 top . x2 bot . l1 length bottom/ top
function getPointsFromRect(x1,y1,x2,y2,l1,l2)
distanceV = {x2 - x1, y2 - y1}
vlen = math.sqrt(distanceV[1]^2 + distanceV[2]^2)
normalized = {distanceV[1] / vlen, distanceV[2] / vlen}
rotated = {-normalized[2], normalized[1]}
p1 = {x1 - rotated[1] * l1 / 2, y1 - rotated[2] * l1 / 2}
p2 = {p1[1] + rotated[1] * l1, p1[2] + rotated[2] * l1}
p3 = {p1[1] + normalized[1] * l2, p1[2] + normalized[2] * l2}
p4 = {p3[1] + rotated[1] * l1, p3[2] + rotated[2] * l1}
points = { p1 , p2 , p3 , p4}
return points
end


function getArrayLength(array)

local counter = 0

  for i, spellelement in pairs(objectList) do 

  couner = counter +1

  end

return counter

end
