--
-- Code by Piotr Machowski <piotr@machowski.co>
--

display.setStatusBar(display.HiddenStatusBar)
system.setIdleTimer(false)
display.setDefault( "background", 88/255, 149/255, 27/255 )

print('Content', display.actualContentWidth .. ' x ' .. display.actualContentHeight)
print('Suffix', display.imageSuffix or 'none')
local scale = math.max(display.pixelHeight, display.pixelWidth) / math.max(display.actualContentHeight, display.actualContentWidth)
print('Scale', scale)
print((scale == 1 or scale % 2 == 0) and 'Pixel Perfect!' or 'Pixel Scaling')

-- initialize scene management
local composer     = require 'composer'
composer.gotoScene( 'src.views.splashView' )

--version
local ver = display.newText( {text='Version: '..system.getInfo('appVersionString'), fontSize=7} )
ver.anchorX, ver.anchorY = 0, 1
ver.x, ver.y  = 2, display.actualContentHeight-1
