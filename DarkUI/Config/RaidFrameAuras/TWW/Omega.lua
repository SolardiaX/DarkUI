local E, C, L = select(2, ...):unpack()

local TIER = 11
local INSTANCE = 1302 -- 法力熔炉：欧米伽

local BOSS
BOSS = 2684 -- 集能哨兵
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1218625) -- 错位矩阵
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1218669) -- 能量切割者
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1219248) -- 奥术辐射
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1219354) -- 潜能法力残渣
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1219439) -- 湮灭奥能重炮
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1219459) -- 具现矩阵
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1219531) -- 根除齐射
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1219607) -- 根除齐射
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1233110) -- 净化闪电
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1233449) -- 拿捏耗子
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1233999) -- 湮灭奥能重炮（DOT）

BOSS = 2686 -- 卢米萨尔
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1226311) -- 注能束缚
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1226366) -- 活体流丝
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1226721) -- 缠丝陷阱
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1227163) -- 蠕行波
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1227784) -- 奥术暴怒
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1237212) -- 贯体束丝
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1237307) -- 巢穴编织
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1243771) -- 奥能黏液
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1247045) -- 超能灌注

BOSS = 2685 -- 缚魂者娜欣达利
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1226827) -- 碎魂法球
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1227049) -- 虚空剑士奇袭
-- E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1227051) -- 虚空剑士奇袭
-- E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1248979) -- 虚空剑士奇袭
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1227052) -- 虚空爆炸
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1227276) -- 笞魂歼灭
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1237607) -- 秘法鞭笞
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1242086) -- 奥术能量
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1242088) -- 奥术驱除
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1249065) -- 魂火汇聚
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1250008) -- 碎裂脉冲

BOSS = 2687 -- 熔炉编织者阿拉兹
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1228188) -- 沉默风暴
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1228214) -- 星界收割
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1228506) -- 非凡力量
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1232775) -- 奥术抹消
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1232412) -- 聚焦之虹
-- E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1233979) -- 星界收割
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1234324) -- 光子轰击
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1236207) -- 星界涌动
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1238878) -- 回音风暴
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1240705) -- 星界灼烧
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1243901) -- 虚空收割

BOSS = 2688 -- 狩魂猎手
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1218103) -- 眼棱
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1221490) -- 邪能灼痕
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1222232) -- 吞噬者之怒
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1222307) -- 吞噬
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1222310) -- 无餍之饥
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1222310) -- 无餍之饥
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1223042) -- 邪能冲撞
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1225130) -- 邪能之刃
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1226493) -- 破碎之魂
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1227847) -- 恶魔追击
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1233105) -- 黑暗残渣
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1233381) -- 凋零烈焰
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1233968) -- 黑洞视界
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1235045) -- 湮灭逼近
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1241908) -- 破裂
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1241946) -- 脆弱
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1242284) -- 灵魂重碾

BOSS = 2747 -- 弗兰克提鲁斯
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1224414) -- 结晶震荡波
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1233411) -- 结晶震荡波
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1231871) -- 震波猛击
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1241137) -- 折射熵变
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1227373) -- 碎壳
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1227378) -- 水晶覆体
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1247424) -- 虚无吞噬
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1250600) -- 虚空闪电

BOSS = 2690 -- 节点之王萨哈达尔
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1224737) -- 誓言约束
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1224767) -- 侍王之奴
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1224795) -- 征服
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1224816) -- 主宰
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1225444) -- 灰飞烟灭
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1226042) -- 歼星新星
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1226362) -- 暮光创痕
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1226413) -- 身星俱碎
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1227470) -- 围攻
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1227549) -- 放逐
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1228056) -- 收割
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1228081) -- 节点光束
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1228114) -- 虚空击碎者
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1228196) -- 次元吐息
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1231097) -- 寰宇裂伤
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1234529) -- 宇宙之喉
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1234539) -- 维度眩光
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1252803) -- 自毁

BOSS = 2691 -- 诸界吞噬者迪门修斯
-- P1阶段
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1243609) -- 浮空
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1228206) -- 过量物质
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1230168) -- 凡躯的脆弱
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1228207) -- 集体引力
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1243577) -- 引力倒逆
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1243699) -- 空间碎片
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1231002) -- 黑暗能量
-- P1.5阶段
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1230674) -- 面条效应
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1237097) -- 天体物理射流
-- P2阶段
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1238773) -- 灭绝
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1239270) -- 虚空守护
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1237325) -- 伽马爆发
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1246145) -- 湮灭之触
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1246542) -- 虚无缠缚
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1237696) -- 碎片地带
-- P3阶段
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1234054) -- 暗影震荡
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1232394) -- 重力井
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1250055) -- 虚空之握
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1234266) -- 寰宇脆弱
-- 其他
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 1229325) -- 湮灭
