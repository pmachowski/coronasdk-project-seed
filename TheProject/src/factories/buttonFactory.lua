--
-- Code by Piotr Machowski <piotr@machowski.co>
--

local ButtonFactory = {}

local print = function() end

function ButtonFactory.enableTouch( _do, _onRelease )
	_do.active = _do.active or true
	_do.isFocused = false
	_do.onRelease = _onRelease
	_do.touch = ButtonFactory.onTouch
	_do:addEventListener('touch', _do)
end

function ButtonFactory.enableTapAndHold( _do, _onHold)
	_do.active = _do.active or true
	_do.isFocused = false
	_do.onHold = _onHold
	_do.touch = ButtonFactory.onTouch
	_do:addEventListener('touch', _do)
end

function ButtonFactory.disableTouch( _do )
	_do:removeEventListener('touch', _do)
	_do.onHold=nil
	_do.onRelease=nil
	_do.isFocused=nil
	_do.active=nil
	_do.holdDelay=nil
end

------------------------------------------

-- _btnOn and _btnOff must be of class Button or ScaleButton
function ButtonFactory.newToggle( _btnOn, _btnOff, _onRelease, _state, _parent, _x, _y, _active )
	local toggle = display.newGroup( )
	toggle.anchorChildren=true
	toggle.btnOff = _btnOff
	toggle:insert( toggle.btnOff, true )
	toggle.btnOn = _btnOn
	toggle:insert( toggle.btnOn, true )
	toggle.onRelease = function(event)
		local newState = event.target ~= toggle.btnOn and true or false
		toggle:switch(newState)
		_onRelease({target=toggle, state=newState})
	end
	--capture buttons events
	toggle.btnOn.onRelease = toggle.onRelease
	toggle.btnOff.onRelease = toggle.onRelease

	function toggle:switch( _state )
		assert( type(_state) == 'boolean', 'Toggle state must be a boolean')
		self.state = _state
		self.btnOn.isVisible  = _state
		self.btnOff.isVisible = not _state
	end
	--switch to the current state
	toggle:switch(_state)

	function toggle:activate(_active )
		self.btnOn.active=_active
		self.btnOff.active=_active
	end
	toggle:activate(_active or false)

	toggle._removeSelf = toggle.removeSelf
	function toggle:removeSelf( )
		self.onRelease=nil
		self.btnOn:removeSelf()
		self.btnOff:removeSelf()
		self:_removeSelf()
		self=nil
		print( '[Toggle Btn] Destroyed' )
	end

	toggle.x = _x or 0
	toggle.y = _y or 0
	_parent:insert( toggle )
	print( '[Toggle Btn] Created' )
	return toggle
end

function ButtonFactory.newTextButton( _params, _onRelease, _parent, _x, _y, _active )
	_params.text = _params.text or 'default'
	_params.font = _params.font or native.systemFont
	_params.fontSize = _params.fontSize or 10
	_params.color = _params.color or {.8,.8,.8}
	_params.colorTap = _params.colorTap or {_params.color[1]*.8,_params.color[2]*.8,_params.color[3]*.8}
	_params.img = _params.img or display.newRect( 0, 0, 140, 24 )

	_params.img.isVisible=false
	_params.img.isHitTestable=true

	local btn = display.newGroup( )
	btn.anchorChildren=true
	btn.img = _params.img
	btn:insert( btn.img, true )
	btn.color = _params.color
	btn.colorTap = _params.colorTap
	btn.txt = display.newText( {text=_params.text, width=btn.img.width, align='center', font=_params.font, fontSize=_params.fontSize } )
	btn.txt:setFillColor( unpack(btn.color) )
	btn:insert( btn.txt, true )
	btn.active = _active or false
	btn.isFocused = false
	btn.onRelease = _onRelease
	btn.touch = ButtonFactory.onTouch
	btn:addEventListener('touch', btn)

	function btn:activate(_active )
		self.active=_active
	end

	btn._removeSelf = btn.removeSelf
	function btn:removeSelf( )
		self:removeEventListener('touch', self)
		self.onRelease=nil
		self.img:removeSelf()
		self:_removeSelf()
		self=nil
		print( '[Btn] Destroyed' )
	end

	btn.x = _x or 0
	btn.y = _y or 0
	_parent:insert( btn )
	print( '[Btn] Created' )
	return btn
end

function ButtonFactory.newScaleButton( _img, _onRelease, _parent, _x, _y, _active )
	local btn = display.newGroup( )
	btn.anchorChildren=true
	btn.img = _img
	btn:insert( btn.img, true )
	btn.active = _active or false
	btn.isFocused = false
	btn.onRelease = _onRelease
	btn.touch = ButtonFactory.onTouch
	btn:addEventListener('touch', btn)

	function btn:activate(_active )
		self.active=_active
	end

	btn._removeSelf = btn.removeSelf
	function btn:removeSelf( )
		self:removeEventListener('touch', self)
		self.onRelease=nil
		self.img:removeSelf()
		self:_removeSelf()
		self=nil
		print( '[Btn] Destroyed' )
	end

	btn.x = _x or 0
	btn.y = _y or 0
	_parent:insert( btn )
	print( '[Btn] Created' )
	return btn
end

function ButtonFactory.newButton( _img, _imgTap, _onRelease, _parent, _x, _y, _active )
	local btn = display.newGroup( )
	btn.anchorChildren=true
	btn.imgTap = _imgTap
	btn:insert( btn.imgTap, true )
	btn.imgTap.isVisible=false
	btn.img = _img
	btn:insert( btn.img, true )
	btn.active = _active or false
	btn.isFocused = false
	btn.onRelease = _onRelease
	btn.touch = ButtonFactory.onTouch
	btn:addEventListener('touch', btn)

	function btn:activate(_active )
		self.active=_active
	end

	btn._removeSelf = btn.removeSelf
	function btn:removeSelf( )
		self:removeEventListener('touch', self)
		self.onRelease=nil
		self.img:removeSelf()
		self.imgTap:removeSelf()
		self:_removeSelf()
		self=nil
		print( '[Btn] Destroyed' )
	end

	btn.x = _x or 0
	btn.y = _y or 0
	_parent:insert( btn )
	print( '[Btn] Created' )
	return btn
end

function ButtonFactory.onTouch(self, event)
	if not self.active then print 'Button not active' return false end
	if 'began' == event.phase then
		-- display.getCurrentStage():setFocus(self)
		self.isFocused = true
		if self.imgTap then
			self.imgTap.isVisible 	= true
			self.img.isVisible 		= false
		elseif self.txt then
			self.txt:setFillColor( unpack(self.colorTap) )
		elseif  self.img then
			self.img.xScale, self.img.yScale = .9, .9
		else
			self.xScale, self.yScale = self.touchScale or 1.1, self.touchScale or 1.1
		end
		if self.onHold then
			self.holdTimer = timer.performWithDelay( self.holdDelay or 1000, function()
					if self.onHold then self.onHold({target=self}) end
				end )
		end
	end
	if self.isFocused then
		local bounds = self.contentBounds
		local x,y = event.x,event.y
		local withinBounds = bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y

		if event.phase == 'moved' then
			if withinBounds then
				if self.imgTap then
					self.imgTap.isVisible 	= true
					self.img.isVisible 		= false
				elseif self.txt then
					self.txt:setFillColor( unpack(self.colorTap) )
				elseif  self.img then
					self.img.xScale, self.img.yScale = .9, .9
				else
					self.xScale, self.yScale = self.touchScale or 1.1, self.touchScale or 1.1
				end
			else
				if self.imgTap then
					self.imgTap.isVisible 	= false
					self.img.isVisible 		= true
				elseif self.txt then
					self.txt:setFillColor( unpack(self.color) )
				elseif self.img then
					self.img.xScale, self.img.yScale = 1,1
				else
					self.xScale, self.yScale = 1,1
				end
			end
		elseif event.phase == 'ended' or event.phase == 'cancelled' then
			if self.holdTimer then
				timer.cancel( self.holdTimer )
				self.holdTimer=nil
			end
			self.holdTimer=nil
			if self.imgTap then
				self.imgTap.isVisible 	= false
				self.img.isVisible 		= true
			elseif self.txt then
				self.txt:setFillColor( unpack(self.color) )
			elseif self.img then
				self.img.xScale, self.img.yScale = 1,1
			else
				self.xScale, self.yScale = 1,1
			end
			if event.phase == 'ended' then
				if withinBounds then
					if self.onRelease then self.onRelease({target=self}) end
				end
				-- display.getCurrentStage():setFocus(self, nil)
				self.isFocused = false
			end
		end
	end
	return true
end


return ButtonFactory
