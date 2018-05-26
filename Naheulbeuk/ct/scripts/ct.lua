-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local enableglobaltoggle = true;
local enablevisibilitytoggle = true;

function onInit()
	Interface.onHotkeyActivated = onHotkey;
	
	registerMenuItem(Interface.getString("list_menu_createitem"), "insert", 5);

	onVisibilityToggle();
	onEntrySectionToggle();

	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "*.name"), "onUpdate", onNameOrTokenUpdated);
	DB.addHandler(DB.getPath(node, "*.token"), "onUpdate", onNameOrTokenUpdated);
end

function onClose()
	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "*.name"), "onUpdate", onNameOrTokenUpdated);
	DB.removeHandler(DB.getPath(node, "*.token"), "onUpdate", onNameOrTokenUpdated);
end

function onNameOrTokenUpdated(vNode)
	for _,w in pairs(getWindows()) do
		w.target_summary.onTargetsChanged();
		
		if w.sub_targeting.subwindow then
			for _,wTarget in pairs(w.sub_targeting.subwindow.targets.getWindows()) do
				wTarget.onRefChanged();
			end
		end
	end
end

function addEntry(bFocus)
	local w = createWindow();
	if bFocus and w then
		w.name.setFocus();
	end
	return w;
end

function onMenuSelection(selection)
	if selection == 5 then
		addEntry(true);
	end
end

function onSortCompare(w1, w2)
	return CombatManager.onSortCompare(w1.getDatabaseNode(), w2.getDatabaseNode());
end

function onHotkey(draginfo)
	local sDragType = draginfo.getType();
	if sDragType == "combattrackernextactor" then
		CombatManager.nextActor();
		return true;
	elseif sDragType == "combattrackernextround" then
		CombatManager.nextRound(1);
		return true;
	end
end

function toggleVisibility()
	if not enablevisibilitytoggle then
		return;
	end
	
	local visibilityon = window.button_global_visibility.getValue();
	for _,v in pairs(getWindows()) do
		if v.friendfoe.getStringValue() ~= "friend" then
			if visibilityon ~= v.tokenvis.getValue() then
				v.tokenvis.setValue(visibilityon);
			end
		end
	end
end

function toggleTargeting()
	if not enableglobaltoggle then
		return;
	end
	
	local targetingon = window.button_global_targeting.getValue();
	for _,v in pairs(getWindows()) do
		v.activatetargeting.setValue(targetingon);
	end
end

function toggleSpacing()
	if not enableglobaltoggle then
		return;
	end
	
	local spacingon = window.button_global_spacing.getValue();
	for _,v in pairs(getWindows()) do
		v.activatespacing.setValue(spacingon);
	end
end

function toggleEffects()
	if not enableglobaltoggle then
		return;
	end
	
	local effectson = window.button_global_effects.getValue();
	for _,v in pairs(getWindows()) do
		v.activateeffects.setValue(effectson);
	end
end

function onVisibilityToggle()
	local anyVisible = 0;
	for _,v in pairs(getWindows()) do
		if (v.friendfoe.getStringValue() ~= "friend") and (v.tokenvis.getValue() == 1) then
			anyVisible = 1;
		end
	end
	
	enablevisibilitytoggle = false;
	window.button_global_visibility.setValue(anyVisible);
	enablevisibilitytoggle = true;
end

function onEntrySectionToggle()
	local anyTargeting = 0;
	local anySpacing = 0;
	local anyEffects = 0;

	for _,v in pairs(getWindows()) do
		if v.activatetargeting.getValue() == 1 then
			anyTargeting = 1;
		end
		if v.activatespacing.getValue() == 1 then
			anySpacing = 1;
		end
		if v.activateeffects.getValue() == 1 then
			anyEffects = 1;
		end
	end

	enableglobaltoggle = false;
	window.button_global_targeting.setValue(anyTargeting);
	window.button_global_spacing.setValue(anySpacing);
	window.button_global_effects.setValue(anyEffects);
	enableglobaltoggle = true;
end

function onDrop(x, y, draginfo)
	if draginfo.isType("shortcut") then
		return CampaignDataManager.handleDrop("combattracker", draginfo);
	end
	
	-- Capture any drops meant for specific CT entries
	local win = getWindowAt(x,y);
	if win then
		local nodeWin = win.getDatabaseNode();
		if nodeWin then
			return CombatManager.onDrop("ct", nodeWin.getNodeName(), draginfo);
		end
	end
end