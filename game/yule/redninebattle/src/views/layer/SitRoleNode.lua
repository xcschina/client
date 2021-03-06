--
-- Author: zhong
-- Date: 2016-07-14 17:42:14
--
--坐下玩家
local SitRoleNode = class("SitRoleNode", cc.Node)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local ClipText = appdf.req(appdf.EXTERNAL_SRC .. "ClipText")
local PopupInfoHead = appdf.req(appdf.EXTERNAL_SRC .. "PopupInfoHead")

function SitRoleNode:ctor( viewParent, index )
	self.m_parent = viewParent
	--加载csb资源
	local csbNode = ExternalFun.loadCSB("SitRoleNode.csb", self)
	self.m_csbNode = csbNode

	--背景特效
	self.m_spEffect = csbNode:getChildByName("sitdown_effect")
	self.m_spEffect:setVisible(false)

	--信息背景
	local infoBg = csbNode:getChildByName("player_info_1")
	infoBg:setLocalZOrder(1)

	--头像底部背景
	local tmp = csbNode:getChildByName("head_bg")
	self.m_headSize = tmp:getContentSize().width-6
	--tmp:removeFromParent()
	--头像框
	--[[self.m_headFrame = csbNode:getChildByName("downbk_1")
	self.m_headFrame:setLocalZOrder(1)--]]
	
	--游戏币
	self.m_textScore = csbNode:getChildByName("score_text")
	self.m_textScore:setLocalZOrder(1)

	--名字
	tmp = csbNode:getChildByName("name_text")
	self.m_clipNick = ClipText:createClipText(tmp:getContentSize(),"")
	self.m_clipNick:setPosition(tmp:getPosition())
	csbNode:addChild(self.m_clipNick)
	self.m_clipNick:setLocalZOrder(1)
	self.m_clipNick:setAnchorPoint(cc.p(0.5,0.5))
	tmp:removeFromParent()
	
	--归属地
	tmp = csbNode:getChildByName("ipLocation")
	self.m_clipIp = ClipText:createClipText(tmp:getContentSize(),"")
	self.m_clipIp:setPosition(tmp:getPosition())
	csbNode:addChild(self.m_clipIp)
	self.m_clipIp:setLocalZOrder(1)
	self.m_clipIp:setAnchorPoint(cc.p(0.5,0.5))
	tmp:removeFromParent()

	--庄家标示
	self.m_spBanker = csbNode:getChildByName("sp_banker")
	self.m_spBanker:setVisible(false)
	self.m_spBanker:setLocalZOrder(2)

	--分数
	self.m_atlasScore = csbNode:getChildByName("altas_score")
	self.m_atlasScore:setString("")
	self.m_atlasScore:setLocalZOrder(2)	

	self.m_nIndex = index
	self.m_spHead = nil

	--下注分数
	self.m_lJettonScore = {0,0,0,0,0,0}

	--飞行动画
	local moveBy = cc.MoveBy:create(1.0, cc.p(0, 50))
	local fadeout = cc.FadeOut:create(0.5)
	local call = cc.CallFunc:create(function( )
		self.m_atlasScore:setPositionY(-40)
	end)
	self.m_actShowScore = cc.Sequence:create(moveBy, fadeout, call)
	ExternalFun.SAFE_RETAIN(self.m_actShowScore)
end

function SitRoleNode:onSitDown( useritem, bAni, isBanker )
	if nil == useritem then
		return
	end
	isBanker = isBanker or false
	
	self:setVisible(true)
	self.m_wChair = useritem.wChairID
	self.m_szNickName = useritem.szNickName
	self.m_lJettonScore = {0,0,0,0,0,0}
	--坐下特效
	if bAni then
		local act = cc.Repeat:create(cc.Blink:create(1.0,1),5)
		self.m_spEffect:stopAllActions()
		self.m_spEffect:runAction(act)
	end	

	--头像
	if nil ~= self.m_spHead and nil ~= self.m_spHead:getParent() then
		self.m_spHead:removeFromParent()
	end
	local head = PopupInfoHead:createClipHead(useritem, 90,"head_mask.png")
	head:setPosition(0,23)
	--local head = PopupInfoHead:createNormalCircle(useritem, 60,("Circleframe.png"))
	if nil ~= head then
		self.m_csbNode:addChild(head)
		local size = cc.Director:getInstance():getWinSize()
		local pos = cc.p(size.width * 0.11+20, size.height * 0.33)
		local anchor = cc.p(self.m_nIndex / 4, 1.0)
		if self.m_nIndex == 1 then
			pos = cc.p(size.width * 0.11+30, size.height * 0.30)
			anchor = cc.p(self.m_nIndex / 4, 0)
		elseif self.m_nIndex == 2 then	
			pos = cc.p(size.width * 0.11+30, size.height * 0.53)
			anchor = cc.p(self.m_nIndex / 4, 0)
		elseif self.m_nIndex == 3 then	
			pos = cc.p(size.width * 0.595-30, size.height * 0.53)
			anchor = cc.p(self.m_nIndex / 4, 1.0)
		elseif self.m_nIndex == 4 then
			pos = cc.p(size.width * 0.595-30, size.height * 0.30)
			anchor = cc.p(self.m_nIndex / 4, 1.0)
		end
		
	--[[	if self.m_nIndex > 3 then			
			pos = cc.p(size.width * 0.595, size.height * 0.33)
		end

		if (self.m_nIndex == 1) or (self.m_nIndex == 4) then
			anchor = cc.p(self.m_nIndex / 4, 0)	
		end--]]
		head:enableInfoPop(true, pos, anchor)
		head:enableHeadFrame(false)
	end	

	self.m_spHead = head

	--昵称
	self.m_clipNick:setString("ID:"..useritem.dwGameID)
	
	--更新归属地
	local ipLocation = ""
	ipLocation = useritem.szAdressLocation

	self.m_clipIp:setString(ipLocation)
	--游戏币
	--[[local str = ExternalFun.formatScoreFloatText(useritem.lScore)
	--[[if string.len(str) > 11 then
		str = string.sub(str,1,11) .. "..."
	end--]]
	self.m_textScore:setString(str)
--]]
	--庄家
	self.m_spBanker:setVisible(isBanker)
end

function SitRoleNode:getChair(  )
	return self.m_wChair
end

function SitRoleNode:getNickName( )
	return self.m_szNickName
end

--获取坐下位置
function SitRoleNode:getIndex( )
	return self.m_nIndex
end

--下注分数设置
function SitRoleNode:addJettonScore(lScore, cbArea)
	if cbArea > 6 then
		return
	end
	self.m_lJettonScore[cbArea] = self.m_lJettonScore[cbArea] + lScore
end

--清空下注分数
function SitRoleNode:clearJettonScore()
	self.m_lJettonScore = {0,0,0,0,0,0}
end

function SitRoleNode:getJettonScoreWithArea(cbArea)
	return self.m_lJettonScore[cbArea]
end

function SitRoleNode:getJettonScore()
	return self.m_lJettonScore
end

--是否庄家
function SitRoleNode:updateBanker( isBanker )
	--庄家
	self.m_spBanker:setVisible(isBanker)
end

--游戏币动画、更新自己游戏币
function SitRoleNode:updateScore( lScore )
	if nil == lScore then
		return
	end
	--游戏币
	--[[local str = ExternalFun.formatScoreText(lScore)
	if string.len(str) > 11 then
		str = string.sub(str,1,11) .. "..."
	end
	self.m_textScore:setString(str)--]]
end

function SitRoleNode:gameEndScoreChange( useritem, changescore )
	self:updateScore(useritem.lScore + changescore)

	if 0 == changescore then
		return
	end

	self.m_atlasScore:setOpacity(255)

	local str = "." .. ExternalFun.numberThousands(changescore)
	if string.len(str) > 10 then
		str = string.sub(str,1,10) .. "///"
	end
	if changescore > 0 then
		--self.m_atlasScore:setProperty(str, "game_res/num_score_add.png", 14, 21, ".")
	elseif changescore < 0 then
		--self.m_atlasScore:setProperty(str, "game_res/num_score_plus.png", 14, 21, ".")
	end
	
	self.m_atlasScore:stopAllActions()
	self.m_atlasScore:runAction(self.m_actShowScore)
end

function SitRoleNode:reSet(  )
	self.m_textScore:setString("")
	self.m_wChair = nil
end

return SitRoleNode