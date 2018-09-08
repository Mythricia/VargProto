-- Prototyping for Varg game
-- By: Avael @ Argent Dawn EU

-- Local vars
local addonName, addonTable = ...
local addonPrettyName = "|cFF9400D3V|r|cFF4B0082a|r|cFFEE1289r|r|cFF00FF00g|r"
local doEventSpam = false
local doVerboseErrors = false
local isAddonLoaded = false

-- Cache some common functions
-- Common lua:
local table = table
local type = type
local pairs = pairs
local ipairs = ipairs
local string = string
local wipe = wipe
local print = print
local tostring = tostring
local tonumber = tonumber

-- Avoid tainting global _
local _

-- AvUtils
local au_genContNames = addonTable.AvUtil.GenerateContNames
local au_getPMapInfos = addonTable.AvUtil.GetPlayerMapInfos	-- {contName, zone, subzone}
local au_strFmt = addonTable.AvUtil.FormatDecimalString
local au_ppTable = addonTable.AvUtil.ppTable
local au_GetCurrentInstanceTier = addonTable.AvUtil.GetCurrentInstanceTier
local au_AvColors = addonTable.AvUtil.AvColors
local au_InstanceTable = addonTable.AvUtil.InstanceTable
local au_GenerateInstanceTable = addonTable.AvUtil.GenerateInstanceTable


-- Check if addon has been fully loaded, we use a separate frame for this
-- TODO: Should re-use a single frame throughout this application

local addonLoadedFrame = CreateFrame("frame", addonName..".".."addonLoadedFrame")
addonLoadedFrame:UnregisterAllEvents()
addonLoadedFrame:RegisterEvent("ADDON_LOADED")

-- We're loaded
local function addonLoaded (self, event, ...)
	if event == "ADDON_LOADED" and ... == addonName then
		isAddonLoaded = true
		print( addonName .. " loaded. ")

		if not VargProto then
			VargProto = {}
		end

		addonTable.data = VargProto
	end
end

-- Register the db init to our addon load frame
addonLoadedFrame:SetScript("OnEvent", addonLoaded)



-- TEST: Check if the item recieved by player is either an armor piece or a weapon. Using the "new" WoW ObjectAPI (Interface\FrameXML\ObjectAPI\*)
-- FIXME: Should also check if soulbound, disabled for testing
local knownItems = {}

local function updateItems(bag)
	if not addonLoaded then return end -- Bail if not loaded

	local numSlots = GetContainerNumSlots(bag)
	local batchSum = 0
	local counter = 0

	for slot = 1, numSlots do
	   local currentItem = Item:CreateFromBagAndSlot(bag, slot)
	   
	   if not currentItem:IsItemEmpty() then
		  local location = currentItem:GetItemLocation()
		  
		  -- Store some data
		  local itemID = currentItem:GetItemID()
		  local itemName = currentItem:GetItemName()
		  local itemlvl = currentItem:GetCurrentItemLevel()

		  -- Use old API to get superType, since ObjectAPI gives subType for some reason
		  local itemType = select(2, GetItemInfoInstant(itemID))

		  -- Check that the item is either actually armor or weapon
		  if (itemType == "Armor" or itemType == "Weapon") and not knownItems[itemID] then
			 print("New valid item: " .. itemName .. " ("..itemID..")"..", type '"..itemType.."', ilvl "..itemlvl)
			 knownItems[itemID] = true
			 batchSum = batchSum + itemlvl
			 counter = counter + 1
		  end
	   end
	end

	-- Calculate the average and update SavedVar. Only run if necessary
	if batchSum > 0 then
		if not addonTable.data.avgIlevel then
			addonTable.data.avgIlevel = batchSum / counter
			print("Varg avgilevel initialized to: "..addonTable.data.avgIlevel)
			return
		end

		addonTable.data.avgIlevel = (addonTable.data.avgIlevel + (batchSum / counter)) / 2
		print("New average: "..addonTable.data.avgIlevel)
	end
end


---------------------BEGIN---------------------
----- Individual event handling functions -----
-----------------------------------------------

-- Event hook table, init as empty!
local hookedEvents = {}


-- Example template
function hookedEvents.BAG_UPDATE(...)
	updateItems(...)
end

----------------------END----------------------
-----------------------------------------------



-- Create frame, unregister all events in case we're re-using a frame
local eventHandlerFrame = CreateFrame("frame", addonName..".".."eventHandlerFrame")
eventHandlerFrame:UnregisterAllEvents()

-- Automagically register all events in hookedEvents{}
for k, v in pairs( hookedEvents ) do
	eventHandlerFrame:RegisterEvent(k)
end


-- Event catcher / handler dispatcher. Calls specified even handler if it exists, otherwise complain with the offending event name
local function catchEvent(self, event, ...)

	-- Check if we should enable verbose output
	if doEventSpam then
		print( au_AvColors.cyan .. addonName .. " caught event: " .. au_AvColors.red .. event)
		for k, v in pairs( {...} ) do
			print( au_AvColors.cyan, k, au_AvColors.red, v )
		end
	end

	-- Call the relevant event handler function if defined, else throw error (if doVerboseErrors enabled)
	if (hookedEvents[event] == nil or hookedEvents[event](unpack({...})) == nil) and doVerboseErrors then
		local errString = (au_AvColors.red..addonName..":: No event handler for event: '"..au_AvColors.orange..event..au_AvColors.red.."'")
		print(errString)
		error(errString)
	end
end

-- Subscribe to ALL event updates, using our frame and event catcher
eventHandlerFrame:SetScript("OnEvent", catchEvent)



------------BEGIN------------
----- SlashCMD Handling -----
-----------------------------

-- Required WoW API globals for /command variants
SLASH_VARGPROTO1, SLASH_VARGPROTO2, SLASH_VARGPROTO3 = "/vargp", "/vargproto", "/vp";



-- -- SlashCMD implementations ( slashCommand[command] ) and descriptions ( slashCommand[command].desc )
local slashCommands = {}

slashCommands.listhooks = {
	func = function(...)
		print(" ")
		print(addonName.." hooked events: ")
		for k, v in pairs( hookedEvents ) do
			print( au_AvColors.red, k )
		end
	end,

	desc = "Lists all registered events"
}


slashCommands.spam = {
	func = function(...)
		doEventSpam = not doEventSpam
		if doEventSpam then
			print(addonName..": Event spam "..au_AvColors.red.."enabled")
		else
			print(addonName..": Event spam "..au_AvColors.green.."disabled")
		end
	end,

	desc = "Toggles verbose reporting of events"
}


slashCommands.verboseerrors = {
	func = function(...)
		doVerboseErrors = not doVerboseErrors
		if doVerboseErrors then
			print(addonPrettyName..": Verbose error logging "..au_AvColors.red.."enabled")
		else
			print(addonPrettyName..": Verbose error logging "..au_AvColors.green.."disabled")
		end
	end,

	desc = "Toggles extra verbose error logging"
}


slashCommands.resetavg = {
	func = function(...)
		addonTable.data.avgIlevel = nil
	end,

	desc = "Wipes the average ilevel for this character."
}


slashCommands.showavg = {
	func = function(...)
		if addonTable.data.avgIlevel then
			print(addonTable.data.avgIlevel)
		else
			print("Avg ilevel not initialized yet.")
		end
	end,

	desc = "Print the current average ilevel for this character."
}



-- SlashCmd catcher/preprocessor
local function slashHandler(msg)

	-- split the recieved slashCmd into a root command plus any extra arguments
	local parts = {}
	local root

	for part in string.lower(msg):gmatch("%S+") do
		table.insert(parts, part)
	end

	root = parts[1]
	table.remove(parts, 1) --FIXME: Must be a better way to strip the first element of the table, or just handle the whole thing better


	-- Utility function to print all available commands
	local function printCmdList()
		local slashListSeparator = "      `- "

		print(" ")
		print(addonPrettyName.." commands:")

		for k, v in pairs(slashCommands) do
			print(k)
			if v.desc then
				print(au_AvColors.cyan..slashListSeparator..au_AvColors.orange..v.desc)
			else
				print(slashListSeparator..au_AvColors.red.."Undocumented.")
			end
		end
	end


	-- Check if the root command exists, and call it. Else print error and list available commands + their description (if any)
	if slashCommands[root] ~= nil then
		slashCommands[root].func(unpack(parts))
	elseif root == nil then
		printCmdList()
	else
		print(" ")
		print(addonPrettyName.." unrecognized command: "..au_AvColors.red..root)
		print("List available commands with "..au_AvColors.cyan..SLASH_VARGPROTO1.."|r or "..au_AvColors.cyan..SLASH_VARGPROTO2)
	end
end

SlashCmdList["VARGPROTO"] = slashHandler;

-------------END-------------
-----------------------------