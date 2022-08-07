//+------------------------------------------------------------------+
//|                                        KompleksEAAbstraction.mqh |
//|                                       Copyright 2022, KompleksEA |
//|                            https://www.kompleksanda.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, KompleksEA"
#property link      "https://www.kompleksanda.blogspot.com"

#include <MT5TradingLibrary/Include/KompleksClassAbstraction.mqh>

class Utility {
    private:
        CandleManager* cMan;
        OrderManager* oMan;
        PositionManager* pMan;
    public:
    Utility(CandleManager* cM, OrderManager* oM, PositionManager* pM) {
        cMan = cM;
        oMan = oM;
        pMan = pM;
    }
    bool deleteAllPendingOrder() {
        bool done = true;
        if (oMan.totalOwnOrders() > 0) {
            ulong ownOrders[];
            oMan.copyOwnPendingTickets(ownOrders);
            for (int i = 0; i < ArraySize(ownOrders); i++) {
                if (oMan.deleteOrder(ownOrders[i]) == ACTION_ERROR) done = false;
            }
        }
        return done;
    }
    bool deleteGivenPendingOrder(ulong &pTickets[]) {
        for (int i = 0; i < ArraySize(pTickets); i++) {
            if (pTickets[i] != WRONG_VALUE && oMan.deleteOrder(pTickets[i]) == ACTION_ERROR) {
                if (VERBOSE) Print("could'nt delete pending order");
                return false;
            }
            pTickets[i] = WRONG_VALUE;
        }
        return true;
    }
};

class SignalIn {
    private:
        MarketStructureManager* cMan;
        OrderManager* oMan;
        PositionManager* pMan;
        Utility* utility;
    public:
    double marketVolume;
    int multiCount;
    SignalIn(MarketStructureManager* cM, OrderManager* oM, PositionManager* pM, Utility* pUtility) {
        cMan = cM;
        oMan = oM;
        pMan = pM;
        utility = pUtility;
        marketVolume = 0;
        multiCount = 0;
    }
    ENUM_SIGNAL tradeSignal(ENUM_SIGNAL pSig, bool invert = false) {
        if (pSig == SIGNAL_BUY) {
            if (invert) return marketCanSell(false, false, true, "normal", false);
            else return marketCanBuy(false, false, true, "normal", false);
        } else if (pSig == SIGNAL_SELL) {
            if (invert) return marketCanBuy(false, false, true, "normal", false);
            else return marketCanSell(false, false, true, "normal", false);
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL wavePredictMarket(STRUCT_CHARTPATTERN_PRED &__pred[], int _pick = 0, bool invert = false, bool multiMode = false) {
        if (pMan.positionIsOpen()) {
            if (!invert) {
                if (__pred[_pick].direction != pMan.PositionType()) {
                    if (!multiMode && pMan.openPosition(__pred[_pick].direction, -1, __pred[_pick].sl, __pred[_pick].tp, false, true, false) == ACTION_ERROR) return SIGNAL_ERROR;
                    else {
                        ENUM_SIGNAL ret = positionTypeToSignal(__pred[_pick].direction);
                        if (multiMode) {
                            if (ret == SIGNAL_BUY) multiCount += 1;
                            else if (ret == SIGNAL_SELL) multiCount -= 1;
                        }
                        return ret;
                    }
                }
            } else {
                if (__pred[_pick].direction == pMan.PositionType()) {
                    ENUM_POSITION_TYPE pType = __pred[_pick].direction == POSITION_TYPE_BUY ? POSITION_TYPE_SELL : POSITION_TYPE_BUY;
                    if  (!multiMode && pMan.openPosition(pType, -1, __pred[_pick].tp, __pred[_pick].sl, false, true, false) == ACTION_ERROR) return SIGNAL_ERROR;
                    else {
                        ENUM_SIGNAL ret = positionTypeToSignal(pType);
                        if (multiMode) {
                            if (ret == SIGNAL_BUY) multiCount += 1;
                            else if (ret == SIGNAL_SELL) multiCount -= 1;
                        }
                        return ret;
                    }
                }
            }
        } else {
            if (invert) {
                ENUM_POSITION_TYPE pType = __pred[_pick].direction == POSITION_TYPE_BUY ? POSITION_TYPE_SELL : POSITION_TYPE_BUY;
                if (!multiMode && pMan.openPosition(pType, -1, __pred[_pick].tp, __pred[_pick].sl, false, true, false) == ACTION_ERROR) return SIGNAL_ERROR;
                else {
                    ENUM_SIGNAL ret = positionTypeToSignal(pType);
                    if (multiMode) {
                        if (ret == SIGNAL_BUY) multiCount += 1;
                        else if (ret == SIGNAL_SELL) multiCount -= 1;
                    }
                    return ret;
                }
            } else {
                if (!multiMode && pMan.openPosition(__pred[_pick].direction, -1, __pred[_pick].sl, __pred[_pick].tp, false, true, false) == ACTION_ERROR) return SIGNAL_ERROR;
                else {
                    ENUM_SIGNAL ret = positionTypeToSignal(__pred[_pick].direction);
                    if (multiMode) {
                        if (ret == SIGNAL_BUY) multiCount += 1;
                        else if (ret == SIGNAL_SELL) multiCount -= 1;
                    }
                    return ret;
                }
            }
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL wavePredictMarketPending(STRUCT_CHARTPATTERN_PRED &rPred[], int _pick = 0, bool invert = false, bool multiMode = false) {
        if (!pMan.positionIsOpen()) {
            if (invert) {
                ENUM_POSITION_TYPE pType = rPred[0].direction == POSITION_TYPE_BUY ? POSITION_TYPE_SELL : POSITION_TYPE_BUY;
                if (!multiMode && pMan.openPosition(pType, -1, rPred[0].tp, rPred[0].sl, false, true, false) == ACTION_ERROR) return SIGNAL_ERROR;
                else {
                    ENUM_SIGNAL ret = positionTypeToSignal(pType);
                    if (multiMode) {
                        if (ret == SIGNAL_BUY) multiCount += 1;
                        else if (ret == SIGNAL_SELL) multiCount -= 1;
                    }
                    return ret;
                }
            } else {
                if (_pick == 0) {
                    if (!multiMode && pMan.openPosition(rPred[0].direction, -1, rPred[0].sl, rPred[0].tp, false, true, false) == ACTION_ERROR) return SIGNAL_ERROR;
                    else {
                        ENUM_SIGNAL ret = positionTypeToSignal(rPred[0].direction);
                        if (multiMode) {
                            if (ret == SIGNAL_BUY) multiCount += 1;
                            else if (ret == SIGNAL_SELL) multiCount -= 1;
                        }
                        return ret;
                    }
                } else {
                    ulong _ticket;
                    return pendingOrderLimitANDStop(rPred[1].direction == POSITION_TYPE_BUY ? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT, _ticket, rPred[1].price, -1, rPred[0].sl, rPred[0].tp, true, true);
                }
            }
        } else {
            if (!invert) {
                if (_pick == 0) {
                    if (pMan.PositionType() != rPred[0].direction) {
                        if (!multiMode && pMan.openPosition(rPred[0].direction, -1, rPred[0].sl, rPred[0].tp, false, true, false) == ACTION_ERROR) return false;
                        else {
                            ENUM_SIGNAL ret = positionTypeToSignal(rPred[0].direction);
                            if (multiMode) {
                                if (ret == SIGNAL_BUY) multiCount += 1;
                                else if (ret == SIGNAL_SELL) multiCount -= 1;
                            }
                            return ret;
                        }
                    }
                } else {
                    ulong _ticket;
                    return pendingOrderLimitANDStop(rPred[1].direction == POSITION_TYPE_BUY ? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT, _ticket, rPred[1].price, -1, rPred[0].sl, rPred[0].tp, true, true);
                }
            } else {
                if (pMan.PositionType() == rPred[0].direction) {
                    ENUM_POSITION_TYPE pType = rPred[0].direction == POSITION_TYPE_BUY ? POSITION_TYPE_SELL : POSITION_TYPE_BUY;
                    if (!multiMode && pMan.openPosition(pType, -1, rPred[0].tp, rPred[0].sl, false, true, false) == ACTION_ERROR) return SIGNAL_ERROR;
                    else {
                        ENUM_SIGNAL ret =  positionTypeToSignal(pType);
                        if (multiMode) {
                            if (ret == SIGNAL_BUY) multiCount += 1;
                            else if (ret == SIGNAL_SELL) multiCount -= 1;
                        }
                        return ret;
                    }
                }
            }
        }
        return SIGNAL_UNKNOWN;
    }    
    bool withinRangeDistance(uint pPoint, uint pLowDistance = 0, uint pHighDistance = 0) {
        if (pLowDistance || pHighDistance) {
            if (pLowDistance) {
                if (pPoint < pLowDistance) return false;
            }
            if (pHighDistance) {
                if (pPoint > pHighDistance) return false;
            }
        }
        return true;
    }
    bool withinLevelDistance(bool& _dir, double pPrice1, double pPrice2, double pLowDistance = 0, double pHighDistance = 0) {
        if (!(pLowDistance && pHighDistance)) return true;
        if (pPrice1 < pLowDistance && pPrice2 < pLowDistance) {
            _dir = false;
            return true;
        }
        if (pPrice1 > pHighDistance && pPrice2 > pHighDistance) {
            _dir = true;
            return true;
        }
        return false;
    }
    ENUM_SIGNAL marketCanTrade(ENUM_POSITION_TYPE pType, bool withAutoStops=false, bool toHedge = true, bool onlyOne = true, string pComment="normal", bool multiMode = false) {
        return pType == POSITION_TYPE_BUY ? marketCanBuy(withAutoStops, toHedge, onlyOne, pComment, multiMode) : marketCanSell(withAutoStops, toHedge, onlyOne, pComment, multiMode);
    }
    ENUM_SIGNAL marketCanTrade(ENUM_POSITION_TYPE pType, double pSL = 0, double pTP = 0, bool toHedge = true, bool onlyOne = true, string pComment="normal", bool multiMode = false) {
        return pType == POSITION_TYPE_BUY ? marketCanBuy(pSL, pTP, toHedge, onlyOne, pComment, multiMode) : marketCanSell(pSL, pTP, toHedge, onlyOne, pComment, multiMode);
    }
    ENUM_SIGNAL marketCanBuy(bool withAutoStops=false, bool toHedge = true, bool onlyOne = true, string pComment="normal", bool multiMode = false) {
        if (multiMode) {multiCount += 1; return SIGNAL_BUY;}
        if (pMan.positionIsOpen()) {
            if (pMan.PositionType() == POSITION_TYPE_SELL) {
                if (pMan.closePosition(toHedge) == ACTION_ERROR) return SIGNAL_ERROR;
            } else {
                if (onlyOne) return SIGNAL_BUY;
            }
        }
        if (pMan.buyNow(-1, 0, 0, !withAutoStops, true, false, pComment) == ACTION_ERROR) return SIGNAL_ERROR;
        return SIGNAL_BUY;
    }
    ENUM_SIGNAL marketCanBuy(double pSL, double pTP, bool toHedge = true, bool onlyOne = true, string pComment="normal", bool multiMode = false) {
        if (multiMode) {multiCount += 1; return SIGNAL_BUY;}
        if (pMan.positionIsOpen()) {
            if (pMan.PositionType() == POSITION_TYPE_SELL) {
                if (pMan.closePosition(toHedge) == ACTION_ERROR) return SIGNAL_ERROR;
            } else {
                if (onlyOne) return SIGNAL_BUY;
            }
        }
        if (pMan.buyNow(-1, pSL, pTP, false, true, false, pComment) == ACTION_ERROR) return SIGNAL_ERROR;
        return SIGNAL_BUY;
    }
    ENUM_SIGNAL marketCanBuyInstance(bool withAutoStops=false, bool toHedge = true, bool onlyOne = true, bool multiMode = false) {
        if (multiMode) {multiCount += 1; return SIGNAL_BUY;}
        if (marketVolume != 0) {
            if (marketVolume < 0) {
                if (pMan.closePositionPartial(MathAbs(marketVolume), toHedge) == ACTION_ERROR) return SIGNAL_ERROR;
                marketVolume = 0;
            } else {
                if (onlyOne) return SIGNAL_BUY;
            }
        }
        if (pMan.buyNow(-1, 0, 0, !withAutoStops) == ACTION_ERROR) return SIGNAL_ERROR;
        marketVolume += pMan.lastVolume;
        return SIGNAL_BUY;
    }
    ENUM_SIGNAL marketCanBuyInstance(double pSL, double pTP, bool toHedge = true, bool onlyOne = true, bool multiMode = false) {
        if (multiMode) {multiCount += 1; return SIGNAL_BUY;}
        if (marketVolume != 0) {
            if (marketVolume < 0) {
                if (pMan.closePositionPartial(MathAbs(marketVolume), toHedge) == ACTION_ERROR) return SIGNAL_ERROR;
                marketVolume = 0;
            } else {
                if (onlyOne) return SIGNAL_BUY;
            }
        }
        if (pMan.buyNow(-1, pSL, pTP, false) == ACTION_ERROR) return SIGNAL_ERROR;
        marketVolume += pMan.lastVolume;
        return SIGNAL_BUY;
    }
    ENUM_SIGNAL marketCanSellInstance(bool withAutoStops=false, bool toHedge = true, bool onlyOne = true, bool multiMode = false) {
        if (multiMode) {multiCount -= 1; return SIGNAL_SELL;}
        if (marketVolume != 0) {
            if (marketVolume > 0) {
                if (pMan.closePositionPartial(marketVolume, toHedge) == ACTION_ERROR) return SIGNAL_ERROR;
                marketVolume = 0;
            } else {
                if (onlyOne) return SIGNAL_SELL;
            }
        }
        if (pMan.sellNow(-1, 0, 0, !withAutoStops) == ACTION_ERROR) return SIGNAL_ERROR;
        marketVolume -= pMan.lastVolume;
        return SIGNAL_SELL;
    }
    ENUM_SIGNAL marketCanSellInstance(double pSL, double pTP, bool toHedge = true, bool onlyOne = true, bool multiMode = false) {
        if (multiMode) {multiCount -= 1; return SIGNAL_SELL;}
        if (marketVolume != 0) {
            if (marketVolume > 0) {
                if (pMan.closePositionPartial(marketVolume, toHedge) == ACTION_ERROR) return SIGNAL_ERROR;
                marketVolume = 0;
            } else {
                if (onlyOne) return SIGNAL_SELL;
            }
        }
        if (pMan.sellNow(-1, pSL, pTP, false) == ACTION_ERROR) return SIGNAL_ERROR;
        marketVolume -= pMan.lastVolume;
        return SIGNAL_SELL;
    }
    ENUM_SIGNAL marketCanSell(bool withAutoStops=false, bool toHedge = true, bool onlyOne = true, string pComment = "normal", bool multiMode = false) {
        if (multiMode) {multiCount -= 1; return SIGNAL_SELL;}
        if (pMan.positionIsOpen()) {
            if (pMan.PositionType() == POSITION_TYPE_BUY) {
                if (pMan.closePosition(toHedge) == ACTION_ERROR) return SIGNAL_ERROR;
            } else {
                if (onlyOne) return SIGNAL_SELL;
            }
        }
        if (pMan.sellNow(-1, 0, 0, !withAutoStops, true, false, pComment) == ACTION_ERROR) return SIGNAL_ERROR;
        return SIGNAL_SELL;
    }
    ENUM_SIGNAL marketCanSell(double pSL, double pTP, bool toHedge = true, bool onlyOne = true, string pComment = "normal", bool multiMode = false) {
        if (multiMode) {multiCount -= 1; return SIGNAL_SELL;}
        if (pMan.positionIsOpen()) {
            if (pMan.PositionType() == POSITION_TYPE_BUY) {
                if (pMan.closePosition(toHedge) == ACTION_ERROR) return SIGNAL_ERROR;
            } else {
                if (onlyOne) return SIGNAL_SELL;
            }
        }
        if (pMan.sellNow(-1, pSL, pTP, false, true, false, pComment) == ACTION_ERROR) return SIGNAL_ERROR;
        return SIGNAL_SELL;
    }
    ENUM_SIGNAL marketCanTradeInstance(ENUM_POSITION_TYPE pType, bool withAutoStops=false, bool toHedge = true, bool onlyOne = true, string pComment="normal", bool multiMode = false) {
        return pType == POSITION_TYPE_BUY ? marketCanBuyInstance(withAutoStops, toHedge, onlyOne, multiMode) : marketCanSellInstance(withAutoStops, toHedge, onlyOne, multiMode);
    }
    ENUM_SIGNAL marketCanTradeInstance(ENUM_POSITION_TYPE pType, double pSL, double pTP, bool toHedge = true, bool onlyOne = true, string pComment="normal", bool multiMode = false) {
        return pType == POSITION_TYPE_BUY ? marketCanBuyInstance(pSL, pTP, toHedge, onlyOne, multiMode) : marketCanSellInstance(pSL, pTP, toHedge, onlyOne, multiMode);
    }
    ENUM_SIGNAL pendingBuyStop(ulong& tick, double pStopPrice, double pVolume = -1, bool withAutoStops=false, bool onlyOne = false, bool onlyOneDeal = false) {
        if (withAutoStops) {
            bool create = true;
            if ((onlyOne && oMan.isOrderTypeInOwn(ORDER_TYPE_BUY_STOP)) || (onlyOneDeal && pMan.positionIsOpen() && pMan.PositionType() == POSITION_TYPE_BUY)) create = false;
            if (create) {
                if(oMan.buyStop(pStopPrice, pVolume, 0, 0) == ACTION_ERROR) return SIGNAL_ERROR;
                tick = oMan.ResultOrder();
                return SIGNAL_PENDINGBUY;
            }
            tick = WRONG_VALUE;
            return SIGNAL_UNKNOWN;
        } else {
            bool create = true;
            if ((onlyOne && oMan.isOrderTypeInOwn(ORDER_TYPE_BUY_STOP)) || (onlyOneDeal && pMan.positionIsOpen() && pMan.PositionType() == POSITION_TYPE_BUY)) create = false;
            if (create) {
                if(oMan.buyStop(pStopPrice, pVolume, 0, 0, true, false) == ACTION_ERROR) return SIGNAL_ERROR;
                tick = oMan.ResultOrder();
                return SIGNAL_PENDINGBUY;
            }
            tick = WRONG_VALUE;
            return SIGNAL_UNKNOWN;
        }
    }
    ENUM_SIGNAL pendingBuyStop(ulong& tick, double pStopPrice, double pVolume, double pSL, double pTP, bool onlyOne = false, bool onlyOneDeal = false) {
        bool create = true;
        if ((onlyOne && oMan.isOrderTypeInOwn(ORDER_TYPE_BUY_STOP)) || (onlyOneDeal && pMan.positionIsOpen() && pMan.PositionType() == POSITION_TYPE_BUY)) create = false;
        if (create) {
            if(oMan.buyStop(pStopPrice, pVolume, pSL, pTP, true, false) == ACTION_ERROR) return SIGNAL_ERROR;
            tick = oMan.ResultOrder();
            return SIGNAL_PENDINGBUY;
        }
        tick = WRONG_VALUE;
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL pendingSellStop(ulong& tick, double pStopPrice, double pVolume = -1, bool withAutoStops=false, bool onlyOne = false, bool onlyOneDeal = false) {
        if (withAutoStops) {
            bool create = true;
            if ((onlyOne && oMan.isOrderTypeInOwn(ORDER_TYPE_SELL_STOP)) || (onlyOneDeal && pMan.positionIsOpen() && pMan.PositionType() == POSITION_TYPE_SELL)) create = false;
            if (create) {
                if(oMan.sellStop(pStopPrice, pVolume, 0, 0) == ACTION_ERROR) return SIGNAL_ERROR;
                tick = oMan.ResultOrder();
                return SIGNAL_PENDINGSELL;
            }
            tick = WRONG_VALUE;
            return SIGNAL_UNKNOWN;
        } else {
            bool create = true;
            if ((onlyOne && oMan.isOrderTypeInOwn(ORDER_TYPE_SELL_STOP)) || (onlyOneDeal && pMan.positionIsOpen() && pMan.PositionType() == POSITION_TYPE_SELL)) create = false;
            if (create) {
                if(oMan.sellStop(pStopPrice, pVolume, 0, 0, true, false) == ACTION_ERROR) return false;
                tick = oMan.ResultOrder();
                return SIGNAL_PENDINGSELL;
            }
            tick = WRONG_VALUE;
            return SIGNAL_UNKNOWN;
        }
    }
    ENUM_SIGNAL pendingSellStop(ulong& tick, double pStopPrice, double pVolume, double pSL, double pTP, bool onlyOne = false, bool onlyOneDeal = false) {
        bool create = true;
        if ((onlyOne && oMan.isOrderTypeInOwn(ORDER_TYPE_SELL_STOP)) || (onlyOneDeal && pMan.positionIsOpen() && pMan.PositionType() == POSITION_TYPE_SELL)) create = false;
        if (create) {
            if(oMan.sellStop(pStopPrice, pVolume, pSL, pTP, true, false) == ACTION_ERROR) return SIGNAL_ERROR;
            tick = oMan.ResultOrder();
            return SIGNAL_PENDINGSELL;
        }
        tick = WRONG_VALUE;
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL pendingBuyLimit(ulong& tick, double pStopPrice, double pVolume = -1, bool withAutoStops=false, bool onlyOne = false, bool onlyOneDeal = false) {
        if (withAutoStops) {
            bool create = true;
            if ((onlyOne && oMan.isOrderTypeInOwn(ORDER_TYPE_BUY_LIMIT)) || (onlyOneDeal && pMan.positionIsOpen() && pMan.PositionType() == POSITION_TYPE_BUY)) create = false;
            if (create) {
                if(oMan.buyLimit(pStopPrice, pVolume, 0, 0) == ACTION_ERROR) return SIGNAL_ERROR;
                tick = oMan.ResultOrder();
                return SIGNAL_PENDINGBUY;
            }
            tick = WRONG_VALUE;
            return SIGNAL_UNKNOWN;
        } else {
            bool create = true;
            if ((onlyOne && oMan.isOrderTypeInOwn(ORDER_TYPE_BUY_LIMIT)) || (onlyOneDeal && pMan.positionIsOpen() && pMan.PositionType() == POSITION_TYPE_BUY)) create = false;
            if (create) {
                if(oMan.buyLimit(pStopPrice, pVolume, 0, 0, true, false) == ACTION_ERROR) return SIGNAL_ERROR;
                tick = oMan.ResultOrder();
                return SIGNAL_PENDINGBUY;
            }
            tick = WRONG_VALUE;
            return SIGNAL_UNKNOWN;
        }
    }
    ENUM_SIGNAL pendingBuyLimit(ulong& tick, double pStopPrice, double pVolume, double pSL, double pTP, bool onlyOne = false, bool onlyOneDeal = false) {
        bool create = true;
        if ((onlyOne && oMan.isOrderTypeInOwn(ORDER_TYPE_BUY_LIMIT)) || (onlyOneDeal && pMan.positionIsOpen() && pMan.PositionType() == POSITION_TYPE_BUY)) create = false;
        if (create) {
            if(oMan.buyLimit(pStopPrice, pVolume, pSL, pTP, true, false) == ACTION_ERROR) return SIGNAL_ERROR;
            tick = oMan.ResultOrder();
            return SIGNAL_PENDINGBUY;
        }
        tick = WRONG_VALUE;
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL pendingSellLimit(ulong& tick, double pStopPrice, double pVolume = -1, bool withAutoStops=false, bool onlyOne = false, bool onlyOneDeal = false) {
        if (withAutoStops) {
            bool create = true;
            if ((onlyOne && oMan.isOrderTypeInOwn(ORDER_TYPE_SELL_LIMIT)) || (onlyOneDeal && pMan.positionIsOpen() && pMan.PositionType() == POSITION_TYPE_SELL)) create = false;
            if (create) {
                if(oMan.sellLimit(pStopPrice, pVolume, 0, 0) == ACTION_ERROR) return SIGNAL_ERROR;
                tick = oMan.ResultOrder();
                return SIGNAL_PENDINGSELL;
            }
            tick = WRONG_VALUE;
            return SIGNAL_UNKNOWN;
        } else {
            bool create = true;
            if ((onlyOne && oMan.isOrderTypeInOwn(ORDER_TYPE_SELL_LIMIT)) || (onlyOneDeal && pMan.positionIsOpen() && pMan.PositionType() == POSITION_TYPE_SELL)) create = false;
            if (create) {
                if(oMan.sellLimit(pStopPrice, pVolume, 0, 0, true, false) == ACTION_ERROR) return SIGNAL_ERROR;
                tick = oMan.ResultOrder();
                return SIGNAL_PENDINGSELL;
            }
            tick = WRONG_VALUE;
            return SIGNAL_UNKNOWN;
        }
    }
    ENUM_SIGNAL pendingSellLimit(ulong& tick, double pStopPrice, double pVolume, double pSL, double pTP, bool onlyOne = false, bool onlyOneDeal = false) {
        bool create = true;
        if ((onlyOne && oMan.isOrderTypeInOwn(ORDER_TYPE_SELL_LIMIT)) || (onlyOneDeal && pMan.positionIsOpen() && pMan.PositionType() == POSITION_TYPE_SELL)) create = false;
        if (create) {
            if(oMan.sellLimit(pStopPrice, pVolume, pSL, pTP, true, false) == ACTION_ERROR) return SIGNAL_ERROR;
            tick = oMan.ResultOrder();
            return SIGNAL_PENDINGSELL;
        }
        tick = WRONG_VALUE;
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL pendingOrderLimitANDStop(ENUM_ORDER_TYPE oType, ulong& tick, double pStopPrice, double pVolume = -1, bool withAutoStops=false, bool onlyOne = false, bool onlyOneDeal = false) {
        if (oType == ORDER_TYPE_BUY_LIMIT) return pendingBuyLimit(tick, pStopPrice, pVolume, withAutoStops, onlyOne, onlyOneDeal);
        else if (oType == ORDER_TYPE_SELL_LIMIT) return pendingSellLimit(tick, pStopPrice, pVolume, withAutoStops, onlyOne, onlyOneDeal);
        else if (oType == ORDER_TYPE_BUY_STOP) return pendingBuyStop(tick, pStopPrice, pVolume, withAutoStops, onlyOne, onlyOneDeal);
        else if (oType == ORDER_TYPE_SELL_STOP) return pendingSellStop(tick, pStopPrice, pVolume, withAutoStops, onlyOne, onlyOneDeal);
        return SIGNAL_ERROR;
    }
    ENUM_SIGNAL pendingOrderLimitANDStop(ENUM_ORDER_TYPE oType, ulong& tick, double pStopPrice, double pVolume, double pSL, double pTP, bool onlyOne = false, bool onlyOneDeal = false) {
        if (oType == ORDER_TYPE_BUY_LIMIT) return pendingBuyLimit(tick, pStopPrice, pVolume, pSL, pTP, onlyOne, onlyOneDeal);
        else if (oType == ORDER_TYPE_SELL_LIMIT) return pendingSellLimit(tick, pStopPrice, pVolume, pSL, pTP, onlyOne, onlyOneDeal);
        else if (oType == ORDER_TYPE_BUY_STOP) return pendingBuyStop(tick, pStopPrice, pVolume, pSL, pTP, onlyOne, onlyOneDeal);
        else if (oType == ORDER_TYPE_SELL_STOP) return pendingSellStop(tick, pStopPrice, pVolume, pSL, pTP, onlyOne, onlyOneDeal);
        return SIGNAL_ERROR;
    }
    ENUM_SIGNAL pendingBuyStopLimit(ulong& tick, double pStopPrice, double pLimitPrice, double pVolume = -1, bool withAutoStops=false, bool onlyOne = false, bool onlyOneDeal = false) {
        if (withAutoStops) {
            bool create = true;
            if ((onlyOne && oMan.isOrderTypeInOwn(ORDER_TYPE_BUY_STOP_LIMIT)) || (onlyOneDeal && pMan.positionIsOpen() && pMan.PositionType() == POSITION_TYPE_BUY)) create = false;
            if (create) {
                if(oMan.buyStopLimit(pLimitPrice, pVolume, pStopPrice, 0, 0) == ACTION_ERROR) return SIGNAL_ERROR;
                tick = oMan.ResultOrder();
                return SIGNAL_PENDINGBUY;
            }
            tick = WRONG_VALUE;
            return SIGNAL_UNKNOWN;
        } else {
            bool create = true;
            if ((onlyOne && oMan.isOrderTypeInOwn(ORDER_TYPE_BUY_STOP_LIMIT)) || (onlyOneDeal && pMan.positionIsOpen() && pMan.PositionType() == POSITION_TYPE_BUY)) create = false;
            if (create) {
                if(oMan.buyStopLimit(pLimitPrice, pVolume, pStopPrice, 0, 0, true, false) == ACTION_ERROR) return SIGNAL_ERROR;
                tick = oMan.ResultOrder();
                return SIGNAL_PENDINGBUY;
            }
            tick = WRONG_VALUE;
            return SIGNAL_UNKNOWN;
        }
    }
    ENUM_SIGNAL pendingBuyStopLimit(ulong& tick, double pStopPrice, double pLimitPrice, double pVolume, double pSL, double pTP, bool onlyOne = false, bool onlyOneDeal = false) {
        bool create = true;
        if ((onlyOne && oMan.isOrderTypeInOwn(ORDER_TYPE_BUY_STOP_LIMIT)) || (onlyOneDeal && pMan.positionIsOpen() && pMan.PositionType() == POSITION_TYPE_BUY)) create = false;
        if (create) {
            if(oMan.buyStopLimit(pLimitPrice, pVolume, pStopPrice, pSL, pTP, true, false) == ACTION_ERROR) return SIGNAL_ERROR;
            tick = oMan.ResultOrder();
            return SIGNAL_PENDINGBUY;
        }
        tick = WRONG_VALUE;
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL pendingSellStopLimit(ulong& tick, double pStopPrice, double pLimitPrice, double pVolume = -1, bool withAutoStops=false, bool onlyOne = false, bool onlyOneDeal = false) {
        if (withAutoStops) {
            bool create = true;
            if ((onlyOne && oMan.isOrderTypeInOwn(ORDER_TYPE_SELL_STOP_LIMIT)) || (onlyOneDeal && pMan.positionIsOpen() && pMan.PositionType() == POSITION_TYPE_SELL)) create = false;
            if (create) {
                if(oMan.sellStopLimit(pLimitPrice, pVolume, pStopPrice, 0, 0) == ACTION_ERROR) return SIGNAL_ERROR;
                tick = oMan.ResultOrder();
                return SIGNAL_PENDINGSELL;
            }
            tick = WRONG_VALUE;
            return SIGNAL_UNKNOWN;
        } else {
            bool create = true;
            if ((onlyOne && oMan.isOrderTypeInOwn(ORDER_TYPE_SELL_STOP_LIMIT)) || (onlyOneDeal && pMan.positionIsOpen() && pMan.PositionType() == POSITION_TYPE_SELL)) create = false;
            if (create) {
                if(oMan.sellStopLimit(pLimitPrice, pVolume, pStopPrice, 0, 0, true, false) == ACTION_ERROR) return SIGNAL_ERROR;
                tick = oMan.ResultOrder();
                return SIGNAL_PENDINGSELL;
            }
            tick = WRONG_VALUE;
            return SIGNAL_UNKNOWN;
        }
    }
    ENUM_SIGNAL pendingSellStopLimit(ulong& tick, double pStopPrice, double pLimitPrice, double pVolume, double pSL, double pTP, bool onlyOne = false, bool onlyOneDeal = false) {
        bool create = true;
        if ((onlyOne && oMan.isOrderTypeInOwn(ORDER_TYPE_SELL_STOP_LIMIT)) || (onlyOneDeal && pMan.positionIsOpen() && pMan.PositionType() == POSITION_TYPE_SELL)) create = false;
        if (create) {
            if(oMan.sellStopLimit(pLimitPrice, pVolume, pStopPrice, pSL, pTP, true, false) == ACTION_ERROR) return SIGNAL_ERROR;
            tick = oMan.ResultOrder();
            return SIGNAL_PENDINGSELL;
        }
        tick = WRONG_VALUE;
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL pendingOrderStopLimit(ENUM_ORDER_TYPE oType, ulong& tick, double pStopPrice, double pLimitPrice, double pVolume = -1, bool withAutoStops=false,
            bool onlyOne = false, bool onlyOneDeal = false) {
        if (oType == ORDER_TYPE_BUY_STOP_LIMIT) return pendingBuyStopLimit(tick, pStopPrice, pLimitPrice, pVolume, withAutoStops, onlyOne, onlyOneDeal);
        else if (oType == ORDER_TYPE_SELL_STOP_LIMIT) return pendingSellStopLimit(tick, pStopPrice, pLimitPrice, pVolume, withAutoStops, onlyOne, onlyOneDeal);
        return SIGNAL_ERROR;
    }
    ENUM_SIGNAL pendingOrderStopLimit(ENUM_ORDER_TYPE oType, ulong& tick, double pStopPrice, double pLimitPrice, double pVolume, double pSL,double pTP,
            bool onlyOne = false, bool onlyOneDeal = false) {
        if (oType == ORDER_TYPE_BUY_STOP_LIMIT) return pendingBuyStopLimit(tick, pStopPrice, pLimitPrice, pVolume, pSL, pTP, onlyOne, onlyOneDeal);
        else if (oType == ORDER_TYPE_SELL_STOP_LIMIT) return pendingSellStopLimit(tick, pStopPrice, pLimitPrice, pVolume, pSL, pTP, onlyOne, onlyOneDeal);
        return SIGNAL_ERROR;
    }
    //Price-based trading signals
    bool SignalIn::PAcreatePendingFromLastCandleWick(uint pPOINTS, ulong &pTickets[], bool withAutoStops=true) {
        if (!utility.deleteGivenPendingOrder(pTickets)) return false;
        Candle* lastCandle = cMan.lastCandle();
        double stopPrice = getHighPriceFROMpoint(pPOINTS, lastCandle.high);
        ulong tick;
        if (pendingBuyStop(tick, stopPrice, -1, withAutoStops) != SIGNAL_ERROR) {
            if (tick != WRONG_VALUE) pTickets[0] = tick;
        } else {
            //delete lastCandle;
            return false;
        }
        stopPrice = getLowPriceFROMpoint(pPOINTS, lastCandle.low);
        if (pendingSellStop(tick, stopPrice, -1, withAutoStops) != SIGNAL_ERROR) {
            if (tick != WRONG_VALUE) pTickets[1] = tick;
            ArrayResize(pTickets, 2);
        } else {
            //delete lastCandle;
            return false;
        }     
        //delete lastCandle;
        return true;
    }
    bool PAcreatePendingFromHighsLows(ulong& pTicket[], uint pBars, long pContraction = 100, uint SLTPstop = 300) {
        double hH = cMan.highestHigh(pBars);
        double lL = cMan.lowestLow(pBars);
        double newhH = pointTOprice(pContraction, hH);
        double newlL = pointTOprice(pContraction, lL, true); //elastic range
        double cBid = cMan.currentBid();
        double cAsk = cMan.currentAsk();
        uint SLTPpoint = pricesTOpoint(newhH, newlL)/2;
        //SLTPpoint = 0;
        if (pContraction > 0) {
            //Break out strategy
            if (SLTPstop == 0) SLTPstop = SLTPpoint;
            if (pTicket[1] == WRONG_VALUE || oMan.deleteOrderBool(pTicket[1], newhH, 30)) {
                if (oMan.buyStop(newhH, -1, SLTPpoint, SLTPstop, true, false) == ACTION_ERROR) return false;
                pTicket[1] = oMan.ResultOrder();
            }
            if (pTicket[0] == WRONG_VALUE || oMan.deleteOrderBool(pTicket[0], newlL, 30)) {
                if (oMan.sellStop(newlL, -1, SLTPpoint, SLTPstop, true, false) == ACTION_ERROR) return false;
                pTicket[0] = oMan.ResultOrder();
            }
        } else if (pContraction < 0) {
            if (SLTPstop == 0) SLTPstop = SLTPpoint;
            //Range trading strategy
            if (newhH < cBid) {
                if (pTicket[0] == WRONG_VALUE || oMan.deleteOrderBool(pTicket[0], newhH, 30)) {
                    if (oMan.sellStop(newhH, -1, SLTPstop, SLTPpoint, true, false) == ACTION_ERROR) return false;
                    pTicket[0] = oMan.ResultOrder();
                }
            } else if (newhH > cBid) {
                if (pTicket[0] == WRONG_VALUE || oMan.deleteOrderBool(pTicket[0], newhH, 30)) {
                    if (oMan.sellLimit(newhH, -1, SLTPstop, SLTPpoint, true, false) == ACTION_ERROR) return false;
                    pTicket[0] = oMan.ResultOrder();
                }
            }
            if (newlL < cAsk) {
                if (pTicket[1] == WRONG_VALUE || oMan.deleteOrderBool(pTicket[1], newlL, 30)) {
                    if (oMan.buyLimit(newlL, -1, SLTPstop, SLTPpoint, true, false) == ACTION_ERROR) return false;
                    pTicket[1] = oMan.ResultOrder();
                }
            } else if (newlL > cAsk) {
                if (pTicket[1] == WRONG_VALUE || oMan.deleteOrderBool(pTicket[1], newlL, 30)) {
                    if (oMan.buyStop(newlL, -1, SLTPstop, SLTPpoint, true, false) == ACTION_ERROR) return false;
                    pTicket[1] = oMan.ResultOrder();
                }
            }
        }
        return true;
    }
    ENUM_SIGNAL SignalIn::PAtradeTrendChannel(tLine* &pRS[], datetime pCdate, bool invert = false,
            uint pLowDistance = 0, uint pHighDistance = 0, bool withAutoStops=false, bool multiMode = false) {
        double cPrice = cMan.currentPrice();
        if (pRS[0]) {
            double rPrice = pRS[0].valueAtTime(pCdate);
            if (cPrice > rPrice && withinRangeDistance(pricesTOpoint(cPrice, rPrice), pLowDistance, pHighDistance)) {
                if (invert) return marketCanBuyInstance(withAutoStops, true, true, multiMode);
                else return marketCanSellInstance(withAutoStops, true, true, multiMode);
            }
        }
        if (pRS[1]) {
            double sPrice = pRS[1].valueAtTime(pCdate);
            if (cPrice < sPrice && withinRangeDistance(pricesTOpoint(cPrice, sPrice), pLowDistance, pHighDistance)) {
                if (invert) return marketCanSellInstance(withAutoStops, true, true, multiMode);
                else return marketCanBuyInstance(withAutoStops, true, true, multiMode);
            }
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::PAtradeSRlines(double &pResist[], double &pSupport[], bool within = true, bool invert = false,
            uint pLowDistance = 20, uint pHighDistance = 30, bool withAutoStops=false, bool multiMode = false) {
        double cPrice = cMan.currentPrice();
        if (ArraySize(pResist) != 0) {
            double toUse = 0;
            if (within) toUse = getNearestPrice(cPrice, pResist);
            else toUse = pResist[ArrayMaximum(pResist)];
            if (withinRangeDistance(pricesTOpoint(toUse, cPrice), pLowDistance, pHighDistance)) {
                if (invert) {
                    return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
                } else {
                    return marketCanSell(withAutoStops, true, true, "normal", multiMode);
                }
            }
        }
        if (ArraySize(pSupport) != 0) {
            double toUse = 0;
            if (within) toUse = getNearestPrice(cPrice, pSupport);
            else toUse = pSupport[ArrayMinimum(pSupport)];
            if (withinRangeDistance(pricesTOpoint(toUse, cPrice), pLowDistance, pHighDistance)) {
                if (invert) {
                    return marketCanSell(withAutoStops, true, true, "normal", multiMode);
                } else {
                    return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
                }
            }
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::PAtradeSRnoLines(double &pResist[], double &pSupport[], int distance = 2, bool invert = false, bool withAutoStops=false, bool multiMode = false) {
        int sNo = ArraySize(pSupport);
        int pNo = ArraySize(pResist);
        if (MathAbs(pNo - sNo) >= distance) {
            if (pNo > sNo) {
                if (invert) return marketCanSell(withAutoStops, true, true, "normal", multiMode);
                else return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
            } else if (sNo > pNo) {
                if (invert) return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
                else return marketCanSell(withAutoStops, true, true, "normal", multiMode);
            }
        }
        return SIGNAL_UNKNOWN;
    }
    bool SignalIn::PAtradeHlines(ulong &order[], double &hLines[], uint stopDistance = 100, bool invert = false, uint pLowDistance = 20,
            uint pHighDistance = 30, bool withAutoStops=false) {
        if (ArraySize(hLines) == 0) return true;
        double cPrice = cMan.currentPrice();
        double nLine = getNearestPrice(cPrice, hLines);
        uint cDist = pricesTOpoint(nLine, cPrice);
        if (withinRangeDistance(cDist, pLowDistance, pHighDistance)) {
            if (stopDistance > cDist) {
                if (invert) {
                    double pOprice = pointTOprice(stopDistance, nLine);
                    if (order[0] == WRONG_VALUE || oMan.deleteOrderBool(order[0], pOprice)) {
                        if (pendingSellLimit(order[0], pOprice, -1, withAutoStops, true) == SIGNAL_ERROR) return false;
                    }
                    pOprice = pointTOprice(-(long)stopDistance, nLine);
                    if (order[1] == WRONG_VALUE || oMan.deleteOrderBool(order[1], pOprice)) {
                        if (pendingBuyLimit(order[1], pOprice, -1, withAutoStops, true) == SIGNAL_ERROR) return false;
                        else return true;
                    }
                } else {
                    double pOprice = pointTOprice(stopDistance, nLine);
                    if (order[0] == WRONG_VALUE || oMan.deleteOrderBool(order[0], pOprice)) {
                        if (pendingBuyStop(order[0], pOprice, -1, withAutoStops, true) == SIGNAL_ERROR) return false;
                    }
                    pOprice = pointTOprice(-(long)stopDistance, nLine);
                    if (order[1] == WRONG_VALUE || oMan.deleteOrderBool(order[1], pOprice)) {
                        if (pendingSellStop(order[1], pOprice, -1, withAutoStops, true) == SIGNAL_ERROR) return false;
                        else return true;
                    }
                }
            } else if (stopDistance < cDist) {
                double pOprice = pointTOprice(stopDistance, nLine);
                if (order[0] == WRONG_VALUE || oMan.deleteOrderBool(order[0], pOprice)) {
                    if (nLine > cPrice) {
                        if (invert) return signalToBool(pendingSellLimit(order[0], pOprice, -1, withAutoStops, true));
                        else return signalToBool(pendingBuyStop(order[0], pOprice, -1, withAutoStops, true));
                    }
                    else if (nLine < cPrice) {
                        if (invert) return signalToBool(pendingBuyLimit(order[0], pOprice, -1, withAutoStops, true));
                        else return signalToBool(pendingSellStop(order[0], pOprice, -1, withAutoStops, true));
                    }
                }
            }
        }
        return true;
    }
    ENUM_SIGNAL SignalIn::PAtradeHline(hLine* pHline, bool invert = false, uint pLowDistance = 0, uint pHighDistance = 0, bool withAutoStops=false,
            bool multiMode = false) {
        if (pHline == NULL) return SIGNAL_UNKNOWN;
        return INcreateMarketOrdersFrom2PriceCrossover(cMan.currentPrice(), pHline.Price(0), invert, pLowDistance, pHighDistance, withAutoStops, multiMode);
    }
    ENUM_SIGNAL SignalIn::PAtradeHline(hLine* &pHlines[], bool invert = false, uint pLowDistance = 0, uint pHighDistance = 0, bool withAutoStops=false,
            bool multiMode = false) {
        if (ArraySize(pHlines) == 0) return SIGNAL_UNKNOWN;
        double cPrice = cMan.currentPrice();
        return INcreateMarketOrdersFrom2PriceCrossover(cPrice, getNearestPrice(cPrice, pHlines), invert, pLowDistance, pHighDistance, withAutoStops, multiMode);
    }
    ENUM_SIGNAL SignalIn::PAtradeCandlePattern(Candle* lCand3, Candle* lCand2, Candle* lCand, string tradeType = "ALL", bool invert = false,
            bool withAutoStops = false, bool multiMode = false) {
        bool drawn = false;
        ENUM_CANDLE_CAT canCat = lCand.category;
        ENUM_CANDLE_PATTERN canPat = CANDLE_PAT_UNKNOWN;
        if (tradeType == "ALL" || tradeType == "TRI" || tradeType == "SINGTRI" || tradeType == "DUALTRI") canPat = cMan.triCandlePat(lCand3, lCand2, lCand);
        if (candlePatternToSignal(canPat) == SIGNAL_UNKNOWN) {
            if (tradeType == "ALL" || tradeType == "DUAL" || tradeType == "DUALTRI" || tradeType == "SINGDUAL") canPat = cMan.dualCandlePat(lCand2, lCand);
        } else {
            if (DRAW) cMan.drawRectAndTexton3Cand(lCand3, lCand2, lCand, StringSubstr(EnumToString(canPat), 11));
            if (ALERT_ON_SIGNAL) MessageBox(StringSubstr(EnumToString(canPat), 11) + " detected");
            drawn = true;
        }
        
        ENUM_SIGNAL catSig = candlePatternToSignal(canPat);
        if (catSig == SIGNAL_UNKNOWN) {
            if (tradeType == "ALL" || tradeType == "SING" || tradeType == "SINGDUAL" || tradeType == "SINGTRI") catSig = candleCatToSignal(canCat);
        } else {
            if (!drawn) {
                if (DRAW) cMan.drawRectAndTexton2Cand(lCand2, lCand, StringSubstr(EnumToString(canPat), 11));
                if (ALERT_ON_SIGNAL) MessageBox(StringSubstr(EnumToString(canPat), 11) + " detected");
                drawn = true;
            }
        }
        if (catSig != SIGNAL_UNKNOWN && !drawn) {
            if (DRAW) cMan.drawRectAndTexton1Cand(lCand, StringSubstr(EnumToString(canCat), 11));
            if (ALERT_ON_SIGNAL) MessageBox(StringSubstr(EnumToString(canCat), 11) + " detected");
            drawn = true;
        }
        if (!ANALYSIS) {
            switch(catSig) {
               case  SIGNAL_BUY:
                 if (invert) return marketCanSell(withAutoStops, true, true, "normal", multiMode);
                 else return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
               case  SIGNAL_SELL:
                 if (invert) return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
                 else return marketCanSell(withAutoStops, true, true, "normal", multiMode);
            }
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::PAtradeChartWaveReversalLikeCandleSticks(DotRange* _CW, uint _limit = 30, int maxLength = 10, bool invert = false, bool withAutoStops = false, bool multiMode = false) {
        if (_CW.Total() < 3) return SIGNAL_UNKNOWN;
        ENUM_SIGNAL sig = SIGNAL_UNKNOWN;
        if (DRAW) drawLinesDotRange(_CW, "wave", clrYellow);
        ENUM_CANDLE_PATTERN pat = _CW.dualWavePatDetect(_limit);
        ENUM_CANDLE_PATTERN pat2 = pat;
        if (pat == CANDLE_PAT_BEARISHENG || pat == CANDLE_PAT_BULLISHENG) {
            int initDir = _CW.chartWaveDirection();
            ENUM_CANDLE_PATTERN toSee = CANDLE_PAT_UNKNOWN;
            if (pat == CANDLE_PAT_BULLISHENG) toSee = CANDLE_PAT_TWEEZZERBOT;
            else if (pat == CANDLE_PAT_BEARISHENG) toSee = CANDLE_PAT_TWEEZZERTOP;
            for (int i = -4; i > -maxLength-4; i--) {
                if (-i >= _CW.Total()) break;
                if (determineChartWaveMove(_CW[i], _CW[i-1]) == initDir) continue;
                pat = dualWavePatDetect(_CW[i], _CW[i+1], _CW[-1], _limit);
                if (pat == toSee) {
                    pat = (toSee == CANDLE_PAT_TWEEZZERTOP) ? CANDLE_PAT_EVENINGSTAR : CANDLE_PAT_MORNINGSTAR;
                    sig = candlePatternToSignal(pat);
                    if (sig != SIGNAL_UNKNOWN) {
                        DotRange* last5 = _CW.slice(i);
                        if (DRAW) rectangle* rect = new rectangle("rectt"+StringSubstr(EnumToString(pat), 11)+IntegerToString(last5.A(0).time), last5.minimumBox(), last5.maximumBox());
                        if (ALERT_ON_SIGNAL) MessageBox(StringSubstr(EnumToString(pat), 11) + " wave detected");
                    }
                    break;
                }
            }
            if (sig == SIGNAL_UNKNOWN) {
                toSee = CANDLE_PAT_UNKNOWN;
                if (pat2 == CANDLE_PAT_BULLISHENG) toSee = CANDLE_PAT_BULLISHHARAMI;
                else if (pat2 == CANDLE_PAT_BEARISHENG) toSee = CANDLE_PAT_BEARISHHARAMI;
                for (int i = -4; i > -maxLength-4; i--) {
                    if (-i >= _CW.Total()) break;
                    pat = dualWavePatDetect(_CW[i], _CW[i+1], _CW[i+2], _limit);
                    if (pat == toSee && numberPairOverlap(_CW[i], _CW[i+1], _CW[-2], _CW[-1])) {
                        pat = (toSee == CANDLE_PAT_BEARISHHARAMI) ? CANDLE_PAT_EVENINGSTAR : CANDLE_PAT_MORNINGSTAR;
                        sig = candlePatternToSignal(pat);
                        if (sig != SIGNAL_UNKNOWN) {
                            DotRange* last5 = _CW.slice(i);
                            if (DRAW) rectangle* rect = new rectangle("rectt"+StringSubstr(EnumToString(pat), 11)+IntegerToString(last5.A(0).time), last5.minimumBox(), last5.maximumBox());
                            if (ALERT_ON_SIGNAL) MessageBox(StringSubstr(EnumToString(pat), 11) + " wave detected");
                        }
                        break;
                    }
                }
            }
        }
        if (!ANALYSIS) {
            switch(sig) {
               case  SIGNAL_BUY:
                 if (invert) return marketCanSell(withAutoStops, true, true, "normal", multiMode);
                 else return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
               case  SIGNAL_SELL:
                 if (invert) return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
                 else return marketCanSell(withAutoStops, true, true, "normal", multiMode);
            }
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::PAtradeChartWaveReversalLikeCandleSticks(int _days = 200, int inpDepth = 12, int inpDeviation = 5, int inpBackstep = 3, uint _limit = 30, int maxLength = 10,
            bool invert = false, bool withAutoStops = false, bool multiMode = false) {
        return PAtradeChartWaveReversalLikeCandleSticks(cMan.getChartWave(_days, inpDepth, inpDeviation, inpBackstep), _limit, maxLength, invert, withAutoStops, multiMode);
    }
    ENUM_SIGNAL SignalIn::PAtradeCandlePatternV2(string tradeType = "ALL", int maxLength = 30, bool invert = false, bool withAutoStops = false, bool multiMode = false) {
        Candle* lCand = cMan.lastCandle();
        Candle* lCand2 = cMan.getCandle(2);
        ENUM_SIGNAL sig = SIGNAL_UNKNOWN;
        ENUM_CANDLE_PATTERN pat = cMan.dualCandlePat(lCand2, lCand);
        ENUM_CANDLE_PATTERN pat2 = pat;
        double sl = 0;
        if ((tradeType == "ALL" || tradeType == "TRI")) {
            if (pat == CANDLE_PAT_BULLISHENG || pat == CANDLE_PAT_BEARISHENG) {
                ENUM_CANDLE_TYPE cType = lCand.type;
                ENUM_CANDLE_PATTERN toSee = CANDLE_PAT_UNKNOWN;
                if (pat == CANDLE_PAT_BULLISHENG) toSee = CANDLE_PAT_TWEEZZERBOT;
                else if (pat == CANDLE_PAT_BEARISHENG) toSee = CANDLE_PAT_TWEEZZERTOP;
                for (int i = 3; i < maxLength; i++) {
                    lCand2 = cMan.getCandle(i);
                    if (lCand2.type == cType) continue;
                    pat = cMan.dualCandlePat(lCand2, lCand);
                    if (pat == toSee) {
                        pat = (toSee == CANDLE_PAT_TWEEZZERTOP) ? CANDLE_PAT_EVENINGSTAR : CANDLE_PAT_MORNINGSTAR;
                        sig = candlePatternToSignal(pat);
                        if (sig != SIGNAL_UNKNOWN) {
                            if (DRAW) cMan.drawRectAndTexton2Cand(lCand2, lCand, StringSubstr(EnumToString(pat), 11));
                            if (ALERT_ON_SIGNAL) MessageBox(StringSubstr(EnumToString(pat), 11) + " candle detected");
                            if (sig == SIGNAL_BUY) sl = MathMin(lCand2.low, lCand.low);
                            else sl = MathMax(lCand2.high, lCand.high);
                        }
                        break;
                    }
                }
            } else if (pat == CANDLE_PAT_BULLISHIMP || pat == CANDLE_PAT_BEARISHIMP) {
                Candle* lCandd = lCand2;
                ENUM_CANDLE_PATTERN toSee = CANDLE_PAT_UNKNOWN;
                if (pat == CANDLE_PAT_BULLISHIMP) toSee = CANDLE_PAT_BEARISHCOR;
                else if (pat == CANDLE_PAT_BEARISHIMP) toSee = CANDLE_PAT_BULLISHCOR;
                for (int i = 3; i < maxLength; i++) {
                    lCand2 = cMan.getCandle(i);
                    pat = cMan.dualCandlePat(lCand2, lCandd);
                    if (pat == toSee && lCand2.bodyOverlap(lCand)) {
                        pat = CANDLE_PAT_UNKNOWN;
                        if (toSee == CANDLE_PAT_BEARISHCOR) pat = CANDLE_PAT_MORNINGSTAR;
                        else if (toSee == CANDLE_PAT_BULLISHCOR) pat = CANDLE_PAT_EVENINGSTAR;
                        sig = candlePatternToSignal(pat);
                        if (sig != SIGNAL_UNKNOWN) {
                            if (DRAW) cMan.drawRectAndTexton2Cand(lCand2, lCand, StringSubstr(EnumToString(pat), 11));
                            if (ALERT_ON_SIGNAL) MessageBox(StringSubstr(EnumToString(pat), 11) + " candle detected");
                            if (sig == SIGNAL_BUY) sl = MathMin(lCand2.low, lCand.low);
                            else sl = MathMax(lCand2.high, lCand.high);
                        }
                        break;
                    }
                    lCandd = lCand2;
                }
            }
            //if (sig == SIGNAL_UNKNOWN) {
            //    lCand2 = cMan.getCandle(2);
            //    Candle* lCand3 = cMan.getCandle(3);
            //    pat = cMan.triCandlePat(lCand3, lCand2, lCand);
            //    sig = candlePatternToSignal(pat);
            //    if (sig != SIGNAL_UNKNOWN) cMan.drawRectAndTexton3Cand(lCand3, lCand2, lCand, StringSubstr(EnumToString(pat), 11));
            //}
        }
        if (sig == SIGNAL_UNKNOWN && (tradeType == "ALL" || tradeType == "DUAL") && (pat2 == CANDLE_PAT_TWEEZZERBOT || pat2 == CANDLE_PAT_TWEEZZERTOP)) {
            sig = candlePatternToSignal(pat2);
            if (sig != SIGNAL_UNKNOWN) {
                if (DRAW) cMan.drawRectAndTexton2Cand(lCand2, lCand, StringSubstr(EnumToString(pat2), 11));
                if (ALERT_ON_SIGNAL) MessageBox(StringSubstr(EnumToString(pat2), 11) + " candle detected");
                if (sig == SIGNAL_BUY) sl = MathMin(lCand2.low, lCand.low);
                else sl = MathMax(lCand2.high, lCand.high);
            }
        }
        if (!ANALYSIS) {
            switch(sig) {
               //case  SIGNAL_BUY:
               //  if (invert) return marketCanSell(withAutoStops, false, true, "normal", multiMode);
               //  else return marketCanBuy(withAutoStops, false, true, "normal", multiMode);
               //case  SIGNAL_SELL:
               //  if (invert) return marketCanBuy(withAutoStops, false, true, "normal", multiMode);
               //  else return marketCanSell(withAutoStops, false, true, "normal", multiMode);
               case  SIGNAL_BUY:
                 if (invert) return marketCanSell(sl, 0, false);
                 else return marketCanBuy(sl, 0, false);
               case  SIGNAL_SELL:
                 if (invert) return marketCanBuy(sl, 0, false);
                 else return marketCanSell(sl, 0, false);
            }
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::PAtradeCandlePattern(string tradeType = "ALL", bool invert = false, bool withAutoStops = false, bool multiMode = false) {
        Candle* lCand = cMan.lastCandle();
        Candle* lCand2 = cMan.getCandle(2);
        Candle* lCand3 = cMan.getCandle(3);
        ENUM_SIGNAL ret = PAtradeCandlePattern(lCand3, lCand2, lCand, tradeType, invert, withAutoStops, multiMode);
        //delete lCand; delete lCand2; delete lCand3;
        return ret;
    }
    ENUM_SIGNAL SignalIn::PAtradeChartWave(DotRange* _CW, int _pick = 0, bool invert = false, bool multiMode = false) {
        if (_CW.Total() < 3) return SIGNAL_UNKNOWN;
        STRUCT_CHARTPATTERN_PRED __pred[3];
        if (DRAW) drawLinesDotRange(_CW, "wave", clrYellow);
        if (!ANALYSIS) {
            _CW.getWaveCPPredict(__pred, false, true);
            //delete _ZZBuffer;
            return wavePredictMarket(__pred, _pick, invert, multiMode);
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::PAtradeChartWave(int _pick = 0, int _days = 200, int inpDepth = 12, int inpDeviation = 5, int inpBackstep = 3, bool invert = false,
            bool multiMode = false) {
        return PAtradeChartWave(cMan.getChartWave(_days, inpDepth, inpDeviation, inpBackstep), _pick, invert, multiMode);
    }
    ENUM_SIGNAL SignalIn::PAtradeChartWaveDirHHLL(DotRange* _CW, bool invert = false, bool multiMode = false) {
        if (_CW.Total() < 4) return SIGNAL_UNKNOWN;
        if (DRAW) drawLinesDotRange(_CW, "wave", clrYellow);
        if (!ANALYSIS) {
            //if (pMan.positionIsOpen()) {
            //    if (!invert && ((pMan.PositionType() == POSITION_TYPE_SELL && last3.firstmove == -1 && last3.chartpattern == CHARTPATTERN_TYPE_TU) ||
            //            (pMan.PositionType() == POSITION_TYPE_BUY && last3.firstmove == 1 && last3.chartpattern == CHARTPATTERN_TYPE_TD))) {
            //        pMan.closePosition(false);
            //    }
            //}
            STRUCT_CHARTPATTERN_CONF last3 = _CW.get3PointWaveCP(false, 20);
            STRUCT_CHARTPATTERN_CONF last3m1 = _CW.slice(-4, 3).get3PointWaveCP(false, 20);
            if (last3m1.chartpattern == CHARTPATTERN_TYPE_TD && last3m1.firstmove == -1 && last3.chartpattern == CHARTPATTERN_TYPE_TD) {
                if (invert) return marketCanBuy(false, false, true, "normal", multiMode);
                else return marketCanSell(false, false, true, "normal", multiMode);
            } else if (last3m1.chartpattern == CHARTPATTERN_TYPE_TU && last3m1.firstmove == 1 && last3.chartpattern == CHARTPATTERN_TYPE_TU) {
                if (invert) return marketCanSell(false, false, true, "normal", multiMode);
                else return marketCanBuy(false, false, true, "normal", multiMode);
            }
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::PAtradeDirChartWave(DotRange* _CW, bool invert = false, bool multiMode = false) {
        if (_CW.Total() < 3) return SIGNAL_UNKNOWN;
        if (DRAW) drawLinesDotRange(_CW, "wave", clrYellow);
        if (!ANALYSIS) {
            ENUM_POSITION_TYPE predType = _CW[-1] > _CW[-2] ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
            //delete _ZZBuffer;
            if (pMan.positionIsOpen()) {
                if (!invert) {
                    if (pMan.PositionType() != predType) return marketCanTrade(predType, false, false, true, "normal", multiMode);
                } else {
                    if (pMan.PositionType() == predType) return marketCanTrade(!invert ? predType : predType == POSITION_TYPE_BUY ? POSITION_TYPE_SELL : POSITION_TYPE_BUY, false, false, true, "normal", multiMode);
                }
            } else return marketCanTrade(!invert ? predType : predType == POSITION_TYPE_BUY ? POSITION_TYPE_SELL : POSITION_TYPE_BUY, false, false, true, "normal", multiMode);
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::PAtradeDirChartWave(int _days = 200, int inpDepth = 12, int inpDeviation = 5, int inpBackstep = 3, bool invert = false, bool multiMode = false) {
        return PAtradeDirChartWave(cMan.getChartWave(_days, inpDepth, inpDeviation, inpBackstep), invert, multiMode);
    }
    ENUM_SIGNAL SignalIn::PAtradeChartPattern(DotRange* _CW, int _pick = 0, bool invert = false, bool multiMode = false, bool rectDraw = true) {
        if (_CW.Total() < 7) {
            //delete _ZZBuffer;
            return SIGNAL_UNKNOWN;
        }
        if (DRAW) drawLinesDotRange(_CW, "wave", clrYellow);
        DotRange* last5 = _CW.slice(-7);
        if (last5 == NULL) return SIGNAL_UNKNOWN;
        STRUCT_CHARTPATTERN_CONF point5Pat = last5.getRealXPointWaveChartPattern(false);
        //STRUCT_CHARTPATTERN_CONF point5Pat = last5.getReal5PointWaveChartPattern(false);
        //STRUCT_CHARTPATTERN_CONF point5Pat = last5.getReal7PointWaveChartPattern(false);
        //STRUCT_CHARTPATTERN_CONF point5Pat = last5.getReal4PointWaveChartPattern(false);
        STRUCT_CHARTPATTERN_PRED rPred[];
        ArrayResize(rPred, 2);
        //leaks memory without delete
        static rectangle* rect;
        //delete rect;
        STRUCT_CHARTPATTERN_PRED __pred[];
        STRUCT_CHARTPATTERN_PRED _Pred[3];
        Comment(StringSubstr(EnumToString(point5Pat.chartpattern), 18));
        if (point5Pat.chartpattern == CHARTPATTERN_TYPE_DOUBLETOP || point5Pat.chartpattern == CHARTPATTERN_TYPE_DOUBLEBOTTOM) {
            if (DRAW) {
                if (rectDraw) rect = new rectangle("rectt"+StringSubstr(EnumToString(point5Pat.chartpattern), 18)+IntegerToString(last5.A(0).time), last5.minimumBox(-5), last5.maximumBox(-5));
                else drawDoubleChartPattern(last5, StringSubstr(EnumToString(point5Pat.chartpattern), 18), 2);
            }
            if (ALERT_ON_SIGNAL) MessageBox(StringSubstr(EnumToString(point5Pat.chartpattern), 18) + " detected");
            if (!ANALYSIS) {
                _CW.getWaveCPPredict(__pred, false, true);
                if (point5Pat.chartpattern == CHARTPATTERN_TYPE_DOUBLETOP) {
                    if (point5Pat.firstmove == -1) _CW.slice(0, _CW.Total()-1).getWaveCPPredict(_Pred, false, true);
                    rPred[0].direction = POSITION_TYPE_SELL;
                    rPred[0].predictedCP = point5Pat.firstmove == 1 ? CHARTPATTERN_TYPE_DOUBLETOP : CHARTPATTERN_TYPE_HEADSHOULDER;
                    rPred[0].sl = point5Pat.firstmove == 1 ? _CW[-2].price : _CW[-3].price;
                    //rPred[0].sl = point5Pat.firstmove == 1 ? _CW[-2].price : _Pred[2].tp;
                    rPred[0].tp = point5Pat.firstmove == 1 ? __pred[0].sl : __pred[2].tp;
                    rPred[1].direction = POSITION_TYPE_SELL;
                    rPred[1].price = _CW[-3].price;
                    rPred[1].predictedCP = CHARTPATTERN_TYPE_DOUBLETOP;
                    rPred[1].sl = point5Pat.firstmove == 1 ? _CW[-2].price : _Pred[2].tp;
                    rPred[1].tp = point5Pat.firstmove == 1 ? __pred[0].sl : _CW[-2].price;
                    //rPred[1].tp = point5Pat.firstmove == 1 ? _CW[-1].price : _CW[-2].price;
                } else {
                    if (point5Pat.firstmove == 1) _CW.slice(0, _CW.Total()-1).getWaveCPPredict(_Pred, false, true);
                    rPred[0].direction = POSITION_TYPE_BUY;
                    rPred[0].predictedCP = point5Pat.firstmove == -1 ? CHARTPATTERN_TYPE_DOUBLEBOTTOM : CHARTPATTERN_TYPE_INVHEADSHOULDER;
                    rPred[0].sl = point5Pat.firstmove == -1 ? _CW[-2].price : _CW[-3].price;
                    //rPred[0].sl = point5Pat.firstmove == -1 ? _CW[-2].price : _Pred[2].tp;
                    rPred[0].tp = point5Pat.firstmove == -1 ? __pred[0].sl : __pred[2].tp;
                    rPred[1].direction = POSITION_TYPE_BUY;
                    rPred[1].price = _CW[-3].price;
                    rPred[1].predictedCP = CHARTPATTERN_TYPE_DOUBLEBOTTOM;
                    rPred[1].sl = point5Pat.firstmove == -1 ? _CW[-2].price : _Pred[2].tp;
                    rPred[1].tp = point5Pat.firstmove == -1 ? __pred[0].sl : __pred[2].tp;
                    //rPred[1].tp = point5Pat.firstmove == -1 ? _CW[-1].price : __pred[2].tp;
                }
                return wavePredictMarketPending(rPred, _pick, invert, multiMode);
            }
        } else if (point5Pat.chartpattern == CHARTPATTERN_TYPE_HEADSHOULDER || point5Pat.chartpattern == CHARTPATTERN_TYPE_INVHEADSHOULDER) {
            if (DRAW) {
                if (rectDraw) rect = new rectangle("rectt"+StringSubstr(EnumToString(point5Pat.chartpattern), 18)+IntegerToString(last5.A(0).time), last5.minimumBox(-7), last5.maximumBox(-7));
                else drawChannelHeadShoulder(last5, StringSubstr(EnumToString(point5Pat.chartpattern), 18), 2);
            }
            if (ALERT_ON_SIGNAL) MessageBox(StringSubstr(EnumToString(point5Pat.chartpattern), 18) + " detected");
            if (!ANALYSIS) {
                _CW.getWaveCPPredict(__pred, false, true);
                if (point5Pat.chartpattern == CHARTPATTERN_TYPE_HEADSHOULDER) {
                    if (point5Pat.firstmove == -1) _CW.slice(0, _CW.Total()-1).getWaveCPPredict(_Pred, false, true);
                    rPred[0].direction = POSITION_TYPE_SELL;
                    rPred[0].predictedCP = point5Pat.firstmove == 1 ? CHARTPATTERN_TYPE_HEADSHOULDER : CHARTPATTERN_TYPE_DOUBLETOP;
                    rPred[0].sl = point5Pat.firstmove == 1 ? _CW[-2].price : _CW[-3].price;
                    rPred[0].tp = point5Pat.firstmove == 1 ? __pred[0].sl : __pred[2].tp;
                    rPred[1].direction = POSITION_TYPE_SELL;
                    rPred[1].price = point5Pat.firstmove == 1 ? __pred[0].tp : _Pred[0].tp;
                    rPred[1].predictedCP = point5Pat.firstmove == 1 ? CHARTPATTERN_TYPE_HEADSHOULDER : CHARTPATTERN_TYPE_DOUBLETOP;
                    rPred[1].sl = point5Pat.firstmove == 1 ? _CW[-2].price : _CW[-3].price;
                    rPred[1].tp = point5Pat.firstmove == 1 ? __pred[0].sl : __pred[2].tp;
                } else {
                    if (point5Pat.firstmove == 1) _CW.slice(0, _CW.Total()-1).getWaveCPPredict(_Pred, false, true);
                    rPred[0].direction = POSITION_TYPE_BUY;
                    rPred[0].predictedCP = point5Pat.firstmove == -1 ? CHARTPATTERN_TYPE_INVHEADSHOULDER : CHARTPATTERN_TYPE_DOUBLEBOTTOM;
                    rPred[0].sl = point5Pat.firstmove == -1 ? _CW[-2].price : _CW[-3].price;
                    rPred[0].tp = point5Pat.firstmove == -1 ? __pred[0].sl : __pred[2].tp;
                    rPred[1].direction = POSITION_TYPE_BUY;
                    rPred[1].price = point5Pat.firstmove == -1 ? __pred[0].tp : _Pred[0].tp;
                    rPred[1].predictedCP = point5Pat.firstmove == -1 ? CHARTPATTERN_TYPE_INVHEADSHOULDER : CHARTPATTERN_TYPE_DOUBLEBOTTOM;
                    rPred[1].sl = point5Pat.firstmove == -1 ? _CW[-2].price : _CW[-3].price;
                    rPred[1].tp = point5Pat.firstmove == -1 ? __pred[0].sl : __pred[2].tp;
                }
                return wavePredictMarketPending(rPred, _pick, invert, multiMode);
            }
        } else if (point5Pat.chartpattern == CHARTPATTERN_TYPE_SYMMETRICALTRIANGLE || point5Pat.chartpattern == CHARTPATTERN_TYPE_RISINGWEDGE || point5Pat.chartpattern == CHARTPATTERN_TYPE_FALLINGWEDGE) {
            if (DRAW) {
                if (rectDraw) rect = new rectangle("rectt"+StringSubstr(EnumToString(point5Pat.chartpattern), 18)+IntegerToString(last5.A(0).time), last5.minimumBox(-4), last5.maximumBox(-4));
                else {
                    if (last5[-4] > last5[-3]) {
                        drawTlineOnDotRangeIndex(last5, -4, -2, "TL"+StringSubstr(EnumToString(point5Pat.chartpattern), 18)+IntegerToString(last5.A(-4).time), clrBlue, false, 2);
                        drawTlineOnDotRangeIndex(last5, -3, -1, "TL"+StringSubstr(EnumToString(point5Pat.chartpattern), 18)+IntegerToString(last5.A(-3).time), clrRed, false, 2);
                    } else {
                        drawTlineOnDotRangeIndex(last5, -3, -1, "TL"+StringSubstr(EnumToString(point5Pat.chartpattern), 18)+IntegerToString(last5.A(-3).time), clrBlue, false, 2);
                        drawTlineOnDotRangeIndex(last5, -4, -2, "TL"+StringSubstr(EnumToString(point5Pat.chartpattern), 18)+IntegerToString(last5.A(-4).time), clrRed, false, 2);
                    }
                }
            }
            if (ALERT_ON_SIGNAL) MessageBox(StringSubstr(EnumToString(point5Pat.chartpattern), 18) + " detected");
            if (point5Pat.chartpattern == CHARTPATTERN_TYPE_SYMMETRICALTRIANGLE) {
                if (!ANALYSIS) {
                    _CW.getWaveCPPredict(__pred, false, true);
                    _CW.slice(0, _CW.Total()-1).getWaveCPPredict(_Pred, false, true);
                    rPred[0].direction = point5Pat.firstmove == 1 ? POSITION_TYPE_SELL : POSITION_TYPE_BUY;
                    rPred[0].predictedCP = CHARTPATTERN_TYPE_SYMMETRICALTRIANGLE;
                    rPred[0].sl = _Pred[2].tp;
                    rPred[0].tp = __pred[2].tp;
                    //rPred[0].tp = _CW[-4].price; 
                    rPred[1].direction = point5Pat.firstmove == 1 ? POSITION_TYPE_SELL : POSITION_TYPE_BUY;
                    rPred[1].price = _CW[-3].price;
                    rPred[1].predictedCP = point5Pat.firstmove == 1 ? CHARTPATTERN_TYPE_DOUBLETOP : CHARTPATTERN_TYPE_DOUBLEBOTTOM;
                    rPred[1].sl = _Pred[2].tp;
                    rPred[1].tp = _CW[-4].price;
                    //return SIGNAL_UNKNOWN;
                    return wavePredictMarketPending(rPred, _pick, invert, multiMode);
                }
            } else if (point5Pat.chartpattern == CHARTPATTERN_TYPE_RISINGWEDGE) {
                if (!ANALYSIS) {
                    _CW.getWaveCPPredict(__pred, false, true);
                    _CW.slice(0, _CW.Total()-1).getWaveCPPredict(_Pred, false, true);
                    rPred[0].direction = POSITION_TYPE_BUY;
                    rPred[0].predictedCP = CHARTPATTERN_TYPE_RISINGWEDGE;
                    rPred[0].sl = point5Pat.firstmove == 1 ? _CW[-2].price : _CW[-3].price;
                    rPred[0].tp = point5Pat.firstmove == 1 ? __pred[0].sl : __pred[2].tp;
                    rPred[1].direction = POSITION_TYPE_BUY;
                    rPred[1].price = point5Pat.firstmove == 1 ? _CW[-2].price : _CW[-3].price;
                    rPred[1].predictedCP = CHARTPATTERN_TYPE_DOUBLEBOTTOM;
                    rPred[1].sl = point5Pat.firstmove == 1 ? __pred[2].tp : _Pred[2].tp;
                    rPred[1].tp = point5Pat.firstmove == 1 ? _CW[-1].price : _CW[-2].price;
                    return wavePredictMarketPending(rPred, _pick, invert, multiMode);
                }
            } else if (point5Pat.chartpattern == CHARTPATTERN_TYPE_FALLINGWEDGE) {
                if (!ANALYSIS) {
                    _CW.getWaveCPPredict(__pred, false, true);
                    _CW.slice(0, _CW.Total()-1).getWaveCPPredict(_Pred, false, true);
                    rPred[0].direction = POSITION_TYPE_SELL;
                    rPred[0].predictedCP = CHARTPATTERN_TYPE_FALLINGWEDGE;
                    rPred[0].sl = point5Pat.firstmove == 1 ? _CW[-3].price : _CW[-2].price;
                    rPred[0].tp = point5Pat.firstmove == 1 ? __pred[2].tp : __pred[1].sl;
                    rPred[1].direction = POSITION_TYPE_SELL;
                    rPred[1].price = point5Pat.firstmove == 1 ? _CW[-3].price : _CW[-2].price;
                    rPred[1].predictedCP = CHARTPATTERN_TYPE_DOUBLETOP;
                    rPred[1].sl = point5Pat.firstmove == 1 ? _Pred[2].tp : __pred[2].tp;
                    rPred[1].tp = point5Pat.firstmove == 1 ? _CW[-2].price : _CW[-1].price;
                    return wavePredictMarketPending(rPred, _pick, invert, multiMode);
                }
            }
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::PAtradeChartPattern(int _pick = 0, int _days = 200, int inpDepth = 12, int inpDeviation = 5, int inpBackstep = 3, bool invert = false, bool multiMode = false, bool rectDraw = true) {
        return PAtradeChartPattern(cMan.getChartWave(_days, inpDepth, inpDeviation, inpBackstep), _pick, invert, multiMode, rectDraw);
    }
    ENUM_SIGNAL SignalIn::PAtradeCPIf(DotRange* _CW, ENUM_CHARTPATTERN_TYPE _toSee = CHARTPATTERN_TYPE_NT, int _pick = 1, bool invert = false, bool multiMode = false) {
        if (DRAW) drawLinesDotRange(_CW, "wave", clrYellow);
        if (!ANALYSIS) {
            if (_CW.get3PointWaveCP(false, 10, false, 40, 60).chartpattern == _toSee) {
                STRUCT_CHARTPATTERN_PRED __pred[];
                _CW.getWaveCPPredict(__pred, false, true);
                return wavePredictMarket(__pred, _pick, invert, multiMode);
            }
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::PAtradeCPIf(ENUM_CHARTPATTERN_TYPE _toSee = CHARTPATTERN_TYPE_NT, int _pick = 1, int _days = 200, int inpDepth = 12, int inpDeviation = 5,
            int inpBackstep = 3, bool invert = false, bool multiMode = false) {
        return PAtradeCPIf(cMan.getChartWave(_days, inpDepth, inpDeviation, inpBackstep), _toSee, _pick, invert, multiMode);
    }
    ENUM_SIGNAL SignalIn::PAtradeFiboLevels(DotRange* _CW, string level = "50", int _pick = 1, bool invert = false, bool multiMode = false, int line1 = -3, int line2 = -2) {
        if (_CW.Total() < 3) return SIGNAL_UNKNOWN;
        if (DRAW) drawLinesDotRange(_CW, "wave", clrYellow);
        ObjectsDeleteAll(ChartID(), "sdfs");
        static retraceFibo* fasYHJG12s;
        delete fasYHJG12s;
        if (_CW[-2] > _CW[-3]) fasYHJG12s = new retraceFibo("sdfs", _CW[line1], Dot(_CW[line2].price, cMan.currentDate() + 30 * cMan.interval));
        else fasYHJG12s = new retraceFibo("sdfs", _CW[line1], Dot(_CW[line2].price, cMan.currentDate() + 30 * cMan.interval));
        fasYHJG12s.Color(clrYellow);
        if (!ANALYSIS) {
            int disFromLevel = (int)pricesTOpoint(fasYHJG12s.valueAt(level), cMan.currentBid());
            if (disFromLevel >= 20 && disFromLevel <= 40) {
                STRUCT_CHARTPATTERN_PRED __pred[];
                _CW.getWaveCPPredict(__pred, false, true);
                if (level == "161.8") {
                    if ((_CW[-2] > _CW[-1] && fasYHJG12s.valueAt(level) > cMan.currentBid()) ||
                            (_CW[-2] < _CW[-1] && fasYHJG12s.valueAt(level) < cMan.currentBid())) {
                        return wavePredictMarket(__pred, _pick, !invert, multiMode);
                    }
                    return wavePredictMarket(__pred, _pick, invert, multiMode);
                } else if ((int)pricesTOpoint(fasYHJG12s.valueAt(level), cMan.currentBid()) <= cMan.currentSpread()) return wavePredictMarket(__pred, _pick, invert, multiMode);
            }
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::PAtradeFiboLevels(string level = "50", int _pick = 1, int _days = 200, int inpDepth = 12, int inpDeviation = 5, int inpBackstep = 3,
            bool invert = false, bool multiMode = false) {
        return PAtradeFiboLevels(cMan.getChartWave(_days, inpDepth, inpDeviation, inpBackstep), level, _pick, invert, multiMode);
    }
    ENUM_SIGNAL SignalIn::PAtradeDivergenceChartWave(DotRange* osc, DotRange* _CW, int _pick = 1, bool invert = false, bool multiMode = false) {
        DotRange* _ZZ = _CW.slice(-4, 3);
        if (_ZZ == NULL) return SIGNAL_UNKNOWN;
        if (DRAW) drawLinesDotRange(_CW, "wave", clrYellow);
        STRUCT_CHARTPATTERN_CONF _conf = _ZZ.get3PointWaveCP(false, 20);
        double p1 = osc.priceAt(_ZZ[-3].time);
        double p2 = osc.priceAt(_ZZ[-1].time);
        if (((_conf.chartpattern == CHARTPATTERN_TYPE_TU && p1 > p2) || (_conf.chartpattern == CHARTPATTERN_TYPE_TD && p1 < p2)) && MathAbs(p1-p2) >= 10) {
            if (DRAW) {
                ObjectsDeleteAll(ChartID(), "dsefgedrdgfwe");
                ObjectsDeleteAll(ChartID(), "gfdgsergsd");
                vLine* v1 = new vLine("dsefgedrdgfwe", _ZZ[-3].time);
                v1 = new vLine("gfdgsergsd", _ZZ[-1].time);
                //Print(p1, "------", p2);
            }
            if (ALERT_ON_SIGNAL) MessageBox("Divergence detected");
            if (!ANALYSIS) {
                STRUCT_CHARTPATTERN_PRED __pred[];
                _CW.getWaveCPPredict(__pred, false, true);
                return wavePredictMarket(__pred, _pick, invert, multiMode);
            }
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::PAtradeDivergenceChartWave(DotRange* osc, int _pick = 1, int _days = 200, int inpDepth = 12, int inpDeviation = 5,
            int inpBackstep = 3, bool invert = false, bool multiMode = false) {
        return PAtradeDivergenceChartWave(osc, cMan.getChartWave(_days, inpDepth, inpDeviation, inpBackstep), _pick, invert, multiMode);
    }
    ENUM_SIGNAL SignalIn::PAtradeAnthonioStrategy(DotRange* _CW, int _pick = 0, bool invert = false, bool multiMode = false) {
        if (_CW.Total() < 6) return SIGNAL_UNKNOWN;
        if (DRAW) drawLinesDotRange(_CW, "wave", clrYellow);
        DotRange* last5 = _CW.slice(-4);
        if (_CW.slice(-4).getReal4PointWaveChartPattern(false).chartpattern == CHARTPATTERN_TYPE_SYMMETRICALTRIANGLE &&
                _CW.slice(-6, 4).getReal4PointWaveChartPattern(false).chartpattern == CHARTPATTERN_TYPE_SYMMETRICALTRIANGLE) {
            if (DRAW) rectangle* rect = new rectangle("recttAntonio"+IntegerToString(_CW[-6].time), _CW.minimumBox(-6), _CW.maximumBox(-6));
            if (ALERT_ON_SIGNAL) MessageBox("Triangle detected");
            if (!ANALYSIS) {
                STRUCT_CHARTPATTERN_PRED __pred[];
                _CW.getWaveCPPredict(__pred, false, true);
                return wavePredictMarket(__pred, _pick, invert, multiMode);
            }
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::PAtradeSRChartWave(DotRange* _CW, bool invert = false, bool multiMode = false, int closeness = 50) {
        if (_CW.Total() < 3) return SIGNAL_UNKNOWN;
        double _S[];
        double _R[];
        double cBid = cMan.currentBid();
        chartWaveToSR(_CW, cBid, _S, _R);
        if (DRAW) drawHlinesAsThick(_S, _R, closeness);
        if (!ANALYSIS) {
            int c_Sp = WRONG_VALUE;
            int c_Rp = WRONG_VALUE;
            if (ArraySize(_S) > 0) c_Sp = (int)pricesTOpoint(cBid, _S[ArrayMaximum(_S)]);
            if (ArraySize(_R) > 0) c_Rp = (int)pricesTOpoint(cBid, _R[ArrayMinimum(_R)]);
            if (c_Sp != WRONG_VALUE) {
                if (c_Rp != WRONG_VALUE) {
                    if (c_Sp < c_Rp) {
                        if (c_Sp < closeness) return marketCanBuy(false, false, true, "normal", multiMode);
                    } else {
                       if (c_Rp < closeness) return marketCanSell(false, false, true, "normal", multiMode);
                    }
                } else {
                    if (c_Sp < closeness) return marketCanBuy(false, false, true, "normal", multiMode);
                }
            } else {
                if (c_Rp != WRONG_VALUE) {
                    if (c_Rp < closeness) return marketCanSell(false, false, true, "normal", multiMode);
                }
            }
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::PApriceCrossTrendLine(bool& pTStatus, tLine* pTline, bool invert = false, bool multiMode = false, uint closeness = 10) {
        if (!CheckPointer(pTline)) return SIGNAL_UNKNOWN;
        double cPrice = cMan.currentPrice();
        double tPrice = pTline.valueAtTime();
        uint pDistance = pricesTOpoint(cPrice, tPrice);
        if (pTStatus) {
            if ((cPrice < tPrice && pDistance >= closeness)) {
                pTStatus = false;
                if (invert) return marketCanBuy(false, false, true, "normal", multiMode);
                else return marketCanSell(false, false, true, "normal", multiMode);
            }
        } else {
            if (cPrice > tPrice && pDistance >= closeness) {
                pTStatus = true;
                if (invert) return marketCanSell(false, false, true, "normal", multiMode);
                else return marketCanBuy(false, false, true, "normal", multiMode);
            }
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::PApriceCrossTrendLine(tLine* pTline, bool invert = false, bool multiMode = false, uint closeness = 10) {
        if (!CheckPointer(pTline)) return SIGNAL_UNKNOWN;
        static bool aUJD12jsdbsdXs = false;
        double cPrice = cMan.currentPrice();
        double tPrice = pTline.valueAtTime();
        uint pDistance = pricesTOpoint(cPrice, tPrice);
        if (aUJD12jsdbsdXs) {
            if (cPrice < tPrice && pDistance >= closeness) {
                aUJD12jsdbsdXs = false;
                if (invert) return marketCanBuy(false, false, true, "normal", multiMode);
                else return marketCanSell(false, false, true, "normal", multiMode);
            }
        } else {
            if (cPrice > tPrice && pDistance >= closeness) {
                aUJD12jsdbsdXs = true;
                if (invert) marketCanSell(false, false, true, "normal", multiMode);
                else return marketCanBuy(false, false, true, "normal", multiMode);
            }
        }
        return SIGNAL_UNKNOWN;
    }
    //Indicator-based trading signals
    ENUM_SIGNAL SignalIn::INcreateMarketOrdersFromPriceTrendCrossover(double trendPrice, double pPrice = 0, uint pLowDistance = 0, uint pHighDistance = 0,
            bool withAutoStops=false, bool multiMode = false) {
        bool canBuy = true;
        bool canSell = true;
        if (pPrice <= 0) {
            double cBid = cMan.currentBid();
            double cAsk = cMan.currentAsk();
            if (pLowDistance || pHighDistance) {
                uint pointBid = pricesTOpoint(cBid, trendPrice);
                uint pointAsk = pricesTOpoint(cAsk, trendPrice);
                if (pLowDistance) {
                    if (pointBid < pLowDistance) canBuy = false;
                    if (pointAsk < pLowDistance) canSell = false;
                }
                if (pHighDistance) {
                    if (pointBid > pHighDistance) canBuy = false;
                    if (pointAsk > pHighDistance) canSell = false;
                }
            }
            canBuy = (cBid > trendPrice && canBuy);
            canSell = (cAsk < trendPrice && canSell);
        } else {
            if (!withinRangeDistance(pricesTOpoint(pPrice, trendPrice), pLowDistance, pHighDistance)) return SIGNAL_UNKNOWN;
            canBuy =  pPrice > trendPrice;
            canSell = pPrice < trendPrice;
        }
        if (canBuy) return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
        else if (canSell) return marketCanSell(withAutoStops, true, true, "normal", multiMode);
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::INcreateMarketOrdersFrom2PriceCrossover(double pPrice1, double pPrice2, bool invert = false, uint pLowDistance = 0,
            uint pHighDistance = 0, bool withAutoStops=false, bool multiMode = false) {
        if (!withinRangeDistance(pricesTOpoint(pPrice1, pPrice2), pLowDistance, pHighDistance)) return SIGNAL_UNKNOWN;
        int expect = priceMARelationship2(pPrice1, pPrice2);
        if (MathAbs(expect) > 0) {
            if (expect < 0) {
                if (invert) return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
                else return marketCanSell(withAutoStops, true, true, "normal", multiMode);
            } else if (expect > 0) {
                if (invert) return marketCanSell(withAutoStops, true, true, "normal", multiMode);
                else return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
            }
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::INcreateMarketOrdersFrom2PriceCrossover2(PriceRange& pPriceRange1, PriceRange& pPriceRange2, bool invert = false,
            uint pHighDistance = 100, bool withAutoStops=false, bool exitOut = true, bool multiMode = false) {
        double cPrice = cMan.currentPrice();
        double pPrice1 = pPriceRange1.At(1);
        double pPrice2 = pPriceRange2.At(1);
        int expect;
        if (exitOut && pMan.positionIsOpen() && pMan.Comment() == "normal") {
            expect = priceMARelationship2(pPrice1, pPrice2);
            if (MathAbs(expect) > 0) {
                if (expect < 0) {
                    if (pMan.PositionType() == POSITION_TYPE_BUY) {
                        if (pMan.reversePositionNetting(2) == ACTION_ERROR) return SIGNAL_ERROR;
                    }
                } else if (expect > 0) {
                    if (pMan.PositionType() == POSITION_TYPE_SELL) {
                        if (pMan.reversePositionNetting(2) == ACTION_ERROR) return SIGNAL_ERROR;
                    }
                }
            }
        }
        if (!withinRangeDistance(pricesTOpoint(cPrice, pPrice2), pHighDistance, 0)) return true;
        expect = priceMARelationship2(pPrice1, pPrice2);
        if (MathAbs(expect) > 0) {
            if (expect < 0) {
                if (invert) {
                    if (cMan.currentAsk() < pPrice2) return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
                } else {
                    if (cMan.currentBid() > pPrice2) return marketCanSell(withAutoStops, true, true, "normal", multiMode);
                }
            } else if (expect > 0) {
                if (invert) {
                    if (cMan.currentBid() > pPrice2) return marketCanSell(withAutoStops, true, true, "normal", multiMode);
                } else {
                    if (cMan.currentAsk() < pPrice2) return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
                }
            }
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::INcreateMarketOrdersFrom2PriceCrossover(double pPrice1, double pPrice2, bool invert,
            double pLowDistance, double pHighDistance, bool withAutoStops=false, bool multiMode = false) {
        if (pLowDistance == 0 || pHighDistance == 0) return SIGNAL_ERROR;
        bool _dir = NULL;
        if (!withinLevelDistance(_dir, pPrice1, pPrice2, pLowDistance, pHighDistance)) return SIGNAL_UNKNOWN;
        int expect = priceMARelationship2(pPrice1, pPrice2);
        if (MathAbs(expect) > 0) {
            if (expect < 0 && _dir) {
                if (invert) return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
                else return marketCanSell(withAutoStops, true, true, "normal", multiMode);
            } else if (expect > 0 && !_dir) {
                if (invert) return marketCanSell(withAutoStops, true, true, "normal", multiMode);
                else return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
            }
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::INcreateMarketOrdersFrom3PriceCrossover(double pPrice1, double pPrice2, double pPrice3, int pExpect, bool withAutoStops=false, bool multiMode = false) {
        int expect = priceMARelationship3(pPrice1, pPrice2, pPrice3);
        if (MathAbs(expect) >= MathAbs(pExpect)) {
            if (expect < 0) return marketCanSell(withAutoStops, true, true, "normal", multiMode);
            else if (expect > 0) return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::INcreateMarketOrdersFrom4PriceCrossover(double pPrice1, double pPrice2, double pPrice3, double pPrice4, int pExpect, bool withAutoStops=false,
            bool multiMode = false) {
        int expect = priceMARelationship4(pPrice1, pPrice2, pPrice3, pPrice4);
        if (MathAbs(expect) >= MathAbs(pExpect)) {
            if (expect < 0) return marketCanSell(withAutoStops, true, true, "normal", multiMode);
            else if (expect > 0) return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::INcreateMarketOrdersFromSlopeChange(Dot &dot1, Dot &dot2, double pSlope, bool withAutoStops=false, bool multiMode = false) {
        double slope = getSlope(dot2.price - dot1.price, cMan.datesToCount(dot2.time, dot1.time));
        if (slope >= MathAbs(pSlope)) {
            if (slope > 0) return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
            else if (slope < 0) return marketCanSell(withAutoStops, true, true, "normal", multiMode);
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::INcreateMarketOrdersFromSlopeChange(double pPrice1, double pPrice2, uint tStep, double pSlope, bool withAutoStops=false, bool multiMode = false) {
        double slope = getSlope(pPrice1 - pPrice2, tStep);
        if (slope >= MathAbs(pSlope)) {
            if (slope > 0) return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
            else if (slope < 0) return marketCanSell(withAutoStops, true, true, "normal", multiMode);
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::INcreateMarketOrdersFromSlopeChange(datetime time1, double pPrice1, datetime time2, double pPrice2, double pSlope, bool withAutoStops=false,
            bool multiMode = false) {
        double slope = getSlope(pPrice1 - pPrice2, cMan.datesToCount(time2, time1));
        if (slope >= MathAbs(pSlope)) {
            if (slope > 0) return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
            else if (slope < 0) return marketCanSell(withAutoStops, true, true, "normal", multiMode);
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::INcreateMarketOrdersFromPriceRange(double pPrice, double lPrice, double hPrice, bool invert = false, bool withAutoStops=false, bool multiMode = false) {
        if (pPrice <= lPrice) {
            if (invert) return marketCanSell(withAutoStops, false, true, "normal", multiMode);
            else return marketCanBuy(withAutoStops, false, true, "normal", multiMode);
        }
        if (pPrice >= hPrice) {
            if (invert) return marketCanBuy(withAutoStops, false, true, "normal", multiMode);
            else return marketCanSell(withAutoStops, false, true, "normal", multiMode);
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::INtrendRangeVSoss(const double& trend[], const double& oss[], const double pPrice, const bool invert = false, bool multiMode = false) {
        if (pPrice >= trend[0] && oss[2] >= oss[1]) {
            if (invert) return marketCanBuy(false, true, true, "normal", multiMode);
            else return marketCanSell(false, true, true, "normal", multiMode);
        } else if (pPrice <= trend[1] && oss[2] <= oss[0]) {
            if (invert) return marketCanSell(false, true, true, "normal", multiMode);
            else return marketCanBuy(false, true, true, "normal", multiMode);
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::INfromSignChange(double pValue, double pSpace = 0, const bool invert = false, bool withAutoStops = false, bool multiMode = false) {
        if (pValue > 0 && pValue >= pSpace) {
            if (invert) return marketCanSell(withAutoStops, true, true, "normal", multiMode);
            else return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
        } else if (pValue < 0  && pValue <= -pSpace) {
            if (invert) return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
            else return marketCanSell(withAutoStops, true, true, "normal", multiMode);
        }
        return SIGNAL_UNKNOWN;
    }
    ENUM_SIGNAL SignalIn::INfromTrendChange(ENUM_TREND_TYPE _tType, const bool invert = false, bool withAutoStops = false, bool multiMode = false) {
        if (_tType == TREND_TYPE_UP) {
            if (invert) return marketCanSell(withAutoStops, true, true, "normal", multiMode);
            else return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
        } else if (_tType == TREND_TYPE_DOWN) {
            if (invert) return marketCanBuy(withAutoStops, true, true, "normal", multiMode);
            else return marketCanSell(withAutoStops, true, true, "normal", multiMode);
        } else if (_tType == TREND_TYPE_NOTREND) {
            if (pMan.closePosition() == ACTION_ERROR) return SIGNAL_ERROR;
            else return SIGNAL_UNKNOWN;
        }
        return SIGNAL_UNKNOWN;
    }
    //Multi Stategy trading strategy
    ENUM_SIGNAL SignalIn::multiDivergenceCandlepat(DotRange* _OSC, DotRange* _CW) {
        PAtradeDivergenceChartWave(_OSC, _CW, 0, false, true);
        PAtradeCandlePattern("DUALTRI", false, false, true);
        if (MathAbs(multiCount) >= 2) {
            multiCount = 0;
            STRUCT_CHARTPATTERN_PRED __pred[];
            _CW.getWaveCPPredict(__pred, false, true);
            return wavePredictMarket(__pred);
        }
        multiCount = 0;
        return SIGNAL_UNKNOWN;
    }
    //For Crash and boom 14 RSI, 1 - 99
    ENUM_SIGNAL SignalIn::multiCWSRandOSC(double _OSCprice, DotRange* _CW, int closeness  = 1000, double _OSClow = 30, double _OSChigh = 70) {
        PAtradeSRChartWave(_CW, false, true, closeness);
        INcreateMarketOrdersFromPriceRange(_OSCprice, _OSClow, _OSChigh, false, false, true);
        if (MathAbs(multiCount) >= 2) {
            multiCount = 0;
            STRUCT_CHARTPATTERN_PRED __pred[];
            _CW.getWaveCPPredict(__pred, false, true);
            return wavePredictMarket(__pred);
        }
        multiCount = 0;
        return SIGNAL_UNKNOWN;
    }
    ////Crash and boom
    //if (pMan.positionIsOpen()) {
    //    if (aMan.Profit() > 0) pMan.closePosition(false);
    //}
    //ENUM_SIGNAL sig = sIn.INcreateMarketOrdersFromPriceTrendCrossover(ema200.currentValue(), cMan.currentBid(), 0, 0, false, true);
    //if (sig == SIGNAL_SELL) {
    //    sIn.marketCanSell(false, false);
    //} else if (sig == SIGNAL_BUY) {
    //    if (pMan.positionIsOpen()) {
    //        pMan.closePosition(false);
    //    }
    //}
};


class SignalOut {
    private:
        CandleManager* cMan;
        OrderManager* oMan;
        PositionManager* pMan;
    public:
    SignalOut(CandleManager* cM, OrderManager* oM, PositionManager* pM) {
        cMan = cM;
        oMan = oM;
        pMan = pM;
    }
    bool fixedTrailingStopLoss(uint pTRAILING_POINT, int pMinProfit = 0, uint pStep = 10) {
        bool done = true;
        if (pMan.positionIsOpen()) {
            if (pMinProfit && pMan.Profit() < pMinProfit) return true;
            if (pStep < 10) pStep = 10;
            double cSL = pMan.scaleStopLoss();
            if (pMan.PositionType() == POSITION_TYPE_BUY) {
                double cAsk = cMan.currentAsk();
                double sl = getLowPriceFROMpoint(pTRAILING_POINT, cAsk);
                if (sl > (cSL + pointTOpriceDifference(pStep))) {
                    if (pMan.setSLTP(cAsk, sl, 0.0, true, true) == ACTION_ERROR) done = false;
                }
            } else {
                double cBid = cMan.currentBid();
                double sl = getHighPriceFROMpoint(pTRAILING_POINT, cBid);
                if (cSL == 0) cSL = sl * 2;
                if (sl < (cSL - pointTOpriceDifference(pStep))) {
                    if (pMan.setSLTP(cBid, sl, 0.0, true, true) == ACTION_ERROR) done = false;
                }
            }
        }
        return done;
    }
    bool fixedTrailingStopLossWhenTP(uint pTRAILING_POINT, double movePer = 80, uint pStep = 10) {
        bool done = true;
        if (pMan.positionIsOpen()) {
            double oPrice = pMan.PriceOpen();
            double cTP = pMan.scaleTakeProfit();
            double cSL = pMan.scaleStopLoss();
            if (cTP > 0 && pMan.Profit() > 0) {
                if (pMan.PositionType() == POSITION_TYPE_BUY) {
                    double cBid = cMan.currentBid();
                    if (((pricesTOpoint(oPrice, cBid)/(double)pricesTOpoint(oPrice, cTP)) * 100) >= movePer) {
                        double sl = getLowPriceFROMpoint(pTRAILING_POINT, cBid);
                        if (sl < oPrice) sl = getHighPriceFROMpoint(10, oPrice);
                        if (pMan.setSLTP(cMan.currentAsk(), sl, 0.0, true, true) == ACTION_ERROR) done = false;
                    }
                } else {
                    double cAsk = cMan.currentAsk();
                    if (((pricesTOpoint(oPrice, cAsk)/(double)pricesTOpoint(oPrice, cTP)) * 100) >= movePer) {
                        double sl = getHighPriceFROMpoint(pTRAILING_POINT, cAsk);
                        if (sl > oPrice) sl = getHighPriceFROMpoint(10, oPrice);
                        if (pMan.setSLTP(cMan.currentBid(), sl, 0.0, true, true) == ACTION_ERROR) done = false;
                    }
                }
            } else if (cTP <= 0 && cSL > 0) {
                if (pStep < 10) pStep = 10;
                if (pMan.PositionType() == POSITION_TYPE_BUY) {
                    double cBid = cMan.currentBid();
                    double sl = getLowPriceFROMpoint(pTRAILING_POINT, cBid);
                    if (sl < oPrice) sl = getLowPriceFROMpoint(10, oPrice);
                    if (sl > (cSL + pointTOpriceDifference(pStep))) {
                        if (pMan.setSLTP(cMan.currentAsk(), sl, 0.0, true, true) == ACTION_ERROR) done = false;
                    }
                } else {
                    double cAsk = cMan.currentAsk();
                    double sl = getHighPriceFROMpoint(pTRAILING_POINT, cAsk);
                    if (sl > oPrice) sl = getLowPriceFROMpoint(10, oPrice);
                    if (sl < (cSL - pointTOpriceDifference(pStep))) {
                        if (pMan.setSLTP(cMan.currentBid(), sl, 0.0, true, true) == ACTION_ERROR) done = false;
                    }
                }
            }
        }
        return done;
    }
    bool trailStopLossByTrend(double sl, int pMinProfit = 0, uint pStep = 10, uint pPoint = 20) {
        bool done = true;
        if (pMan.positionIsOpen()) {
            if (pMinProfit && pMan.Profit() < pMinProfit) return true;
            if (pStep < 10) pStep = 10;
            double cSL = pMan.scaleStopLoss();
            if (pMan.PositionType() == POSITION_TYPE_BUY) {
                if (sl > (cSL + pointTOpriceDifference(pStep))) {
                    if (pMan.setSLTP_price(sl, 0, false) == ACTION_ERROR)
                        return fixedTrailingStopLoss(pPoint);
                }
            } else {
                if (cSL == 0) cSL = sl * 2;
                if (sl < (cSL - pointTOpriceDifference(pStep))) {
                    if (pMan.setSLTP_price(sl, 0, false) == ACTION_ERROR)
                        return fixedTrailingStopLoss(pPoint);
                }
            }          
        }
        return done;
    }
    // Break even stop
    bool breakEvenStop(int pBreakEven, int pLockProfit) {
        if (!pMan.positionIsOpen() || pBreakEven <= 0) return true;
        double sl = pMan.scaleStopLoss();
        double oPrice = pMan.PriceOpen();
        if (pMan.PositionType() == POSITION_TYPE_BUY) {
            double breakEvenPrice = NormalizeDouble(oPrice + (pLockProfit * _Point), _Digits);
            double currentProfit = cMan.currentBid() - oPrice;
            if(sl < breakEvenPrice && currentProfit >= pBreakEven * _Point) {
                if (pMan.setSLTP_price(breakEvenPrice, 0, false) == ACTION_ERROR) {
                    Print("Could'nt set SLTP");
                    return false;
                }
            }
        } else {
            double breakEvenPrice = NormalizeDouble(oPrice - (pLockProfit * _Point), _Digits);
            double currentProfit = oPrice - cMan.currentAsk();
            if (sl == 0) sl = breakEvenPrice * 2;
            if(sl > breakEvenPrice && currentProfit >= pBreakEven * _Point) {
                if (pMan.setSLTP_price(breakEvenPrice, 0, false) == ACTION_ERROR) {
                    Print("Could'nt set SLTP");
                    return false;
                }
            }
        }
        return true;
    }
};
/*
        dR = msMan.getChartWave(DAYS, DEPTH, DEVIATION, BACKSTEP);
        dR2 = msMan.getChartWave(DAYS/BACKSTEP, DEPTH/3, BACKSTEP/2, BACKSTEP/4);
        //drawLinesDotRange(dR2, "dave", clrBlue);
        //drawLinesDotRange(dR, "wave", clrYellow);
        DotRange* dRR = dR.slice(-5, 4);
        DotRange* dRR2 = dR2.slice(-5, 4);
        
        drawChannel4DotWave(SR, dRR, "ranger", true, 3);
        drawChannel4DotWave(SR2, dRR2, "dranger", true, 1);
        
        ENUM_SIGNAL e11 = sIn.PApriceCrossTrendLine(upStatus, SR[0], false, true, 0);
        ENUM_SIGNAL e12 = sIn.PApriceCrossTrendLine(downStatus, SR[1], false, true, 0);
        
        ENUM_SIGNAL e21 = sIn.PApriceCrossTrendLine(upStatus1, SR2[0], false, true, 0);
        ENUM_SIGNAL e22 = sIn.PApriceCrossTrendLine(downStatus1, SR2[1], false, true, 0);
        
        double cPrice = cMan.currentPrice();
        
        if (!pMan.positionIsOpen()) {
            if (e22 == SIGNAL_SELL && cPrice < SR[0].valueAtTime() && cPrice > SR[1].valueAtTime()) sIn.tradeSignal(e22);
            else if (e21 == SIGNAL_BUY && cPrice > SR[1].valueAtTime() && cPrice < SR[0].valueAtTime()) sIn.tradeSignal(e21);
        } else {
            if (aMan.Profit() > 0) {
                if ((pMan.PositionType() == POSITION_TYPE_SELL  && e11 == SIGNAL_BUY) ||
                        (pMan.PositionType() == POSITION_TYPE_BUY  && e12 == SIGNAL_SELL)) {
                    pMan.closePosition(false);
                }
            } else if (aMan.Profit() < 0) {
                if ((pMan.PositionType() == POSITION_TYPE_SELL && cPrice > SR2[0].valueAtTime()) ||
                        (pMan.PositionType() == POSITION_TYPE_BUY && cPrice < SR2[1].valueAtTime())) {
                    pMan.closePosition(false);
                }
            }
        }
*/


/*
        PriceRange* highRange;
        PriceRange* lowRange;
        DateRange* dateRange;
        highRange = cMan.lastNhighPrices(DAYS, 1, false);
        lowRange = cMan.lastNlowPrices(DAYS, 1, false);
        dateRange = cMan.lastNdates(DAYS, 1, false);
        
        DotRange* sH = new DotRange(highRange, dateRange).swingHighs();
        DotRange* sL = new DotRange(lowRange, dateRange).swingLows();
        
        DotRange* startMax = new DotRange();
        DotRange* endMax = new DotRange();
        sH.allSlopes(startMax, endMax, LINE_LEN_MIN, DAY_DIFF, "DOWN");
        
        DotRange* startMin = new DotRange();
        DotRange* endMin = new DotRange();
        sL.allSlopes(startMin, endMin, LINE_LEN_MIN, DAY_DIFF, "UP");
        
        drawLinesPairAcrossDotRange(startMax, endMax);
        drawLinesDotRangePair(startMin, endMin, "WaveChart", clrBlue);
*/