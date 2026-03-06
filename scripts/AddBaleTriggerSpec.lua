--
-- Mod: FS25_AddBaleTriggerSpecialization
--
-- File: scripts/AddBaleTriggerSpec.lua
--
-- Author: PBSMods
-- email: pbsmods (at) pbsmods (dot) ch
-- @Date: 02.03.2026
-- @Version: 1.0.0.0

-- #############################################################################


AddBaleTriggerSpec = {}

function AddBaleTriggerSpec.prerequisitesPresent(specializations)
    return true
end

function AddBaleTriggerSpec.registerFunctions(placeableType)
    SpecializationUtil.registerFunction(placeableType, "addBaleImportTrigger", AddBaleTriggerSpec.addBaleImportTrigger)
end

function AddBaleTriggerSpec.registerEventListeners(placeableType)
    SpecializationUtil.registerEventListener(placeableType, "onLoad", AddBaleTriggerSpec)
end

function AddBaleTriggerSpec:onLoad(savegame)
    if self.spec_storage ~= nil and
       self.spec_loadingStation ~= nil and
       self.spec_baleTrigger == nil then

        self:addBaleImportTrigger()
    end
end

function AddBaleTriggerSpec:addBaleImportTrigger()

    local triggerNode = createTransformGroup("baleImportTrigger")
    link(self.rootNode, triggerNode)
    setTranslation(triggerNode, 0, 0, -5)

    self.spec_addBaleImport = {}
    self.spec_addBaleImport.triggerNode = triggerNode

    addTrigger(triggerNode, "onBaleTriggerCallback", self)

end

function AddBaleTriggerSpec:onBaleTriggerCallback(triggerId, otherId, onEnter, onLeave, onStay)

    if onEnter then
        local bale = g_currentMission.nodeToObject[otherId]

        if bale ~= nil and bale.getFillType ~= nil then

            local fillType = bale:getFillType()
            local fillLevel = bale:getFillLevel()

            if self.spec_storage:getFreeCapacity(fillType) >= fillLevel then
                AddBaleFillEvent.sendEvent(self, fillType, fillLevel)
                bale:delete()
            end
        end
    end
end

-- Registrierung an alle Placeables
TypeManager.validateTypes = Utils.appendedFunction(
  TypeManager.validateTypes,
  function(self)
    -- Nur ausführen, wenn der aktuelle Manager der PlaceableTypeManager ist
    if self == g_placeableTypeManager then
      for typeName, typeEntry in pairs(self.types) do
        -- Prüfe, ob die Spezialisierung "storage" in diesem Placeable-Typ existiert
        if typeEntry.specializationsByName ~= nil and typeEntry.specializationsByName["storage"] then
          -- Hänge die neue Spezialisierung dynamisch an
          self:addSpecializationToType("AddBaleTriggerSpec", typeName)
        end
      end
    end
  end
)

-- Registrierung an alle Placeables
--PlaceableTypeManager.validatePlaceableTypes = Utils.appendedFunction(
--    PlaceableTypeManager.validatePlaceableTypes,
--    function(self)
--        for typeName, typeEntry in pairs(self.placeableTypes) do
--            if SpecializationUtil.hasSpecialization(Storage, typeEntry.specializations) then
--                typeEntry:addSpecialization("AddBaleTriggerSpec")
--            end
--        end
--    end
--)

