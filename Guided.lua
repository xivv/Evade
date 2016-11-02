

-- They are all linear
local objectList = {
["Morgana"] = {spellName = "DarkBindingMissile", spellDelay = 250, projectileSpeed = 1200, range = 1300, radius = 80, type = linear},
["Karma"] = {spellName = "KarmaQ", spellDelay = 250, projectileSpeed = 1700, range = 1050, radius = 90, type = linear},
["Blitzcrank"] = {spellName = "RocketGrab", spellDelay = 250, projectileSpeed = 1800, range = 1050, radius = 70, type = linear},
["Ezrael"]{name = "MysticShot",spellDelay = 250, projectileSpeed = 2000, range = 1200,  radius = 80, type = linear}
};	

local dodgeList = {};

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
if (getHitBoxRadius(myHero)*2 < spell.spellinformation.radius) then return end

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

											  return {true,"left",collisionPoint,leftEdgeVector,middleVector,rightEdgeVector,spell}

end

if ((collisionPoint = checkLineCollisionPoint(rightBottom[1],
                                              rightBottom[2],
											  rightTop[1],
											  rightTop[2],
											  myHero.x,myHero.y,getHitBoxRadius(myHero))) ~= nil) then 
											  
											  return {true,"right",collisionPoint,leftEdgeVector,middleVector,rightEdgeVector,spell}

end

if ((collisionPoint = checkLineCollisionPoint(spell.spell.startPos.x,
                                              spell.spell.startPos.z,
											  spell.spell.endPos.x,
											  spell.spell.endPos.z,
											  myHero.x,myHero.y,getHitBoxRadius(myHero))) ~= nil) then 

											  return {true,"middle",collisionPoint,leftEdgeVector,middleVector,rightEdgeVector,spell}

end

return {false,"nil",nil,nil,spell}

end

function shortestWay(evadeObject)





end

function getHitBoxRadius(target)
    return GetDistance(target.minBBox, target.maxBBox)/2
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
