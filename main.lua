-- Frappy Bird! Save your decoupled brothers from the sinking island.
-- WASD or arrow keys to move, Space to couple.

-- Made in 48 hours for Sonen Game Jam (http://sonengamejam.org/).
-- Topic for the Game Jam was "coupled".

-- Code & penguin graphics by Simen Heggestøyl
-- Music by Ådne Lyngstad Nilsen
-- Sky backdrop by Bart Kelsey

-- This program is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 3 of the License, or (at your option)
-- any later version.

-- This program is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-- more details.

-- You should have received a copy of the GNU General Public License along
-- with this program.  If not, see <http://www.gnu.org/licenses/>.

w = 1200 -- screen width
h = 600 -- screen height

g = love.graphics -- graphics namespace
k = love.keyboard -- keyboard namespace
p = love.physics -- physics namespace

o = {} -- all physical objects
o.g = {} -- ground objects
o.p = {} -- penguins
o.b = {} -- blocks
o.c = {} -- cannon balls

ppm = 64 -- pixels per meter
face = "left" -- default player facing

t = 0 -- seconds since game start

function love.load()
   -- set display mode
   g.setMode(w, h, false, false, 8)

   -- size of a meter
   p.setMeter(ppm)

   -- load graphics
   sky = g.newImage("sprites/sky.png")
   pingu = g.newImage("sprites/pingu.png")
   player1 = g.newImage("sprites/player1.png")
   player2 = g.newImage("sprites/player2.png")

   -- load sounds
   bgm = love.audio.newSource("sound/bgm.ogg", "ogg")
   chirp = love.audio.newSource("sound/penguin.ogg", "ogg")
   chirphi = love.audio.newSource("sound/penguin_hi.ogg", "ogg")
   love.audio.play(bgm)

   -- create world
   world = p.newWorld(0, 9.81*ppm, true)
   world:setCallbacks(beginContact, nil, nil, nil)

   -- create ground
   sinking = addground(125, h - 100/2, 250, 100)
   addground(-1, h, 1, h*2)
   addground(w + 1, h, 1, h*2)
   addground(w - 250/2, h - 100/2, 250, 100)
   addground(600, 500, 200, 40)

   -- create the player
   o.player = {}
   o.player.body = p.newBody(world, 1050, 500, "dynamic")
   o.player.shape = p.newCircleShape(player1:getHeight() / 2)
   o.player.fixture = p.newFixture(o.player.body, o.player.shape, 3)
   o.player.fixture:setRestitution(0.5) --let the player bounce
   o.player.fixture:setFriction(10)

   -- create them penguins
   for i = 1, 4 do
      addpenguin(i*50, 500)
   end

   -- create blocks
   addblock(10, h - 150, 20, 100)
   addblock(125, h - 200, 250, 20)
   addblock(240, h - 150, 20, 100)
   addblock(500 + 25, 400, 50, 200)
   addblock(700 - 25, 400, 50, 200)

   -- initial graphics setup
   g.setBackgroundColor(104, 136, 248)
end

function addground(x, y, w, h)
   local ground = {}
   ground.body = p.newBody(world, x, y)
   ground.shape = p.newRectangleShape(w, h)
   ground.fixture = p.newFixture(ground.body, ground.shape)
   table.insert(o.g, ground)
   return ground
end

function addpenguin(x, y)
   local penguin = {}
   penguin.body = p.newBody(world, x, y, "dynamic")
   penguin.shape = p.newCircleShape(pingu:getWidth() / 2)
   penguin.fixture = p.newFixture(penguin.body, penguin.shape, 2)
   penguin.fixture:setRestitution(0.6)
   penguin.fixture:setUserData("penguin")
   table.insert(o.p, penguin)
end

function addblock(x, y, w, h)
   local block = {}
   block.body = p.newBody(world, x, y, "dynamic")
   block.shape = p.newRectangleShape(0, 0, w, h)
   block.fixture = p.newFixture(block.body, block.shape, 0.5)
   table.insert(o.b, block)
end

function firecannon()
   local ball = {}
   local x = 600
   local y = -50
   ball.body = p.newBody(world, x, y, "dynamic")
   ball.shape = p.newCircleShape(5)
   ball.fixture = p.newFixture(ball.body, ball.shape, 1.5)
   ball.body:applyForce(1, 0)
   table.insert(o.c, ball)
end

function love.update(dt)
   t = t + dt

   world:update(dt) -- put the world into motion

   sinking.body:setY(sinking.body:getY() + 0.02)

   if (t > 10) then
      firecannon()
      for i = 1, #o.c do
         if o.c[i].body:getY() > h + 50 then
            table.remove(o.c[i])
         end
      end
   end

   if k.isDown("right") or k.isDown("d") then
      o.player.body:applyForce(600, 0)
      face = "right"
   end
   if k.isDown("left") or k.isDown("a") then
      o.player.body:applyForce(-600, 0)
      face = "left"
   end
   if k.isDown("up") or k.isDown("w") then
      o.player.body:applyForce(0, -1600)
   end
end

function coupleClosest(toWhom)
   best = math.huge
   bestObj = nil
   for key, obj in pairs(o.p) do
      local dist = p.getDistance(toWhom.fixture, obj.fixture)
      if dist < best then
         best = dist
         bestObj = obj
      end
   end
   join(toWhom, bestObj, best + 50)
end

function join(object1, object2, maxLength)
   o.joint = p.newRopeJoint(
      object1.body,
      object2.body,
      object1.body:getX() * ppm,
      object1.body:getY() * ppm,
      object2.body:getX() * ppm,
      object2.body:getY() * ppm,
      maxLength, true)
end

function beginContact(a, b, coll)
   -- if a:getUserData() == "penguin" and b:getUserData() == "penguin" then
   -- love.audio.play(chirp)
   -- end
end

function love.draw()
   -- draw background
   g.draw(sky, 0, -100)

   -- draw ground
   g.setColor(187, 242, 244)
   for i = 1, #o.g do
      g.polygon("fill", o.g[i].body:getWorldPoints(o.g[i].shape:getPoints()))
   end

   local pvx, pvy = o.player.body:getLinearVelocity()
   local aspeed = 10

   if math.abs(pvy) < 5 then
      aspeed = 0
   end

   local psprite = player2

   if t*aspeed % 2 > 1 then
      psprite = player1
   end

   -- draw player
   g.setColor(255, 255, 255)
   if face == "left" then
      g.draw(
         psprite,
         o.player.body:getX() - player1:getWidth()/2,
         o.player.body:getY() - player1:getHeight()/2)
   else
      g.draw(
         psprite,
         o.player.body:getX() + player1:getWidth()/2,
         o.player.body:getY() - player1:getHeight()/2,
         0, -1, 1)
   end

   -- draw penguins
   g.setColor(255, 255, 255)
   for i = 1, #o.p do
      g.push()
      g.translate(o.p[i].body:getX(), o.p[i].body:getY())
      g.rotate(o.p[i].body:getAngle())
      g.draw(pingu, -pingu:getWidth()/2, -pingu:getHeight()/2)
      g.pop()
   end

   -- draw blocks
   g.setColor(150, 150, 150)
   for i = 1, #o.b do
      g.polygon("fill", o.b[i].body:getWorldPoints(o.b[i].shape:getPoints()))
   end

   -- draw cannon balls
   g.setColor(255, 0, 0)
   for i = 1, #o.c do
      g.circle("fill", o.c[i].body:getX(), o.c[i].body:getY(),
               o.c[i].shape:getRadius())
   end

   -- draw the rope
   g.setColor(150, 150, 150)
   if o.joint then
      x1, y1, x2, y2 = o.joint:getAnchors()
      g.line(x1, y1, x2, y2)
   end

   --- draw lava
   drawlava(10)
end

function drawlava(len)
   g.setBlendMode("alpha")
   g.setColor(255, 0, 0, 170)
   g.push()
   g.translate(0, h)
   math.randomseed(1)
   for i = 0, w, 10 do
      g.circle(
         "fill", i, 0, 20 + math.random() * math.sin(t) * 10, 50)
   end
   g.pop()
end

function love.keypressed(key)
   if key == "q" or key == "escape" then
      love.event.push("quit")
   end
   if key == " " then
      coupleClosest(o.player)
   end
end

function love.keyreleased(key)
   if key == " " then
      o.joint:destroy()
      o.joint = nil
   end
end
