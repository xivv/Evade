


local lastSpell

local lastSpellDelay

local lastSpellSpeed

local lastSpellRange

local lastSpellRadius



local startVector

local endVector

local p1

local p2

local p3

local p4


local evade = true

local collideLeft

local collideMiddle

local collideRight

local evadeVector 

local wayToEvade

local ts

function OnLoad()

ts = TargetSelector(TARGET_LOW_HP_PRIORITY,2000)

end


function OnTick()

ts:update()

end


local objectList = {
["Morgana"] = {spellName = "DarkBindingMissile", spellDelay = 250, projectileSpeed = 1200, range = 1300, radius = 80},
["Karma"] = {spellName = "KarmaQ", spellDelay = 250, projectileSpeed = 1700, range = 1050, radius = 90},
["Blitzcrank"] = {spellName = "RocketGrab", spellDelay = 250, projectileSpeed = 1800, range = 1050, radius = 70},
["Ezrael"]{name = "MysticShot",spellDelay = 250, projectileSpeed = 2000, range = 1200,  radius = 80}
};	






function evadeToPosition(directionInformation)

if(evade) then

if(canEscapeFullHit(skillShotwillHitInWhichTime(lastSpellDelay,lastSpellDelay,getSkillShotFromHeroDistance()),directionInformation[3],myHero)) then
							  
oldPosition = {myHero.x,myHero.z}
newPosition = {myHero.x + directionInformation[2].x,myHero.z + directionInformation[2].z}

myHero:MoveTo(newPosition[1],newPosition[2])
evade = false
end
end
end

 



-- Delay . Speed . Range . Radius


function OnProcessSpell(unit, spell)

for i, skillShot in pairs(objectList) do

if spell.name == skillShot.spellName and unit ~= myHero then
lastSpell = spell
lastSpellDelay = skillShot.spellDelay
lastSpellSpeed = skillShot.projectileSpeed
lastSpellRange = skillShot.range
lastSpellRadius = skillShot.radius


startVector = Vector (spell.startPos.x,spell.startPos.y,spell.startPos.z)
endVector = Vector(spell.endPos.x,spell.endPos.y,spell.endPos.z)

points = getPointsFromRect(endVector.x,endVector.z,startVector.x,startVector.z, lastSpellRadius * 2,lastSpellRange)

p1 = points[1]
p2 = points[2]
p3 = points[3]
p4 = points[4]
return
end
end
end


function skillShotwillHitInWhichTime(spellDelay,projectileSpeed,distance)
PrintChat("Time till collision " .. (spellDelay / 1000 +  distance / projectileSpeed))
return spellDelay / 1000 +  distance / projectileSpeed
end


function canEscapeFullHit(timeUntilHit,wayToEscape,unit)

if timeUntilHit * unit.ms > wayToEscape then
PrintChat("Can evade hit in time")
 return true
 else
 PrintChat("Cant evade in time")
end

end



-- returns { directionToEvade,vectorToEvade,distanceToEvade}
function getEvadeDirectionVectorDistance()

--check to which site the distance from the middlepoint of target is closer to which outside vector

local distanceToLeftSide = pointLineDistance2(p3[1],p3[2],p1[1],p1[2],myHero.x,myHero.z)
local distanceToRightSide = pointLineDistance2(p4[1],p4[2],p2[1],p2[2],myHero.x,myHero.z)

local leftEvadeVector = Vector(p2[1] - p1[1], endVector.y,p2[2] - p1[2]):normalized()
local rightEvadeVector = Vector(p1[1] - p2[1], endVector.y,p1[2] - p2[2]):normalized()

local playerCollisionVectorPoint
local outerCirclePoint

local distance
local direction
local vectorToEvade

if( distanceToLeftSide < distanceToRightSide) then

direction = "left"
playerCollisionVectorPoint = {myHero.x + rightEvadeVector.x, myHero.z + rightEvadeVector.z}
else
direction = "right"
playerCollisionVectorPoint = { myHero.x + leftEvadeVector.x, myHero.z + leftEvadeVector.z}

end


outerCirclePoint = checklineCollisionPoint(myHero.x,myHero.z,playerCollisionVectorPoint[1],playerCollisionVectorPoint[2], myHero.x, myHero.z, getHitBoxRadius(myHero))

if direction == "left" then
distance =  pointLineDistance2(p3[1],p3[2],p1[1],p1[2],outerCirclePoint[1],outerCirclePoint[2])
directionToEvade = Vector(leftEvadeVector.x * distance * 2,myHero.y,leftEvadeVector.z * distance * 2)
else

distance = pointLineDistance2(p4[1],p4[2],p2[1],p2[2],outerCirclePoint[1],outerCirclePoint[2])
directionToEvade = Vector(rightEvadeVector.x * distance * 2,myHero.y,rightEvadeVector.z * distance * 2)
end
PrintChat("Evade distance" .. directionToEvade:len())
PrintChat("Evade neded distance" .. distance)

return { direction , directionToEvade , distance} 

end






function OnDraw()
   
   if(lastSpell ~= nil and lastSpell.startPos.x ~= nil ) then
  
   
   DrawCircle(endVector.x,endVector.y, endVector.z,lastSpellRadius, ARGB(255,255,255,255))
   DrawLineBorder3D(startVector.x,startVector.y,startVector.z,endVector.x,endVector.y,endVector.z,lastSpellRadius * 2,ARGB(255,255,255,255),1)
   DrawLine3D(p3[1],myHero.y,p3[2],p1[1],myHero.y,p1[2],3,ARGB(255,0,0,255))
   DrawLine3D(p4[1],myHero.y,p4[2],p2[1],myHero.y,p2[2],3,ARGB(255,255,0,255))

   if(ts.target ~= nil) then
      if(intersects()) then
         evadeToPosition(getEvadeDirectionVectorDistance())
      else
      end
   end
   
   end
   

  
   DrawCircle(myHero.x, myHero.y, myHero.z,getHitBoxRadius(myHero), ARGB(255,255,0,0))
   
end


function intersects()


if checkLineCollision(p1[1],p1[2],p3[1],p3[2],myHero.x,myHero.z,getHitBoxRadius(myHero)) then
collideLeft = true
return true
end

if checkLineCollision(p2[1],p2[2],p4[1],p4[2],myHero.x,myHero.z,getHitBoxRadius(myHero)) then
collideRight = true
return true

end

if checkLineCollision(startVector.x,startVector.z,endVector.x,endVector.z,myHero.x,myHero.z,getHitBoxRadius(myHero)) then
collideMiddle = true
return true

end

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

                     
function pointLineDistance2(startx,starty,endx,endy,pointx,pointy)

local l2 =  (endx - startx)^2 + (endy - starty)^2
if l2 == 0 then return math.sqrt( (pointx - startx)^2 + (pointy - starty)^2 ) end
local scalar1 = {(pointx - startx), (pointy - starty)}
local scalar2 =  {(endx - startx), (endy - starty)}

local t = math.max(0,math.min(1,(scalar1[1] * scalar2[1] + scalar1[2] * scalar2[2]) / l2))
local projection = {   startx + t * ( endx - startx)  ,  starty + t * ( endy - starty) }

return math.sqrt( (projection[1] - pointx)^2 + (projection[2] - pointy)^2 )
end



function pointLineDistance(startx,starty,endx,endy,pointx,pointy)

local cn = { pointx - startx, pointy - starty}
local bn = { endx - startx, endx - starty}

local angle = math.atan2(bn[2],bn[1]) - math.atan2(cn[2],cn[1])
local abLength = math.sqrt(bn[1] * bn[1] + bn[2] * bn[2])

return math.sqrt((math.sin(angle)*abLength)^2)
end



function OnDeleteObj(obj)
for i, skillShot in pairs(objectList) do
if obj.spellName:find(skillShot.spellName) then


      lastSpell = nil
	  evade = false

end
end
end


--local ende

--local start

function getSkillShotFromHeroDistance()

return math.sqrt(  (myHero.x - startVector.x)^2 + (myHero.z - startVector.z)^2 )

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





function getHitBoxRadius(target)
    return GetDistance(target.minBBox, target.maxBBox)/2
end

