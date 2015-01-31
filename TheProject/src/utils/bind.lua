--
-- Code by Piotr Machowski <piotr@machowski.co>
--

--[[ USAGE

local bind = require 'bind'

local Class={}
Class.__name = 'ClassName'

function Class:foo()
	print('hello from '..self.__name..'!', msg)
end

local greeter = bind(Class, class.foo)

greeter() -- hello from ClassName!

--]]

local bind = function( context, func, ...)
	if select("#", ...) > 0 then
		local args = { n = select("#", ...), ... }--handle nil in varargs
		return function ( ... )
			return func(context, unpack( args, 1, args.n ), ...)
		end
	else
		return function ( ... )
			return func(context, ...)
		end
	end
end

return bind
