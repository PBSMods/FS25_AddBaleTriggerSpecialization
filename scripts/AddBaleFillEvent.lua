--
-- Mod: FS25_AddBaleTriggerSpecialization
--
-- File: scripts/AddBaleFillEvent.lua
--
-- Author: PBSMods
-- email: pbsmods (at) pbsmods (dot) ch
-- @Date: 02.03.2026
-- @Version: 1.0.0.0

-- #############################################################################

--[[

]]--

AddBaleFillEvent = {}
local AddBaleFillEvent_mt = Class(AddBaleFillEvent, Event)

InitEventClass(AddBaleFillEvent, "AddBaleFillEvent")

function AddBaleFillEvent.emptyNew()
    return Event.new(AddBaleFillEvent_mt)
end

function AddBaleFillEvent.new(placeable, fillType, fillLevel)
    local self = AddBaleFillEvent.emptyNew()
    self.placeable = placeable
    self.fillType = fillType
    self.fillLevel = fillLevel
    return self
end

function AddBaleFillEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.placeable)
    streamWriteUIntN(streamId, self.fillType, FillTypeManager.SEND_NUM_BITS)
    streamWriteFloat32(streamId, self.fillLevel)
end

function AddBaleFillEvent:readStream(streamId, connection)
    self.placeable = NetworkUtil.readNodeObject(streamId)
    self.fillType = streamReadUIntN(streamId, FillTypeManager.SEND_NUM_BITS)
    self.fillLevel = streamReadFloat32(streamId)
    self:run(connection)
end

function AddBaleFillEvent:run(connection)
    if self.placeable ~= nil and self.placeable.spec_storage ~= nil then
        self.placeable.spec_storage:addFillLevel(
            self.placeable:getOwnerFarmId(),
            self.fillLevel,
            self.fillType,
            ToolType.UNDEFINED,
            nil
        )
    end

    if not connection:getIsServer() then
        g_server:broadcastEvent(self, false, connection)
    end
end

function AddBaleFillEvent.sendEvent(placeable, fillType, fillLevel)
    if g_server ~= nil then
        g_server:broadcastEvent(
            AddBaleFillEvent.new(placeable, fillType, fillLevel),
            nil,
            nil,
            placeable
        )
    else
        g_client:getServerConnection():sendEvent(
            AddBaleFillEvent.new(placeable, fillType, fillLevel)
        )
    end
end
