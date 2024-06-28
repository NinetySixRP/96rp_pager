local number = ''
local contacts = {}
local messages = {}
local currentContact = 1
local currentMessage = 1
local currentPagerObj = 0

--------------------------------------------------------------------------
-- Gets pager data from server
--------------------------------------------------------------------------
function GetPagerData()
    local pagerData = lib.callback.await('96rp-pager:server:GetPagerData', false)
    number = pagerData.number
    contacts = pagerData.contacts
    messages = pagerData.messages
    currentMessage = #messages
end


--------------------------------------------------------------------------
-- Returns name or number if no contact found
--------------------------------------------------------------------------
function GetContactFromNumber(number)
    local contact = number
    for key, value in pairs(contacts) do
        if value.number == number then
            return value.name
        end
    end
    return contact
end

--------------------------------------------------------------------------
-- Increases or resets the indexer back to 1
--------------------------------------------------------------------------
function IncreaseIndex(index, tableCount)
    if index < tableCount then
        index = index + 1
    else
        index = 1
    end
    return index
end

--------------------------------------------------------------------------
-- Decreases or sets the indexer to tableCount
--------------------------------------------------------------------------
function DecreaseIndex(index, tableCount)
    if index > 1 then
        index = index - 1
    else
        index = tableCount
    end
    return index
end

--------------------------------------------------------------------------
-- Returns the opposite position of the indexer
--------------------------------------------------------------------------
function GetCurrentIndexReversed(index)
    local half = index / 2
    
    return index
end
--------------------------------------------------------------------------
-- Shows Messages
--------------------------------------------------------------------------
function ShowMessage(message)
    local text = "No Messages found :("
    local contact = ""
    local showReminder = false
    if message then
        contact = GetContactFromNumber(message.number)
        if not message.chatType then
            message.chatType = 'Private message'
        end
        text = string.format("Sender: %s,<br> %s Nr%s:</br> %s", contact, message.chatType, GetCurrentIndexReversed(currentMessage), message.text)
        if contact == message.number then
            showReminder = true
        end
    end
    SendNUIMessage({
        showReminder = showReminder,
        text = text,
        action = "pagerShowMessage"
    })
end

--------------------------------------------------------------------------
-- Shows Contact
--------------------------------------------------------------------------
function ShowContact(contact)
    local text = "No Contacts found :("
    local showReminder = false
    if contact then
        text = string.format("Name: %s<br>Number: %s", contact.name, contact.number)
        showReminder = true
    end
    SendNUIMessage({
        showReminder = showReminder,
        text = text,
        action = "pagerShowContact"
    })
    currentMessage = #messages + 1
end

--------------------------------------------------------------------------
-- Loads pager data after a player joined and finished loading
--------------------------------------------------------------------------
AddEventHandler('QBCore:Client:OnPlayerLoaded', function() 
    GetPagerData()
end)

--------------------------------------------------------------------------
-- Gets triggered, when the resource starts 
-- (examples: player joins server, script restart)
--------------------------------------------------------------------------
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    GetPagerData()
    lib.requestAnimDict(Config.Animations.usePager.dict)
    lib.requestAnimDict(Config.Animations.getPagerOutOfPocket.dict)
    lib.requestAnimDict(Config.Animations.putPagerInPocket.dict)
    lib.requestModel(Config.PagerObj)
end)

--------------------------------------------------------------------------
-- Shows received message when triggered
--------------------------------------------------------------------------
RegisterNetEvent("96rp-pager:pager:received", function(senderNumber, chatType, message)
    local contact = GetContactFromNumber(senderNumber)
	table.insert(messages, {
		number = senderNumber,
        chatType = chatType,
		text = message
	})
    SendNUIMessage({
        text = string.format("Sender: %s,<br> %s:</br> %s", contact, chatType, message),
        action = "pagerReceived"
    })
end)

--------------------------------------------------------------------------
-- Shows pager when opened 
-- (you need to trigger this event in your inventory system
--  when the pager is used)
--------------------------------------------------------------------------
RegisterNetEvent("96rp-pager:pager:show", function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        text = string.format("Welcome :)<br> Your number: %s", number),
        action = "pagerShowMessageSimple"
    })
    currentMessage = #messages + 1

    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then
        TriggerServerEvent('96rp-pager:server:PlayAnimation', true)
    end
    while not IsEntityPlayingAnim(playerPed, Config.Animations.getPagerOutOfPocket.dict, Config.Animations.getPagerOutOfPocket.name, 3) do
        Wait(100)
    end
    Wait(1000)
    local playerCoords = GetEntityCoords(playerPed)
    
    if DoesEntityExist(currentPagerObj) then
        DeleteEntity(currentPagerObj)
    end
    currentPagerObj = CreateObject(Config.PagerObj, playerCoords.x, playerCoords.y, playerCoords.z + 3, true, false, false)
    local boneIndex = GetPedBoneIndex(playerPed, 28422)

    local x = 0.0
    local y = 0.0
    local z = 0.0
    local rotX = 0.0
    local rotY = 0.0
    local rotZ = 0.0
    local p9 = false
    local useSoftPinning = false
    local collision = false
    local isPed = false
    local rotationorder = 2
    local syncRotation = true
    AttachEntityToEntity(currentPagerObj, playerPed, boneIndex, x, y, z, rotX, rotY, rotZ, p9, useSoftPinning, collision, isPed, rotationorder, syncRotation)
end)

--------------------------------------------------------------------------
-- Closes pager
--------------------------------------------------------------------------
RegisterNUICallback('dismissPager', function(data, cb)
    SetNuiFocus(false, false)
    local playerPed = PlayerPedId()
    while not IsEntityPlayingAnim(playerPed, Config.Animations.usePager.dict, Config.Animations.usePager.name, 3) do
        Wait(100)
    end
    StopAnimTask(playerPed, Config.Animations.usePager.dict, Config.Animations.usePager.name, 0.01)
    if not IsPedInAnyVehicle(playerPed, false) then
        TriggerServerEvent('96rp-pager:server:PlayAnimation', false)
    end
    Wait(Config.Animations.putPagerInPocket.time)
    if DoesEntityExist(currentPagerObj) then
        DeleteEntity(currentPagerObj)
    end
    cb('')
end)

--------------------------------------------------------------------------
-- Saves or Removes current contact
--------------------------------------------------------------------------
RegisterNUICallback('interactWithContact', function(pagerData, cb)
    if pagerData.interaction == "save" then
        local message = messages[currentMessage]
        table.insert(contacts, {
            name = pagerData.value,
            number = message.number
        })
        TriggerServerEvent('96rp-pager:server:SaveContact', pagerData.value, message.number)
        ShowMessage(message)
    elseif pagerData.interaction == "delete" then
        local contact = contacts[currentContact]
        table.remove(contacts, currentContact)
		TriggerServerEvent('96rp-pager:server:RemoveContact', contact.number)
        currentContact = 1
        local contactLeft = nil
        if #contacts > 0 then
            contactLeft = contacts[currentContact]
        end
        ShowContact(contactLeft)
    end
    cb("test")
end)

--------------------------------------------------------------------------
-- Shows Message
--------------------------------------------------------------------------
RegisterNUICallback('showMessageUp', function(data, cb)
    currentMessage = DecreaseIndex(currentMessage, #messages)
    local message = messages[currentMessage]
    ShowMessage(message)
    cb('')
end)

--------------------------------------------------------------------------
-- Shows Message
--------------------------------------------------------------------------
RegisterNUICallback('showMessageDown', function(data, cb)
    currentMessage = IncreaseIndex(currentMessage, #messages)
    local message = messages[currentMessage]
    ShowMessage(message)
    cb('')
end)

--------------------------------------------------------------------------
-- Shows contact
--------------------------------------------------------------------------
RegisterNUICallback('showContactLeft', function(data, cb)
    currentContact = DecreaseIndex(currentContact, #contacts)
    local contact = contacts[currentContact]
    ShowContact(contact)
    cb('')
end)

--------------------------------------------------------------------------
-- Shows contact
--------------------------------------------------------------------------
RegisterNUICallback('showContactRight', function(data, cb)
    currentContact = IncreaseIndex(currentContact, #contacts)
    local contact = contacts[currentContact]
    ShowContact(contact)
    cb('')
end)

--------------------------------------------------------------------------
-- Keyboard interaction for closing pager
--------------------------------------------------------------------------
RegisterKeyMapping('dismisspager', 'Dismiss a pager', 'keyboard', 'x')

--------------------------------------------------------------------------
-- Closes NUI command for bugs from other scripts
--------------------------------------------------------------------------
RegisterCommand("closeNUI", function(source, args, rawCommand)
	SetNuiFocus(false, false)
end, false)