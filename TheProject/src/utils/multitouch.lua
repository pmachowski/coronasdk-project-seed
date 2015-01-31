--
-- Code by Piotr Machowski <piotr@machowski.co>
--

system.activate('multitouch')

local Multitouch = {}
Multitouch.dots     = {}
Multitouch.dotCount = 0

local _shift, _zoom, _touch, _beginAutoScroll
local primary, secondary
local prevCenter, prevScale
local trackTimer, timestamp, vx, vy, px, py

local function track()
	local now     = system.getTimer()
	local elapsed = now - timestamp
	local dx, dy  = primary.x - px, primary.y - py

	vx = 0.8 * 1000 * dx / (1 + elapsed) + 0.2 * vx
	vy = 0.8 * 1000 * dy / (1 + elapsed) + 0.2 * vy

	timestamp = now
	px, py = primary.x, primary.y
end

function Multitouch.clear()
	for i,v in pairs(Multitouch.dots) do
		if v.removeSelf then
			display.getCurrentStage():setFocus(nil,i)
			v:removeEventListener('touch', v)
			v:removeSelf()
		end
		Multitouch.dots[i] = nil
	end
	Multitouch.dotCount = 0
	primary, secondary = nil,nil
	prevCenter, prevScale = nil
end

function Multitouch.newDot(event)
	Multitouch.dots[event.id] = display.newCircle(0, 0, 20)
	-- Multitouch.dots[event.id]:setFillColor(0, 255, 0, .5)
	Multitouch.dots[event.id].isVisible = false
	Multitouch.dots[event.id].isHitTestable = true
	Multitouch.dots[event.id].x = event.xStart
	Multitouch.dots[event.id].y = event.yStart
	Multitouch.dots[event.id].ev = event
	Multitouch.dots[event.id].touch = Multitouch.dotHandle
	Multitouch.dots[event.id]:addEventListener('touch', Multitouch.dots[event.id])
	display.getCurrentStage():setFocus(Multitouch.dots[event.id],event.id)
	Multitouch.dotCount = Multitouch.dotCount + 1
	if not primary then
		primary = Multitouch.dots[event.id]

		timestamp = system.getTimer( )
		px, py = event.x, event.y
		vx, vy = 0, 0
		trackTimer = timer.performWithDelay( 50, track, -1)
	elseif not secondary then
		timer.cancel( trackTimer )
		trackTimer = nil
		secondary = Multitouch.dots[event.id]
		if _touch then
			_touch({ phase = 'cancelled', x=primary.ev.x, y=primary.ev.y })
		end
	end
	Multitouch.work()
end

function Multitouch.dotHandle(self, event)
	self.ev.x, self.ev.y = event.x, event.y
	self.x, self.y = event.x, event.y
	if event.phase == 'ended' or event.phase == 'cancelled' then
		local replace = false
		if self == primary then
			replace = true
			primary = secondary
			if not secondary and _touch then
				_touch(event)
			end
		elseif self == secondary then replace = true end
		local finish = false
		if replace then
			for _,v in pairs(Multitouch.dots) do
				if (not finish) and v ~= self and v ~= secondary and v ~= primary then
					finish = true
					secondary = v
				end
			end
		end
		if (replace and not finish) then
			secondary = nil
			if not trackTimer then
				trackTimer = timer.performWithDelay( 100, track, -1)
			end
		end
		if (replace and not finish) and primary and (not secondary) and _touch then
			_touch({phase = 'began', x=primary.ev.x, y=primary.ev.y})
		end
		display.getCurrentStage():setFocus(nil,event.id)
		self:removeEventListener('touch', self)
		self:removeSelf()
		Multitouch.dots[self.ev.id] = nil

		Multitouch.dotCount = Multitouch.dotCount-1

		if not primary then
			timer.cancel( trackTimer )
			trackTimer=nil
			_beginAutoScroll(vx, vy)
		end
	elseif event.phase == 'moved' then
		self.ev = event
		if (self == primary) or (self == secondary) then
			Multitouch.work()
		end
	end
end

function Multitouch.work()
	if not primary then return nil end

	if not secondary then
		prevCenter, prevScale = nil, nil
		if _touch then _touch(primary.ev) end
	else
		local cx, cy =
			(primary.ev.x + secondary.ev.x)/2,
			(primary.ev.y + secondary.ev.y)/2
		if prevCenter then
			local dx, dy =
				cx - prevCenter.x,
				cy - prevCenter.y
			if _shift then
				_shift(dx,dy)
			end
		else
			prevCenter = {}
		end
		prevCenter.x, prevCenter.y = cx, cy
		local dx, dy =
			primary.ev.x - secondary.ev.x,
			primary.ev.y - secondary.ev.y
		local len = math.sqrt(dx*dx+dy*dy)
		if prevScale then
			if _zoom then
				_zoom(len/prevScale)
			end
		end
		prevScale = len
	end
end

function Multitouch.setShift(fun) -- dx, dy
	_shift = fun
end

function Multitouch.setZoom(fun) -- scale
	_zoom = fun
end

function Multitouch.setTouch(fun) -- event
	_touch = fun
end

function Multitouch.setAutoScroll(fun) -- vx, vy
	_beginAutoScroll = fun
end

function Multitouch.reset(  )
	if trackTimer then timer.cancel( trackTimer ) trackTimer=nil end
	_shift=nil
	_zoom=nil
	_touch=nil
	_beginAutoScroll=nil
end

return Multitouch
