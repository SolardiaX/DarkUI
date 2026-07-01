# DarkUI Skins — 面板测试清单

`DarkUI/Skins/Frames/` 下现有 **68 个换肤文件**(从 AuroraClassic 移植),本表是逐面板的游戏内验证清单。

> **总开关**:`C.skins.enable` 必须为真。每个面板另有独立子开关(下表「开关」列,均在 `Config/Settings.lua` 的 `C.skins` 表)。`parchment_remover` 是共享的羊皮纸移除子开关。

## 如何测试

1. `/console scriptErrors 1` 打开 Lua 报错弹窗(测换肤必开)。
2. `/reload` 后逐面板打开,**首要看是否弹 Lua 错误**(报错会带文件名+行号,直接定位)。
3. 每个面板的**通用回归**(见末尾「通用验证要点」)。
4. LoadOnDemand 面板(冒险指南、专业、拍卖行等)首次打开才加载并触发换肤——打开时留意首帧是否报错。

---

## A. 快捷键 / 常驻面板(登录即可测,最优先)

- [x] **角色装备** `Character.lua` — `C` — `character`:主窗口底/边、装备槽图标品质边、左侧分页标签、属性面板、模型旋转按钮
- [x] **天赋 / 法术书 / 专精** `PlayerSpells.lua` — `N` — `talent`:天赋树节点、法术书页、导入弹窗输入框
- [x] **通用天赋树** `GenericTrait.lua` — 自动随对应系统 — `talent`:节点/货币文字
- [x] **收藏(坐骑/宠物/玩具/外观/战团场景)** `Collectables.lua` — `Shift-P` — `collections`:5 标签、筛选箭头、列表填充式选中、图标品质边、玩具/传家宝品质边、套装模型框、战团场景翻页
- [x] **冒险指南** `EncounterJournal.lua` — `Shift-J` — `encounterjournal`:难度下拉、首领列表、战利品图标品质边、模型框
- [x] **成就** `Achievement.lua` — `Y` — `achievement`:分类侧栏、成就卡片、图标
- [x] **好友列表** `Friends.lua` — `O` — `friends`:标签、列表项、添加好友输入框
- [x] **公会与社区** `Communities.lua` — `J` — `communities`:成员列表、聊天框 inset、新建社区弹窗输入框、职业图标
- [x] **PVE 面板(寻找团队/副本)** `PVEFrame.lua` + `LFG.lua` + `LFGList.lua` — `I` — `lfg`:角色定位图标、奖励按钮图标品质边、自定义查找列表输入框
- [x] **PVP 面板** `PVP.lua` — `I` 内 PVP 页 — `pvp`:战场列表、荣誉/征服进度条
- [x] **大秘境记分板** `PVPMatch.lua` / `Challenges.lua` — 战场结束 / `M`→钥石 — `pvp` / `lfg`:记分行、词缀图标
- [x] **游戏菜单** `Menu.lua` — `Esc` — `misc`:菜单按钮底/边

## B. 主城 NPC / 容器交互

- [x] **商人** `Merchant.lua` — 任意商人 — `merchant`:物品槽图标、回购/标签
- [x] **邮箱** `Mail.lua` — 邮箱 — `mail`:收件箱列表、发信输入框(收件人/主题/金额)、附件槽
- [x] **交易** `Trade.lua` — 右键玩家→交易 — `trade`:交易槽图标、金额输入框
- [x] **拍卖行** `AuctionHouse.lua` — 拍卖师 — `auctionhouse`:数量/价格输入框、搜索栏、结果列表行、出价槽
- [x] **公会银行** `GuildBank.lua` — 公会银行 — `guildBank`:物品格、标签页、**标签图标选择弹窗**(`S:ReskinIconSelectionFrame`)
- [ ] **虚空仓库** `VoidStorage.lua` — 虚空仓库 NPC — `voidStorage`:存放/取出格、搜索框
- [ ] **黑市** `BlackMarket.lua` — 黑市拍卖师 — `blackMarket`:竞拍列表、出价框
- [x] **理发店** `Barber.lua` — 理发师 — `barber`:外观自定义按钮、滑块
- [ ] **物品升级** `ItemUpgrade.lua` — 升级 NPC — `itemUpgrade`:物品槽、升级条(预览 tooltip 保持原生外观,见已知项)
- [ ] **幻化** `Transmog.lua` — 幻化师 — `transmogrify`(+`parchment_remover`):外观格图标品质边、套装、武器下拉
- [ ] **拆解机** `ScrappingMachine.lua` — 拆解机 — `scrapping`:放入格图标
- [ ] **专业技能(操作台)** `Professions.lua` — 铁砧/炼金台 或 `P` — `tradeskill`(+`parchment_remover`):配方列表、配方图标、品质条、订单
- [ ] **专业技能书** `ProfessionsBook.lua` — `P` — `tradeskill`:专业图标
- [ ] **接单(公共订单)** `ProfessionsOrders.lua` — 制作订单台 — `tradeskill`:订单列表行
- [ ] **职业训练师** `Trainer.lua` — 训练师 — `trainer`:技能列表、训练按钮
- [ ] **兽栏(猎人)** `Stable.lua` — 兽栏管理员 — `stable`:宠物槽、模型控制
- [ ] **签名请愿(公会/竞技场)** `Petition.lua` — 请愿书道具 — `petition`
- [ ] **出租车(飞行点)** `Taxi.lua` — 飞行管理员 — `misc`:飞行点底图
- [ ] **职业护甲战袍** `Tabard.lua` — 战袍设计师 — `misc`:颜色选择、费用框
- [ ] **书信/物品文本** `ItemText.lua` — 阅读书籍/信件道具 — `misc`

## C. 玩家 / 物品 / 情景交互

- [x] **观察** `Inspect.lua` — 右键其他玩家→观察 — `inspect`:装备槽图标品质边
- [x] **试衣间** `DressingRoom.lua` — `Ctrl`+点击装备 / 右键预览 — `dressingroom`:模型框、套装弹窗
- [x] **NPC 对话** `Gossip.lua` — 有对话选项的 NPC — `gossip`:对话选项底
- [ ] **镶嵌宝石** `Socket.lua` — 右键带插槽装备 — `socket`:插槽图标(按宝石类型染边)、应用按钮
- [ ] **公会邀请弹窗** `GuildInvite.lua` — 被邀请入公会 — `guild`
- [ ] **公会注册** `GuildRegistrar.lua` — 公会管理员 — `guild`:输入框
- [ ] **公会控制** `GuildControl.lua` — 公会信息→公会控制 — `guild`:权限复选框、排名输入框
- [ ] **点击施法绑定** `Binding.lua` — 快速键位绑定入口 — `binding`
- [ ] **点击绑定 UI** `ClickBinding.lua` — 点击施法设置 — `misc`
- [ ] **准备确认弹窗** `ReadyCheck.lua` — 队伍发起准备确认 — `misc`
- [ ] **拾取掌控提示** `LossOfControl.lua` — 被眩晕/沉默时 — `misc`
- [ ] **死亡回顾** `DeathRecap.lua` — 死亡后点击回放 — `deathRecap`
- [ ] **鬼魂归位** `Ghost.lua` — 死亡为鬼魂时 — `misc`:渐变底
- [ ] **取色器** `ColorPicker.lua` — 任意打开取色对话框处 — `misc`
- [ ] **静态弹窗** `StaticPopup.lua` — 各类确认弹窗(删除物品/退组等)— `misc`:弹窗底/边、按钮、关闭 X、输入框

## D. 斜杠 / 小地图入口

- [ ] **宏命令** `Macro.lua` — `/macro` — `macro`:宏列表、**图标选择弹窗**
- [ ] **时间管理 / 秒表** `TimeManager.lua` — `/stopwatch` + 小地图时钟 — `timemanager`:秒表框、闹钟复选框/输入框
- [ ] **日历** `Calendar.lua` — 小地图日历图标 — `calendar`:月历格、事件、创建弹窗

## E. 资料片系统(需对应内容/区域可达;部分为旧版,addon 不加载则换肤不触发,属正常)

- [ ] **大秘宝宝库(Great Vault)** `WeeklyRewards.lua` — 主城宝库 NPC — `weeklyRewards`(+`parchment_remover`):奖励格(开/关 parchment 两态都看)
- [ ] **主要派系声望** `MajorFaction.lua` — 派系声望 UI — `majorFactions`
- [ ] **地下探秘(Delves)** `Delves.lua` — 仪表盘/同伴配置/难度选择器 — `lfg`:同伴技能图标、翻页
- [ ] **资料片登陆页** `ExpansionLanding.lua` — 资料片登陆页入口 — `expansionLanding`
- [ ] **要塞 / 职业大厅** `Garrison.lua` — 要塞/职业大厅 — `garrison`:随从列表、任务页图标(*WoD/Legion 内容*)
- [ ] **灵魂羁绊** `Soulbinds.lua` — 灵魂羁绊 UI — `soulbinds`(*暗影国度*)
- [ ] **盟约(预览/圣所/声望)** `Covenant.lua` — 盟约 UI — `covenant`(*暗影国度*)
- [ ] **神器(传承)** `Artifact.lua` — 神器 UI — `artifact`(*军团再临*)
- [ ] **艾泽里特(项链/精华/物品交互)** `Azerite.lua` — 艾泽里特 UI — `azerite`(*争霸艾泽拉斯*)
- [ ] **考古** `Archaeology.lua` — 考古 UI — `archaeology`:翻页箭头
- [ ] **盟约种族** `AlliedRaces.lua` — 盟约种族 UI — `alliedRaces`
- [ ] **时空漫游(Chromie Time)** `ChromieTime.lua` — Chromie NPC — `chromieTime`
- [ ] **交易站(Perks Program)** `PerksProgram.lua` — 交易站 — `perksProgram`:商品卡片、图标
- [ ] **奥尔多瑞姆/符文重铸** `Obliterum.lua` / `Runeforge.lua` — 对应工作站 — `obliterum` / `runeforge`(预览 tooltip 保持原生,见已知项)

---

## 通用验证要点(每个面板都过一遍)

- [ ] **无 Lua 报错**:打开/翻页/筛选/选中时都不弹错(`scriptErrors 1`)。
- [ ] **主窗口质感统一**:不透明底 + 渐变 + 外阴影 + 边框(对齐 Merchant/角色装备);子面板/inset 透明观感。
- [ ] **无残留原生美术**:暴雪原生金边/羊皮纸/插槽边/高亮已被清除或替换。
- [ ] **图标品质边**:有品质概念的图标(物品槽/战利品/玩具/传家宝/外观)边框为对应品质色,且紧贴 icon。
- [ ] **滚动条 / 翻页箭头 / 下拉 / 输入框 / 复选框**:均为 DarkUI 样式,位置不错位。
- [ ] **标签页**:选中态文字/底色正确,不偏移。

## 已知项 / 边界

- **预览 Tooltip 未换肤**:`ItemUpgrade.lua` 与 `Runeforge.lua` 的预览 tooltip 框保持原生外观(Aurora `B.ReskinTooltip` 无对应 `S:` facade,标记 TODO,非报错)。
- **Modules 自有不在本表**:背包、Tooltip、世界地图、目标追踪、警报、对话气泡、拾取、聊天、任务、团队框体由 `DarkUI/Modules/` 负责,未从 Aurora 移植。
- **共用开关**:Delves/Challenges/PVE/LFG 共用 `lfg`;GuildInvite/GuildRegistrar/GuildControl 共用 `guild`;Professions/ProfessionsBook/ProfessionsOrders 共用 `tradeskill`;PlayerSpells/GenericTrait 共用 `talent`;多个 utility 共用 `misc`。
- **旧资料片面板**:Garrison/Soulbinds/Covenant/Artifact/Azerite 等针对已过期内容,12.0 下对应 addon 通常不加载,换肤不触发——非缺陷。
