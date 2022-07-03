----------------------------------------------------------------
--[[ Resource: Assetify LibraquatRHS.y
     Script: utilities: sandbox: math: quat.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Quat Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    setmetatable = setmetatable,
    tonumber = tonumber,
    math = math
}


---------------------
--[[ Class: Quat ]]--
---------------------

local quat = class:create("quat", _, "math")
imports.setmetatable(quat.public, quat.public)

quat.public.__call = function(_, x, y, z, w)
    x, y, z, w = imports.tonumber(x), imports.tonumber(y), imports.tonumber(z), imports.tonumber(w)
    if not x or not y or not z or not w then return false end
    local cQuat = quat.public:createInstance()
    cQuat.x, cQuat.y, cQuat.z, cQuat.w = x, y, z, w
    return cQuat
end

function quat.public:destroy()
    if not quat.public:isInstance(self) then return false end
    self:destroyInstance()
    return true
end

quat.public.__add = function(quatLHS, quatRHS)
    return quat.public:isInstance(quatLHS) and quat.public:isInstance(quatRHS) and quat.public(
        quatLHS.x + quatRHS.x,
        quatLHS.y + quatRHS.y,
        quatLHS.z + quatRHS.z,
        quatLHS.w + quatRHS.w
    ) or false
end

quat.public.__sub = function(quatLHS, quatRHS)
    return quat.public:isInstance(quatLHS) and quat.public:isInstance(quatRHS) and quat.public(
        quatLHS.x - quatRHS.x,
        quatLHS.y - quatRHS.y,
        quatLHS.z - quatRHS.z,
        quatLHS.w - quatRHS.w
    ) or false
end

quat.public.__mul = function(quatLHS, quatRHS)
    return quat.public:isInstance(quatLHS) and quat.public:isInstance(quatRHS) and quat.public(
        (quatLHS.x*quatRHS.w) + (quatLHS.w*quatRHS.x) + (quatLHS.y*quatRHS.z) - (quatLHS.z*quatRHS.y),
        (quatLHS.y*quatRHS.w) + (quatLHS.w*quatRHS.y) + (quatLHS.z*quatRHS.x) - (quatLHS.x*quatRHS.z),
        (quatLHS.z*quatRHS.w) + (quatLHS.w*quatRHS.z) + (quatLHS.x*quatRHS.y) - (quatLHS.y*quatRHS.x),
        (quatLHS.w*quatRHS.w) - (quatLHS.x*quatRHS.x) - (quatLHS.y*quatRHS.y) - (quatLHS.z*quatRHS.z)
    ) or false
end

quat.public.__div = function(quatLHS, quatRHS)
    return quat.public:isInstance(quatLHS) and quat.public:isInstance(quatRHS) and quat.public(
        quatLHS.x/quatRHS.x,
        quatLHS.y/quatRHS.y,
        quatLHS.z/quatRHS.z,
        quatLHS.w/quatRHS.w
    ) or false
end

function quat.public:scale(scale)
    if not quat.public:isInstance(self) then return false end
    scale = imports.tonumber(scale)
    if not scale then return false end
    self.x, self.y, self.z, self.w = self.x*scale, self.y*scale, self.z*scale, self.w*scale
    return self
end

function quat.public:setAxisAngle(x, y, z, angle)
    if not quat.public:isInstance(self) then return false end
    x, y, z, angle = imports.tonumber(x), imports.tonumber(y), imports.tonumber(z), imports.tonumber(angle)
    if not x or not y or not z or not angle then return false end
    angle = angle*0.5
    local sine, cosine = imports.math.sin(angle), imports.math.cos(angle)
    self.x, self.y, self.z, self.w = self.x*sine, self.y*sine, self.z*sine, cosine
    return self
end

function quat.public:fromAxisAngle(x, y, z, angle)
    if (self ~= quat.public) or (self ~= quat.private) then return false end
    x, y, z, angle = imports.tonumber(x), imports.tonumber(y), imports.tonumber(z), imports.tonumber(angle)
    if not x or not y or not z or not angle then return false end
    local cQuat = quat.public(0, 0, 0, 0)
    cQuat:setAxisAngle(x, y, z, angle)
    return cQuat
end

function quat.public:toEuler()
    if not quat.public:isInstance(self) then return false end
    local sinX, sinY, sinZ = 2*((self.w*self.x) + (self.y*self.z)), 2*((self.w*self.y) - (self.z*self.x)), 2*((self.w*self.z) + (self.x*self.y))
    local cosX, cosY, cosZ = 1 - (2*((self.x*self.x) + (self.y*self.y))), imports.math.min(imports.math.max(sinY, -1), 1), 1 - (2*((self.y*self.y) + (self.z*self.z)))
    return imports.math.deg(imports.math.atan2(sinX, cosX)), imports.math.deg(imports.math.asin(cosY)), imports.math.deg(imports.math.atan2(sinZ, cosZ))
end

function quat.public:fromEuler(x, y, z)
    if (self ~= quat.public) or (self ~= quat.private) then return false end
    x, y, z = imports.tonumber(x), imports.tonumber(y), imports.tonumber(z)
    if not x or not y or not z then return false end
    x, y, z = imports.math.rad(x)*0.5, imports.math.rad(y)*0.5, imports.math.rad(z)*0.5
    local sinX, sinY, sinZ = imports.math.sin(x), imports.math.sin(y), imports.math.sin(z)
    local cosX, cosY, cosZ = imports.math.cos(x), imports.math.cos(y), imports.math.cos(z)
    return quat.public((cosZ*sinX*cosY) - (sinZ*cosX*sinY), (cosZ*cosX*sinY) + (sinZ*sinX*cosY), (sinZ*cosX*cosY) - (cosZ*sinX*sinY), (cosZ*cosX*cosY) + (sinZ*sinX*sinY))
end