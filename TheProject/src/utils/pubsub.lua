--
-- PubSub - Lua public subscribe
-- Code by Piotr Machowski <piotr@machowski.co>
--

--[[ USAGE
local PubSub = require 'pubsub'

-- subscribe
var testSubscription = PubSub.subscribe( 'example1', testSubscriber );

-- publish a topic or message asyncronously
PubSub.publish( 'example1', 'hello scriptjunkie!' );
PubSub.publish( 'example1', 'test','a','b','c' );

-- unsubscribe from further topics
PubSub.unsubscribe( testSubscription );

--]]

local PubSub = {}

local channels    = {}
local lastUid     = 0
local tableRemove = table.remove

 local function publish( topic , ...)
    --there are no subscribers to this channel
    if not channels[topic] then
        return false
    end
    local args = {...}

    local function notify()
        local subscribers = channels[topic]

        for  i=1, #subscribers do
            subscribers[i].callback( topic, unpack( args ) )
        end
    end

    timer.performWithDelay( 0, notify )
    return true
end



-- /**
--  *  Publishes the topic, passing the data to it's subscribers
--  *  @topic (String): The topic to publish
--  *  @data: The data to pass to subscribers
-- **/

function PubSub.publish( topic, ... )
    return publish( topic, ... )
end



-- /**
--  *  Subscribes the passed function to the passed topic.
--  *  Every returned token is unique and should be stored if you need to unsubscribe
--  *  @topic (String): The topic to subscribe to
--  *  @callback (Function): The function to call when a new topic is published
-- **/

function PubSub.subscribe ( topic, callback )
    -- topic is not registered yet
    if not channels[topic] then
        channels[topic] = {}
    end

    -- bump unique id
    lastUid = lastUid + 1
    local token = lastUid
    channels[topic][#channels[topic]+1] = { token = token, callback = callback }

    -- // return token for unsubscribing
    return token
end

-- /**
--  *  Unsubscribes a specific subscriber from a specific topic using the unique token
--  *  @token (String): The token of the function to unsubscribe
-- **/

function PubSub.unsubscribe ( token )
    for _,channel in pairs(channels) do
        for i,topic in ipairs(channel) do
            if topic.token == token then
                tableRemove( channel, i )
                return token
            end
        end
    end

    return false
end


return PubSub
