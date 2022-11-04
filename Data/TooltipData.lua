-- [[ Namespaces ]] --
local _, addon = ...;
local data = addon.Data;
addon.TooltipData = {};
local tooltipData = addon.TooltipData;
addon.Data.TooltipData = {};

local function ProcessGuid(guid)
    local unitType, _, serverId, instanceId, zoneUid, id, spawnUid = strsplit("-", guid);
    return unitType, serverId, instanceId, zoneUid, id, spawnUid;
end

local function AddTooltipLine(tooltipLine)
    local _, name, _, achievementIsCompleted, _, _, _, _, _, _, _, _, wasEarnedByMe = addon.GetAchievementInfo(tooltipLine.AchievementId);
    if not name then -- Achievement does not exist
        return;
    end

    local show = false;
    if not wasEarnedByMe and addon.Options.db.Tooltip.Units.ShowCriteriaIf.AchievementWasNotEarnedByMe then
        show = true;
    end

    if achievementIsCompleted and addon.Options.db.Tooltip.Units.ShowCriteriaIf.AchievementIsCompleted then
        show = true;
    end

    if not show then
        return;
    end

    local _, _, criteriaIsCompleted = GetAchievementCriteriaInfo(tooltipLine.AchievementId, tooltipLine.CriteriaIndex);

    if criteriaIsCompleted and not addon.Options.db.Tooltip.Units.ShowCriteriaIf.CriteriaIsCompleted then
        return;
    end

    if criteriaIsCompleted then
        local color = addon.Colors.GreenRGB;
        GameTooltip:AddLine("|T136814:0|t " .. tooltipLine.CompletedText:ReplaceVars{
            achievement = name
        }, color.R, color.G, color.B);
    else
        local color = addon.Colors.RedRGB;
        GameTooltip:AddLine("|T136813:0|t " .. tooltipLine.NotCompletedText:ReplaceVars{
            achievement = name
        }, color.R, color.G, color.B);
    end
end

local function ProcessUnit(guid)
    if not addon.Options.db.Tooltip.Units.ShowCriteria then
        return;
    end

    if not guid then
        return;
    end
    if addon.Diagnostics.DebugEnabled() then
        GameTooltip:AddLine(guid);
    end

    local unitType, _, _, _, id = ProcessGuid(guid);
    id = tonumber(id);
    if unitType ~= "Creature" or not id then
        return;
    end

    local unitDatum = addon.Data.TooltipData[id];
    if not unitDatum then
        return;
    end

    for _, tooltipLine in next, unitDatum.TooltipLines do
        if tooltipLine.Type == addon.Objects.TooltipDataType.Unit then
            AddTooltipLine(tooltipLine);
        end
    end
end

local function ProcessItem(itemId)
    if not addon.Options.db.Tooltip.Units.ShowCriteria then
        return;
    end

    if not itemId then
        return;
    end
    if addon.Diagnostics.DebugEnabled() then
        GameTooltip:AddLine(itemId);
    end

    -- local unitType, _, _, _, id = ProcessGuid(guid);
    -- if unitType ~= "Creature" then
    --     return;
    -- end
    -- local unitDatum = addon.Data.ItemData[id];
    -- if not unitDatum then
    --     return;
    -- end
    -- local _, name, _, achievementIsCompleted, _, _, _, _, _, _, _, _, wasEarnedByMe = addon.GetAchievementInfo(unitDatum.AchievementId);
    -- if not name then -- Achievement does not exist
    --     return;
    -- end

    -- local show = false;
    -- if not wasEarnedByMe and addon.Options.db.Tooltip.Units.ShowCriteriaIf.AchievementWasNotEarnedByMe then
    --     show = true;
    -- end

    -- if achievementIsCompleted and addon.Options.db.Tooltip.Units.ShowCriteriaIf.AchievementIsCompleted then
    --     show = true;
    -- end

    -- if not show then
    --     return;
    -- end

    -- local _, _, criteriaIsCompleted = GetAchievementCriteriaInfo(unitDatum.AchievementId, unitDatum.CriteriaIndex);

    -- if criteriaIsCompleted and not addon.Options.db.Tooltip.Units.ShowCriteriaIf.CriteriaIsCompleted then
    --     return;
    -- end

    -- if criteriaIsCompleted then
    --     local color = addon.Colors.GreenRGB;
    --     GameTooltip:AddLine("|T136814:0|t " .. unitDatum.CompletedText:ReplaceVars{
    --         achievement = name
    --     }, color.R, color.G, color.B);
    -- else
    --     local color = addon.Colors.RedRGB;
    --     GameTooltip:AddLine("|T136813:0|t " .. unitDatum.NotCompletedText:ReplaceVars{
    --         achievement = name
    --     }, color.R, color.G, color.B);
    -- end
end

local function ProcessUnit100000()
    local _, unit = GameTooltip:GetUnit();
    if not unit then
        return;
    end
    local guid = UnitGUID(unit);
    ProcessUnit(guid);
end

local function ProcessItem100000()
    local _, link = GameTooltip:GetItem();
    if not link then
        return;
    end
    local itemId = (select(3, strfind(link, "item:(%d+)")));
    itemId = tonumber(itemId);
    ProcessItem(itemId);
end

local function ProcessUnit100002(tooltip, localData)
    ProcessUnit(localData.guid);
end

local function ProcessItem100002(tooltip, localData)
    -- ProcessItem(localData.guid);
end

function tooltipData.Load()
    local tocVersion = select(4, GetBuildInfo());
    if tocVersion < 100002 then
        GameTooltip:HookScript("OnTooltipSetUnit", ProcessUnit100000);
        GameTooltip:HookScript("OnTooltipSetItem", ProcessItem100000);
    else
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, ProcessUnit100002);
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, ProcessItem100002);
    end

    data.ExportedTooltipData.Load(addon.Data.TooltipData);
end

-- local unitLink = "|cffffff00|Hunit:%s|h[%s]|h|r"

-- function KrowiAF_ParseGUID(unit)
-- 	local guid = UnitGUID(unit)
-- 	local name = UnitName(unit)
-- 	if guid then
-- 		local link = unitLink:format(guid, name) -- clickable link
-- 		local unit_type = strsplit("-", guid)
-- 		if unit_type == "Creature" or unit_type == "Vehicle" then
-- 			local _, _, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-", guid)
-- 			print(format("%s is a creature with NPC ID %d", link, npc_id))
-- 		elseif unit_type == "Player" then
-- 			local _, server_id, player_id = strsplit("-", guid)
-- 			print(format("%s is a player with ID %s", link, player_id))
-- 		end
-- 	end
-- end