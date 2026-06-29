# DarkUI Skins — 面板测试清单

当前 `DarkUI/Skins/Frames/` 下全部 **32 个换肤文件**及其游戏内测试方式,按「打开路径」分组,方便成批验证。

> 总开关:`C.skins.enable` 必须为真;每个面板另有独立子开关(下表「开关」列,均在 `Config/Settings.lua` 的 `skins` 表)。`parchment_remover` 是羊皮纸移除子开关,与主开关并存。

## A. 快捷键直接打开(最快,登录后即可测)

| 面板 | 文件 | 打开方式 | 开关 |
|---|---|---|---|
| 角色装备 | Character.lua | `C` | `character` |
| 天赋/法术书/专精 | PlayerSpells.lua | `N` | `talent` |
| 收藏(坐骑/宠物/玩具/外观) | Collectables.lua | `Shift-P` | `collections` |
| 冒险指南 | EncounterJournal.lua | `Shift-J` | `encounterjournal` |
| 好友列表 | Friends.lua | `O` | `friends` |
| 公会与社区 | Communities.lua | `J` | `communities` |
| 寻找团队/副本 | LFG.lua | `I` | `lfg` |
| PVP 面板 | PVP.lua | `H`(荣誉)/ `I` 内 PVP 页 | `pvp` |

## B. 斜杠命令打开

| 面板 | 文件 | 命令 | 开关 |
|---|---|---|---|
| 宏命令 | Macro.lua | `/macro` | `macro` |
| 秒表/时间管理 | TimeManager.lua | `/stopwatch`(秒表)+ 小地图时钟(闹钟) | `timemanager` |
| 日历 | Calendar.lua | 小地图日历图标 | `calendar` |

## C. 主城固定 NPC 交互

| 面板 | 文件 | NPC | 开关 |
|---|---|---|---|
| 拍卖行 | AuctionHouse.lua | 拍卖师 | `auctionhouse` |
| 商人 | Merchant.lua | 任意商人 | `merchant` |
| 邮箱 | Mail.lua | 邮箱 | `mail` |
| 理发店 | Barber.lua | 理发师 | `barber` |
| 物品升级 | ItemUpgrade.lua | 物品升级 NPC(如 Zskera) | `itemUpgrade` |
| 幻化 | Transmog.lua | 幻化师 | `transmogrify`(+`parchment_remover`) |
| 职业训练师 | Trainer.lua | 职业训练师 | `trainer` |
| 兽栏(猎人) | Stable.lua | 兽栏管理员 | `stable` |
| 专业技能(操作台/工作站) | Professions.lua | 铁砧/炼金台等,或按 `P` | `tradeskill`(+`parchment_remover`) |
| 专业技能书 | SpellBook.lua | 专业技能书入口 | `spellbook`(+`parchment_remover`) |

## D. 玩家 / 物品 / 情景交互

| 面板 | 文件 | 触发 | 开关 |
|---|---|---|---|
| 观察 | Inspect.lua | 右键其他玩家头像 → 观察 | `inspect` |
| 交易 | Trade.lua | 右键玩家 → 交易 | `trade` |
| 试衣间 | DressingRoom.lua | `Ctrl`+点击装备 / 右键预览 | `dressingroom` |
| NPC 对话 | Gossip.lua | 与有对话选项的 NPC 交互 | `gossip` |
| 镶嵌宝石 | Socket.lua | 右键带插槽的装备 | `socket` |
| 公会邀请弹窗 | Guild.lua | 被邀请入公会时弹出(需他人邀请) | `guild` |
| 点击施法绑定 | Binding.lua | 点击施法绑定设置入口 | `binding` |
| 右键下拉菜单 | Menu.lua | 任意右键上下文菜单 | `misc` |

## E. 版本特定场景(较难即时复现)

| 面板 | 文件 | 触发 | 开关 |
|---|---|---|---|
| 大秘宝宝库(Great Vault) | WeeklyRewards.lua | 主城宝库 NPC(每周维护后有奖励时最完整) | `weeklyRewards`(+`parchment_remover`) |
| 主要派系声望 | MajorFaction.lua | 派系声望 UI(对应资料片区域) | `majorFactions` |
| 地下探秘(Delves) | Delves.lua | Delves 仪表盘 / 难度选择器(需当前资料片) | `lfg` |

---

## 测试要点

- **统一通用回归**:每个面板看主窗口是否为 **不透明底 + 渐变 + 外阴影 + regular 边**(对齐 Merchant/Macro);子面板/inset 应为透明观感。
- **品质边全局统一**(已改 `S:HandleIconBorder`):品质边应为纹理边并紧贴 icon。重点看 **专业 / 大秘宝 / 观察 / 冒险指南 / 收藏 / 探秘 / 试衣间 / 拍卖行**;camp B(商人/邮件/角色装备/物品升级/交易)应保持原样无回归。
- **hint /「?」按钮**(`disableTutorialButtons=true`):逐面板确认无残留。
- **主窗口统一 Plan**(`vectorized-sleeping-eagle.md`):涉及 **物品升级 / 日历 / 主要派系 / 大秘宝**,其中大秘宝需 **parchment_remover 开/关两种状态都测**。

## 备注

- Collectables 还含 `campsites` / `tooltip` 子开关(其它特性);主换肤由 `collections` 控制。
- Delves 与 LFG 共用 `C.skins.lfg`。
- Professions / SpellBook / Transmog / WeeklyRewards 各有专属主开关,`parchment_remover` 为共享的羊皮纸移除子开关。
