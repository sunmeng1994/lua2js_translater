// /*
//  *游戏主逻辑
//  */
// var gg = window.gg;
// var dd = window.dd;
var CardDef = require('CardDef').cardDef;
var GameShareDef = require('GameShareDef');
const gCore = window.gCore;
const def = gCore.def;
const ut = gCore.ut;
const Utils = require('Utils');


// //起始手牌
// var FIRST_HANDCARD_COUNT = 25;
// //最大底牌数目
// var MAX_HIDECARD_COUNT = 10;
// var CardVector = [];
// var CardsVector = [];


var GameLogic = function() {

	this.SplitedCardsTag = {
	    ["Singles"] = [],
		["Pairs"] = [],
		["Triples"] = [],
		["Tractors2"] = [],
		["Tractors3"] = [],
	}

	this.AnalyzedCardsTag = {
	    ["Singles"] = [],
		["Pairs"] = [],
		["Triples"] = [],
		["Tractors2"] = [],
		["Tractors3"] = [],
	}

	this.SignalDataTag = {
	    ["signalDirect"] = [],
		["signalKing"] = [],
		["bBigOnTop"] = false,
		["bFlowerOnTop"] = false,
	}

	this.Pair = {
	    ["first"] = -1
	    ,["seccond"] = -1
	}

	this.GameEndResult = {
	    ["score"] = [],//roleid 从一开始
	    ["hideCards"] = {};
	    ["hideCardsTimes"] = 0,
	    ["hideScore"] = 0,
	    ["gameScore"] = 0,
	    ["punishScore"] = 0,
	}

	this.FIRST_HANDCARD_COUNT              = 25             // 起始手牌;
	this.MAX_HIDECARD_COUNT                = 10             // 最大底牌个数;
	this.bCallCardWithKing = false                 // 是否带王叫主;
	this.PackCount = 2                             // 几副牌;
	this.MainColor = 0                             // 主牌花色;
	this.MainValue = 0                             // 级牌的值;
	 //GameLogic._HideCardCount = 8                         // 底牌的个数;
	this.TotalCards = []                           //所有的牌;
	this.MainColor = CardDef.CARD_COLOR_NULL               //无效花色;
	this.SortWeight = []                           //花色的权重（注意索引从0开始）;
	this.HideCardsCount = 0                        //埋牌的数量;
	//this.MainColor = nil;

	this.CreatePair= function()
	{
		var pair = self.Pair.concat();
		return pair;
	};

	this.CreateGameEnd= function()
	{
		var _a = self.GameEndResult.concat();
		return _a;
	};
	 //[[;
	// 创建SplitedCards Table;
	// 参数：无;
	// 返回值：无;
	 //]];
	this.CreateSplitedCardsTable= function(_a)
	{
		if(_a != nil){
			_a.Singles = [];
			_a.Pairs = [];
			_a.Triples = [];
			_a.Tractors2 = [];
			_a.Tractors3 = [];
			return;
		}
		var tmpSplitedCardsTable = self.SplitedCardsTag.concat();
		return tmpSplitedCardsTable;
	};


	 //[[;
	// 创建AnalyzedCards Table;
	// 参数：无;
	// 返回值：无;
	 //]];
	this.CreateAnalyzedCardsTable= function()
	{
		var tmpAnalyzedCardsTable = self.AnalyzedCardsTag.concat();
		return tmpAnalyzedCardsTable;
	};
	 //[[;
	// 创建SignalData Table;
	// 参数：无;
	// 返回值：无;
	 //]];
	this.CreateSignalDataTable= function()
	{
		var tmpSignalDataTable = self.SignalDataTag.concat();
		return tmpSignalDataTable;
	};
	 //[[;
	// 创建 设置几副牌，并设置所有牌;
	// 参数：无;
	// 返回值：无;
	 //]];
	this.SetPackCount= function(count)
	{
		if(0 == count||3 < count){
			count = 2;
		}

		if(this.PackCount != count){
			this.PackCount = count;
			for(var i =0;i <this.PackCount ;i ++){
				for(var j=0;j<CardDef._cardData.length;j++)
				{
					this.TotalCards.push(CardDef._cardData[j]);
				}       
			}        
		}
	};
	this.GetPackCount= function()
	{
		return this.PackCount;
	};

	//  //洗牌;
	// this.ShuulfCards= function(_getShffleCards)
	// {
	// 	_getShffleCards = [];
	// 	math.randomseed(os.time());

	// 	var randPos = 0;;
	// 	for(var i =0;i <this.TotalCards.length;i ++){
	// 		randPos = math.random(1,#this.TotalCards);
	// 		_getShffleCards[i] = this.TotalCards[randPos];
	// 		this.TotalCards[randPos] = this.TotalCards[#this.TotalCards - (i-1)];
	// 		this.TotalCards[#this.TotalCards - (i-1)] = _getShffleCards[i];
	// 	}
		
	// };

	 //更新花色权重;
	this.UpdateSortWeight= function()
	{
		this.SortWeight[CardDef.CARD_COLOR_NULL] = 0;
		 //王牌花色;
		this.SortWeight[CardDef.CARD_COLOR_JOKER/16] = 5 * GameShareDef.CARD_COLOR_SORT_WEIGHT;
		var j = 1;
		for(var i =0;i <4;i ++){
			if(i * 16 != this.MainColor){
				this.SortWeight[i] = GameShareDef.CARD_COLOR_SORT_WEIGHT * j;
				j = j + 1;
			}
			else
			{
				this.SortWeight[this.MainColor/16] = 4 * GameShareDef.CARD_COLOR_SORT_WEIGHT;
			}
		}
		
		if(this.MainColor == CardDef.CARD_COLOR_MEI_HUA){
			var tmp = this.SortWeight[CardDef.CARD_COLOR_HONG_TAO/16];;
			this.SortWeight[CardDef.CARD_COLOR_HONG_TAO/16] = this.SortWeight[CardDef.CARD_COLOR_HEI_TAO/16];
			this.SortWeight[CardDef.CARD_COLOR_HEI_TAO/16] = tmp;

		}else if( this.MainColor == CardDef.CARD_COLOR_HONG_TAO)
		{
			var tmp = this.SortWeight[CardDef.CARD_COLOR_FANG_KUAI/16];;
			this.SortWeight[CardDef.CARD_COLOR_FANG_KUAI/16] = this.SortWeight[CardDef.CARD_COLOR_MEI_HUA/16];
			this.SortWeight[CardDef.CARD_COLOR_MEI_HUA/16] = tmp;
		}
	};



	 //设置主花色;
	this.SetMainColor= function(color)
	{
		if(color != this.MainColor){
			this.MainColor = color;
			this.UpdateSortWeight();
		}
	};
	 //[[;
	// 获取级牌值;
	// 参数：无;
	// 返回值：级牌;
	 //]];
	this.GetMainValue= function()
	{
		return this.MainValue;
	};

	 //[[;
	// 获取主牌花色;
	// 参数：无;
	// 返回值：主牌花色;
	 //]];
	this.GetMainColor= function()
	{
		return this.MainColor;
	};
	 //[[;
	// 获取是否带王叫主;
	// 参数：无;
	// 返回值：是否带王叫主;
	 //]];
	 // //-从这里开始写;
	this.IsCallCardWithKing= function()
	{
		return this.bCallCardWithKing ;
	};

	 //[[;
	// 设置是否带王叫主;
	// 参数：是否带王叫主;
	// 返回值：无;
	 //]];
	this.SetCallCardWithKing= function(bCallWithKing)
	{
		this.bCallCardWithKing = bCallWithKing;
	};

	 //得到逻辑花色;
	this.GetLogicColor= function(card)
	{
		if(card == CardDef.CARD_BJOKER||
		   card == CardDef.CARD_RJOKER||
		   this.GetCardColor(card) == this.MainColor||
		   this.GetCardValue(card) == this.MainValue)
		{
			return GameShareDef.LOGIC_CARD_COLOR_MAIN;
		}

		if(this.GetCardColor(card) ==  CardDef.CARD_COLOR_FANG_KUAI){
			return GameShareDef.LOGIC_CARD_COLOR_FANG_KUAI;
		}

		if(this.GetCardColor(card) == CardDef.CARD_COLOR_MEI_HUA){
			return GameShareDef.LOGIC_CARD_COLOR_MEI_HUA;
		}

		if(this.GetCardColor(card) == CardDef.CARD_COLOR_HONG_TAO){
			return GameShareDef.LOGIC_CARD_COLOR_HONG_TAO;
		}

		if(this.GetCardColor(card) == CardDef.CARD_COLOR_HEI_TAO){
			return GameShareDef.LOGIC_CARD_COLOR_HEI_TAO;
		}

		return GameShareDef.LOGIC_CARD_COLOR_NULL;
	};

	 //[[;
	// 比较两组牌;
	// @parm	cards0			牌组0 - table;
	// 		turnwincard		当前轮最大的牌	- number;
	// 		turncardtype	当前轮牌型;
	// 		throwcards		排序后的首出牌;
	// 		linkFirst		 // ;
	// @return	1 	表示牌组0大于牌组1;
	// 		-1	表示牌组0小于牌组2;
	// 		nil	表示两组牌型不一致;
	// ]];
	this.compareCards= function(cards0, turnwincard, turncardtype, throwcards, linkFirst)
	{
		if(this.GetCardsType(cards0) != turncardtype){
			return;
		}
		
		this.SortCards(cards0, false);
		var ret = false;
		
		if(turncardtype == GameShareDef.CARD_TYPE_NULL){
			return;
		}
		else if(turncardtype == GameShareDef.CARD_TYPE_SINGLE ||
				turncardtype == GameShareDef.CARD_TYPE_TRACTOR_2 ||
				turncardtype == GameShareDef.CARD_TYPE_SAME_2 or||
				turncardtype == GameShareDef.CARD_TYPE_TRACTOR_3)
		{
			ret = this.CompareCardSingle(turnwincard, cards0[0]);
		}
		else if( turncardtype == GameShareDef.CARD_TYPE_THROW_CARD){
			var card1color = this.GetLogicColor(turnwincard);
			if(card1color != GameShareDef.LOGIC_CARD_COLOR_MAIN&&turncardtype != GameShareDef.CARD_TYPE_NULL&&this.GetLogicColor(cards0[1]) == GameShareDef.LOGIC_CARD_COLOR_MAIN){
				flagValue = [];
				flagValue.flagValue = 0;
				
				if(this.CheckAllThrowCardTypeFit(throwCards, cards0, flagValue, linkFirst))
				{
					if	this.GetLogicColor(turnwincard) != GameShareDef.LOGIC_CARD_COLOR_MAIN or
						(this.GetLogicColor(turnwincard) == GameShareDef.LOGIC_CARD_COLOR_MAIN and
						this.GetCardLogicValue(flagValue.flagValue) > this.GetCardLogicValue(flagValue.flagValue))
					{
						ret = false;
					}
				}
			}
		}
		
		if(ret == true)
		{ 
			return 1
		}
		else if( ret == false)
		{ 
			return -1
		}
	};

	 //;
	this.CalcuStepTurn= function(value)
	{
		return Math.floor((value-2)/13);
	};
	 //设置级数;
	this.SetMainValue= function(value)
	{
		this.MainValue = this.CalcuStepValue(value);
	};

	 //得到牌的权值;
	this.GetCardSortValue= function(card)
	{
		var color = this.GetCardColor(card);
		var value = this.GetCardValue(card);

		var sortValue = 0;
		if(value > CardDef.CARD_VALUE_K){
			sortValue = value + 20;
	   	}else{
			sortValue = value;
	    }

		var sortIndex = color/16; 
		if(value != this.MainValue){
			if(value == CardDef.CARD_VALUE_A){
				sortValue = sortValue + 13;
			}
			sortValue = sortValue + this.SortWeight[sortIndex];
		}else{
			if(this.MainColor != CardDef.CARD_COLOR_NULL){
				sortValue = this.SortWeight[sortIndex]/GameShareDef.CARD_COLOR_SORT_WEIGHT + 14 + this.SortWeight[this.MainColor/16];
			}else{
				sortValue = this.SortWeight[sortIndex]/GameShareDef.CARD_COLOR_SORT_WEIGHT + 14 + this.SortWeight[5];
			}
		}

		return sortValue;
	};
	 //得到牌的逻辑值;
	this.GetCardLogicValue= function(card)
	{
		var cardValue = this.GetCardValue(card);;
		var cardColor = this.GetCardColor(card);;

		var logicValue = 0;;
		if(CardDef.CARD_BJOKER == card){
			if(CardDef.CARD_COLOR_JOKER == this.MainColor){
				logicValue = 15;
			}else{
				logicValue = 16;
			}
		}else if( CardDef.CARD_RJOKER == card){
			if(CardDef.CARD_COLOR_JOKER == this.MainColor){
				logicValue = 16;
			}else{
				logicValue = 17;
			}
		}else if( cardValue != this.MainValue){
			if(this.MainValue == CardDef.CARD_VALUE_A){
				logicValue = cardValue;
			}else if( cardValue == CardDef.CARD_VALUE_A){
				logicValue = 13;
			}else if( cardValue < this.MainValue){
				logicValue = cardValue;
			}else{
				logicValue = cardValue - 1;
			}
		}else{
			if((this.MainColor == CardDef.CARD_COLOR_JOKER)){
				logicValue = 14;;
			}else if( (cardColor != this.MainColor)){
				logicValue = 14;;
			else ;
				logicValue = 15;;
			}
		}

		return logicValue;
	};



	 //得到牌的类型;
	this.GetCardsType= function(_sortCards)
	{
		// if(type(_sortCards) != "table"){
		// 	return GameShareDef.CARD_TYPE_NULL;
		// }

		if(1 == _sortCards.length){
			return GameShareDef.CARD_TYPE_SINGLE;
		}

		if(_sortCards[0] == _sortCards[_sortCards.length-1]){
			if(2 == _sortCards.length){
				return GameShareDef.CARD_TYPE_SAME_2;
			}
			if(3 == _sortCards.length){
				return GameShareDef.CARD_TYPE_SAME_3;
			}
		   
			return GameShareDef.CARD_TYPE_NULL;
		}

		var firstCardLogicColor = this.GetLogicColor(_sortCards[1]);;
		var sameCount = 0;;
		for(var i=0;i<v .length;i++){
			v =_sortCards[i]
			if(_sortCards[1] == v){
				sameCount = sameCount + 1;
			}else if( this.GetLogicColor(v) != firstCardLogicColor){
				return GameShareDef.CARD_TYPE_NULL;
			}
		}
		
		 //拖拉机;
		if(2 <= sameCount&&_sortCards.length%sameCount == 0){
			var tractorCount = _sortCards.length / sameCount;;
			 //判断是否相连;
			var isTractor = true;
			for(var i=0;i<tractorCount;i++){          
				
				var index = i * sameCount - (1);;
			   
				if(index+1 > _sortCards.length){
					break;
				}
				if(_sortCards[index] != _sortCards[index + 1]){
					isTractor = false;
					break;
				}
				if(index+sameCount > _sortCards.length){
					break;
				}
				var leftValue = this.GetCardLogicValue(_sortCards[index]);;
				var rightValue = this.GetCardLogicValue(_sortCards[index+sameCount]);;
				if(rightValue - leftValue != -1){
					isTractor = false;
					break;
				}
			}

			if(isTractor){
				if(2 == sameCount){
					return GameShareDef.CARD_TYPE_TRACTOR_2;
				}
				if(3 == sameCount){
					return GameShareDef.CARD_TYPE_TRACTOR_3;
				}
				return GameShareDef.CARD_TYPE_NULL;
			}                
		}

		return GameShareDef.CARD_TYPE_THROW_CARD;
	};

	 //;
	this.GetCardFitValue= function(card)
	{
		var cardColor = this.GetCardColor(card);
		var cardValue = this.GetCardValue(card);
		var fitIndex = cardColor /16;
		var fitValue = 0;
		if(cardValue > CardDef.CARD_VALUE_K){
			fitValue = cardValue + 5;
		}else{
			fitValue = cardValue;
		}

		if(cardValue != this.MainValue){
			if(cardValue == CardDef.CARD_VALUE_A){
				fitValue = fitValue + 13;
			}else if( cardValue < this.MainValue||this.MainValue == CardDef.CARD_VALUE_A){
				fitValue = fitValue + 1;
			}
		}else{
			fitValue = this.SortWeight[fitIndex] / GameShareDef.CARD_COLOR_SORT_WEIGHT + 14;
		}

		if(this.GetLogicColor(card) == GameShareDef.LOGIC_CARD_COLOR_MAIN){
			fitValue = fitValue + this.SortWeight[4];
		}else{
			fitValue = fitValue + this.SortWeight[fitIndex];
		}

		return fitValue;
	};
	 //有没有这种花色的牌;
	this.HasCard= function(_cards,lc)
	{
		// if("table" != type(_cards)){
		// 	return false;
		// }

		for(var i=0;i<v .length;i++){
			v =_cards[i]
			if(this.GetLogicColor(v) == lc){
				return true;
			}
		}
		
		return false;
	};
	 //得到这种花色的个数;
	this.GetCardCount= function(_cards,lc)
	{
		// if("table" != type(_cards)){
		// 	return false;
		// }

		var count = 0;;
		var isBegin = 1;

		for(var i=0;i<_cards.length;i++)
		{
			var k=i;
			var v=_cards[k];
			if(this.GetLogicColor(v) == lc){
				isBegin = 2;
				count = count + 1;
			}else if( 2 == isBegin){
				break;
			} 
		}

		// for(var i=0;i<v .length;i++){
		// 	v =_cards[i]

		// }          
		
		return count ;
	};

	 //是否有相同的两张牌;
	this.HasSame2= function(_cards,lc)
	{
		// if("table" != type(_cards)){
		// 	return false;
		// }

		if(_cards.length < 2){
			return false;
		}

		var card = _cards[0];;
		for(var i=1;i<_cards.length;i++){
			if(this.GetLogicColor(_cards[i]) == lc&&card == _cards[i]){
				return true;
			}

			card = _cards[i];
		}
		
		return false;
	};
	 //该花色两两相同的有几个;
	this.GetSame2Count= function(_cards,lc)
	{
		// if("table" != type(_cards)){
		// 	return false;
		// }

		var count = 0;;
		var index = -1;;
		for(var i=0;i<_cards.length;i++){
			if(this.GetLogicColor(_cards[i]) == lc){
				index = i;
				break;
			}
			 //index = index + 1;
		}

		if(-1 == index){
			return 0;
		}
		
		var prev = CardDef.CARD_NULL;;
		var sameCnt = 0;
		for(i = index;i<_cards.length;i++){
			if(this.GetLogicColor(_cards[i]) != lc){
				break;
			}

			if(_cards[i] != prev){
				sameCnt = 1;
				prev = _cards[i];
			}else{
				sameCnt = sameCnt + 1;
				if(sameCnt >= 2){
					count = count + 1;
					sameCnt = 0;
				}
			}
		}
		
		return count;
	};

	 //得到该花色下两两相同的牌;
	this.GetSame2Cards= function(_cards,lc,_res)
	{
		// if("table" != type(_cards)){
		// 	return false;
		// }

		var count = 0;;
		var index = 1;;
		for(var i=0;i<_cards.length;i++){
			if(this.GetLogicColor(_cards[i]) == lc){
				break;
			}
			index = index + 1;
		}
		
		var prev = CardDef.CARD_NULL;;
		var sameCnt = 0;;
		for(i = index;i<_cards.length;i++){
			if(this.GetLogicColor(_cards[i]) != lc){
				break;
			}

			if(_cards[i] != prev){
				sameCnt = 1;
				prev = _cards[i];
			}else{
				sameCnt = sameCnt + 1;
				if(sameCnt >= 2){
					_res.push(_cards[i]);
					count = count + 1;
					sameCnt = 0;
				}
			}
		}
		
		return count;
	};

	 //是否有相同花色的三个;
	this.HasSame3= function(_cards,lc)
	{
		// if("table" != type(_cards)){
		// 	return false;
		// }

		if(_cards.length < 3){
			return false;
		}

		var hasSame = false;
		var card = _cards[1];;
		for(i=2,_cards.length){
			if(this.GetLogicColor(_cards[i]) == lc&&card == _cards[i]){
				if(hasSame){
					return true;
				}else{
					hasSame = true;
				}
			}

			card = _cards[i];
		}
		
		return false;
	};

	this.GetSame3Count= function(_cards,lc)
	{
		// if("table" != type(_cards)){
		// 	return false;
		// }

		var count = 0;;
		var index = 0;;
		for(var i=0;i<_cards.length;i++){
			if(this.GetLogicColor(_cards[i]) == lc){
				index = i;
				break;
			}
			 //index = index + 1;
		}
		
		if(0 == index){
			return 0;
		}

		var prev = CardDef.CARD_NULL;;
		var sameCnt = 0;;
		for(i = index;i<_cards.length;i++){
			if(this.GetLogicColor(_cards[i]) != lc){
				break;
			}

			if(_cards[i] != prev){
				sameCnt = 1;
				prev = _cards[i];
			}else{
				sameCnt = sameCnt + 1;
				if(sameCnt >= 3){
					count = count + 1;
					sameCnt = 0;
				}
			}
		}
		
		return count;
	};

	 //得到该花色下三三相同的牌;
	this.GetSame3Cards= function(_cards,lc,_res)
	{
		// if("table" != type(_cards)){
		// 	return false;
		// }

		var count = 0;;
		var index = 1;;
		for(var i=0;i<_cards.length;i++){
			if(this.GetLogicColor(_cards[i]) == lc){
				break;
			}
			index = index + 1;
		}
		
		var prev = CardDef.CARD_NULL;;
		var sameCnt = 0;;
		for(i = index,_cards.length){
			if(this.GetLogicColor(_cards[i]) != lc){
				break;
			}

			if(_cards[i] != prev){
				sameCnt = 1;
				prev = _cards[i];
			}else{
				sameCnt = sameCnt + 1;
				if(sameCnt >= 3){
					//_res.push(_cards[i]);
					_res.push(_cards[i]);
					count = count + 1;
					sameCnt = 0;
				}
			}
		}
		
		return count;
	};

	 //是否有二 拖拉机;
	this.HasTractor2= function(_cards,lc,size)
	{
		if(type(_cards) != "table"){
			return false;
		}
		var tractorSize = 0;
		var preSameCount = 0;
		var sameCount = 0;
		var preCard = CardDef.CARD_NULL;
		var card = CardDef.CARD_NULL;
		var index = 1;
		for(var i=0;i<_cards.length;i++){        
			if(this.GetLogicColor(_cards[i]) == lc){
				index = i;
				break;
			}
		}

		if(0 == index){
			return false;
		}

		for(i = index,_cards.length){
			if(this.GetLogicColor(_cards[i]) != lc){
				break;
			}

			if(_cards[i] != card){
				if(preSameCount > 1&&sameCount > 1&&this.GetCardLogicValue(preCard) - this.GetCardLogicValue(card) == 1){
					if(0 == tractorSize){
						tractorSize = 2;
					}else{
						tractorSize = tractorSize + 1;
					}

					if(size == tractorSize){
						return true;
					}
				}else{
					tractorSize = 0;
				}

				preCard = card;
				preSameCount = sameCount;

				card = _cards[i];
				sameCount = 1;
			}else{
				sameCount = sameCount + 1;
			}
		}
		
		if(preSameCount > 1&&sameCount > 1&&this.GetCardLogicValue(preCard) - this.GetCardLogicValue(card) == 1){
			if(0 == tractorSize){
				tractorSize = 2;
			}else{
				tractorSize = tractorSize + 1;
			}

			if(size == tractorSize){
				return true;
			}
		}
		return false;
	};
	 //是否有三 拖拉机;
	this.HasTractor3= function(_cards,lc,size)
	{
		// if(type(_cards) == "table"){
		// 	return false;
		// }
		var tractorSize = 0;;
		var preSameCount = 0;
		var sameCount = 0;;
		var preCard = CardDef.CARD_NULL;;
		var card = CardDef.CARD_NULL;;
		var index = 0;;
		for(i=index;i<_cards.length;i++){
			index = i;
			if(this.GetLogicColor(_cards[i]) == lc){
				break;
			}
		}

		for(i = index;_cards.length;i++){
			if(this.GetLogicColor(_cards[i]) != lc){
				break;
			}

			if(_cards[i] != card){
				if(preSameCount > 2&&sameCount > 2&&this.GetCardLogicValue(preCard) - this.GetCardLogicValue(card) == 1){
					if(0 == tractorSize){
						tractorSize = 2;
					}else{
						tractorSize = tractorSize + 1;
					}

					if(size == tractorSize){
						return true;
					}
				}else{
					tractorSize = 0;
				}

				preCard = card;
				preSameCount = sameCount;

				card = _cards[i];
				sameCount = 1;
			}else{
				sameCount = sameCount + 1;
			}
		}
		
		if(preSameCount > 2&&sameCount > 2&&this.GetCardLogicValue(preCard) - this.GetCardLogicValue(card) == 1){
			if(0 == tractorSize){
				tractorSize = 2;
			}else{
				tractorSize = tractorSize + 1;
			}

			if(size == tractorSize){
				return true;
			}
		}
		return false;
	};
	 //得到二拖拉机的数量;
	this.GetTractor2Count= function(_cards,lc,size)
	{
		// if(type(_cards) == "table"){
		// 	return false;
		// }

		var getNum = 0;;
		var tractorSize = 0;;
		var preSameCount = 0;
		var sameCount = 0;;
		var preCard = CardDef.CARD_NULL;;
		var card = CardDef.CARD_NULL;;
		var index = 0;
		for(var i=index;i++;i<_cards.length){
			index = i;
			if(this.GetLogicColor(_cards[i]) == lc){
				break;
			}
		}

		for(i = index;i<_cards.length;i++){
			if(this.GetLogicColor(_cards[i]) != lc){
				break;
			}

			if(_cards[i] != card){
				if(preSameCount > 1&&sameCount > 1&&this.GetCardLogicValue(preCard) - this.GetCardLogicValue(card) == 1){
					if(0 == tractorSize){
						tractorSize = 2;
					}else{
						tractorSize = tractorSize + 1;
					}

					if(size == tractorSize){
						getNum = getNum + 1;
						preCard = CardDef.CARD_NULL;
						card = CardDef.CARD_NULL;
						preSameCount = 0;
						sameCount = 0;
						tractorSize = 0;
					}
				}else{
					tractorSize = 0;
				}

				preCard = card;
				preSameCount = sameCount;

				card = _cards[i];
				sameCount = 1;
			}else{
				sameCount = sameCount + 1;
			}
		}
		
		if(preSameCount > 1&&sameCount > 1&&this.GetCardLogicValue(preCard) - this.GetCardLogicValue(card) == 1){
			if(0 == tractorSize){
				tractorSize = 2;
			}else{
				tractorSize = tractorSize + 1;
			}

			if(size == tractorSize){
				return true;
			}
		}
		return false;
	};


	 //得到二拖拉机的牌;
	this.GetTractor2Cards= function(_cards,lc,size,_res)
	{
		var _pairData = [];
		if(this.GetSame2Cards(_cards,lc,_pairData) < 2){
			return 0;
		}

		var preValue = 0;;
		var count = 0;;
		var _tractor = [];;
		for(var i=0;i<_cards.length;i++)
		{
			var k=i;
			var v=_cards[k];
			var value = this.GetCardLogicValue(v);;

			 //跳过重复的副主;
			if(preValue != value){
				if(preValue != 0&&preValue - value == 1){
					_tractor.push(v);
					if(size != 0&&_tractor.length >= size){
						var _tmpTractor = _tractor.concat();;
						_res.push(_tmpTractor);
						_tractor = [];
						count = count + 1;
						preValue = 0;
					}else{
						preValue = value;
					}
				}else{
					if(0 == size&&_tractor.length >= 2){
						if(count < _tractor.length){
							count = _tractor.length;
						}

						var _tmpTractor = _tractor.concat();;
						_res.push(_tmpTractor);
					}
					_tractor = [];
					_tractor.push(v);
					preValue = value;
				}
			}
		}
		
		if(0 == size&&_tractor.length >= 2){
			if(count < _tractor.length){
				count = _tractor.length;
			}

			var _tmpTractor = _tractor.concat();;
			_res.push( _tmpTractor);
		}

		return count;
	};

	this.GetTractor3Count= function(_cards,lc,size)
	{
		// if(type(_cards) == "table"){
		// 	return false;
		// }

		var getNum = 0;
		var tractorSize = 0;
		var preSameCount = 0;
		var sameCount = 0;
		var preCard = CardDef.CARD_NULL;
		var card = CardDef.CARD_NULL;
		var index = 0;
		for(var i=index;i<_cards.length;i++){
			index = i;
			if(this.GetLogicColor(_cards[i]) == lc){
				break;
			}
		}

		for(var i = index;i<_cards.length;i++){
			if(this.GetLogicColor(_cards[i]) != lc){
				break;
			}

			if(_cards[i] != card){
				if(preSameCount > 2&&sameCount > 2&&this.GetCardLogicValue(preCard) - this.GetCardLogicValue(card) == 1){
					if(0 == tractorSize){
						tractorSize = 2;
					}else{
						tractorSize = tractorSize + 1;
					}

					if(size == tractorSize){
						getNum = getNum + 1;
						preCard = CardDef.CARD_NULL;
						card = CardDef.CARD_NULL;
						preSameCount = 0;
						sameCount = 0;
						tractorSize = 0;
					}
				}else{
					tractorSize = 0;
				}

				preCard = card;
				preSameCount = sameCount;

				card = _cards[i];
				sameCount = 1;
			}else{
				sameCount = sameCount + 1;
			}
		}
		
		if(preSameCount > 2&&sameCount > 2&&this.GetCardLogicValue(preCard) - this.GetCardLogicValue(card) == 1){
			if(0 == tractorSize){
				tractorSize = 2;
			}else{
				tractorSize = tractorSize + 1;
			}

			if(size == tractorSize){
				return true;
			}
		}
		return false;
	};

	 //得到三拖拉机的牌;
	this.GetTractor3Cards= function(_cards,lc,size,_res)
	{
		var _pairData = [];
		if(this.GetSame3Cards(_cards,lc,_pairData) < 2){
			return 0;
		}

		var preValue = 0;
		var count = 0;
		var _tractor = [];

		for(var i=0;i<_pairData.length;i++)
		{	
			var k=i;
			var v=_pairData[k];
			var value = this.GetCardLogicValue(v);;

			 //跳过重复的副主;
			if(preValue != value){
				if(preValue != 0&&preValue - value == 1){
					_tractor.push(v);
					if(size != 0&&_tractor.length >= size){
						var _tmpTractor = _tractor.concat();;
						_res.push(_tmpTractor);
						_tractor = [];
						count = count + 1;
						preValue = 0;
					}else{
						preValue = value;
					}
				}else{
					if(0 == size&&_tractor.length >= 2){
						if(count < _tractor.length){
							count = _tractor.length;
						}

						var _tmpTractor = _tractor.concat();;
						_res.push(_tmpTractor);
					}
					_tractor = [];
					_tractor.push(v);
					preValue = value;
				}
			}
		}
		
		if(0 == size&&_tractor.length >= 2){
			if(count < _tractor.length){
				count = _tractor.length;
			}

			var _tmpTractor = _tractor.concat();;
			_res.push( _tmpTractor);
		}

		return count;
	};

	 //刪除 table中刪除table;
	this.RemoveCards= function(_cards,_removes)
	{
		// if(type(_cards) != "table"||type(_removes) != "table"){
		// 	return;
		// }


		for(var i=0;i<_removes.length;i++)
		{
			var k=i;
			var v=_removes[i];
			table.removebyvalue(_cards,v,false);
			
		}        
	};

	 //排序table size从大到小;
	this.CompareTractorSize= function(_a,_b)
	{
		return _a.length > _b.length;
	};

	 //根据牌型分牌;
	this.SplitCards2= function(_cards, _lc, _firstcardtype)
	{
		if(0 == _cards.length){
			return;
		}
		
		var begin = 0;
		for(var i =0;i < _cards.length;i ++){
			begin = i;
			if(this.GetLogicColor(_cards[i]) == _lc)
			{ 
				break;
			} 
		}
		
		if(begin > _cards.length)
		{ 
			return ;
		}
		
		var endIndex = begin;
		for(var i =0;i < _cards.length;i ++)
		{
			if(this.GetLogicColor(_cards[i]) != _lc)
			{ 
				break;
			}
			else
			{
				endIndex = i;
			} 
		}
		
		var _ret = [];
		
		if(GameShareDef.CARD_TYPE_SINGLE == _firstcardtype){
			for(var i =0;i < _cards.length;i ++){
				var _subs = [];
				_subs.push( _cards[i]);
				_ret.push( _subs);
			}
			return _ret;
		}else if( GameShareDef.CARD_TYPE_SAME_2 == _firstcardtype){
			var _preval = this.GetCardValue(_cards[begin]);
			for(var i =0;i < endIndex;i ++){
				if(_preval == this.GetCardValue(_cards[i])){
					var _subs = [];
					_subs.push( _cards[i]);
					_subs.push( _cards[i]);
					_ret.push( _subs);
				}
				_preval = this.GetCardValue(_cards[i]);
			}
			return _ret;
		}else if( GameShareDef.CARD_TYPE_TRACTOR_2 == _firstcardtype){
			
		}
	};

	 //把牌分成连刻，连队，刻字，对子，单张;
	this.SplitCards= function(_cards,lc,_res,firstCardType)
	{
		if(lc==CardDef.CARD_COLOR_NULL){
			return ;
		}

		this.CreateSplitedCardsTable(_res);
		 //设置初值;
		firstCardType = firstCardType||GameShareDef.CARD_TYPE_NULL;
		if(0 == _cards.length){
			return;
		}

		var begin = 1;
		for(var i=0;i<_cards.length;i++)
		{
			var k=i;
			var v=_cards[k];
			begin = i   ;
			if(this.GetLogicColor(v) == lc){
				break;
			}        
		}
		
		if(begin > _cards.length){
			return;
		}

		var endIndex = begin;
		for(var i =0;i <_cards.length;i ++){
			 //endIndex = i;
			if(this.GetLogicColor(_cards[i]) != lc){
				break;
			}else
			{
				endIndex = i
			}
		}
		
		if(GameShareDef.CARD_TYPE_TRACTOR_2 != firstCardType){
			var prev = 0;;
			var sameCount = 0;;
			for(i = begin,endIndex)
			{
				if(_cards[i] !=prev)
				{
					if(1 == sameCount){
						_res.Singles.push(prev);
				  	}else if( 2 == sameCount){
						_res.Pairs.push(prev);
				  	}else if( 3 == sameCount){
						_res.Triples.push(prev);
				  	}
				  	sameCount = 1;
				  	prev = _cards[i];
			  	}
			  	else
			  	{
				  sameCount = sameCount + 1;
			  	}
		   	}

			if(1 == sameCount){
				_res.Singles.push( prev);
			}else if( 2 == sameCount){
				_res.Pairs.push( prev);
			}else if( 3 == sameCount){
				_res.Triples.push( prev);
			}
		   
			//查找拖拉机;
		   	if(0 != _res.Triples.length){
				var prevalue = 0;
			   	var tractor = [];
			   	var removeCards = [];
				for(var i=0;i<_res.Triples.length;i++)
				{
					var k=i;
					var v=_res.Triples[k];
					var value = this.GetCardLogicValue(v);;
					if(prevalue != value){
						if(prevalue != 0&&prevalue - value == 1){
							tractor.push(v);
							prevalue = value;
						}else{
							if(tractor.length >=2){
								var tmpTra = tractor.concat();;
								_res.Tractors3.push(tmpTra);
								//table.insertto(removeCards,tractor,0);
								removeCards=tractor.concat(removeCards);
							}
							tractor = [];
							tractor.push(v);
							prevalue = value;
						}
					}
			   	}
			   	if(2 <= tractor.length){
					var tmpTra = tractor.concat();;
					_res.Tractors3.push( tmpTra);
					//table.insertto(removeCards, tractor, 0);
					removeCards=tractor.concat(removeCards);
			   	}
			   	if(0 != removeCards.length){
					this.RemoveCards(_res.Triples,removeCards);
			   	}
		   }
		   if(0 != _res.Pairs.length){
			   	var prevalue = 0;;
			   	var tractor = [];;
			   	var removeCards = [];;
				for(var i=0;i<_res.Pairs.length;i++)
				{
					var k=i;
					var v=_res.Pairs[k];
					var value = this.GetCardLogicValue(v);;
					if(prevalue != value){
						if(prevalue != 0&&prevalue - value == 1){
							tractor.push(v);
							prevalue = value;
						}else{
							if(tractor.length >=2){
								var tmpTra = tractor.concat();;
								_res.Tractors2.push(tmpTra);
								//table.insertto(removeCards,tractor,0);
								removeCards=tractor.concat(removeCards);
							}
							tractor = [];
							tractor.push(v);
							prevalue = value;
						}
					}
			   }
			   if(2 <= tractor.length){
					var tmpTra = tractor.concat();;
					_res.Tractors2.push( tmpTra);
					//table.insertto(removeCards, tractor, 0);
					removeCards=tractor.concat(removeCards);

			   }
			   if(0 != removeCards.length){
					this.RemoveCards(_res.Pairs,removeCards);
			   }
		   }
		}else{
			var removeCards = [];;
			 //得到花色相同的手牌;
			var tmpCards = [];;
			for(i = begin,endIndex){
				tmpCards.push(_cards[i]);
			}
			this.GetTractor3Cards(tmpCards,lc,0,_res.Tractors3);
			for(var i=0;i<_res.Tractors3.length;i++)
			{
				var k=i;
				var v=_res.Pairs[k];
				for(var j=0;j<v.length;j++)
				{
					var m=v[j];
					removeCards.push(m);
				   	removeCards.push(m);
				   	removeCards.push(m);
				}        
			}
		   
		   	this.RemoveCards(tmpCards,removeCards);

		   	this.GetTractor2Cards(tmpCards,lc,0,_res.Tractors2);


			for(var i=0;i<_res.Tractors2.length;i++)
			{
				var k=i;
				var v=_res.Tractors2[k];
				for(var j=0;j<v.length;j++)
				{
					var m=v[j];
					removeCards.push(m);
				   	removeCards.push(m);
				}        
			}

			this.RemoveCards(tmpCards,removeCards);

			var prev = 0;;
			var sameCnt = 0;;
			//for(var i=0;i<v .length;i++){
			//	v =tmpCards[i]
			for(var i=0;i<tmpCards.length;i++)
			{
				var k=i;
				var v=tmpCards[k];
				if(v != prev){
					if(1 == sameCnt){
						_res.Singles.push(prev);
					}else if( 2 == sameCnt){
						_res.Pairs.push(prev);
					}else if( 3 == sameCnt){
						_res.Triples.push(prev);
					}
					sameCnt = 1;
					prev = v;

				}else{
					sameCnt = sameCnt + 1;
				}
			}
			if(1 == sameCnt){
				_res.Singles.push( prev);
			}else if( 2 == sameCnt){
				_res.Pairs.push( prev);
			}else if( 3 == sameCnt){
				_res.Triples.push( prev);
			}        
		}
		
		if(2 <= _res.Tractors2.length){
			_res.Tractors2.sort(this.CompareTractorSize.bind(this));
		}
		if(2 <= _res.Tractors3.length){
			_res.Tractors3.sort(this.CompareTractorSize.bind(this));
		}
	};



	this.SplitIndex= function(cardidx,range,result, firstCardType)
	{

		firstCardType = firstCardType||GameShareDef.CARD_TYPE_NULL;

		var tmpCardIdx = cardidx.concat();;

		if(firstCardType == GameShareDef.CARD_TYPE_TRACTOR_2){

			var tractor = [];;
			var selIndex = -1;;
			for(var curIdx=0;curIdx<-1;curIdx++){
				if(tmpCardIdx[curIdx] >=2&&(-1 == selIndex||-1 == range.first||curIdx < range.first||curIdx > range.second)){
					tractor.push(curIdx);
					if(-1 == selIndex&&-1 != range.first&&curIdx >= range.first&&curIdx <= range.second){
						selIndex = curIdx;
					}
				}else if( -1 != range.first&&curIdx >= range.first&&curIdx <= range.second){
					
				}else{
					if(tractor.length >= 2){
						for(var i=0;i<v .length;i++){
							v =tractor[i]
						{
							tractor[i] = tractor[i] - 2;
						}     
						
						result.Tractors2.push(tractor);
					}
					tractor = [];
				} 
			}        
			if(tractor.length >= 2){
				 for(var i=0;i<v .length;i++){
				 	v =tractor[i]
					 tractor[i] = tractor[i] - 2;
				 }     

				 result.Tractors2.push(tractor);
			}
			tractor = [];
		}else if( firstCardType == GameShareDef.CARD_TYPE_SAME_3){
			for(var i=0;i<-1;i++){
				if(tmpCardIdx[i] >= 3){
					 result.Triples.push(i);
					tmpCardIdx[i] = tmpCardIdx[i] - 3;
				}
			}
		
		}else{
			 //连刻;
			var tractor = [];;
			var selIndex = -1;;
			for(var curIdx=0;curIdx<-1;curIdx++){
				if(tmpCardIdx[curIdx] >= 3&&(-1 == selIndex||-1 == range.first||curIdx < range.first||curIdx > range.second)){
					tractor.push(curIdx);
					if(-1 == selIndex&&-1 != range.first&&curIdx >= range.first&&curIdx <= range.second){
						selIndex = curIdx;
					}
				}else if( -1 != range.first&&curIdx >= range.first&&curIdx <= range.second){
					
				}else{
					if(tractor.length >= 2){
						for(var i=0;i<v .length;i++){
							v =tractor[i]
							tractor[i] = tractor[i] - 3;
						}     
						
						result.Tractors3.push(tractor);
					}
					tractor = [];
				} 
			}   
			if(tractor.length >= 2){
				 for(var i=0;i<v .length;i++){
				 	v =tractor[i]
					 tractor[i] = tractor[i] - 3;
				 }     

				 result.Tractors3.push(tractor);
			}
			tractor = []    ;
		}

		if(firstCardType != GameShareDef.CARD_TYPE_TRACTOR_2){
			var tractor = [];;
			var selIndex = -1;;
			for(var curIdx=0;curIdx<-1;curIdx++){
				if(tmpCardIdx[curIdx] >= 2&&(-1 == selIndex||-1 == range.first||curIdx < range.first||curIdx > range.second)){
					tractor.push(curIdx);
					if(-1 == selIndex&&-1 != range.first&&curIdx >= range.first&&curIdx <= range.second){
						selIndex = curIdx;
					}
				}else if( -1 != range.first&&curIdx >= range.first&&curIdx <= range.second){
					
				}else{
					if(tractor.length >= 2){
						for(var i=0;i<v .length;i++){
							v =tractor[i]
							tractor[i] = tractor[i] - 2;
						}     
						
						result.Tractors2.push(tractor);
					}
					tractor = [];
				} 
			}   
			if(tractor.length >= 2){
				 for(var i=0;i<v .length;i++){
				 	v =tractor[i]
					 tractor[i] = tractor[i] - 2;
				 }     

				 result.Tractors2.push(tractor);
			}
			tractor = []   ;
		}

		for(var i=0;i<-1 ;i++){
		   if(tmpCardIdx[i] == 1){
				result.Singles.push(i);
		   }else if( tmpCardIdx[i] == 2){
				result.Pairs.push(i);
		   }else if( tmpCardIdx[i] == 3){
				result.Triples.push(i);
		   } 

		   tmpCardIdx[i] = 0;
		}   
		
		if(result.Tractors2.length>= 2){
			  result.Tractors2.sort(this.CompareTractorSize.bind(this));
		} 

		if(result.Tractors3.length >= 2){
			result.Tractors3.sort(this.CompareTractorSize.bind(this));
		}
	};


	 //pair排序，从小到达;
	this.LessPaiSort= function(_pair1,_pair2)
	{
		return _pair1[1] < _pair2[1];
	};

	 //pair排序，从小到达;
	this.BigPaiSort= function(_pair1,_pair2)
	{
		return tonumber(_pair1[1]) > tonumber(_pair2[1]);
	};

	 //排序;
	this.SortCards= function(_cards,asc)
	{
	    var sortCards = [];;
	   	for(var i=0;i<v .length;i++){
	   		v =_cards[i]
			var pair = [];;
			pair[1] = this.GetCardSortValue(v);
			pair[2] = v;
			sortCards.push(pair);
	   }   

		//排序;
	   	if(asc){
			sortCards.sort(this.LessPaiSort.bind(this));
	   	}else{
			sortCards.sort(this.BigPaiSort.bind(this));
	   	}
	   	for(var i=0;i<v .length;i++){
	   		v =_cards[i]
			_cards[i] = nil;
	   	}

	   for(var i=0;i<v .length;i++){
	   	v =sortCards[i]
			_cards[i] = v[2];
	   }   
	};
	 //排序;
	this.SortCardsByLogicValue= function(_cards,asc)
	{
	   var sortCards = [];;
	   for(var i=0;i<v .length;i++){
	   	v =_cards[i]
			var pair = [];;
			pair[1] = this.GetCardLogicValue(v);
			pair[2] = v;
			sortCards.push(pair);
	   }   

		//排序;
	   if(asc){
			sortCards.sort(this.LessPaiSort.bind(this));
	   }else{
			sortCards.sort(this.BigPaiSort.bind(this));
	   }
	   for(var i=0;i<v .length;i++){
	   	v =_cards[i]
			_cards[i] = nil;
	   }

	   for(var i=0;i<v .length;i++){
	   	v =sortCards[i]
			_cards[i] = v[2];
	   }   
	};


	 //把牌分成连刻，连队，刻字，对子，单张，没有去掉重复的;
	this.AnalyzedCards= function(_cards,lc,_res)
	{
		_res = this.CreateAnalyzedCardsTable();
		if(0 == _cards.length){
			return;
		}

		var begin = 1;;
		for(var i=0;i<value .length;i++){
			value =_cards[i]
			begin = i;
			if(this.GetLogicColor(value) == lc){
				break;
			}
		}
		
		if(begin == _cards.length){
			return;
		}

		var endIndex = 0;;
		for(var i =0;i <_cards.length;i ++){
			endIndex = i;
			if(this.GetLogicColor(_cards[i]) != lc){
				break;
			}
		}
		var card = 0;;
		var  preCard = 0;;
		var prevPairCard = 0;;
		var prevTriCard = 0;;
		var sameCount = 0;;
		var preSameCount = 0;;
		var tractor2 = [];;
		var tractor3 = [];;
		while true){
			if(begin == endIndex||_cards[begin] != card){
				if(preSameCount != 0){
					if(0 != preSameCount){
						_res.Singles.push(preCard);
					}
					if(preSameCount >=2){
						_res.Pairs.push(preCard);
						if(sameCount < 2){
							if(0 != tractor2.length){
								tractor2.push(preCard);
								var tmpTra2 = tractor2.concat();;
								_res.Tractors2.push(tmpTra2);
								tractor2 = [];
							}
						}
					}
					if(sameCount == 3){
						_res.Triples.push(preCard);
						if(sameCount < 3){
							if(0 != tractor3){
								table.insert(preCard);
								var tmpTra3 = tractor3.concat();;
								_res.Tractors3.push(tmpTra3);
								tractor3 = [];
							}
						}
					}
					if(sameCount >= 2&&preSameCount >= 2){
						if(this.GetCardLogicValue(prevPairCard) - this.GetCardLogicValue(card) == 1){
							tractor2.push(prevPairCard);
						}else{
							if(0 != tractor2.length){
								table.insert(preCard);
								var tmpTra2 = tractor2.concat();;
								_res.Tractors2.push(tmpTra2);
								tractor2 = [];
							}
						}
					}
					if(sameCount >= 3&&preSameCount >= 3){
						if(this.GetCardLogicValue(prevPairCard) - this.GetCardLogicValue(card) == 1){
							tractor2.push(prevTriCard);
						}else{
							if(0 != tractor3.length){
								table.insert(preCard);
								var tmpTra3 = tractor3.concat();;
								_res.Tractors3.push(tmpTra3);
								tractor3 = [];
							}
						}
					}
				}
				if(begin != endIndex){
					preCard = card;
					preSameCount = sameCount;
					if(sameCount >= 2){
						prevPairCard = card;
					}
					if(sameCount >= 3){
						prevTriCard = card;
					}
					card = _cards[begin];
					sameCount = 1;
				}else{
					if(0 != sameCount){
						_res.Singles.push(card);
						if(sameCount >= 2){
							_res.Pairs.push(card);
							if(0 != tractor2.length){
								tractor2.push(card);
								var tmpTra2 = tractor2.concat();;
								_res.Tractors2.push(tmpTra2);
								tmpTra2 = [];
							}
						}
						if(sameCount == 3){
							_res.Triples.push(card);
							if(0 != tractor3){
								tractor3.push(card);
								var tmpTra3 = tractor3.concat();;
								_res.Tractors3.push(tmpTra3);
								tractor3 = [];
							}
						}
					}else{
						break;
					}            
				}
			}else{
				sameCount = sameCount + 1;
			}
			begin = begin + 1;
		}
		if(_res.Tractors2.length >= 2){
			_res.Tractors2.sort(this.CompareTractorSize.bind(this));
		}
		if(_res.Tractors3.length >= 2){
			_res.Tractors3.sort(this.CompareTractorSize.bind(this));
		}
	};


	 //[[;
	// 设置主牌花色;
	// 参数：主牌列表;
	// 返回值：无;
	 //]];
	this.SetMainColor1= function(mianCardList) 
	{
		if(type(mianCardList) != "table"){         
			return ;
		} 
		if(table.nums(mianCardList) == 0){ 
			return;
		} 
		if(this.PackCount != 2||this.bCallCardWithKing == true){ 
			return;
		} 

		var mainColor = CardDef.CARD_COLOR_NULL;
		for(var j =0;j <1;j ++){ 
			if(this.bCallCardWithKing == false){ 
				if(table.nums(mianCardList)  > 1&&(mianCardList[1] != mianCardList[2])){
					break;
				}else{
					mainColor = this.GetCardColor(mianCardList[1]);
					break;
				} 
			} 
			var blackJokeCount = 0  ;
			var redJokeCount = 0;
			var mainValueCount = 0;
			for(var i =0;i <table.nums(mianCardList;i ++){ 
				var  card = mianCardList[i];;
				if(this.GetCardValue(card) == CardDef.CARD_VALUE_BJOKE){ 
					blackJokeCount = blackJokeCount + 1;
				}else if( this.GetCardValue(card) == CardDef.VALUE_RJOKER){ 
					redJokeCount = redJokeCount + 1;
				}else if( this.GetCardValue(card) == this.MainValue){ 
					 // 确保主只有一种花色;
					if( mainColor != CardDef.CARD_COLOR_NULL&& mainColor != this.GetCardColor(card)){ 
						break;;
					} 
					mainValueCount = mainValueCount + 1;
					mainColor = this.GetCardColor(card);;
				else	 // 非大小王和主;

					mainColor = CardDef.CARD_COLOR_NULL;;
					break;;
				} 
			end ;
			if(this.bCallCardWithKing&& redJokeCount > 0&& blackJokeCount > 0){ 
				mainColor = CardDef.CARD_COLOR_NULL;;
				break;
			} 

			if(redJokeCount == table.nums(mianCardList)|| blackJokeCount == table.nums(mianCardList) ){ 
				mainColor =CardDef.CARD_COLOR_JOKER;;
				break;;
			end ;
			if(this.bCallCardWithKing == false){   //	// 非带王亮主
				break;;
			} 
			if((redJokeCount == 1&& (mainColor == CardDef.CARD_COLOR_HONG_TAO|| mainColor == CardDef.CARD_COLOR_FANG_KUAI))||;
				(blackJokeCount == 1&& (mainColor == CardDef.CARD_COLOR_HEI_TAO|| mainColor == CardDef.CARD_COLOR_MEI_HUA))){ 
				break;;
			} 
			mainColor = CardDef.CARD_COLOR_NULL; ;
		} 
		this.SetMainColor(mainColor);;
	};

	 //比较单牌;
	this.CompareCardSingle= function(left,right)
	{
		var leftColor = this.GetLogicColor(left);;
		var rightColor = this.GetLogicColor(right);;
		if((leftColor == rightColor)){
			return this.GetCardLogicValue(left) < this.GetCardLogicValue(right);;
		}else if( rightColor == GameShareDef.LOGIC_CARD_COLOR_MAIN){
			return true;;
		}else{
			return false;;
		}
	};

	this.ResizeToMin= function(_data,size)
	{
		if(type(_data) != "table"){
			return;
		}

		if(size >= _data.length){
			return;
		}

		for(var i=0;i<_data.length;i++){
		   if(i > size){
				_data[i] = nil;
		   } 
		}    
	};
	this.ResizeToMax= function(_data,size)
	{
		if(type(_data) != "table"){
			return;
		}

		this.TableClear(_data);

		for(var i=0;i<size;i++){       
			_data[i] = 0       ;
		}    
	};

	 //检查牌是否合法;
	this.CheckFit= function(destData,checkData,range)
	{
		if(type(destData) != "table"||type(checkData) != "table"||type(range) != "table"){
			return;
		}

		var fitData = checkData.concat();;
		 //先连刻;
		for(var j=0;j<itrNeed .length;j++){
			itrNeed =destData.Tractors3[j]
			var find = false;;
			for(var i=0;i<-1;i++){
				var itrFit = fitData.Tractors3[i];;
				if(itrFit.length >= itrNeed.length){
					if(itrNeed.length - itrFit.length >= 2){
						this.ResizeToMin(fitData.Tractors3,itrFit.length - itrNeed.length);
					}else if( itrFit.length - itrNeed.length == 1){
						fitData.Triples.push(itrFit[1]);
						table.remove(fitData.Tractors3,itrFit.length);
					}else{
						table.remove(fitData.Tractors3,itrFit.length);
					}

					find = true;
					break;
				}    
			}        
			if(!find){
				return false;
			}
		}    

		 //连对;
		for(var j=0;j<itrNeed .length;j++){
			itrNeed =destData.Tractors2[j]
			var find = false;;
			for(var i=0;i<-1;i++){
				var itrFit = fitData.Tractors2[i];;
				if(itrFit.length >= itrNeed.length){
					if(itrFit.length - itrNeed.length >= 2){
						this.ResizeToMin(fitData.Tractors2,itrFit.length - itrNeed.length);
					}else if(itrFit.length - itrNeed.length == 1){
						var newTrac = false;;
						var tractors2 = [];
						if(-1 != range.first&&(itrFit[1]) == range.first -1||(itrFit[1]) == range.second + 1||(itrFit[itrFit.length]) == range.first - 1||(itrFit[itrFit.length]) == range.second + 1){
							for(var k=0;k<itrPair .length;k++){
								itrPair =fitData.Pairs[k]
								if(itrPair >= range.first&&itrPair <= range.second){
									tractors2.push(itrFit[1]);
									tractors2.push(itrPair);
									newTrac = true;
									table.remove(fitData.Pairs,k);
									break;
								}
							}
						}else{
							fitData.Pairs.push(itrFit[1]);
						}
						table.remove(fitData.Tractors2,fitData.Tractors2.length);
						if(newTrac){
							fitData.Tractors2.push(tractors2);
						}
					}else{
						table.remove(fitData.Tractors2,fitData.Tractors2.length);
					}

					find = true;
					break;
				}    
			}        
			if(!find&&0 != fitData.Tractors3.length){
				for(var i=0;i<-1;i++){
					var itrFit = fitData.Tractors3[i];;

					if(itrFit.length >= itrNeed.length){
						if(itrFit.length - itrNeed.length >= 2){
							this.ResizeToMin(fitData.Tractors3, itrFit.length - itrNeed.length);
						}else if(itrFit.length - itrNeed.length == 1){
							fitData.Triples.push( itrFit[1]);
							table.remove(fitData.Tractors3, itrFit.length);
						}else{
							table.remove(fitData.Tractors3, itrFit.length);
						}

						find = true;
						break;
					}    
				}
			}
			if(!find){
				return false;
			}
		}

		 //统计连对和连可得剩余量;
		var triCountInTracotr3 = 0;;
		var pairCountInTractor2 = 0;;
		if(0 != fitData.Tractors3.length){
			for(var i=0;i<v .length;i++){
				v =fitData.Tractors3[i]
				triCountInTracotr3 = triCountInTracotr3 + v.length;
			}        
		}

		if(0 != fitData.Tractors2.length){
			for(var i=0;i<v .length;i++){
				v =fitData.Tractors2[i]
				pairCountInTractor2 = pairCountInTractor2 + v.length;
			}        
		}

		if(fitData.Triples.length +triCountInTracotr3 < destData.Triples.length){
			return false;
		}

		if(fitData.Triples.length + triCountInTracotr3 - destData.Triples.length + fitData.Pairs.length + pairCountInTractor2 < destData.Pairs.length){
			return false;
		}

		return true;
	};

	this.CheckFitFlag= function(throwData,cardidx,range,flagIdx)
	{
		if(type(flagIdx) != "table"){
			return;
		}

		if(0 == throwData.Tractors3.length&&0 == throwData.Triples.length){
			var outData = [];
			this.SplitIndex(cardidx,range,outData,GameShareDef.CARD_TYPE_TRACTOR_2);
			var ret = this.CheckFit(throwData,outData,range);;
			if(ret){
				if(0 != throwData.Tractors2.length&&0 != outData.Tractors2){
					flagIdx.flagIdx = outData.Tractors2[1][1];
				}else if( 0 != throwData.Pairs.length){
					var maxFlagIdx = 0;;
					if(0 != outData.Pairs.length){
						maxFlagIdx = outData.Pairs[1];
					}
					if(0 != outData.Tractors2.length&&(0 == maxFlagIdx||outData.Tractors2[1][1] > maxFlagIdx)){
						maxFlagIdx = outData.Tractors2[1][1];
					}
					flagIdx.flagIdx = maxFlagIdx;
				}else if( 0 != throwData.Singles&&0 != outData.Singles.length){
					flagIdx.flagIdx = outData.outData.Singles[1];
				}else{
					flagIdx.flagIdx = cardidx.length - 1;
				}
			}
			return ret;
		}

		if(0 != throwData.Tractors3.length){
			var tractors3 = throwData.Tractors3[throwData.Tractors3.length].concat();;
			var tractorSize = 0;;
			var selIndex = -1;;

			var i = 0;;
			while i <= cardidx.length){
				i = i + 1;
				var v = cardidx[i];        ;
			 //for(var i=0;i<v .length;i++){
			 //	v =cardidx[i]
			   if(v == 3&&(-1 == selIndex||-1 == range.first||i < range.first||i > range.second)){
					if(-1 == selIndex&&i >= range.first&&i < range.second){
						selIndex = i;
					}

					tractorSize = tractorSize + 1;
					if(tractorSize == tractors3.length){
						 //修改;
						table.remove(throwData.Tractors3,throwData.Tractors3.length);
						var retIdx = i;;
						var once = false;;

						var j = 1;;
						while j <= tractorSize){                  
						   if(-1 == selIndex&&!once&&i - j >= range.first&&i - j <= range.second){
							   once = true;
							   j = i - j - selIndex;
						   } 

						   retIdx = i - j;

						   cardidx[retIdx] = cardidx[retIdx] - 3;
						   if(-1 != range.first&&retIdx >= range.first&&retIdx <= range.second){
								j = j + retIdx - range.first;
						   }
						   j = j + 1;
						}  
						
						if(this.CheckFitFlag(throwData,cardidx,range,flagIdx)){
							flagIdx.flagIdx = retIdx;
							return true;
						}else{
							 //还原;
							throwData.Tractors3.push(tractors3);
							once = false;
							var j = 1;;
							while j <= tractorSize){                  
							   if(-1 == selIndex&&!once&&i - j >= range.first&&i - j <= range.second){
								   once = true;
								   j = i - j - selIndex;
							   } 

							   retIdx = i - j;

							   cardidx[retIdx] = cardidx[retIdx] + 3;
							   if(-1 != range.first&&retIdx >= range.first&&retIdx <= range.second){
									j = j + retIdx - range.first;
							   }
							   j = j + 1;
							}  

							i = retIdx;
							tractorSize = 0;
						}  
					
					}

			   }else if( -1 != range.first&&i >= range.first&&i <= range.second){

			   else               ;
				   tractorSize = 0;
			   }           
					
			}        
			return false;
		}

		if(0 != throwData.Triples.length){
			for(var i=0;i<v .length;i++){
				v =cardidx[i]
				if(v == 3){
					 //修改;
					var card = throwData.Triples[throwData.Triples.length];;
					table.remove(throwData.Triples,throwData.Triples.length);
					cardidx[i] = cardidx[i] - 3;

					if(this.CheckFit(throwData,cardidx,range,flagIdx)){
						flagIdx.flagIdx = i;
						return true;
					}else{
						throwData.Triples.push(card);
						cardidx[i] = cardidx[i] + 3;
					}
				}
			}
			return false;
		}
		return false;
	};

	this.CollectScoreCards= function(cards,srcCards)
	{
		for(var i=0;i<v .length;i++){
			v =srcCards[i]
			var cardValue = this.GetCardValue(v);;
			if(cardValue == CardDef.CARD_VALUE_5||cardValue == CardDef.CARD_VALUE_10||cardValue == CardDef.CARD_VALUE_K){
				 // cards.push(cardValue);
				cards.push( v);
			} 
		}    
	};
	this.GetCardsScore= function(cards)
	{
		var score = 0;;
		for(var i=0;i<v .length;i++){
			v =cards[i]
			var cardValue = this.GetCardValue(v);;
			if(cardValue == CardDef.CARD_VALUE_5){
				score = score + 5;
			}else if( cardValue == CardDef.CARD_VALUE_10||cardValue == CardDef.CARD_VALUE_K){
				score = score + 10;
			} 
		}    
		return score;;
	};

	 //得到相同花色的牌;
	this.GetSameCard= function(cards , lc , result)
	{
		if(type(cards) != "table"||type(result) != "table"){
			return;
		}
		
		if(cards.length <= 0){
			this.TableClear(result);
			return;
		}

		if(lc == GameShareDef.LOGIC_CARD_COLOR_NULL){
			this.TableClear(result);
			return;
		}

		for(var i=0;i<v .length;i++){
			v =cards[i]
			if(this.GetLogicColor(v) == lc)){		
				result.push(v);
			}
		}
	};

	 //判断牌是否是相同的颜色;
	this.IsSameColor= function(cardList)
	{
		if(0 == cardList.length){
			return false;
		}

		this.SortCards(cardList,false);
		return this.GetLogicColor(cardList[1]) == this.GetLogicColor(cardList[cardList.length-1]);
	};

	 //清空表;
	this.TableClear= function(_a)
	{
		if(type(_a) != "table"){
			return;
		}

		for(var i=0;i<_a.length ;i++){
		   _a[i] = nil ;
		}    
	};
	 //安全的copy ;
	this.TableCopy= function(_dest,_ori)
	{
		if(type(_dest) != "table"||type(_ori) != "table"){
			return;
		}

		this.TableClear(_dest);

		_dest=_dest.concat(_ori);
	};
	 //提示出哪张牌;
	this.GetUniqueoutCards= function(handCards,firstOutCards,resultCard,possibleOutCards)
	{
	   if(0 == handCards.length||0 == firstOutCards.length){
			this.TableClear(resultCard);
			this.TableCopy( possibleOutCards ,handCards);
			return;
	   } 

	   if(handCards.length < firstOutCards.length){
			this.TableClear(resultCard);
			this.TableClear(possibleOutCards);
			return;
	   }

	   if(!this.IsSameColor(firstOutCards)){
			this.TableClear(resultCard);
			this.TableClear(possibleOutCards);
			return;
	   }

	   if(handCards.length == firstOutCards.length){
			this.TableCopy(resultCard,handCards);
			this.TableCopy(possibleOutCards,resultCard);
			return;
	   }
	   var tmpHandCards = handCards.concat();;
	   var cardClassifiy = [];;
	   this.GetSameCard(tmpHandCards,this.GetLogicColor(firstOutCards[1]),cardClassifiy);

	   if(cardClassifiy.length <= firstOutCards.length){
			this.TableClear(resultCard);

			this.TableCopy(resultCard,cardClassifiy);
			this.TableClear(possibleOutCards);

			if(cardClassifiy.length == firstOutCards.length){
				this.TableCopy(possibleOutCards,cardClassifiy);
			}else{
				this.TableCopy(possibleOutCards,tmpHandCards);
			}

			return;
	   }

	   var SpliteCards = this.CreateSplitedCardsTable();;
	   this.SplitCards(cardClassifiy,this.GetLogicColor(cardClassifiy[1]),SpliteCards);
	   var outCardType = this.GetCardsType(firstOutCards);

	   if(outCardType == GameShareDef.CARD_TYPE_NULL){
			this.TableClear(resultCard);
			this.TableCopy(possibleOutCards,tmpHandCards);
			return;
	   }else if( outCardType == GameShareDef.CARD_TYPE_SINGLE){ //-OK
			this.TableClear(resultCard);
			this.TableCopy(possibleOutCards,cardClassifiy);
			return;
	   }else if( outCardType == GameShareDef.CARD_TYPE_SAME_2){  // OK
			if(0 < SpliteCards.Pairs.length){
				 //对子;
				this.TableClear(resultCard);
				possibleOutCards=possibleOutCards.concat(SpliteCards.Pairs);
				possibleOutCards=possibleOutCards.concat(SpliteCards.Pairs);

				for(var i=0;i<v .length;i++){
					v =SpliteCards.Tractors2[i]
					possibleOutCards=possibleOutCards.concat(v);
					possibleOutCards=possibleOutCards.concat(v);
				}
				return;
			}else{
				 //没有对子;
				this.TableClear(resultCard);
				if(0 < SpliteCards.Tractors2.length){
					for(var i=0;i<v .length;i++){
						v =SpliteCards.Tractors2[i]
						possibleOutCards=possibleOutCards.concat(v);
						possibleOutCards=possibleOutCards.concat(v);
					}
				}else{
					this.TableCopy(possibleOutCards,cardClassifiy)                ;
				}           
				return;
			}
	   }else if( outCardType == GameShareDef.CARD_TYPE_TRACTOR_2){
			var moreThanAndEqualCards = [];;

			var lessThanCards = [];;

			for(var i=0;i<v .length;i++){
				v =SpliteCards.Tractors2[i]
				 //大于等于的拖拉机;
				 if(v.length >= firstOutCards.length/2){
					moreThanAndEqualCards.push(v);
				 }else{
					lessThanCards.push(v);
				 }
			}

			 //一个;
			if(moreThanAndEqualCards.length == 1){
				if(moreThanAndEqualCards[1].length == firstOutCards.length/2){
					resultCard=resultCard.concat(moreThanAndEqualCards[1]);
					resultCard=resultCard.concat(moreThanAndEqualCards[1]);
					this.TableCopy(possibleOutCards,resultCard);
				}else{
					for(var i=0;i<v .length;i++){
						v =moreThanAndEqualCards[i]
						possibleOutCards=possibleOutCards.concat(v);
						possibleOutCards=possibleOutCards.concat(v);
					}
					this.TableClear(resultCard);
				}
				return;
			}else if( 0 < moreThanAndEqualCards.length){
				for(var i=0;i<v .length;i++){
					v =moreThanAndEqualCards[i]
						possibleOutCards=possibleOutCards.concat(v);
						possibleOutCards=possibleOutCards.concat(v);
					}
					this.TableClear(resultCard);
				return;
			}

			 //小于的拖拉机没有;
			if(0 == lessThanCards.length){
				if(SpliteCards.Pairs.length <= firstOutCards.length/2){
					resultCard=resultCard.concat(SpliteCards.Pairs);
					resultCard=resultCard.concat(SpliteCards.Pairs);

					if(SpliteCards.Pairs.length == firstOutCards.length/2){
						this.TableCopy(possibleOutCards,resultCard);
					}else{
						this.TableCopy(possibleOutCards,cardClassifiy);
					}
				}else{
					possibleOutCards=possibleOutCards.concat(SpliteCards.Pairs);
					possibleOutCards=possibleOutCards.concat(SpliteCards.Pairs);
					this.TableClear(resultCard);
				}
				return;
			 //小于的拖拉机存在;
			}else{
				var cardsize = 0;;
				 //所有小于拖拉机的联数;
				for(var i=0;i<v .length;i++){
					v =lessThanCards[i]
					cardsize = cardsize + v.length;
				}
			   
				//手中没有对子;
				if(0 == SpliteCards.Pairs.length){
					if(cardsize <= firstOutCards.length/2){
						for(var i=0;i< v .length;i++){
							 v =lessThanCards[i]
							resultCard=resultCard.concat(v);
							resultCard=resultCard.concat(v);
						}
						if(cardsize == firstOutCards.length/2){
							this.TableCopy(possibleOutCards,resultCard);
						}else{
							this.TableCopy(possibleOutCards,cardClassifiy);
						}
						return;
					}else{
						for(var i=0;i< v .length;i++){
							 v =lessThanCards[i]
							possibleOutCards=possibleOutCards.concat(v);
							possibleOutCards=possibleOutCards.concat(v);
						}
						this.TableClear(resultCard);
						return;
					}
				}else{
					 //手中有对子并且存在小于的拖拉机;
					if(cardsize + SpliteCards.Pairs.length <= firstOutCards.length/2){
						for(var i=0;i< v .length;i++){
							 v =lessThanCards[i]
							resultCard=resultCard.concat(v);
							resultCard=resultCard.concat(v);
						}

						resultCard=resultCard.concat(SpliteCards.Pairs);
						resultCard=resultCard.concat(SpliteCards.Pairs);

						if(cardsize+SpliteCards.Pairs.length == firstOutCards.length/2){
							this.TableCopy(possibleOutCards,resultCard);
						}else{
							this.TableCopy(possibleOutCards,cardClassifiy);
						}
					}else{
						for(var i=0;i< v .length;i++){
							 v =lessThanCards[i]
							possibleOutCards=possibleOutCards.concat(v);
							possibleOutCards=possibleOutCards.concat(v);
						}
						
						possibleOutCards=possibleOutCards.concat(SpliteCards.Pairs);
						possibleOutCards=possibleOutCards.concat(SpliteCards.Pairs);

						var linkSize = firstOutCards.length / 2;;
						for(var i=0;i<-1;i++){
							for(var j=0;j<v .length;j++){
								v =lessThanCards[j]
							   if(v.length == i){
									var cardlist = lessThanCards[j].concat();;
									if(cardlist.length + resultCard.length/2 > linkSize){
										return;
									}else if(cardlist.length + resultCard.length/2 == linkSize){
										resultCard=resultCard.concat(cardlist);
										resultCard=resultCard.concat(cardlist);
										return;
									}else{
										 resultCard=resultCard.concat(cardlist);
										 resultCard=resultCard.concat(cardlist);
									}
							   } 
							}                        
						}
						if(resultCard.length/2 < linkSize){
							var linktmpsize = linkSize - resultCard.length/2;;
							if(SpliteCards.Pairs.length <= linktmpsize){
								resultCard=resultCard.concat(SpliteCards.Pairs);
								resultCard=resultCard.concat(SpliteCards.Pairs);
							}else{
								return;
							}
						}else{
							return;
						}
					}
				}
			}        
	   }else if( outCardType == GameShareDef.CARD_TYPE_THROW_CARD){
			var outSplitedCards = this.CreateSplitedCardsTable();;
			this.SplitCards(firstOutCards,this.GetLogicColor(firstOutCards[1]),outSplitedCards);
			var cardOutsize = 0;;
			for(var i=0;i<v .length;i++){
				v =outSplitedCards.Tractors2[i]
				cardOutsize = cardOutsize + v.length;
			}

			var cardHandsize = 0;;
			for(var i=0;i<v .length;i++){
				v =SpliteCards.Tractors2[i]
				cardHandsize = cardHandsize + v.length;
			}

			if(0 < outSplitedCards.Singles.length){
				this.TableCopy(possibleOutCards,cardClassifiy);
			}else{
				if(cardHandsize + SpliteCards.Pairs.length < firstOutCards.length/2){
					this.TableCopy(possibleOutCards,cardClassifiy);
				}else{
					for(var i=0;i< v .length;i++){
						 v =SpliteCards.Tractors2[i]
						possibleOutCards=possibleOutCards.concat( v);
						possibleOutCards=possibleOutCards.concat( v);
					}
								
					possibleOutCards=possibleOutCards.concat( SpliteCards.Pairs);
					possibleOutCards=possibleOutCards.concat( SpliteCards.Pairs);
				}
			}

			 //确定唯一性;
			if(0 < outSplitedCards.Singles.length){
				if(cardHandsize + SpliteCards.Pairs.length <= cardOutsize + outSplitedCards.Pairs.length){
					for(var i=0;i<v .length;i++){
						v =SpliteCards.Tractors2[i]
						resultCard=resultCard.concat(v);
						resultCard=resultCard.concat(v);
					}
					resultCard=resultCard.concat(SpliteCards.Pairs);
					resultCard=resultCard.concat(SpliteCards.Pairs);
				}else{
					var linkSize = firstOutCards.length/2;;
					for(var i=0;i<-1;i++){                   
					   for(var j=0;j<v .length;j++){
					   	v =SpliteCards.Tractors2[j]
							if(v.length == i){
								var cardlist = v.concat();
								if(cardlist.length + resultCard.length/2 > linkSize){
									return;
								}else if( cardlist.length + resultCard.length/2 == linkSize){
									resultCard=resultCard.concat(cardlist);
									resultCard=resultCard.concat(cardlist);
									return;
								}else{
									resultCard=resultCard.concat(cardlist);
									resultCard=resultCard.concat(cardlist);
								}
							}
					   }
						
					}                
					if(resultCard.length/2 < linkSize){
						var linktmpsize = linkSize - resultCard.length/2;;
						if(SpliteCards.Pairs.length <= linktmpsize){
							resultCard=resultCard.concat(SpliteCards.Pairs);
							resultCard=resultCard.concat(SpliteCards.Pairs);
						}else{
							return;
						}
					}else{
						return;
					}
					return;
				}
			}else{
				if(cardHandsize + SpliteCards.Pairs.length <= firstOutCards.length/2){
					for(var i=0;i<v .length;i++){
						v =SpliteCards.Tractors2[i]
						resultCard=resultCard.concat(v);
						resultCard=resultCard.concat(v);
					}
					
					resultCard=resultCard.concat(SpliteCards.Pairs);
					resultCard=resultCard.concat(SpliteCards.Pairs)   ;
				}else{
					var linkSize = firstOutCards.length/2;;
					for(var i=0;i<-1;i++){
						for(var j=0;j<v .length;j++){
							v =SpliteCards.Tractors2[j]
							if(i == v.length){
								var cardlist = v.concat();;
								if(cardlist.length + resultCard.length/2 > linkSize){
									return;
								}else if(cardlist.length + resultCard.length/2 == linkSize){
									resultCard=resultCard.concat(cardlist);
									resultCard=resultCard.concat(cardlist);
									return;
								}else{
									resultCard=resultCard.concat(cardlist);
									resultCard=resultCard.concat(cardlist);
								   
								}
							}
						}
						
					}
					if(resultCard.length/2 < linkSize){
						var linktmpsize = linkSize - resultCard.length/2;
						if(SpliteCards.Pairs.length <= linktmpsize){
							resultCard=resultCard.concat(SpliteCards.Pairs);
							resultCard=resultCard.concat(SpliteCards.Pairs);
						}else{
							return;
						}
					}else{
						return;
					}
					return     ;
				}
			}
	   }
	};
	 //左开右闭（有问题慎用）;
	this.TableRease= function(_card,h,e)
	{
		if(type(_card) != "table"){
			return;
		}

		if(e - 1 < h||_card.length < e - 1){
			return;
		}

		for(var i=0;i<e - 1;i++){        
			table.remove(_card,1)       ;
		}    
	};



	 // 判定是否符合甩牌的所有牌型;
	 // 外部确保所有牌都为同一花色,且排序过;
	this.CheckAllThrowCardTypeFit= function(throwCards,outCards,flagValue,linkFirst)
	{
		if(type(flagValue) != "table" ){
			return false;
		}

		if(type(throwCards) != "table"||type(outCards) != "table"){
			return false;
		}

		if(0 ==throwCards.length||throwCards.length != outCards.length){
			return false;
		}

		var throw_split_cards = this.CreateSplitedCardsTable();
		this.SplitCards(throwCards,this.GetLogicColor(throwCards[1]),throw_split_cards,(linkFirst&&GameShareDef.CARD_TYPE_TRACTOR_2)||GameShareDef.CARD_TYPE_NULL);
			
		var range = this.CreatePair();;
		range.first = -1;
		range.second = -1;

		var idxCards = [];;
		var cardIdx = [];;

		this.ResizeToMax(idxCards,300);
		this.ResizeToMax(cardIdx,300);

		var startIdx = this.GetCardFitValue(outCards[1]);;
		var endIdx = 0;;
		for(var i=0;i<v .length;i++){
			v =outCards[i]
			}Idx = this.GetCardFitValue(v)
			cardIdx[endIdx] = cardIdx[endIdx] + 1;
			idxCards[endIdx] = v ;
		}
		
		var viceMain = [];;
		table.insert(viceMain,Card:make(CardDef.CARD_COLOR_FANG_KUAI,this.GetMainValue()));
		table.insert(viceMain,Card:make(CardDef.CARD_COLOR_MEI_HUA,this.GetMainValue()));
		table.insert(viceMain,Card:make(CardDef.CARD_COLOR_HONG_TAO,this.GetMainValue()));
		table.insert(viceMain,Card:make(CardDef.CARD_COLOR_HEI_TAO,this.GetMainValue()));


		for(var i=0;i<v .length;i++){
			v =viceMain[i]
			if(this.GetCardColor(v) != this.GetMainColor()){
				var val = this.GetCardFitValue(v);

				if(range.first == -1||range.first > val){
					range.first = val;
				}

				if(range.second == -1||range.second < val){
					range.second = val;
				}
			}
		}
		
		 // 只需要检测牌型是否匹配, 所以可以无需具体的索引值;
		this.ResizeToMin(idxCards,startIdx );
		this.ResizeToMin(cardIdx,startIdx);

		this.TableRease(idxCards,1,endIdx);
		this.TableRease(cardIdx,1,endIdx);

		range.first = range.first - endIdx;
		range.second = range.second - endIdx;

		if(range.second < 0||range.first + 1 > idxCards.length){
			range.first = -1;
			range.second = -1;
		}else{
			range.first = math.max(0,range.first);
			range.second = math.min(idxCards.length - 1,range.second);
		}

		if(2 == this.GetPackCount()){
			var out_split_cards = [];;
			this.SplitCards(outCards,this.GetLogicColor(outCards[1]),out_split_cards,(linkFirst&&GameShareDef.CARD_TYPE_TRACTOR_2)||GameShareDef.CARD_TYPE_NULL);

			if(this.CheckFit(throw_split_cards,out_split_cards,range)){
				if(throw_split_cards.Tractors2.length != 0&&out_split_cards.Tractors2.length != 0){
					flagValue.flagValue = out_split_cards.Tractors2[1][1];
				}else if( 0 != throw_split_cards.Pairs.length){
					var maxFlasVal = 0;;
					if(0 != out_split_cards.Pairs.length){
						maxFlasVal = out_split_cards.Pairs[1];
					}
					if(0 != out_split_cards.Tractors2.length&&(CardDef.CARD_NULL == maxFlasVal||this.CompareCardSingle(maxFlasVal,out_split_cards.Tractors2[1][1]))){
						maxFlasVal = out_split_cards.Tractors2[1][1];
					}

					flagValue.flagValue = maxFlasVal;
				}else{
					flagValue.flagValue = outCards[1];
				}
				return true;
			}
		}else{
			var falgIdx = [];;
			if(this.CheckFitFlag(throw_split_cards,cardIdx,range,falgIdx)){
				flagValue.flagValue = idxCards[falgIdx.flagIdx];
				return true;
			}
		}

		return false;
	};

	 //检查甩牌牌型是否符合;
	this.CheckFollowThrowCard= function(throwCards,outCards,chairCards,lc,linkFirst)
	{
		if(throwCards.length == 0||outCards.length == 0||throwCards.length != outCards.length){
			return false;
		}
		flagValue = [];
		flagValue.flagValue = 0;
		if(this.CheckAllThrowCardTypeFit(throwCards,outCards,flagValue,linkFirst)){
			return true;
		}
		var throw_split_cards = this.CreateSplitedCardsTable();
		var out_split_cards = this.CreateSplitedCardsTable();
		var chair_split_cards = this.CreateSplitedCardsTable();
		this.SplitCards(throwCards,this.GetLogicColor(throwCards[1]),throw_split_cards,(linkFirst&&GameShareDef.CARD_TYPE_TRACTOR_2)||GameShareDef.CARD_TYPE_NULL);
		this.SplitCards(outCards,this.GetLogicColor(throwCards[1]),out_split_cards,(linkFirst&&GameShareDef.CARD_TYPE_TRACTOR_2)||GameShareDef.CARD_TYPE_NULL);
		this.SplitCards(chairCards,this.GetLogicColor(throwCards[1]),chair_split_cards,(linkFirst&&GameShareDef.CARD_TYPE_TRACTOR_2)||GameShareDef.CARD_TYPE_NULL);

		if(throw_split_cards.Tractors3.length != 0&&chair_split_cards.Tractors3.length != 0){
			if(out_split_cards.Tractors3.length == 0){
				return false;
			}

			var itr_throw = 1;
			var itr_out = 1;
			var itr_chair = 1;
			while true){
				if(itr_throw <= throw_split_cards.Tractors3.length&&itr_chair <= chair_split_cards.Tractors3.length&&itr_out > out_split_cards.Tractors3.length){
					return false;
				}
				if(itr_throw > throw_split_cards.Tractors3.length||itr_chair > chair_split_cards.Tractors3.length){
					return false;
				}

				if(throw_split_cards.Tractors3[itr_throw].length > out_split_cards.Tractors3[itr_out].length&&chair_split_cards.Tractors3[itr_chair].length > out_split_cards.Tractors3[itr_out].length){
					return false;
				}

				if(chair_split_cards.Tractors3[itr_chair].length > throw_split_cards.Tractors3[itr_throw].length){
					this.ResizeToMin(chair_split_cards.Tractors3[itr_chair],chair_split_cards.Tractors3[itr_chair].length - throw_split_cards.Tractors3[itr_throw].length);

					itr_chair = itr_chair + 1;
				}else{
					table.remove(chair_split_cards.Tractors3,itr_chair);
				}
				table.remove(out_split_cards,itr_out);
				table.remove(throw_split_cards,itr_throw);
			}
		}

		if(throw_split_cards.Tractors2.length != 0){
			if(chair_split_cards.Tractors2.length + chair_split_cards.Tractors3.length > 0&&out_split_cards.Tractors2.length + out_split_cards.Tractors3.length == 0){
				return false;
			}

			var itr_throw = 1;
			var itr_out = 1;
			var itr_chair = 1;
			while true){
				var throwSize = throw_split_cards.Tractors2.length;
				var chairSize = chair_split_cards.Tractors2.length;
				var outSize = out_split_cards.Tractors2.length;

				var itr_throw_size = 1;
				if(0 != throwSize){
					itr_throw_size = throw_split_cards.Tractors2[itr_throw].length;
				}
				var itr_out_size = 1;
				if(0 != outSize){
					itr_out_size = out_split_cards.Tractors2[itr_out].length;
				}
				var itr_chair_size = 1;
				if(0 != chairSize){
					itr_chair_size = chair_split_cards.Tractors2[itr_chair].length;
				}
				if((itr_throw <= throwSize&&itr_chair <= chairSize&&itr_out > outSize)||(itr_throw <= throwSize&&itr_chair <= chairSize&&itr_out <= outSize&&itr_chair_size > itr_out_size&&itr_throw_size > itr_out_size)){
					var itr_find = 0;
					for(var i=0;i<chair_split_cards.Tractors3.length;i++){
						if(chair_split_cards.Tractors3[i].length > itr_throw_size){
							itr_find = i;
							break;
						}
					}
					if(0 == itr_find){
						return false;
					}else{
						this.ResizeToMin(chair_split_cards.Tractors3[itr_find],chair_split_cards.Tractors3[itr_find] - itr_throw_size);
					}
				}

				if(itr_throw > throwSize||itr_out > outSize||itr_chair > chairSize){
					break;
				}

				if(itr_chair_size > itr_throw_size){
					this.ResizeToMin(chair_split_cards.Tractors2[itr_chair],itr_chair_size - itr_throw_size);
					if(chair_split_cards.Tractors2.length >= 2){
						chair_split_cards.Tractors2.sort(this.CompareTractorSize.bind(this));
						itr_chair = 1;
					}
				}else if( itr_chair_size == itr_throw_size){
					table.remove(chair_split_cards.Tractors2,itr_chair);
					 //itr_chair_size = #chair_split_cards.Tractors2[itr_chair];
				}

				if(itr_out_size > itr_throw_size){
					this.ResizeToMin(out_split_cards.Tractors2[itr_out],itr_out_size - itr_throw_size);
					if(out_split_cards.Tractors2.length >= 2){
						out_split_cards.Tractors2.sort(this.CompareTractorSize.bind(this));
						itr_out = 1;
					}
				}else{
					table.remove(out_split_cards.Tractors2,itr_out);
				}

				table.remove(throw_split_cards.Tractors2,itr_throw);
				if(itr_throw > throw_split_cards.Tractors2.length||itr_chair > chair_split_cards.Tractors2.length){
					break;
				}
			}
		}

		 //统计连对和连刻的数量;
		var triCountInTracotr3 = 0;
		var pairCountInTractor2 = 0;
		if(chair_split_cards.Tractors3.length != 0){
			for(var i=0;i<chair_split_cards.Tractors3.length;i++){
				triCountInTracotr3 = triCountInTracotr3 + chair_split_cards.Tractors3[i].length;
			}
		}
		if(chair_split_cards.Tractors2.length != 0){
			for(var i=0;i<chair_split_cards.Tractors2.length;i++){
				pairCountInTractor2 = pairCountInTractor2 + chair_split_cards.Tractors2[i].length;
			}
		}

		var totalTriCnt_chair = chair_split_cards.Triples.length + triCountInTracotr3;
		var totalPairCnt_chair = chair_split_cards.Pairs.length + pairCountInTractor2;
		triCountInTracotr3 = 0;
		pairCountInTractor2 = 0;
		
		if(out_split_cards.Tractors3.length != 0){
			for(var i=0;i<out_split_cards.Tractors3.length;i++){
				triCountInTracotr3 = triCountInTracotr3 + out_split_cards.Tractors3[i];
			}
		}
		if(out_split_cards.Tractors2.length != 0){
			for(var i=0;i<out_split_cards.Tractors2.length;i++){
				pairCountInTractor2 = pairCountInTractor2 + out_split_cards.Tractors2[i];
			}
		}

		var totalTriCnt_out = out_split_cards.Triples.length + triCountInTracotr3;
		var totalPairCnt_out = out_split_cards.Pairs.length + pairCountInTractor2;
		triCountInTracotr3 = 0;
		pairCountInTractor2 = 0;
		if(throw_split_cards.Tractors3.length != 0){
			for(var i=0;i<throw_split_cards.Tractors3.length;i++){
				triCountInTracotr3 = triCountInTracotr3 + throw_split_cards.Tractors3[i].length;
			}
		}
		if(throw_split_cards.Tractors2.length != 0){
			for(var i=0;i<throw_split_cards.Tractors2.length;i++){
				pairCountInTractor2 = pairCountInTractor2 + throw_split_cards.Tractors2[i].length;
			}
		}

		var totalTriCnt_throw = throw_split_cards.Triples.length + triCountInTracotr3;
		var totalPairCnt_throw = throw_split_cards.Pairs.length + pairCountInTractor2;
		if(throw_split_cards.Triples.length != 0&&totalTriCnt_out < totalTriCnt_chair&&totalTriCnt_out < totalTriCnt_throw){  
			return false;
		}

		totalPairCnt_throw = totalPairCnt_throw + totalTriCnt_throw;
		totalPairCnt_chair = totalPairCnt_chair + totalTriCnt_chair;
		totalPairCnt_out = totalPairCnt_out + totalTriCnt_out;
		if(totalPairCnt_out < totalPairCnt_throw&&totalPairCnt_out < totalPairCnt_chair){
			return false;
		}
		return true;
	};
	 //檢查牌是否合法;
	this.CanOutCards= function(outCards,chairCards,firstCards,myChairId,turnOutChairId,firstOutChairId,turnLogicColor,turnCardType,linkFirst)
	{
		if(linkFirst == nil){
			linkFirst = false;
		}
		if(outCards.length == 0||turnOutChairId != myChairId){
			return false;
		}

		 //手牌;
		var sortedOutCards = outCards.concat();;
		this.SortCards(sortedOutCards,false);
		 //自己出的牌;
		var sortedChairCards = chairCards.concat();;
		this.SortCards(sortedChairCards,false);
		var outCardsType = GameShareDef.CARD_TYPE_NULL;;

		outCardsType = this.GetCardsType(sortedOutCards);

		 //first out;
		if(turnOutChairId == firstOutChairId){
	  
			if(outCardsType == GameShareDef.CARD_TYPE_NULL){
				return false;
			}

			return true;
		}

		var sortedFirstOutCards = firstCards.concat();;
		this.SortCards(sortedFirstOutCards,false);

		if(sortedOutCards.length != sortedFirstOutCards.length){
			return false;
		}

		if(this.GetCardCount(sortedFirstOutCards,turnLogicColor) > this.GetCardCount(sortedOutCards,turnLogicColor)&&this.GetCardCount(sortedChairCards,turnLogicColor) > this.GetCardCount(sortedOutCards,turnLogicColor)){
			return false;
		}

		if(turnCardType == outCardsType||outCardsType == GameShareDef.CARD_TYPE_THROW_CARD){
			if(turnLogicColor != this.GetLogicColor(sortedOutCards[1])&&this.HasCard(sortedChairCards,turnLogicColor)){
				return false;
			}
		}else if( outCardsType == GameShareDef.CARD_TYPE_NULL){
			if(this.GetCardCount(sortedChairCards,turnLogicColor) > this.GetCardCount(sortedOutCards,turnLogicColor)){
				return false;
			}
		}else if( outCardsType < GameShareDef.CARD_TYPE_SINGLE||outCardsType > GameShareDef.CARD_TYPE_TRACTOR_3){
			return false;
		}

		if(GameShareDef.CARD_TYPE_SINGLE == turnCardType){
			return true;
		}else if( GameShareDef.CARD_TYPE_SAME_2 == turnCardType){
			if(outCardsType == GameShareDef.CARD_TYPE_THROW_CARD){
				 //有對必須先出對;
				if(this.GetSame2Count(sortedChairCards,turnLogicColor) > 0){
					return false;
				}
			}
		}else if( GameShareDef.CARD_TYPE_SAME_3 == turnCardType){
			if(outCardsType == GameShareDef.CARD_TYPE_THROW_CARD){
				if(this.GetSame3Count(sortedChairCards,turnLogicColor) > 0){
					return false;
				}else if( this.GetSame2Count(sortedChairCards,turnLogicColor) > 0&&this.GetSame2Count(sortedOutCards,turnLogicColor) == 0){
					return false;
				}
			}
		}else if( GameShareDef.CARD_TYPE_TRACTOR_2 == turnCardType){
			if(GameShareDef.CARD_TYPE_THROW_CARD == outCardsType){
				 //有拖拉機必須顯出拖拉機;
				if(this.HasTractor2(sortedChairCards,turnLogicColor,sortedFirstOutCards.length / 2)){
					return false;
				}

				 //有對顯出對;
				var outPairCount = this.GetSame2Count(sortedOutCards,turnLogicColor);;
				if(outPairCount < sortedFirstOutCards.length/2&&this.GetSame2Count(sortedChairCards,turnLogicColor) > outPairCount){
					return false;
				}
			}
		}else if( GameShareDef.CARD_TYPE_THROW_CARD == turnCardType){
			if(turnLogicColor == this.GetLogicColor(sortedOutCards[1])&&this.GetLogicColor(sortedOutCards[1]) == this.GetLogicColor(sortedOutCards[sortedOutCards.length-1])){
				if(!this.CheckFollowThrowCard(sortedFirstOutCards,sortedOutCards,sortedChairCards,turnLogicColor,linkFirst)){
					return false;
				}
			}
		}else{
			return false;
		}

		return true;
	};

	 //设置埋牌的数量;
	this.SetHideCardsCount= function(value)
	{
		this.HideCardsCount = value;
	};
	 //得到埋牌的数量;
	this.GetHideCardsCount= function()
	{
		return this.HideCardsCount;
	};
	 //  检查牌型;
	this.CheckCardsType= function(cards,cardsType)
	{
		if(GameShareDef.CARD_TYPE_NULL == cardsType){
			return this.GetLogicColor(cards[1]) != this.GetLogicColor(cards[cards.length]);
		}else if( GameShareDef.CARD_TYPE_SINGLE == cardsType){
			return cards.length == 1;
		}else if( GameShareDef.CARD_TYPE_SAME_2 == cardsType){
			return cards.length == 2&&cards[1] == cards[2];
		}else if( GameShareDef.CARD_TYPE_TRACTOR_2 == cardsType){
			if(cards.length < 4||cards.length%2 != 0){
				return false;
			}
			var logicValue = this.GetCardLogicValue(cards[1]);
			var tractorCount = cards.length/2;
			for(var i=0;i<tractorCount-1;i++){
				if(cards[i*2+1] != cards[i*2+2]||logicValue - this.GetCardLogicValue(cards[i*2+1]) != i){
					return false;
				}
			}
			return true;
		}else if( GameShareDef.CARD_TYPE_THROW_CARD == cardsType){
			if(cards.length < 2){
				return false;
			}
			return this.GetLogicColor(cards[1]) == this.GetLogicColor(cards[cards.length-1]);
		}
		return false;
	};
	 //// 得到甩牌;
	this.GetFollowThrowCard= function(throwCards,chairCards,result,lc,isLinkFirst)
	{
		if(nil == isLinkFirst){
			isLinkFirst = false;
		}
		if(chairCards.length < throwCards.length){
			return;
		}

		 //  同种花色的牌;
		var handCards = [];
		for(var i=0;i<chairCards.length;i++){
			if(this.GetLogicColor(chairCards[i]) == lc){
				handCards.push(chairCards[i]);
			}else if( 0 != handCards.length){
				break;
			}
		}
		if(0 == handCards.length){
			for(var i=0;i<-1;i++){            
				result.push(chairCards[i]);
				if(result.length == throwCards.length){
					return;
				}        
			}
		}

		if(handCards.length <= throwCards.length){
			result=result.concat(handCards);
			if(result.length == throwCards.length){
				return;
			}
			for(var i=0;i<-1;i++){
				if(this.GetLogicColor(chairCards[i]) != lc){
					result.push(chairCards[i]);
					if(result.length == throwCards.length){
						return;
					}
				}
			}
			return;
		}

		var throwCard_split = [];
		var tmpCardType = GameShareDef.CARD_TYPE_NULL;
		if(isLinkFirst){
			tmpCardType = GameShareDef.CARD_TYPE_TRACTOR_2;
		}
		this.SplitCards(throwCards,this.GetLogicColor(throwCards[1]),throwCard_split,tmpCardType);
		var handCards_split = [];
		this.SplitCards(handCards,lc,handCards_split,tmpCardType);

		if(0 != throwCard_split.Tractors2.length){
			for(var i=0;i<throwCard_split.Tractors2.length;i++){
				var length = throwCard_split.Tractors2[i].length;
				while length >= 2&&0 != handCards_split.Tractors2.length){
					var handTrac2 = handCards_split.Tractors2[1];
					if(handTrac2.length <= length){
						for(var j=0;j<handTrac2.length;j++){
							result.push(handTrac2[j]);
							result.push(handTrac2[j]);
						}
						length = length - handTrac2.length;
						table.remove(handCards_split.Tractors2,1);
					}else{
						var leftSize = handTrac2.length - length;
						for(var j=0;j<-1;j++){
							result.push(handTrac2[j]);
							result.push(handTrac2[j]);
							length = length - 1;
							if(0 == length){
								break;
							}
						}
						if(leftSize >= 2){
							this.ResizeToMin(handCards_split.Tractors2[1],leftSize);
							handCards_split.Tractors2.sort(this.CompareTractorSize.bind(this));
						}else{
							handCards_split.Pairs.push(handTrac2[1]);
							table.remove(handCards_split.Tractors2,1);
							break;
						}
					}
				}

				if(length > 0&&0 != handCards_split.Pairs.length){
					var pairs = handCards_split.Pairs;
					var leftSize = 0;
					if(pairs.length > length){
						leftSize = pairs.length - length;
					}
					for(var j=0;j<-1;j++){
						result.push(pairs[j]);
						result.push(pairs[j]);
						length = length - 1;
						if(0 == length){
							break;
						}
					}
					this.ResizeToMin(handCards_split.Pairs,leftSize);
				}
				
			}
		}

		if(0 != handCards_split.Tractors2.length){
			for(var i=0;i<handCards_split.Tractors2.length;i++){
				if(0 != handCards_split.Tractors2[i].length){
					handCards_split.Pairs=handCards_split.Pairs.concat(handCards_split.Tractors2[i])                ;
				}
			}
		}

		if(0 != throwCard_split.Pairs.length){
			var leftPairLen = throwCard_split.Pairs.length;
			if(0 != handCards_split.Pairs.length){
				var pairs = handCards_split.Pairs;
				var leftSize = 0;
				if(pairs.length > leftPairLen){
					leftSize = pairs.length - leftPairLen;
				}

				for(var i=0;i<-1;i++){
					result.push(pairs[i]);
					result.push(pairs[i]);
					leftPairLen = leftPairLen - 1;
					if(0 == leftPairLen){
						break;
					}                                        
				}
				this.ResizeToMin(handCards_split.Pairs,leftSize)     ;
			}
		}

		if(result.length < throwCards.length){
			this.RemoveCards(handCards,result);
			for(var i=0;i<-1;i++){
				result.push(handCards[i]);
				if(result.length == throwCards.length){
					break;
				}
			}
		}
	};

	this.IsContainCardValueInTables= function(_resCardList,_a)
	{
		for(var i=0;i<_resCardList.length;i++){
			if(table.indexof(_resCardList[i],_a)){
				return true;
			}
		}
		return false;
	};
	GameLogic._scanTable = [];
	GameLogic._TishiStu = [];
	GameLogic._TishiStu.cardList = [];
	GameLogic._TishiStu.mustOutCards = [];
	GameLogic._TishiStu.possOutCards = {[],[],[],[],[]}
	GameLogic._TishiStu.turnOutCount = 0;
	GameLogic._TishiStu.turnOutList = [];
	GameLogic._TishiStu.turnLogicColor = 0;
	GameLogic._TishiStu.isLinkFirst = false;
	GameLogic._TishiStu.resCardList = [];

	this.TipSingle= function(_TishiStu)
	{
		if(_TishiStu.mustOutCards.length >= _TishiStu.turnOutCount){        
			for(var i=0;i<_TishiStu.mustOutCards.length;i++){
				if(!this.IsContainCardValueInTables(_TishiStu.resCardList,_TishiStu.mustOutCards[i])&&1 == this.FindCardCount(_TishiStu.mustOutCards,(_TishiStu.mustOutCards[i]))){
					var tmpList = [];
					tmpList.push(_TishiStu.mustOutCards[i]);
					_TishiStu.resCardList.push(tmpList);
				}
			}
			for(var i=0;i<_TishiStu.mustOutCards.length;i++){
				if(!this.IsContainCardValueInTables(_TishiStu.resCardList,_TishiStu.mustOutCards[i])&&2 <= this.FindCardCount(_TishiStu.mustOutCards,(_TishiStu.mustOutCards[i]))){
					var tmpList = [];
					tmpList.push(_TishiStu.mustOutCards[i]);
					_TishiStu.resCardList.push(tmpList);
				}
			}
			return;
		}
		this.GetTipMustCardsLack(_TishiStu);
	};
	this.FindCardValueCount= function(_cardList,_value)
	{
		var cardCount = 0;
		for(var i=0;i<_cardList.length;i++){
			if(this.GetCardValue(_cardList[i]) == _value){
				cardCount = cardCount + 1;
			}
		}
		return cardCount;
	};
	this.FindCardCount= function(_cardList,_value)
	{
		var cardCount = 0;
		for(var i=0;i<_cardList.length;i++){
			if((_cardList[i]) == _value){
				cardCount = cardCount + 1;
			}
		}
		return cardCount;
	};
	 //数量从小到大;
	this.SortCardsByCount= function(_cardList)
	{
		if(0 == _cardList.length){
			return;
		}
		var tmpList = {[],[]}
		for(var i=0;i<_cardList.length;i++){
			var cardCount = this.FindCardCount(_cardList,_cardList[i]);
			if(cardCount == 1&&0 == this.FindCardCount(tmpList[1],_cardList[i])){
				tmpList[1].push(_cardList[i]);
			}else if( cardCount == 2&&0 == this.FindCardCount(tmpList[2],_cardList[i])){
				tmpList[2].push(_cardList[i]);
			}
		}
		for(var i=0;i<tmpList.length;i++){
			this.SortCards(tmpList[i],true);
		}
		
		for(var i=0;i<_cardList.length;i++){
			_cardList[i] = nil;
		}
		
		if(0 != tmpList[1].length){
			_cardList=_cardList.concat(tmpList[1]);
		}
		for(var i=0;i<tmpList[2].length;i++){
			_cardList.push(tmpList[2][i]);
			_cardList.push(tmpList[2][i]);
		}    
	};

	this.TipPair= function(_TishiStu)
	{
		if(_TishiStu.mustOutCards.length >= _TishiStu.turnOutCount){    
			 //找对子;
			for(var i=0;i<_TishiStu.mustOutCards.length;i++){
				var cardCount = this.FindCardCount(_TishiStu.mustOutCards,(_TishiStu.mustOutCards[i]));
				if(!this.IsContainCardValueInTables(_TishiStu.resCardList,_TishiStu.mustOutCards[i])&&2 == cardCount){
					var tmpList = [];
					tmpList.push(_TishiStu.mustOutCards[i]);
					tmpList.push(_TishiStu.mustOutCards[i]);
					_TishiStu.resCardList.push(tmpList);
				}
			}
			for(var i=0;i<_TishiStu.mustOutCards.length;i++){
				var cardCount = this.FindCardCount(_TishiStu.mustOutCards,(_TishiStu.mustOutCards[i]));
				if(!this.IsContainCardValueInTables(_TishiStu.resCardList,_TishiStu.mustOutCards[i])&&2 < cardCount){
					var tmpList = [];
					tmpList.push(_TishiStu.mustOutCards[i]);
					tmpList.push(_TishiStu.mustOutCards[i]);
					_TishiStu.resCardList.push(tmpList);
				}
			}
			if(0 == _TishiStu.resCardList.length){
				var tmpList = [];
				this.SortCards(_TishiStu.mustOutCards,true);
				this.SortCardsByCount(_TishiStu.mustOutCards);
				for(var i=0;i<_TishiStu.mustOutCards.length;i++){   
					if(i < _TishiStu.mustOutCards.length){                    
						tmpList.push( _TishiStu.mustOutCards[i]);
						tmpList.push( _TishiStu.mustOutCards[i+1]);
						if(2 == tmpList.length){                        
							_TishiStu.resCardList.push( tmpList);
							tmpList = [];
						}
					}            
				}  
			} 
			return;
		}
		this.GetTipMustCardsLack(_TishiStu);
	};
	this.DeleateSame= function(_a)
	{
		for(var i=0;i<-1;i++){
			if(i-1 >= 1&&_a[i-1] == _a[i]){
				table.remove(_a,i);
			}
		}    
	};
	this.IsSameCards= function(_a,_b)
	{
		var a = _a.concat();
		var b = _b.concat();
		// a);
.sort(this.		// table.sort(a.bind(this));
		// b);
.sort(this.		// table.sort(b.bind(this));
		a.sort();
		b.sort();
		if(a.length != b.length){
			return false;
		}
		for(var i=0;i<a.length;i++){
			if(a[i] != b[i]){
				return false;
			}
		}
		return true;
	};
	this.GetTipMustCardsLack= function(_TishiStu)
	{
		var leaveCount = _TishiStu.turnOutCount - _TishiStu.mustOutCards.length;
		var tmpList = [];
		tmpList=tmpList.concat(_TishiStu.mustOutCards);
		var possOut = _TishiStu.cardList.concat();
		this.RemoveCards(possOut,_TishiStu.mustOutCards);
		var zhuList = [];
		for(var i=0;i<-1;i++){
			if(this.GetLogicColor(possOut[i]) == GameShareDef.LOGIC_CARD_COLOR_MAIN){
				zhuList.push(possOut[i]);
				table.remove(possOut,i);
			}
		}
		this.SortCardsByCount(possOut);
		this.SortCardsByCount(zhuList);
		if(zhuList.length != 0){
			possOut=possOut.concat(zhuList);
		}
		if(1 == leaveCount){
			this.DeleateSame(possOut);
		}
		for(var i=0;i<possOut.length;i++){
			var tmpResList = tmpList.concat();
			for(m=i,possOut.length){
				if(tmpResList.length != _TishiStu.turnOutCount){
					tmpResList.push(possOut[m]);
				}else{
					break;
				}
			}        
			if(tmpResList.length == _TishiStu.turnOutCount){
				_TishiStu.resCardList.push( tmpResList);
			}
		}
	   
	};
	this.TipLinkTwo= function(_TishiStu)
	{
		if(_TishiStu.mustOutCards.length >= _TishiStu.turnOutCount){    
			var splitCards = [];
			 //这个函数必须是从大到小排序;
			this.SortCards(_TishiStu.mustOutCards,false);
			this.SplitCards(_TishiStu.mustOutCards,_TishiStu.turnLogicColor,splitCards,GameShareDef.CARD_TYPE_TRACTOR_2);
			
			 //先看看有没有;
			for(var i=0;i<-1;i++){
				if(splitCards.Tractors2[i].length*2 >= _TishiStu.turnOutCount){
					var tmpList = [];
					var m = splitCards.Tractors2[i].length;
					while true){
						tmpList.push(splitCards.Tractors2[i][m]);
						tmpList.push(splitCards.Tractors2[i][m]);
						if(tmpList.length == _TishiStu.turnOutCount){      
							table.remove(splitCards.Tractors2[i],splitCards.Tractors2[i].length)                                          ;
							_TishiStu.resCardList.push(tmpList);
							tmpList = []          ;
							m = splitCards.Tractors2[i].length;
						}else{
							m = m - 1;
							if(m <= 0){
								break;
							}            
						}
					}
				}
			}
			if(0 != _TishiStu.resCardList.length){
				return;
			}
			 //找到一个最长的;
			var tmpList = [];
			if(0 != splitCards.Tractors2.length){
				for(var i=0;i<-1;i++){
					if(2 < _TishiStu.turnOutCount - tmpList.length&&splitCards.Tractors2[1].length*2 + tmpList.length < _TishiStu.turnOutCount){
						tmpList=tmpList.concat(splitCards.Tractors2[1]);
						tmpList=tmpList.concat(splitCards.Tractors2[1]);
						table.remove(splitCards.Tractors2,1);
					}else{
						break;
					}
				}
			   
				if(2 < _TishiStu.turnOutCount - tmpList.length){
					this.GetTipRestCards(splitCards,_TishiStu,GameShareDef.CARD_TYPE_TRACTOR_2,tmpList);
				}            
			}
			 //开始找对子;
			if(0 != _TishiStu.resCardList.length){
				return;
			}
			 //把自己牌中剩下的拖拉机放进对子里;
			for(var i=0;i<splitCards.Tractors2.length;i++){
				if(0 != splitCards.Tractors2[i].length){
					splitCards.Pairs=splitCards.Pairs.concat(splitCards.Tractors2[i]);
				}            
			}
			this.SortCards(splitCards.Pairs,false);
			
			 //对子牌够了;
			if(splitCards.Pairs.length*2 + tmpList.length >= _TishiStu.turnOutCount){
				this.GetTipRestCards(splitCards,_TishiStu,GameShareDef.CARD_TYPE_SAME_2,tmpList);
				return     ;
			}

			 //找到一个最长的;
			for(var i=0;i<-1;i++){            
				tmpList.push(splitCards.Pairs[i]);
				tmpList.push(splitCards.Pairs[i]);
				table.remove(splitCards.Pairs,i);
			}
		   
			 //找到一个最长的;
			var Singles = _TishiStu.mustOutCards.concat();
			this.RemoveCards(Singles,tmpList);
			this.SortCards(Singles,false);
			
			this.GetTipRestCards(splitCards,_TishiStu,GameShareDef.CARD_TYPE_SINGLE,tmpList,Singles)       ;
			return;
		}
		this.GetTipMustCardsLack(_TishiStu);
	};
	this.GetTipTractor2= function(SplitOutCards,SplitHandCards,tmpList,length,handIndex)    
	{
		var tmpResList = [];
		for(var s=0;s<-1;s++){
			tmpResList.push(SplitHandCards.Tractors2[handIndex][s]);
			tmpResList.push(SplitHandCards.Tractors2[handIndex][s]);
			table.remove(SplitHandCards.Tractors2[handIndex],s);
			if(length == math.floor(tmpResList.length/2)){
				tmpList=tmpList.concat(tmpResList);
				if(0 == SplitHandCards.Tractors2[handIndex].length){
					table.remove(SplitHandCards.Tractors2,handIndex)             ;
				}else{
					if(SplitHandCards.Tractors2[handIndex].length <= 1){
						SplitHandCards.Pairs.push(SplitHandCards.Tractors2[handIndex][1]);
						this.SortCards(SplitHandCards.Pairs,false);
						table.remove(SplitHandCards.Tractors2,handIndex)      ;
					}else{
						SplitHandCards.Tractors2.sort(this.CompareTractorSize.bind(this));
						return true //代表改顺子没有用完;
					}       
				}         
				break;
			}                            
		}
	};
	this.GetTipRestCards= function(SplitHandCards,_TishiStu,_restType,tmpList,Singles)
	{
		var _restCount = _TishiStu.turnOutCount - tmpList.length;
		if(_restType == GameShareDef.CARD_TYPE_TRACTOR_2){
			for(var i=0;i<-1;i++){
				var tmpResList = [];
				var m = SplitHandCards.Tractors2[i].length;
				while true){
					tmpResList.push(SplitHandCards.Tractors2[i][m]);
					tmpResList.push(SplitHandCards.Tractors2[i][m]);
					if(tmpResList.length == _restCount){      
						table.remove(SplitHandCards.Tractors2[i],SplitHandCards.Tractors2[i].length)    ;
						tmpResList=tmpResList.concat(tmpList);
						_TishiStu.resCardList.push(tmpResList);
						tmpResList = []          ;
						m = SplitHandCards.Tractors2[i].length;
					}else{
						m = m - 1;
						if(m <= 0){
							break;
						}            
					}
				 }
			}   
		}else if( _restType == GameShareDef.CARD_TYPE_SAME_2){
			for(var i=0;i<-1;i++){  
				var tmpResList = tmpList.concat()  ;
				for(m=i,SplitHandCards.Pairs.length){
					if(tmpResList.length != _TishiStu.turnOutCount){
						tmpResList.push(SplitHandCards.Pairs[m]);
						tmpResList.push(SplitHandCards.Pairs[m]);
					}else{
						break;
					}
				}
				if(tmpResList.length == _TishiStu.turnOutCount){
					_TishiStu.resCardList.push(tmpResList);
				}
			}      
		}else if( _restType == GameShareDef.CARD_TYPE_SINGLE){
			if(_restCount == 1){
				for(var i=0;i<-1;i++){
				   if(i-1 > 0&&Singles[i-1] == Singles[i]){
						table.remove(Singles,i);
				   } 
				}            
			}
			for(var i=0;i<-1;i++){                
				if(_restCount + #tmpList >= _TishiStu.turnOutCount){
					var tmpResList = tmpList.concat() ;
					for(var s=0;s<_restCount-1;s++){
						if(i-s >= 1){
							tmpResList.push(Singles[i-s]);
						}
					}               
																		  
					table.remove(Singles,i)                ;
					if(tmpResList.length == _TishiStu.turnOutCount){
						_TishiStu.resCardList.push(tmpResList);
					}                
				}
			}
		}
	};
	this.TableResize= function(_a,size)
	{
		for(var i=0;i<-1;i++){
			if(_a.length > size){
				table.remove(_a,i);
			}else{
				break;
			}
		}    
	};
	this.TipThrow= function(_TishiStu)
	{
		if(_TishiStu.mustOutCards.length >= _TishiStu.turnOutCount){    
			var SplitOutCards = [];
			var SplitHandCards = [];
			if(_TishiStu.isLinkFirst){
				this.SplitCards(_TishiStu.turnOutList,_TishiStu.turnLogicColor,SplitOutCards,GameShareDef.CARD_TYPE_TRACTOR_2);
				this.SplitCards(_TishiStu.cardList,_TishiStu.turnLogicColor,SplitHandCards,GameShareDef.CARD_TYPE_TRACTOR_2);
			}else{
				this.SplitCards(_TishiStu.turnOutList,_TishiStu.turnLogicColor,SplitOutCards,GameShareDef.CARD_TYPE_NULL   );
				this.SplitCards(_TishiStu.cardList,_TishiStu.turnLogicColor,SplitHandCards,GameShareDef.CARD_TYPE_NULL   );
			}
			 //先从最小的拖拉机找;
			var tipType = 0 ;
			var tmpList = [];
			if(0 != SplitOutCards.Tractors2.length){
				for(var i=0;i<SplitOutCards.Tractors2.length;i++){
					var length = SplitOutCards.Tractors2[1].length     ;
					if(0 == SplitHandCards.Tractors2.length){
						break;
					}
					var m = SplitHandCards.Tractors2.length    ;
					while true){
						if(0 == SplitHandCards.Tractors2.length||0 == SplitHandCards.Tractors2.length[SplitHandCards.Tractors2].length-1){
							break;
						}                   
						var handLength = SplitHandCards.Tractors2[m].length     ;
						if(0 == SplitOutCards.Pairs.length&&0 == SplitOutCards.Singles.length&&1 == SplitOutCards.Tractors2.length&&handLength*2 + tmpList.length >= _TishiStu.turnOutCount){
							tipType = GameShareDef.CARD_TYPE_TRACTOR_2;
							break;
						}        
						if(handLength >= length){                        
							table.remove(SplitOutCards.Tractors2,i);
							var isSave = this.GetTipTractor2(SplitOutCards,SplitHandCards,tmpList,length,m);
							if(!isSave){
								m = m - 1;
								if(m <= 0){
									break;
								}
							}
						}else{
							m = m - 1;
							if(m <= 0){
								break;
							}
						}
					}                     
				}            
				 //从最大的拖拉机开始找,找一个最长的              ;
				for(var i=0;i<SplitOutCards.Tractors2.length;i++){
					var length = SplitOutCards.Tractors2[i].length                ;
					while (true){
						var m = 1                 ;
						if(0 == SplitHandCards.Tractors2.length||0 == SplitHandCards.Tractors2[SplitHandCards.Tractors2.length-1].length){
							break;
						}                  
						
						var handLength = SplitHandCards.Tractors2[m].length     ;
						if(0 == SplitOutCards.Pairs.length&&0 == SplitOutCards.Singles.length&&i == SplitOutCards.Tractors2.length&&handLength*2 + tmpList.length >= _TishiStu.turnOutCount){
							tipType = GameShareDef.CARD_TYPE_TRACTOR_2;
							break;
						}          
						var needLength = handLength;
						if(needLength > length){
							needLength = length;
						}                                      
						
						this.GetTipTractor2(SplitOutCards,SplitHandCards,tmpList,needLength,m);
						length = length - needLength;
						this.TableResize(SplitOutCards.Tractors2[i],length);
						if(length == 0){                        
							break;
						}
					}               
					if(length > 0){
						break;
					}                   
				}
				if(tipType != 0){
					this.GetTipRestCards(SplitHandCards,_TishiStu,tipType,tmpList,SplitHandCards.Singles);
					return;
				}
			}
			 //把对手的拖拉机放进对子里;
			for(var i=0;i<SplitOutCards.Tractors2.length;i++){
				if(SplitOutCards.Tractors2[i].length != 0){
					SplitOutCards.Pairs=SplitOutCards.Pairs.concat(SplitOutCards.Tractors2[i]);
				}
			}
			
			 //把自己牌中剩下的拖拉机放进对子里;
			for(var i=0;i<SplitHandCards.Tractors2.length;i++){
				if(0 != SplitHandCards.Tractors2[i].length){
					SplitHandCards.Pairs=SplitHandCards.Pairs.concat(SplitHandCards.Tractors2[i]);
				}            
			}
			this.SortCards(SplitHandCards.Pairs,false);

			if(0 != SplitOutCards.Pairs.length&&0 == SplitOutCards.Singles.length&&SplitHandCards.Pairs.length*2 + #tmpList >= _TishiStu.turnOutCount){
				this.GetTipRestCards(SplitHandCards,_TishiStu,GameShareDef.CARD_TYPE_SAME_2,tmpList);
				return;
			}
			
			if(0 != SplitOutCards.Pairs.length){
				this.SortCards(SplitHandCards.Pairs,false);
				var length = SplitOutCards.Pairs.length;
				for(var i=0;i<-1;i++){                
					if(0 != SplitHandCards.Pairs.length){                    
						tmpList.push(SplitHandCards.Pairs[SplitHandCards.Pairs.length-1]);
						tmpList.push(SplitHandCards.Pairs[SplitHandCards.Pairs.length-1]);
						table.remove(SplitHandCards.Pairs,SplitHandCards.Pairs.length);
						table.remove(SplitOutCards.Pairs,i)            ;
					}else{
						break;
					}
				}              
			}
				var Singles = _TishiStu.mustOutCards.concat();
				this.RemoveCards(Singles,tmpList);
				this.SortCards(Singles,false);
				this.GetTipRestCards(SplitHandCards,_TishiStu,GameShareDef.CARD_TYPE_SINGLE,tmpList,Singles);
			return;
		}
			
		this.GetTipMustCardsLack(_TishiStu);
	};
	 //得到要出的牌;
	this.GetSimpleOutCards= function(getOutCards,handCard,firstOutCards,myselfChairId,firstOutChairId,turnLogicColor,turnCardType,isLinkFirst)
	{
		//Utils.ccLog(" // // // // // //-1 // // // // // //-");
		if(nil == isLinkFirst){
			isLinkFirst = false;
		}
		var cardsType = 0;
		if(type(getOutCards) != "table"||type(handCard) != "table"||0 == handCard.length){
			return cardsType;
		}
		//Utils.ccLog(" // // // // // //-2 // // // // // //-");
		if(firstOutChairId == myselfChairId){
			//Utils.ccLog(" // // // // // //-3 // // // // // //-");
			var split_cards = [];
			this.SplitCards(handCard,this.GetLogicColor(handCard[handCard.length-1]),split_cards);
			if(0 != split_cards.Tractors2.length){
				cardsType = GameShareDef.CARD_TYPE_TRACTOR_2;
				var t = [];
				var tractor = split_cards.Tractors2[split_cards.Tractors2.length];
				for(var i=0;i<tractor.length;i++){
					t.push(tractor[i]);
					t.push(tractor[i]);
				}
				getOutCards.push( t);
			}else if( 0 != split_cards.Triples.length){
				cardsType = GameShareDef.CARD_TYPE_SAME_3;
				var t = [];
				t.push(split_cards.Triples[split_cards.Triples.length-1]);
				t.push(split_cards.Triples[split_cards.Triples.length-1]);
				t.push(split_cards.Triples[split_cards.Triples.length-1]);
				getOutCards.push( t);
			}else if( 0 != split_cards.Pairs.length){
				cardsType = GameShareDef.CARD_TYPE_SAME_2;
				var t = [];
				t.push(split_cards.Pairs[split_cards.Pairs.length-1]);
				t.push(split_cards.Pairs[split_cards.Pairs.length-1]);
				getOutCards.push( t);
			}else{
				cardsType = GameShareDef.CARD_TYPE_SINGLE;
				getOutCards.push({handCard[handCard-1]});
			}
			//Utils.ccLog(" // // // // // //-end // // // // // //-");
			return cardsType;
		}

		this.SortCards(firstOutCards,false);
		//Utils.ccLog(" // // // // // //-3 // // // // // //-");
		var _TishiStu = this.TishiStu.concat();
		_TishiStu.turnOutCount = firstOutCards.length;
		_TishiStu.cardList = handCard.concat();
		for(var i=0;i<handCard.length;i++){
			if(this.GetLogicColor(handCard[i]) == turnLogicColor){
				_TishiStu.mustOutCards.push(handCard[i]);
			}
		}
		//Utils.ccLog(" // // // // // //-4 // // // // // //-");
		this.SortCards(_TishiStu.mustOutCards,true);
		_TishiStu.possOutCards = {[],[],[],[],[]}
		if(_TishiStu.mustOutCards.length < firstOutCards.length){
			for(var i =0;i < handCard.length;i ++){
				if(!table.indexof(_TishiStu.mustOutCards,handCard[i])){
					var color = this.GetCardColor(handCard[i])/16;
					_TishiStu.possOutCards[color].push(handCard[i]);
				}
			}
			for(var i=0;i<5;i++){
				this.SortCards(_TishiStu.possOutCards[i],true);
			}        
		}
		//Utils.ccLog(" // // // // // //-5 // // // // // //-");
		_TishiStu.turnOutCount = firstOutCards.length;
		_TishiStu.turnOutList = firstOutCards.concat();
		_TishiStu.turnLogicColor = turnLogicColor;
		_TishiStu.isLinkFirst = isLinkFirst;
		
		//Utils.ccLog(" // // // // // //-6 // // // // // //-");
		if(turnCardType == GameShareDef.CARD_TYPE_SINGLE){
			this.TipSingle(_TishiStu);
		}else if( turnCardType == GameShareDef.CARD_TYPE_SAME_2){
			this.TipPair(_TishiStu);
		}else if( turnCardType == GameShareDef.CARD_TYPE_TRACTOR_2){
			this.TipLinkTwo(_TishiStu);
		}else if( turnCardType == GameShareDef.CARD_TYPE_THROW_CARD){
			this.TipThrow(_TishiStu);
		}
		getOutCards=getOutCards.concat(_TishiStu.resCardList);
		//Utils.ccLog(" // // // // // //-end // // // // // //-");
	};

	this.IsScoreCard= function( card )
	{
		var cardValue = this.GetCardValue(card);
		if(cardValue==CardDef.CARD_VALUE_K||cardValue==CardDef.CARD_VALUE_10||cardValue==CardDef.CARD_VALUE_5){
			return true;
		}
		return false;
	};

	this.InserTable= function(table1,table2)
	{
		if(table1==nil||table2==nil){
			return ;
		}
		for(var i=0;i<table2.length;i++){
			table1[table1.length]=table2[i];
		}
	};
	this.CalcuStepValue= function(value)
	{
		return ((value-1+13)%13)+1;
	};
	this.isTractor= function( cards )
	{
		cards = cards||[];
		if(cards.length > 0){
			var lc = this.GetLogicColor(cards[1]);
			var result = [];
			this.SplitCards(cards, lc , result);
			return result.Tractors2.length == 1&&result.Tractors2[1].length * 2 == cards.length;
		}

		return false;
	};
	this.GetCardValue = function(card) {
		return card % 16; //CardDef.CARD_VALUE(card)
	};
	this.GetCardColor = function(card) {
		return Math.floor(card / 16) * 16; //CardDef.CARD_COLOR(card);
	};




	var ctor = (function() {

	}).bind(this);


	// 执行构造函数
	ctor();
}
module.exports = {
	// 	FIRST_HANDCARD_COUNT: FIRST_HANDCARD_COUNT,
	// 	MAX_HIDECARD_COUNT: MAX_HIDECARD_COUNT,
	// 	CardVector: CardVector,
	// 	CardsVector: CardsVector,
	// 	splitedCards: splitedCards,
	// 	analyzedCards: analyzedCards,
	// 	signalData: signalData,
	// packCards: packCards,
	GameLogic: GameLogic,
}