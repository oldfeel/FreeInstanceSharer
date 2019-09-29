if GetLocale() ~= "zhCN" then return end

local FIS, L = unpack(select(2, ...))

L["Auto Entering Queue"] = "自动进入队列"
L["Auto Extend Saved Instance"] = "自动延长副本锁定"
L["Auto Invite by Battle.net Whisper Message"] = "战网密语自动邀请信息"
L["Auto Invite by Battle.net Whisper"] = "战网密语自动邀请"
L["Auto Invite by In-game Whisper Message"] = "密语自动邀请信息"
L["Auto Invite by In-game Whisper"] = "密语自动邀请"
L["Auto Leave Group"] = "检查成员位置并自动退组"
L["Check Queue Interval (ms)"] = "检查时间间隔（毫秒）"
L["Debug Mode"] = "调试模式"
L["Entering Queue Message"] = "进入队列信息"
L["Fail to fetch your character infomation from Battle.net, please try to whisper to NAME in game."] = "无法从战网获取你的角色信息，请尝试游戏内密语 NAME 。"
L["Fetch Error Message"] = "战网获取错误信息"
L["Free Instance Sharer"] = "便利CD分享"
L["General settings"] = "通用设定"
L["Invite Only Mode"] = "极简模式"
L["Leave Message"] = "退组信息"
L["Leave Queue Message"] = "离开队列信息"
L["Leave Queue by In-game Whisper Message"] = "密语离开队列信息"
L["Leave Queue by In-game Whisper"] = "密语离开队列"
L["MTIME - Max time to wait players to enter instances."] = "MTIME - 最长等待进本时间。"
L["Max Waiting Time (s)"] = "最长等待进本时间（秒）"
L["NAME - The name and realm of current character."] = "NAME - 当前角色的玩家名与服务器名。"
L["Notify Message"] = "提示信息"
L["Open config"] = "开启设置"
L["Prevent AFK"] = "防暂离"
L["Promoted you to team leader. If you're in Icecrown Citadel, you need to set to Heroic by yourself."] = "已将队长转交，如果副本为冰冠堡垒，请自行在副本内修改难度为英雄。"
L["QCURR - The position of the player in queue."] = "QCURR - 当前玩家在队列的位置。"
L["QLEN - The length of the queue."] = "QLEN - 队列长度。"
L["Query Message"] = "查询队列信息"
L["Welcome Message"] = "进组信息"
L["You can insert following words into the text field, and it will be replace by corresponding variables."] = "信息中可以含有以下字符串，发送时将被自动替换为对应的变量。"
L["You have MTIME second(s) to enter instance. Difficulty set to 25 players normal in default. Send '10' in party to set to 10 players, 'H' to set to Heroic."] = "你现在有 MTIME 秒的进本时间。默认难度为25人普通，在队伍发送 10 切换为10人模式，发送 H 切换为英雄模式。"
L["You're queued, and your postion is QCURR."] = "你已进入队列，排在第 QCURR 名。"
