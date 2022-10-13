-- [[ Namespaces ]] --
local _, addon = ...;
local section = {};

function section.CheckAdd(achievement)
    return true;
end

function section.Add(achievement)
	print(achievement.Id,achievement.IsAccountWide)
	if achievement.IsAccountWide then
		if achievement.IsCompleted then
			GameTooltip:AddLine(ACCOUNT_WIDE_ACHIEVEMENT_COMPLETED);
		else
			GameTooltip:AddLine(ACCOUNT_WIDE_ACHIEVEMENT);
		end
		return;
	end

	local earnedBy, notEarnedBy = addon.GUI.AchievementTooltip.EvaluateCharacters(achievement);
	if earnedBy ~= "" then
		GameTooltip:AddLine(format(ACHIEVEMENT_EARNED_BY, earnedBy), nil, nil, nil, true);
	end
	if notEarnedBy ~= "" then
		GameTooltip:AddLine(format(addon.L["Not earned by:"], notEarnedBy), nil, nil, nil, true);
	end
end

tinsert(addon.GUI.AchievementTooltip.Sections, section);