local _, addon = ...
local L = addon.L

local defaultConfig = {
  ["enable"] = true, -- 启动时启用
  ["autoExtend"] = true, -- 自动延长锁定
  ["checkInterval"] = 0.5, -- 检查间隔
  ["autoInvite"] = true, -- 密语进组
  ["autoInviteMsg"] = "123", -- 密语进组信息
  ["autoInviteBN"] = true, -- 战网密语进组
  ["autoInviteBNMsg"] = "123", -- 战网密语进组信息
  ["autoQueue"] = true, -- 进组申请排队
  ["maxWaitingTime"] = 30, -- 最长在组等待时间 (0 - 无限制)
  ["autoLeave"] = true, -- 检查成员位置并退组
  ["welcomeMsg"] = true, -- 进组时发送信息
  ["leaveMsg"] = true, -- 退组时发送信息
}

local autoLeavePlacesID = {
  766, -- 安其拉
  796, -- 黑暗神殿
  529, -- 奥杜尔
  604, -- 冰冠堡垒
  754, -- 黑翼血环
  773, -- 风神王座
  800, -- 火焰之地
  824, -- 巨龙之魂
  886, -- 永春台
  896, -- 魔古山宝库
  930, -- 雷电王座
  953, -- 决战奥格瑞玛
  988, -- 黑石铸造厂
  1026, -- 地狱火堡垒
}

local status = 0 -- 运行状态 0 - 未就绪 1 - 空闲 2 - 正在邀请 3 - 已经进组
local timeElapsed = 0 -- 上次检查时间间隔
local autoLeavePlaces = {}
local queue = {} -- 排队队列
local invitedTime -- 接受邀请的时间
local groupRosterUpdateTimes -- GROUP_ROSTER_UPDATE 触发次数

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("UPDATE_INSTANCE_INFO")
eventFrame:RegisterEvent("CHAT_MSG_WHISPER")
eventFrame:RegisterEvent("CHAT_MSG_BN_WHISPER")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("CHAT_MSG_PARTY")
eventFrame:SetScript("OnUpdate", function (self, ...)
  self.OnUpdate(self, ...)
end)
eventFrame:SetScript("OnEvent", function (self, event, ...)
	self[event](self, ...)
end)

function eventFrame:OnUpdate (elapsed)
  timeElapsed = timeElapsed + elapsed
  if FISConfig.enable and timeElapsed >= FISConfig.checkInterval then
    timeElapsed = 0
    if status == 1 then
      -- check queue
      if #queue > 0 then
        local name = queue[1]
        table.remove(queue, 1)
        self.inviteToGroup(self, name)
      end
    elseif status == 3 then
      -- check max waiting time
      if FISConfig.maxWaitingTime and time() - invitedTime >= FISConfig.maxWaitingTime then
        self.leaveGroup(self)
      end

      -- check player place
      if FISConfig.autoLeave then
        local _, _, _, _, _, _, zone = GetRaidRosterInfo(2);
        print("Get Player Zone: " .. zone)
        local flag, place = false
        for _, place in pairs(autoLeavePlaces) do
          if zone == place then
            flag = true
            break
          end
        end
        if flag then
          self.leaveGroup(self)
        end
      end
    end
  end
end

-- initialization
-- return nil
function eventFrame:init ()
  if status == 0 then
    local ID;
    for _, ID in pairs(autoLeavePlacesID) do
      table.insert(autoLeavePlaces, GetMapNameByID(ID))
    end
    self.printStatus(self)
    status = 1
  end
end

-- print current status and config to chatframe
-- return nil
function eventFrame:printStatus ()
  if FISConfig.enable then
    if status then
      print(L["MSG_PREFIX"] .. L["SHARE_STARTED"])
      print(L["AUTO_EXTEND"] .. (FISConfig.autoExtend and L["TEXT_ENABLE"] or L["TEXT_DISABLE"]))
      print(L["CHECK_INVAL"] .. FISConfig.checkInterval .. "s")
      print(L["AUTO_INVITE"] .. (FISConfig.autoInvite and L["TEXT_ENABLE"] or L["TEXT_DISABLE"]) .. " " .. string.format(L["AUTO_INVITE_MSG"], FISConfig.autoInviteMsg))
      print(L["AUTO_INVITE_BN"] .. (FISConfig.autoInviteBN and L["TEXT_ENABLE"] or L["TEXT_DISABLE"]) .. " " .. string.format(L["AUTO_INVITE_MSG"], FISConfig.autoInviteBNMsg))
      print(L["AUTO_QUEUE"] .. (FISConfig.autoQueue and L["TEXT_ENABLE"] or L["TEXT_DISABLE"]))
      print(L["MAX_TIME"] .. FISConfig.maxWaitingTime .. "s")
      print(L["AUTO_LEAVE"] .. (FISConfig.autoLeave and L["TEXT_ENABLE"] or L["TEXT_DISABLE"]))
      print(L["SHOW_WELCOME_MSG"] .. (FISConfig.welcomeMsg and L["TEXT_ENABLE"] or L["TEXT_DISABLE"]))
      print(L["SHOW_LEAVE_MSG"] .. (FISConfig.leaveMsg and L["TEXT_ENABLE"] or L["TEXT_DISABLE"]))
    else
      print(L["MSG_PREFIX"] .. L["SHARE_STARTING"])
    end
  else
    print(L["MSG_PREFIX"] .. L["SHARE_STOP"])
  end
end

-- add a player to queue
-- return nil - not enabled 0 - success 1 - fail(exists)
function eventFrame:addToQueue (name)
  if FISConfig.enable then
    if FISConfig.autoQueue then
      local flag, curr = false
      for _, curr in pairs(queue) do
        if curr == name then
          flag = true
          break
        end
      end
      if flag == false then
        SendChatMessage(string.format(L["QUEUE_MSG"], #queue + 1), "WHISPER", nil, name)
        table.insert(queue, name)
      end
      return not flag
    else
      self.inviteToGroup(self, name)
      return 0
    end
  end
end

-- invite player
-- return nil
function eventFrame:inviteToGroup (name)
  if FISConfig.enable then
    SetRaidDifficultyID(14) -- 普通难度
    SetLegacyRaidDifficultyID(4) -- 旧世副本难度25人普通
    ResetInstances()
    InviteUnit(name)
    if FISConfig.autoQueue then
      groupRosterUpdateTimes = 0
      status = 2
    else
      status = 1
    end
  end
end

-- mark invited
-- return nil
function eventFrame:playerInvited ()
  invitedTime = time()
  SendChatMessage(string.format(L["WELCOME_MSG"], FISConfig.maxWaitingTime), "PARTY")
  status = 3
end

-- mark rejected
-- return nil
function eventFrame:playerRejected ()
  status = 1
end

-- mark leaved
-- return nil
function eventFrame:playerLeaved ()
  status = 1
end

-- transfer leader and leave party
-- return nil
function eventFrame:leaveGroup ()
  if status == 3 then
    SendChatMessage(L["LEAVE_MSG"], "PARTY")
    -- set status first to prevent GROUP_ROSTER_UPDATE handle
    status = 1
    PromoteToLeader("party1")
    LeaveParty()
  end
end

function eventFrame:slashCmdHandler (message, editbox)
  -- TODO: not only change enable
  FISConfig.enable = not FISConfig.enable
  self.printStatus(self)
  -- DEBUG: print message
  print("Slash CMD Handler: " .. message)
end

function eventFrame:PLAYER_ENTERING_WORLD ()
  RequestRaidInfo()
  if not FISConfig then
    FISConfig = defaultConfig
  else
    local key, value
    for key, value in pairs(defaultConfig) do
      if not FISConfig[key] then
        FISConfig[key] = defaultConfig[key]
      end
    end
  end
end

function eventFrame:UPDATE_INSTANCE_INFO ()
  if FISConfig.enable and FISConfig.autoExtend then
    for i = 1, GetNumSavedInstances() do
      local _, _, _, _, _, extended = GetSavedInstanceInfo(i)
      if not extended then
        SetSavedInstanceExtend(i, true) -- 延长副本锁定
      end
    end
  end
  self.init(self)
end

function eventFrame:CHAT_MSG_WHISPER (...)
  if FISConfig.enable then
    local message, sender = ...

    local isInviteMsg = message == FISConfig.autoInviteMsg

    if FISConfig.autoInvite and isInviteMsg then
      self.addToQueue(self, sender)
    end
  end
end

function eventFrame:CHAT_MSG_BN_WHISPER (...)
  if FISConfig.enable then
    local message, _, _, _, _, _, _, _, _, _, _, _, presenceID = ...

    local _, _, _, _, _, bnetIDGameAccount = BNGetFriendInfoByID(presenceID)
    local _, characterName, _, realmName = BNGetGameAccountInfo(bnetIDGameAccount)

    local isInviteMsg = message == FISConfig.autoInviteBNMsg

    if FISConfig.autoInviteBN and isInviteMsg then
      self.addToQueue(self, characterName .. "-" .. realmName)
    end
  end
end

function eventFrame:GROUP_ROSTER_UPDATE ()
  -- NOTE: before inviting: 2 times, accepted or rejected: 1 times, leaving party: 3 times
  groupRosterUpdateTimes = groupRosterUpdateTimes + 1
  if groupRosterUpdateTimes > 2 then
    if status == 2 then
      if GetNumGroupMembers() > 1 then
        -- accepted
        self.playerInvited(self)
      else
        -- rejected
        self.playerRejected(self)
      end
    else if status == 3 then
      if GetNumGroupMembers() == 1 then
        -- player leaved
        self.playerLeaved(self)
      end
    end
  end
end

function eventFrame:CHAT_MSG_PARTY (...)
  local message = ...

  local isTenPlayer = string.find(message, "10")
  local isHeroic = string.find(message, "H") or string.find(message, "h")

  local RaidDifficulty = isHeroic and 15 or 14
  local LegacyRaidDifficulty = isHeroic and (isTenPlayer and 5 or 6) or (isTenPlayer and 3 or 4)

  SetRaidDifficultyID(RaidDifficulty)
  SetLegacyRaidDifficultyID(LegacyRaidDifficulty)
end

SLASH_FIS1 = "/fis"
SlashCmdList["FIS"] = function (...)
  eventFrame.slashCmdHandler(eventFrame, ...)
end
