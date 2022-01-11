//+------------------------------------------------------------------+
//|                                          KompleksAbstraction.mqh |
//|                                      Copyright 2020, KompleksEA. |
//|                            https://www.kompleksanda.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, KompleksEA."
#property link      "https://www.kompleksanda.blogspot.com"

#include <Object.mqh>
#include <Arrays\ArrayDouble.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayInt.mqh>
#include <Arrays\ArrayObj.mqh>

#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\TerminalInfo.mqh>

#include <Indicators\Trend.mqh>

#define  MAX_RETRIES 3 //Maximum retries
#define  RETRY_DELAY 2000 //Retry delay
input bool AUTO_ADJUST_STOP = true; //Adjust incorrect stops?

//Money Management
enum ENUM_MONEY_MANAGEMENT_MODE {
    MONEY_MANAGEMENT_FIXED,
    MONEY_MANAGEMENT_BALANCE_PERCENTAGE,
    MONEY_MANAGEMENT_MARTINGALE,
};
sinput string MONEY_MANAGEMENT; //MONEY MANAGEMENT
input ENUM_MONEY_MANAGEMENT_MODE MONEY_MANAGEMENT_MODE = MONEY_MANAGEMENT_FIXED; //Money Management mode
input double MONEY_RISK_BALANCE_PERCENTAGE = 2.0; //Percentage of balance to risk
input double MONEY_RISK_FIXED = 1.0; //Fixed lot size
input double MONEY_MANAGEMENT_MARTINGALE_CHANGE_PERCENTAGE = 1.0; //Martingale percentage change

//Risk & Profit Management
sinput string RISK_PROFIT_MANAGEMENT; //RISK & PROFIT MANAGEMENT
input double RR_RATIO = 0.3333; //Risk to profit ratio
input uint RR_RATIO_SCALE = 100; // Risk to profit scale factor
input bool AUTO_TAKE_PARTIAL_PROFIT = false; //Take partial profits?
input bool AUTO_TAKE_PARTIAL_LOSS = false; //Take partial loses?
input uint AUTO_PARTIAL_COUNT = 1; //Number of partial takes
input double EB_RATIO = 0; //Equity to balance ratio


//Scale out SL or Scale in TP
input bool AUTO_SCALEOUT_POSITION = false; // Scale out SLs?
input bool AUTO_SCALEOUT_INCLUDE_TP = false; //Scale in TPs?
input double AUTO_SCALEOUT_MULTIPLIER = 2; // Stop scale multiplier

enum ENUM_CHECK_RETCODE {
    CHECK_RETCODE_OK,
    CHECK_RETCODE_ERROR,
    CHECK_RETCODE_RETRY
};
enum ENUM_ACTION_RETCODE {
    ACTION_DONE,
    ACTION_NOCHANGES,
    ACTION_ERROR,
    ACTION_NOTSENT,
    ACTION_UNKNOWN
};
enum ENUM_CANDLE_TYPE {
   CANDLE_TYPE_BEAR,
   CANDLE_TYPE_BULL,
   CANDLE_TYPE_DOJI,
   CANDLE_TYPE_DASH
};
enum ENUM_CANDLE_CAT {
    CANDLE_CAT_BEAR,
    CANDLE_CAT_BULL,
    CANDLE_CAT_DOJI, //bull or bear
    CANDLE_CAT_DASH,
    CANDLE_CAT_HAMMER, //bull
    CANDLE_CAT_INVHAMMER, //bear
    CANDLE_CAT_FLY, //bull
    CANDLE_CAT_INVFLY, //bear
};

enum ENUM_CANDLE_PATTERN {
    CANDLE_PAT_UNKNOWN,
    CANDLE_PAT_BULLISHENG,
    CANDLE_PAT_BEARISHENG,
    CANDLE_PAT_MORNINGSTAR, //bull
    CANDLE_PAT_EVENINGSTAR, //bear
    CANDLE_PAT_BULLISHHARAMI,
    CANDLE_PAT_BEARISHHARAMI,
    CANDLE_PAT_TWEEZZERBOT, //bull
    CANDLE_PAT_TWEEZZERTOP, //bear
};

double pointTOpriceDifference(double point) {
    double diff = point * _Point;
    return NormalizeDouble(diff, _Digits);
}
uint pricesTOpoint(double pPriceHigh, double pPriceLow) {
    return (uint)(NormalizeDouble(MathAbs(pPriceHigh - pPriceLow) / _Point, 0));
}
uint getSLpointFROM_RRR(double pRRR=0, double pScale=0) {
    if (pScale <= 0) pScale = RR_RATIO_SCALE;
    return (uint)(pScale);
}
uint getTPpointFROM_RRR(double pRRR=0, double pScale=0) {
    if (pRRR <= 0) pRRR = RR_RATIO;
    if (pScale <= 0) pScale = RR_RATIO_SCALE;
    return (uint)(NormalizeDouble((1 / pRRR)*pScale, 0));
}
double getLowPriceFROMpoint(int pPoint, double pPrice) {
    if (pPoint <= 0) return 0;
    double pDiff = pointTOpriceDifference(pPoint);
    return NormalizeDouble(pPrice - pDiff, _Digits);
}
double getHighPriceFROMpoint(int pPoint, double pPrice) {
    if (pPoint <= 0) return 0;
    double pDiff = pointTOpriceDifference(pPoint);
    return NormalizeDouble(pPrice + pDiff, _Digits);
}
double verifyVolume(double pVol) {
    double volStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    int ratio = (int)MathRound(pVol/volStep);
    if (MathAbs(ratio*volStep - pVol) > 0.0000001) pVol = ratio*volStep;
    double minVol = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
    double maxVol = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
    if (pVol < minVol) pVol = minVol;
    if (pVol > maxVol) pVol = maxVol;
    return pVol;  
}

void addToEndofDoubleArr(double& arr[], double elem) {
    ArrayResize(arr, ArraySize(arr)+1);
    arr[ArraySize(arr)-1] = elem;
}

void adjustPricesWithinLevel(double& arr[], double pPrice, uint pPoint, bool lastOnly=false) {
    int end;
    if (lastOnly) end = ArraySize(arr)-1;
    else end = 0;
    if (end < 0) {
        addToEndofDoubleArr(arr, pPrice);
        return;
    }
    for (int i = ArraySize(arr)-1; i >= end; i--) {
        if (pricesTOpoint(arr[i], pPrice) <= pPoint) {
            arr[i] = (arr[i] +pPrice)/2;
            return;
        }
    }
    addToEndofDoubleArr(arr, pPrice);
}

ENUM_CHECK_RETCODE CheckReturnCode(uint pRetCode) {
    switch(pRetCode) {
        case TRADE_RETCODE_DONE:
        case TRADE_RETCODE_DONE_PARTIAL:
        case TRADE_RETCODE_PLACED:
        case TRADE_RETCODE_NO_CHANGES:
            return CHECK_RETCODE_OK;
        case TRADE_RETCODE_REQUOTE:
        case TRADE_RETCODE_CONNECTION:
        case TRADE_RETCODE_PRICE_CHANGED:
        case TRADE_RETCODE_TIMEOUT:
        case TRADE_RETCODE_PRICE_OFF:
        case TRADE_RETCODE_REJECT:
        case TRADE_RETCODE_ERROR:
            return CHECK_RETCODE_RETRY;
        default: return CHECK_RETCODE_ERROR;
    }
}
ENUM_POSITION_TYPE mapOrderTypeTOpositionType(ENUM_ORDER_TYPE pType) {
    switch(pType) {
       case ORDER_TYPE_BUY:
       case ORDER_TYPE_BUY_STOP:
       case ORDER_TYPE_BUY_LIMIT:
       case ORDER_TYPE_BUY_STOP_LIMIT:
            return POSITION_TYPE_BUY;
       case ORDER_TYPE_SELL:
       case ORDER_TYPE_SELL_STOP:
       case ORDER_TYPE_SELL_LIMIT:
       case ORDER_TYPE_SELL_STOP_LIMIT:
            return POSITION_TYPE_SELL;
       default:
            return WRONG_VALUE;
     }
}
bool mapActionrRetcodeToBool(ENUM_ACTION_RETCODE retCode) {
    if (retCode == ACTION_DONE) return true;
    return false;
}
ENUM_TRADE_REQUEST_ACTIONS mapOrderTypeTOrequestAction(
        ENUM_ORDER_TYPE orderType) {
    switch(orderType) {
        case ORDER_TYPE_BUY:
        case ORDER_TYPE_SELL:
            return TRADE_ACTION_DEAL;
        case ORDER_TYPE_BUY_STOP:  
        case ORDER_TYPE_SELL_STOP:
        case ORDER_TYPE_BUY_LIMIT:
        case ORDER_TYPE_SELL_LIMIT:
        case ORDER_TYPE_BUY_STOP_LIMIT:
        case ORDER_TYPE_SELL_STOP_LIMIT:
            return TRADE_ACTION_PENDING;
        default:
            return WRONG_VALUE;
    }
}
string mapOrderTypeTOorderCat(ENUM_ORDER_TYPE pType) {
    switch(pType) {
       case ORDER_TYPE_BUY:
       case ORDER_TYPE_SELL:
            return "market";
       case ORDER_TYPE_BUY_LIMIT:
       case ORDER_TYPE_SELL_LIMIT:
            return "limit";
       case ORDER_TYPE_SELL_STOP:
       case ORDER_TYPE_BUY_STOP:
            return "stop";
       case ORDER_TYPE_SELL_STOP_LIMIT:
       case ORDER_TYPE_BUY_STOP_LIMIT:
            return "stoplimit";
       default:
            return "";
     }
}
string mapOrderTypeTOstring(ENUM_ORDER_TYPE pType) {
    if(pType == ORDER_TYPE_BUY) return "buy";
    else if(pType == ORDER_TYPE_SELL) return "sell";
    else if(pType == ORDER_TYPE_BUY_STOP) return "buy stop";
    else if(pType == ORDER_TYPE_BUY_LIMIT) return "buy limit";
    else if(pType == ORDER_TYPE_SELL_STOP) return "sell stop";
    else if(pType == ORDER_TYPE_SELL_LIMIT) return "sell limit";
    else if(pType == ORDER_TYPE_BUY_STOP_LIMIT) return "buy stop limit";
    else if(pType == ORDER_TYPE_SELL_STOP_LIMIT) return "sell stop limit";
    else return "";
}
string mapRequestActionTOstring(ENUM_TRADE_REQUEST_ACTIONS pRequestAction){
    if (pRequestAction == TRADE_ACTION_DEAL) return "market";
    else if (pRequestAction == TRADE_ACTION_PENDING) return "pending";
    else if (pRequestAction == TRADE_ACTION_SLTP) return "modify market";
    else if (pRequestAction == TRADE_ACTION_MODIFY) return "modify pending";
    else if (pRequestAction == TRADE_ACTION_REMOVE) return "delete pending";
    else return "";
}
double minimumStopLevel(double pPrice, string pDir) {
    ulong stopPoint = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
    if (stopPoint == 0) stopPoint = 50;
    double stopLevel = pointTOpriceDifference(stopPoint);
    if (pDir == "high") return pPrice + stopLevel;
    if (pDir == "low") return pPrice - stopLevel;
    return WRONG_VALUE;
}
ENUM_ACTION_RETCODE getSLTP(double &pArr[], ENUM_POSITION_TYPE tradeDir, double pPrice, int pSL, int pTP,
        bool keepZero=false) {
    double minStopHigh = minimumStopLevel(pPrice, "high");
    double minStopLow = minimumStopLevel(pPrice, "low");
    double curPrice;
    if (tradeDir == POSITION_TYPE_BUY) {
        if (pSL <= 0) {
            if (keepZero) {
                pArr[0] = 0;
            } else {
                curPrice = getLowPriceFROMpoint(getSLpointFROM_RRR(), pPrice);
                if (curPrice > minStopLow) {
                    if (AUTO_ADJUST_STOP) {
                        curPrice = minStopLow;
                        Print("Stop Auto Adjusted");
                    }
                    else return ACTION_ERROR;
                }
                pArr[0] = curPrice;
            }
        } else {
            curPrice = getLowPriceFROMpoint(pSL, pPrice);
            if (curPrice > minStopLow) {
                if (AUTO_ADJUST_STOP) {
                    curPrice = minStopLow;
                    Print("Stop Auto Adjusted");
                }
                else return ACTION_ERROR;
            }
            pArr[0] = curPrice;
        }
        if (pTP <= 0) {
            if (keepZero) {
                pArr[1] = 0;
            } else {
                curPrice = getHighPriceFROMpoint(getTPpointFROM_RRR(), pPrice);
                if (curPrice < minStopHigh) {
                    if (AUTO_ADJUST_STOP) {
                        curPrice = minStopHigh;
                        Print("Stop Auto Adjusted");
                    }
                    else return ACTION_ERROR;
                }
                pArr[1] = curPrice;
            }
        } else {
            curPrice = getHighPriceFROMpoint(pTP, pPrice);
            if (curPrice < minStopHigh) {
                if (AUTO_ADJUST_STOP) {
                    curPrice = minStopHigh;
                    Print("Stop Auto Adjusted");
                }
                else return ACTION_ERROR;
            }
            pArr[1] = curPrice;
        }
    } else if (tradeDir == POSITION_TYPE_SELL) {
        if (pSL <= 0) {
            if (!keepZero) {
                curPrice = getHighPriceFROMpoint(getSLpointFROM_RRR(), pPrice);
                if (curPrice < minStopHigh) {
                    if (AUTO_ADJUST_STOP) {
                        curPrice = minStopHigh;
                        Print("Stop Auto Adjusted");
                    }
                    else return ACTION_ERROR;
                }
                pArr[0] = curPrice;
            } else pArr[0] = 0;
        } else {
            curPrice = getHighPriceFROMpoint(pSL, pPrice);
            if (curPrice < minStopHigh) {
                if (AUTO_ADJUST_STOP) {
                    curPrice = minStopHigh;
                    Print("Stop Auto Adjusted");
                }
                else return ACTION_ERROR;
            }
            pArr[0] = curPrice;
        }
        if (pTP <= 0) {
            if (!keepZero) {
                curPrice = getLowPriceFROMpoint(getTPpointFROM_RRR(), pPrice);
                if (curPrice > minStopLow) {
                    if (AUTO_ADJUST_STOP) {
                        curPrice = minStopLow;
                        Print("Stop Auto Adjusted");
                    }
                    else return ACTION_ERROR;
                }
                pArr[1] = curPrice;
            } else pArr[1] = 0;
        } else {
            curPrice = getLowPriceFROMpoint(pTP, pPrice);
            if (curPrice > minStopLow) {
                if (AUTO_ADJUST_STOP) {
                    curPrice = minStopLow;
                    Print("Stop Auto Adjusted");
                }
                else return ACTION_ERROR;
            }
            pArr[1] = curPrice;
        }
    }
    return ACTION_DONE;
}
ENUM_ACTION_RETCODE mapSLTPtoPoints(ENUM_POSITION_TYPE orderDir, double priceToUse,
        double pSL, double pTP, uint &pArr[]) {
    pArr[0] = 0;
    pArr[1] = 0;
    if (pSL < 0 || pTP < 0) {
        Print("SL/TP < 0");
        return ACTION_ERROR;
    } else if (pSL == 0 && pTP == 0) return ACTION_DONE;
    if (orderDir == POSITION_TYPE_BUY) {
        if (pSL > 0) {
            if (pTP > 0 && (pSL >= pTP || pTP <= priceToUse)) {
                Print("Illegal values of SL/TP");
                return ACTION_ERROR;
            }
            pArr[0] = pricesTOpoint(priceToUse, pSL);
        }
        if (pTP > 0) {
            if ((pSL > 0 && pSL >= pTP) || pTP <= priceToUse) {
                Print("Illegal values of SL/TP");
                return ACTION_ERROR;
            }
            pArr[1] = pricesTOpoint(pTP, priceToUse);
        }
    } else if (orderDir == POSITION_TYPE_SELL) {
        if (pSL > 0) {
            if (pTP > 0 && (pSL <= pTP || pTP >= priceToUse)) {
                Print("Illegal values of SL/TP");
                return ACTION_ERROR;
            }
            pArr[0] = pricesTOpoint(pSL, priceToUse);
        }
        if (pTP > 0) {
            if ((pSL > 0 && pSL <= pTP) || pTP >= priceToUse) {
                Print("Illegal values of SL/TP");
                return ACTION_ERROR;
            }
            pArr[1] = pricesTOpoint(priceToUse, pTP);
        }
    }
    return ACTION_DONE;
}

class PriceRange : public CArrayDouble {
    public:
    PriceRange::PriceRange(double &pPrices[]) {
        for (int i = 0; i < ArraySize(pPrices); i++) {
            if (!Add(pPrices[i]))
                Print("Could'nt add a price");
        }
    }
};
class LongRange : public CArrayLong {
    public:
    LongRange::LongRange(long &pLong[]) {
        for (int i = 0; i < ArraySize(pLong); i++) {
            if (!Add(pLong[i]))
                Print("Could'nt add a long");
        }
    }
};
class IntRange : public CArrayInt {
    public:
    IntRange::IntRange(int &pInt[]) {
        for (int i = 0; i < ArraySize(pInt); i++) {
            if (!Add(pInt[i]))
                Print("Could'nt add a int");
        }
    }
};

// Price Managers
class PriceManager {
    protected:
        ENUM_TIMEFRAMES timeFrame;
    public:
    PriceManager::PriceManager(ENUM_TIMEFRAMES pTF=PERIOD_CURRENT) {
        timeFrame = pTF;
    }
    double PriceManager::currentAsk() {
        return SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    }
    double PriceManager::currentBid() {
        return SymbolInfoDouble(_Symbol, SYMBOL_BID);
    }
    PriceRange* PriceManager::lastNclosePrices(int n, int pShift = 0) {
        double prices[];
        ArraySetAsSeries(prices, true);
        CopyClose(_Symbol, timeFrame, 0+pShift, n+pShift, prices);
        return new PriceRange(prices);
    }
    PriceRange* PriceManager::lastNopenPrices(int n, int pShift = 0) {
        double prices[];
        ArraySetAsSeries(prices, true);
        CopyOpen(_Symbol, timeFrame, 0+pShift, n+pShift, prices);
        return new PriceRange(prices);
    }
    PriceRange* PriceManager::lastNhighPrices(int n, int pShift = 0) {
        double prices[];
        ArraySetAsSeries(prices, true);
        CopyHigh(_Symbol, timeFrame, 0+pShift, n+pShift, prices);
        return new PriceRange(prices);
    }
    PriceRange* PriceManager::lastNlowPrices(int n, int pShift = 0) {
        double prices[];
        ArraySetAsSeries(prices, true);
        CopyLow(_Symbol, timeFrame, 0+pShift, n+pShift, prices);
        return new PriceRange(prices);
    }
    double PriceManager::currentClose(void) {
        return lastNclosePrices(1).At(0);
    }
    double PriceManager::lastClose(void) {
        return lastNclosePrices(1, 1).At(0);
    }
    double PriceManager::currentOpen(void) {
        return lastNopenPrices(1).At(0);
    }
    double PriceManager::lastOpen(void) {
        return lastNopenPrices(1, 1).At(0);
    }
    double PriceManager::currentLow(void) {
        return lastNlowPrices(1).At(0);
    }
    double PriceManager::lastLow(void) {
        return lastNlowPrices(1, 1).At(0);
    }
    double PriceManager::currentHigh(void) {
        return lastNhighPrices(1).At(0);
    }
    double PriceManager::lastHigh(void) {
        return lastNhighPrices(1, 1).At(0);
    }
};
class Order : public COrderInfo {
    public:
    Order::Order(ulong pTicket) {
        Select(pTicket);
    }
    ENUM_ACTION_RETCODE Order::deleteOrder(void) {
        OrderManager* orderManager = new OrderManager(NULL);
        int retryCount = 0;
        ulong ticket = Ticket();
        do {
            if (!orderManager.OrderDelete(Ticket())) {
                Print("Error: Basic structure not complete");
                delete orderManager;
                return ACTION_ERROR;
            }
            ENUM_CHECK_RETCODE checkCode = CheckReturnCode(orderManager.ResultRetcode());
            if(checkCode == CHECK_RETCODE_ERROR) {
                Print("Fatal Error occurred");
                delete orderManager;
                return(ACTION_ERROR);
            } else if(checkCode == CHECK_RETCODE_OK) {
                delete orderManager;
                return(ACTION_DONE);
            } else if (checkCode == CHECK_RETCODE_RETRY) {
                Print("Server error detected, retrying...");
                Sleep(RETRY_DELAY);
                retryCount++;
            } else {
                Print("Unknown Check return code");
                delete orderManager;
                return(ACTION_UNKNOWN);
            }  
        } while (retryCount < MAX_RETRIES);
        if(retryCount >= MAX_RETRIES) {
            //string errDesc = TradeServerReturnCodeDescription(result.retcode);
            //Alert("Max retries exceeded: Error ",result.retcode," - ",errDesc);
            Print("Max retries exceeded");
            delete orderManager;
            return (ACTION_NOTSENT);
        }
        delete orderManager;
        return(ACTION_UNKNOWN);
    }
    ENUM_ACTION_RETCODE Order::modifyOrder(int pPrice = 0, int pSL = 0, int pTP = 0, bool keepZero = false,
            bool keepSLTP = true, double pStopPrice = 0.00, ENUM_ORDER_TYPE_TIME pTypeTime = NULL, datetime pOrderExpTime = NULL) {
        if (pPrice < 0 || pSL < 0 || pTP < 0 || pStopPrice < 0) return ACTION_ERROR;
        ENUM_ORDER_TYPE orderType = OrderType();
        ENUM_POSITION_TYPE orderDir = mapOrderTypeTOpositionType(orderType);
        PriceManager priceManager;
        double cStopPrice = PriceStopLimit();
        double openPrice = PriceOpen();
        double newPrice = openPrice;
        
        if (orderDir == POSITION_TYPE_BUY) {
            if (pPrice > 0){
                if (orderType == ORDER_TYPE_BUY_STOP) newPrice = getHighPriceFROMpoint(pPrice, priceManager.currentAsk());
                else if (orderType == ORDER_TYPE_BUY_STOP_LIMIT) {
                    if (pStopPrice == 0) newPrice = getLowPriceFROMpoint(pPrice, cStopPrice);
                    else newPrice = getLowPriceFROMpoint(pPrice, pStopPrice);
                } else if (orderType == ORDER_TYPE_BUY_LIMIT) newPrice = getLowPriceFROMpoint(pPrice, priceManager.currentAsk());
            }
        } else if (orderDir == POSITION_TYPE_SELL) {
            if (pPrice > 0){
                if (orderType == ORDER_TYPE_SELL_STOP) newPrice = getLowPriceFROMpoint(pPrice, priceManager.currentBid());
                else if (orderType == ORDER_TYPE_SELL_STOP_LIMIT) {
                    if (pStopPrice == 0) newPrice = getHighPriceFROMpoint(pPrice, cStopPrice);
                    else newPrice = getLowPriceFROMpoint(pPrice, pStopPrice);
                } else if (orderType == ORDER_TYPE_SELL_LIMIT) newPrice = getHighPriceFROMpoint(pPrice, priceManager.currentBid());
            }
        }
        return modifyOrder(newPrice, pSL, pTP, keepZero, keepSLTP, pStopPrice, pTypeTime, pOrderExpTime);
    }
    ENUM_ACTION_RETCODE Order::modifyOrder(double pPrice = 0.00, int pSL = 0, int pTP = 0, bool keepZero = false,
            bool keepSLTP = true, double pStopPrice = 0.00, ENUM_ORDER_TYPE_TIME pTypeTime = NULL, datetime pOrderExpTime = NULL) {
        if (pSL < 0 || pTP < 0 || pPrice < 0 || pStopPrice < 0) return ACTION_ERROR;
        ENUM_POSITION_TYPE orderDir = mapOrderTypeTOpositionType(OrderType());
        double openPrice = PriceOpen();
        double newPrice = pPrice;
        if (pPrice == 0) newPrice = openPrice;
        double SLTP_prices[2] = {0, 0};
        if (getSLTP(SLTP_prices, orderDir, newPrice, pSL, pTP, keepZero) == ACTION_ERROR) {
            Print("One or more of SL/TP below stop level");
            return ACTION_ERROR;
        }
        if (keepSLTP) {
            if (SLTP_prices[0] == 0) SLTP_prices[0] = StopLoss();
            if (SLTP_prices[1] == 0) SLTP_prices[1] = TakeProfit();
        }
        OrderManager* orderManager = new OrderManager(NULL);
        ulong ticket = Ticket();
        int retryCount = 0;
        do {
            if (!orderManager.OrderModify(ticket, newPrice, SLTP_prices[0], SLTP_prices[1], pTypeTime, pOrderExpTime, pStopPrice)) {
                Print("Error: Basic structure not complete");
                return ACTION_ERROR;
            }
            ENUM_CHECK_RETCODE checkCode = CheckReturnCode(orderManager.ResultRetcode());
            if(checkCode == CHECK_RETCODE_ERROR) {
                Print("Fatal Error occurred");
                return(ACTION_ERROR);
            } else if(checkCode == CHECK_RETCODE_OK) {
                return(ACTION_DONE);
            } else if (checkCode == CHECK_RETCODE_RETRY) {
                Print("Server error detected, retrying...");
                Sleep(RETRY_DELAY);
                retryCount++;
            } else {
                Print("Unknown Check return code");
                return(ACTION_UNKNOWN);
            }  
        } while (retryCount < MAX_RETRIES);
        if(retryCount >= MAX_RETRIES) {
            //string errDesc = TradeServerReturnCodeDescription(result.retcode);
            //Alert("Max retries exceeded: Error ",result.retcode," - ",errDesc);
            Print("Max retries exceeded");
            return (ACTION_NOTSENT);
        }
        return(ACTION_UNKNOWN);
    }
    ENUM_ACTION_RETCODE Order::modifyOrder(double pPrice, double pSL = 0.00,
            double pTP = 0.00, bool keepZero = false, bool keepSLTP = true, double pStopPrice = 0.00,
            ENUM_ORDER_TYPE_TIME pTypeTime = NULL, datetime pOrderExpTime = NULL) {
        if (pSL < 0 || pTP < 0 || pPrice < 0 || pStopPrice < 0) return ACTION_ERROR;
        ENUM_POSITION_TYPE orderDir = mapOrderTypeTOpositionType(OrderType());
        double openPrice = PriceOpen();
        double newPrice = pPrice;
        if (pPrice == 0) newPrice = openPrice;
        uint newSL = 0;
        uint newTP = 0;
        if (orderDir == POSITION_TYPE_BUY) {
            newSL = pricesTOpoint(newPrice, pSL);
            newTP = pricesTOpoint(pTP, newPrice);
        } else if (orderDir == POSITION_TYPE_SELL) {
            newSL = pricesTOpoint(pSL, newPrice);
            newTP = pricesTOpoint(newPrice, pTP);
        }
        return modifyOrder(newPrice, newSL, newTP, keepZero, keepSLTP, pStopPrice, pTypeTime, pOrderExpTime);
    }
};

class OrderEx : public CHistoryOrderInfo {
    public:
    OrderEx(ulong pTicket) {
        Ticket(pTicket);
    };
    bool isValid(void) {
        bool retBool = true;
        State();
        if (GetLastError() != 0) retBool = false;
        ResetLastError();
        return retBool;
    }
};

class Deal : public CDealInfo {
    public:
    Deal(ulong pTicket) {
        Ticket(pTicket);
    }
};


class AccountManager : public CAccountInfo {
    public:
    AccountManager(void) {};
    double AccountManager::MarginCheck(ENUM_ORDER_TYPE pType, double pPrice, double pVol) {
        return CAccountInfo::MarginCheck(_Symbol, pType, pVol, pPrice);
    }
    double AccountManager::OrderProfitCheck(ENUM_ORDER_TYPE pType, double pOpen, double pClose, double pVol = 1) {
        return CAccountInfo::OrderProfitCheck(_Symbol, pType, pVol, pOpen, pClose);
    }
    double AccountManager::EBratio(void) {
        return Equity()/Balance();
    }
    double AccountManager::balanceChanged(void) {
        static double prevBalance = Balance();
        double cBal = Balance();
        if (prevBalance != cBal) {
            double pDiff = cBal - prevBalance;
            prevBalance = cBal;
            return pDiff;
        }
        return 0;
    }
    double AccountManager::balanceChanged(double pBal) {return Balance() - pBal;}
};


class SymbolManager : public CSymbolInfo {
    public:
    SymbolManager (void) {
        Name(_Symbol);
    }
};

class TerminalManager : public CTerminalInfo {
    public:
    TerminalManager (void);
};

class MoneyManager {
    private:
    AccountManager* aMan;
    SymbolManager* sMan;
    double martingalePercent;
    public:
    MoneyManager(AccountManager* aMMan, SymbolManager* sMMan) {
        aMan = aMMan;
        sMan = sMMan;
        martingalePercent = MONEY_RISK_BALANCE_PERCENTAGE;
    }
    double MoneyManager::getVolume(uint pPoints = 0) {
        switch(MONEY_MANAGEMENT_MODE) {
            case MONEY_MANAGEMENT_FIXED:
                return fixedVolume();
            case MONEY_MANAGEMENT_BALANCE_PERCENTAGE:
                return balancePercentage(MONEY_RISK_BALANCE_PERCENTAGE, pPoints);
            case MONEY_MANAGEMENT_MARTINGALE:
                return balancePercentage(martingalePercent, pPoints);
            default:
                return fixedVolume();
        }
    }
    
    double balancePercentage(double pPercent, uint pStopPoints = 0) {
        if(pPercent > 0) {
            if(pPercent > MONEY_RISK_BALANCE_PERCENTAGE) pPercent = MONEY_RISK_BALANCE_PERCENTAGE;
            if (pStopPoints <= 0) pStopPoints = RR_RATIO_SCALE;
            return verifyVolume(((aMan.Balance()*(pPercent/100))/pStopPoints)/sMan.TickValue());
        }
        return 0;
    }
    double fixedVolume(double pFixedVol = 0) {
        if (pFixedVol <= 0) pFixedVol = MONEY_RISK_FIXED;
        return verifyVolume(pFixedVol);
    }
    void changeMartingale(double lastProfit) {
        if (lastProfit > 0) martingalePercent += MONEY_MANAGEMENT_MARTINGALE_CHANGE_PERCENTAGE;
        else if (lastProfit < 0) martingalePercent -= MONEY_MANAGEMENT_MARTINGALE_CHANGE_PERCENTAGE;
    }
};

class OrderManager: public CTrade {
    private:
    MqlTradeRequest request;
    MqlTradeResult result;
    MoneyManager* mMan;
    
    public:
    OrderManager(MoneyManager* mMMan) {
        SetTypeFilling(ORDER_FILLING_FOK);
        ZeroMemory(request);
        ZeroMemory(result);
        mMan = mMMan;
        
    }
    double OrderManager::getVolume(uint pPoints = 0) {
        switch(MONEY_MANAGEMENT_MODE) {
            case MONEY_MANAGEMENT_FIXED:
                return mMan.fixedVolume();
            case MONEY_MANAGEMENT_BALANCE_PERCENTAGE:
                return mMan.balancePercentage(MONEY_RISK_BALANCE_PERCENTAGE, pPoints);
            default:
                return MONEY_RISK_FIXED;
                break;
        }
    }
    void OrderManager::setSlippage(ulong pSlippage) {
        request.deviation = pSlippage;
        SetDeviationInPoints(pSlippage);
    }
    ENUM_ACTION_RETCODE OrderManager::deleteOrder(ulong ticket) {
        Order *order = getOwnOrder(ticket);
        ENUM_ACTION_RETCODE retCode = ACTION_DONE;
        if (order != NULL) {
            retCode = order.deleteOrder();
            if (retCode == ACTION_DONE) delete order;
        } //else retCode = ACTION_ERROR; //The order doesn't exist, maybe deleted or wrong or has executed
        return retCode;
    }
    ENUM_ACTION_RETCODE OrderManager::createOrder(ENUM_ORDER_TYPE pType, int pPrice,
            double pVolume, int pSL=0, int pTP=0, bool keepZero=false, bool keepSLTP = true,
            double pStopPrice=0.00000, ENUM_ORDER_TYPE_TIME pTypeTime = NULL, datetime pOrderExpTime = NULL,
            string pComment=NULL) {
        double price;
        PriceManager priceManager;
        if (pType == ORDER_TYPE_BUY_STOP || pType == ORDER_TYPE_SELL_LIMIT) price = getHighPriceFROMpoint(pPrice, priceManager.currentAsk());
        else if (pType == ORDER_TYPE_SELL_STOP || pType == ORDER_TYPE_BUY_LIMIT) price = getLowPriceFROMpoint(pPrice, priceManager.currentBid());
        else if (pType == ORDER_TYPE_BUY_STOP_LIMIT) price = getLowPriceFROMpoint(pPrice, pStopPrice);
        else if (pType == ORDER_TYPE_SELL_STOP_LIMIT) price = getHighPriceFROMpoint(pPrice, pStopPrice);
        else {
            Print("Can't create deal with order manager");
            return ACTION_ERROR;
        }
        return createOrder(pType, price, pVolume, pSL, pTP, keepZero, keepSLTP, pStopPrice, pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::createOrder(ENUM_ORDER_TYPE pType, double pPrice,
            double pVolume, int pSL=0, int pTP=0, bool keepZero=false, bool keepSLTP = true,
            double pStopPrice=0.00000, ENUM_ORDER_TYPE_TIME pTypeTime = NULL, datetime pOrderExpTime = NULL,
            string pComment=NULL) {
        ENUM_TRADE_REQUEST_ACTIONS action = mapOrderTypeTOrequestAction(pType);
        PriceManager priceManager;
        double SLTP_prices[2] = {0.0, 0.0};
        if (action == TRADE_ACTION_PENDING) {
            if (pType == ORDER_TYPE_BUY_LIMIT) {
                if (pPrice >= priceManager.currentAsk()) return ACTION_ERROR;
            } else if (pType == ORDER_TYPE_SELL_STOP) {
                if (pPrice >= priceManager.currentBid()) return ACTION_ERROR;
            } else if (pType == ORDER_TYPE_SELL_LIMIT) {
                if (pPrice <= priceManager.currentBid()) return ACTION_ERROR;
            } else if (pType == ORDER_TYPE_BUY_STOP) {
                if (pPrice <= priceManager.currentAsk()) return ACTION_ERROR;
            } else if (pType == ORDER_TYPE_BUY_STOP_LIMIT) {
                if (pPrice >= pStopPrice) return ACTION_ERROR;
            } else if (pType == ORDER_TYPE_SELL_STOP_LIMIT) {
                if (pPrice <= pStopPrice) return ACTION_ERROR;
            }
            if (getSLTP(SLTP_prices, mapOrderTypeTOpositionType(pType), pPrice, pSL, pTP, keepZero) == ACTION_ERROR) {
                Print("One or more of SL/TP below stop level");
                return ACTION_ERROR;
            }  
        } else if (action == TRADE_ACTION_DEAL) {
            Print("Can't create deal with order manager");
            return ACTION_ERROR;
        }
        if (pVolume < 0) pVolume = mMan.getVolume(pSL);
        string orderType = mapOrderTypeTOstring(pType);
        int retryCount = 0;
        do {
            ENUM_CHECK_RETCODE checkCode;
            if (!OrderOpen(_Symbol, pType, pVolume, pStopPrice, pPrice, SLTP_prices[0],
                SLTP_prices[1], pTypeTime, pOrderExpTime, pComment)) {
                Print("Request structure not complete");
                return ACTION_ERROR;
            }
            checkCode = CheckReturnCode(ResultRetcode());
            if(checkCode == CHECK_RETCODE_ERROR) {
                Print("Fatal Error occurred");
                return(ACTION_ERROR);
            } else if(checkCode == CHECK_RETCODE_OK) {
                return(ACTION_DONE);
            } else if (checkCode == CHECK_RETCODE_RETRY) {
                Print("Server error detected, retrying...");
                Sleep(RETRY_DELAY);
                retryCount++;
            } else {
                Print("Unknown Check return code");
                return(ACTION_UNKNOWN);
            }  
        } while (retryCount < MAX_RETRIES);
        if(retryCount >= MAX_RETRIES) {
            //string errDesc = TradeServerReturnCodeDescription(result.retcode);
            //Alert("Max retries exceeded: Error ",result.retcode," - ",errDesc);
            Print("Max retries exceeded");
            return (ACTION_NOTSENT);
        }
        return(ACTION_UNKNOWN);
    }
    ENUM_ACTION_RETCODE OrderManager::createOrder(ENUM_ORDER_TYPE pType, double pPrice,
            double pVolume, double pSL=0.000000, double pTP=0.000000, bool keepZero=false,
            bool keepSLTP = true, double pStopPrice=0.000000, ENUM_ORDER_TYPE_TIME pTypeTime = NULL,
            datetime pOrderExpTime = NULL, string pComment=NULL) {
        ENUM_POSITION_TYPE orderDir = mapOrderTypeTOpositionType(pType);
        ENUM_TRADE_REQUEST_ACTIONS reqAction = mapOrderTypeTOrequestAction(pType);
        if (reqAction == TRADE_ACTION_DEAL) {
            Print("Can't create deal with order manager");
            return ACTION_ERROR;
        }
        int SLTPpoints[2];
        if (mapSLTPtoPoints(orderDir, pPrice, pSL, pTP, SLTPpoints) == ACTION_ERROR)
            return ACTION_ERROR;
        return createOrder(pType, pPrice, pVolume, SLTPpoints[0], SLTPpoints[1], pStopPrice,
            keepZero, keepSLTP, pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::modifyOrder(ulong ticket, int pPrice=0, int pSL=0, int pTP=0,
            bool keepZero = false, bool keepSLTP = true, double pStopPrice=0.00000,
            ENUM_ORDER_TYPE_TIME pTypeTime = NULL, datetime pOrderExpTime = NULL) {
        Order *order = getOwnOrder(ticket);
        ENUM_ACTION_RETCODE retCode;
        if (order == NULL) {
            retCode = ACTION_ERROR;
        } else {
            retCode = order.modifyOrder(pPrice, pSL, pTP, keepZero, keepSLTP, pStopPrice, pTypeTime, pOrderExpTime);
            delete order;
        }
        return retCode;
    }
    ENUM_ACTION_RETCODE OrderManager::modifyOrder(ulong ticket, double pPrice=-0.00, int pSL=0, int pTP=0,
            bool keepZero = false, bool keepSLTP = true, double pStopPrice=0.00000,
            ENUM_ORDER_TYPE_TIME pTypeTime = NULL, datetime pOrderExpTime = NULL) {
        Order *order = getOwnOrder(ticket);
        ENUM_ACTION_RETCODE retCode;
        if (order == NULL) {
            retCode = ACTION_ERROR;
        } else {
            retCode = order.modifyOrder(pPrice, pSL, pTP, keepZero, keepSLTP, pStopPrice, pTypeTime, pOrderExpTime);
            delete order;
        }
        return retCode;
    }
    ENUM_ACTION_RETCODE OrderManager::modifyOrder(ulong ticket, double pPrice=0.00, double pSL=0.00, double pTP=0.00,
            bool keepZero = false, bool keepSLTP = true, double pStopPrice=0.00000,
            ENUM_ORDER_TYPE_TIME pTypeTime = NULL, datetime pOrderExpTime = NULL) {
        Order *order = getOwnOrder(ticket);
        ENUM_ACTION_RETCODE retCode;
        if (order == NULL) {
            retCode = ACTION_ERROR;
        } else {
            retCode = order.modifyOrder(pPrice, pSL, pTP, keepZero, keepSLTP, pStopPrice, pTypeTime, pOrderExpTime);
            delete order;
        }
        return retCode;
    }
  
    //HELPER FUNCTIONS
    //
    //
    ENUM_ACTION_RETCODE OrderManager::buyLimit(double pPrice, double pVolume, double pSL=0.000000,
            double pTP=0.000000, bool keepZero=false, bool keepSLTP = true,
            ENUM_ORDER_TYPE_TIME pTypeTime = NULL, datetime pOrderExpTime = NULL, string pComment=NULL) {
        return createOrder(ORDER_TYPE_BUY_LIMIT, pPrice, pVolume, pSL, pTP, keepZero, keepSLTP, 0.000000,
            pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::buyLimit(double pPrice, double pVolume, int pSL=0,
            int pTP=0, bool keepZero=false, bool keepSLTP = true, ENUM_ORDER_TYPE_TIME pTypeTime = NULL,
            datetime pOrderExpTime = NULL, string pComment=NULL) {
        return createOrder(ORDER_TYPE_BUY_LIMIT, pPrice, pVolume, pSL, pTP, keepZero, keepSLTP, 0.000000,
            pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::buyLimit(int pPrice, double pVolume, int pSL=0,
            int pTP=0, bool keepZero=false, bool keepSLTP = true, ENUM_ORDER_TYPE_TIME pTypeTime = NULL,
            datetime pOrderExpTime = NULL, string pComment=NULL) {
        return createOrder(ORDER_TYPE_BUY_LIMIT, pPrice, pVolume, pSL, pTP, keepZero, keepSLTP, 0.000000,
            pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::sellLimit(double pPrice, double pVolume, double pSL=0.000000,
            double pTP=0.000000, bool keepZero=false, bool keepSLTP=true,
            ENUM_ORDER_TYPE_TIME pTypeTime = NULL, datetime pOrderExpTime = NULL, string pComment=NULL) {
        return createOrder(ORDER_TYPE_SELL_LIMIT, pPrice, pVolume, pSL, pTP, keepZero, keepSLTP, 0.000000,
            pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::sellLimit(double pPrice, double pVolume, int pSL=0,
            int pTP=0, bool keepZero=false, bool keepSLTP=true, ENUM_ORDER_TYPE_TIME pTypeTime = NULL,
            datetime pOrderExpTime = NULL, string pComment=NULL) {
        return createOrder(ORDER_TYPE_SELL_LIMIT, pPrice, pVolume, pSL, pTP, keepZero, keepSLTP, 0.000000,
            pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::sellLimit(int pPrice, double pVolume, int pSL=0,
            int pTP=0, bool keepZero=false, bool keepSLTP=true, ENUM_ORDER_TYPE_TIME pTypeTime = NULL,
            datetime pOrderExpTime = NULL, string pComment=NULL) {
        return createOrder(ORDER_TYPE_SELL_LIMIT, pPrice, pVolume, pSL, pTP, keepZero, keepSLTP, 0.000000,
            pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::buyStop(double pPrice, double pVolume, double pSL=0.000000,
            double pTP=0.000000, bool keepZero=false, bool keepSLTP=true, ENUM_ORDER_TYPE_TIME pTypeTime = NULL,
            datetime pOrderExpTime = NULL, string pComment=NULL) {
        return createOrder(ORDER_TYPE_BUY_STOP, pPrice, pVolume, pSL, pTP, keepZero, keepSLTP, 0.000000,
            pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::buyStop(double pPrice, double pVolume, int pSL=0,
            int pTP=0, bool keepZero=false, bool keepSLTP=true, ENUM_ORDER_TYPE_TIME pTypeTime = NULL,
            datetime pOrderExpTime = NULL, string pComment=NULL) {
        return createOrder(ORDER_TYPE_BUY_STOP, pPrice, pVolume, pSL, pTP, keepZero, keepSLTP, 0.000000,
            pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::buyStop(int pPrice, double pVolume, int pSL=0,
            int pTP=0, bool keepZero=false, bool keepSLTP=true, ENUM_ORDER_TYPE_TIME pTypeTime = NULL,
            datetime pOrderExpTime = NULL, string pComment=NULL) {
        return createOrder(ORDER_TYPE_BUY_STOP, pPrice, pVolume, pSL, pTP, keepZero, keepSLTP, 0.000000,
            pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::sellStop(double pPrice, double pVolume, double pSL=0.000000,
            double pTP=0.000000, bool keepZero=false, bool keepSLTP = true,
            ENUM_ORDER_TYPE_TIME pTypeTime = NULL, datetime pOrderExpTime = NULL, string pComment=NULL) {
        return createOrder(ORDER_TYPE_SELL_STOP, pPrice, pVolume, pSL, pTP, keepZero, keepSLTP, 0.000000,
            pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::sellStop(double pPrice, double pVolume, int pSL=0,
            int pTP=0, bool keepZero=false, bool keepSLTP=true, ENUM_ORDER_TYPE_TIME pTypeTime = NULL,
            datetime pOrderExpTime = NULL, string pComment=NULL) {
        return createOrder(ORDER_TYPE_SELL_STOP, pPrice, pVolume, pSL, pTP, keepZero, keepSLTP, 0.000000,
            pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::sellStop(int pPrice, double pVolume, int pSL=0,
            int pTP=0, bool keepZero=false, bool keepSLTP=true, ENUM_ORDER_TYPE_TIME pTypeTime = NULL,
            datetime pOrderExpTime = NULL, string pComment=NULL) {
        return createOrder(ORDER_TYPE_SELL_STOP, pPrice, pVolume, pSL, pTP, keepZero, keepSLTP, 0.000000,
            pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::buyStopLimit(double pPrice, double pVolume, double pStopPrice,
            double pSL=0.000000, double pTP=0.000000, bool keepZero=false, bool keepSLTP=true,
            ENUM_ORDER_TYPE_TIME pTypeTime = NULL, datetime pOrderExpTime = NULL, string pComment=NULL) {
        return createOrder(ORDER_TYPE_BUY_STOP_LIMIT, pPrice, pVolume, pSL, pTP, keepZero, keepSLTP, pStopPrice,
            pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::buyStopLimit(double pPrice, double pVolume, double pStopPrice,
            int pSL=0, int pTP=0, bool keepZero=false, bool keepSLTP=true, ENUM_ORDER_TYPE_TIME pTypeTime = NULL,
            datetime pOrderExpTime = NULL, string pComment=NULL) {
        return createOrder(ORDER_TYPE_BUY_STOP_LIMIT, pPrice, pVolume, pSL, pTP, keepZero, keepSLTP, pStopPrice,
            pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::buyStopLimit(int pPrice, double pVolume, double pStopPrice,
            int pSL=0, int pTP=0, bool keepZero=false, bool keepSLTP=true, ENUM_ORDER_TYPE_TIME pTypeTime = NULL,
            datetime pOrderExpTime = NULL, string pComment=NULL) {
        return createOrder(ORDER_TYPE_BUY_STOP_LIMIT, pPrice, pVolume, pSL, pTP, keepZero, keepSLTP, pStopPrice,
            pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::sellStopLimit(double pPrice, double pVolume, double pStopPrice,
            double pSL=0.000000, double pTP=0.000000, bool keepZero=false, bool keepSLTP=true,
            ENUM_ORDER_TYPE_TIME pTypeTime = NULL, datetime pOrderExpTime = NULL, string pComment=NULL) {
        return createOrder(ORDER_TYPE_SELL_STOP_LIMIT, pPrice, pVolume, pSL, pTP, keepZero, keepSLTP, pStopPrice,
            pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::sellStopLimit(double pPrice, double pVolume, double pStopPrice,
            int pSL=0, int pTP=0, bool keepZero=false, bool keepSLTP=true,ENUM_ORDER_TYPE_TIME pTypeTime = NULL,
            datetime pOrderExpTime = NULL, string pComment=NULL) {
        return createOrder(ORDER_TYPE_SELL_STOP_LIMIT, pPrice, pVolume, pSL, pTP, keepZero, keepSLTP, pStopPrice,
            pTypeTime, pOrderExpTime, pComment);
    }
    ENUM_ACTION_RETCODE OrderManager::sellStopLimit(int pPrice, double pVolume, double pStopPrice,
            int pSL=0, int pTP=0, bool keepZero=false, bool keepSLTP = true, ENUM_ORDER_TYPE_TIME pTypeTime = NULL,
            datetime pOrderExpTime = NULL, string pComment=NULL) {
        return createOrder(ORDER_TYPE_SELL_STOP_LIMIT, pPrice, pVolume, pSL, pTP, keepZero, keepSLTP, pStopPrice,
            pTypeTime, pOrderExpTime, pComment);
    }
    int OrderManager::totalOwnOrders(ENUM_ORDER_TYPE pType = NULL) {
        int total = 0;
        for (int i = 0; i < OrdersTotal(); i++) {
            if (getOwnTicketFromOrderPool(i, pType) != WRONG_VALUE) total += 1;
        }
        return total;
    }
    int OrderManager::totalOwnExOrders(ENUM_ORDER_TYPE pType = NULL) {
        int total = 0;
        for (int i = 0; i < HistoryOrdersTotal(); i++) {
            if (getOwnTicketFromHistoryPool(i, pType) != WRONG_VALUE) total += 1;
        }
        return total;
    }
    int OrderManager::totalOwnDeals(void) {
        int total = 0;
        for (int i = 0; i < HistoryDealsTotal(); i++) {
            if (getOwnTicketFromDealPool(i) != WRONG_VALUE) total += 1;
        }
        return total;
    }
    int OrderManager::totalOrders(ENUM_ORDER_TYPE pType = NULL) {
        if (pType) {
            int total = 0;
            for (int i = 0; i < OrdersTotal(); i++) {
                if (getTicketFromOrderPool(i, pType) != WRONG_VALUE) total += 1;
            }
            return total;
        } else return OrdersTotal();
    }
    int OrderManager::totalExOrders(ENUM_ORDER_TYPE pType = NULL) {
        if (pType) {
            int total = 0;
            for (int i = 0; i < HistoryOrdersTotal(); i++) {
                if (getTicketFromHistoryPool(i, pType) != WRONG_VALUE) total += 1;
            }
            return total;
        } else return HistoryOrdersTotal();
    }
    int OrderManager::totalDeals(void) {return HistoryDealsTotal();}
    Order* OrderManager::getOwnOrder(ulong pTicket, ENUM_ORDER_TYPE pType = NULL) {
        Order *order = new Order(pTicket);
        if ((order.Symbol() != _Symbol) || (pType && order.OrderType() != pType)) {
            delete order;
            return NULL;
        }
        return order;
    }
    OrderEx* OrderManager::getOwnExOrder(ulong pTicket, ENUM_ORDER_TYPE pType = NULL) {
        OrderEx *order = new OrderEx(pTicket);
        if ((order.Symbol() != _Symbol) || (pType && order.OrderType() != pType)) {
            delete order;
            return NULL;
        }
        return order;
    }
    Deal* OrderManager::getOwnDeal(ulong pTicket) {
        Deal* deal = new Deal(pTicket);
        OrderEx* order = getOwnExOrder(deal.Order());
        if (order) {
            delete order;
            return deal;
        }
        delete deal;
        return NULL;
    }
    Order* OrderManager::getOrder(ulong pTicket, ENUM_ORDER_TYPE pType = NULL) {
        Order *order = new Order(pTicket);
        if (pType && order.OrderType() != pType) {
            delete order;
            return NULL;
        }
        return order;
    }
    OrderEx* OrderManager::getExOrder(ulong pTicket, ENUM_ORDER_TYPE pType = NULL) {
        OrderEx *order = new OrderEx(pTicket);
        if (pType && order.OrderType() != pType) {
            delete order;
            return NULL;
        }
        return order;
    }
    Deal* OrderManager::getDeal(ulong pTicket) {return new Deal(pTicket);}
    ulong OrderManager::getOwnTicketFromOrderPool(int i, ENUM_ORDER_TYPE pType = NULL) {
        ulong ticket = OrderGetTicket(i);
        Order *order = getOwnOrder(ticket, pType);
        if (order == NULL) ticket = WRONG_VALUE;
        delete order;
        return ticket;
    }
    ulong OrderManager::getOwnTicketFromHistoryPool(int i, ENUM_ORDER_TYPE pType = NULL) {
        ulong ticket = HistoryOrderGetTicket(i);
        OrderEx *order = getOwnExOrder(ticket, pType);
        if (order == NULL) ticket = WRONG_VALUE;
        delete order;
        return ticket;
    }
    ulong OrderManager::getOwnTicketFromDealPool(int i) {
        ulong ticket = HistoryDealGetTicket(i);
        Deal *deal = getOwnDeal(ticket);
        if (deal == NULL) ticket = WRONG_VALUE;
        delete deal;
        return ticket;
    }
    ulong OrderManager::getTicketFromOrderPool(int i, ENUM_ORDER_TYPE pType = NULL) {
        ulong ticket = OrderGetTicket(i);
        Order *order = getOrder(ticket, pType);
        if (order == NULL) ticket = WRONG_VALUE;
        delete order;
        return ticket;
    }
    ulong OrderManager::getTicketFromHistoryPool(int i, ENUM_ORDER_TYPE pType = NULL) {
        ulong ticket = HistoryOrderGetTicket(i);
        OrderEx *order = getExOrder(ticket, pType);
        if (order == NULL) ticket = WRONG_VALUE;
        delete order;
        return ticket;
    }
    ulong OrderManager::getTicketFromDealPool(int i) {return HistoryDealGetTicket(i);}
    void OrderManager::copyOwnPendingTickets(ulong &pTickets[], ENUM_ORDER_TYPE pType = NULL) {
        ulong tickets[];
        ulong ticket;
        int index = 0;
        for (int i = 0; i < OrdersTotal(); i++) {
            ticket = getOwnTicketFromOrderPool(i, pType);
            if (ticket != WRONG_VALUE) {
                index++;
                ArrayResize(tickets,  index);
                tickets[index-1] = ticket;
            }
        }
        ArrayCopy(pTickets, tickets);
    }
    void OrderManager::copyOwnHistoryTickets(ulong &pTickets[], ENUM_ORDER_TYPE pType = NULL) {
        ulong tickets[];
        ulong ticket;
        int index = 0;
        for (int i = 0; i < HistoryOrdersTotal(); i++) {
            ticket = getOwnTicketFromHistoryPool(i, pType);
            if (ticket != WRONG_VALUE) {
                index++;
                ArrayResize(tickets,  index);
                tickets[index-1] = ticket;
            }
        }
        ArrayCopy(pTickets, tickets);
    }
    void OrderManager::copyOwnDealTickets(ulong &pTickets[]) {
        ulong tickets[];
        ulong ticket;
        int index = 0;
        for (int i = 0; i < HistoryDealsTotal(); i++) {
            ticket = getOwnTicketFromDealPool(i);
            if (ticket != WRONG_VALUE) {
                index++;
                ArrayResize(tickets,  index);
                tickets[index-1] = ticket;
            }
        }
        ArrayCopy(pTickets, tickets);
    }
    void OrderManager::copyPendingTickets(ulong &pTickets[], ENUM_ORDER_TYPE pType = NULL) {
        ulong tickets[];
        ulong ticket;
        int index = 0;
        for (int i = 0; i < OrdersTotal(); i++) {
            ticket = getTicketFromOrderPool(i, pType);
            if (ticket != WRONG_VALUE) {
                index++;
                ArrayResize(tickets,  index);
                tickets[index-1] = ticket;
            }
        }
        ArrayCopy(pTickets, tickets);
    }
    void OrderManager::copyHistoryTickets(ulong &pTickets[], ENUM_ORDER_TYPE pType = NULL) {
        ulong tickets[];
        ulong ticket;
        int index = 0;
        for (int i = 0; i < HistoryOrdersTotal(); i++) {
            ticket = getTicketFromHistoryPool(i, pType);
            if (ticket != WRONG_VALUE) {
                index++;
                ArrayResize(tickets,  index);
                tickets[index-1] = ticket;
            }
        }
        ArrayCopy(pTickets, tickets);
    }
    void OrderManager::copyDealTickets(ulong &pTickets[]) {
        ulong tickets[];
        ulong ticket;
        int index = 0;
        for (int i = 0; i < HistoryDealsTotal(); i++) {
            ticket = getTicketFromDealPool(i);
            if (ticket != WRONG_VALUE) {
                index++;
                ArrayResize(tickets,  index);
                tickets[index-1] = ticket;
            }
        }
        ArrayCopy(pTickets, tickets);
    }
    bool OrderManager::hasNumofOrdersChanged(int ownOrderPrev) {
        return ownOrderPrev != totalOwnOrders();
    }
    bool OrderManager::hasNumofOrdersChanged() {
        static int lastNumOfOrders = WRONG_VALUE;
        int currentNumOfOrders = totalOwnOrders();
        if (lastNumOfOrders == WRONG_VALUE) {
            lastNumOfOrders = currentNumOfOrders;
            return false;
        }
        if (lastNumOfOrders != currentNumOfOrders) {
            lastNumOfOrders = currentNumOfOrders;
            return true;
        }
        return false;
    }
    bool OrderManager::hasNumofOrdersChangedV2(int& numDifference) {
        static int lastNumOfOrders = WRONG_VALUE;
        int currentNumOfOrders = totalOwnOrders();
        if (lastNumOfOrders == WRONG_VALUE) {
            lastNumOfOrders = 0;
            return hasNumofOrdersChangedV2(numDifference);
        }
        if (lastNumOfOrders != currentNumOfOrders) {
            numDifference = currentNumOfOrders - lastNumOfOrders;
            lastNumOfOrders = currentNumOfOrders;
            return true;
        }
        numDifference = 0;
        return false;
    }
};
class PositionManager : public CPositionInfo {
    private:
    MqlTradeRequest request;
    MqlTradeResult result;
    OrderManager* oMan;
    MoneyManager* mMan;
    ENUM_ACTION_RETCODE PositionManager::checkScaleOut(ENUM_POSITION_TYPE pDir, double pSL, double pTP,
            bool toClear=false) {
        if (toClear) {
            if (pSL <= 0) {
                if (SLticket != WRONG_VALUE && oMan.deleteOrder(SLticket) == ACTION_ERROR) {
                    Print("Could'nt delete SL order");
                    return ACTION_ERROR;
                }
                SLticket = WRONG_VALUE;
                request.sl = 0;
            } else {
                if (SLticket == WRONG_VALUE) request.sl = pSL;
            }
            if (pTP <= 0) {
                if (TPticket != WRONG_VALUE && oMan.deleteOrder(TPticket) == ACTION_ERROR) {
                    Print("Could'nt delete TP order");
                    return ACTION_ERROR;
                }
                TPticket = WRONG_VALUE;
                request.tp = 0;
            } else {
                if (TPticket == WRONG_VALUE) request.tp = pTP;
            }
            return sendRequest();
            //return checkScaleOut(pDir, pSL, pTP, false);
        }
        if (AUTO_SCALEOUT_POSITION) {
            if (pSL <= 0) {
                if (SLticket != WRONG_VALUE && oMan.deleteOrder(SLticket) == ACTION_ERROR) {
                    Print("Could'nt delete SL order");
                    return ACTION_ERROR;
                }
                SLticket = WRONG_VALUE;
            } else {
                if (pSL != scaleStopLoss() || (pSL == scaleStopLoss() && SLticket == WRONG_VALUE)) {
                    if (SLticket != WRONG_VALUE && oMan.deleteOrder(SLticket) == ACTION_ERROR) {
                        Print("Could'nt delete SL order");
                        return ACTION_ERROR;
                    }
                    SLticket = WRONG_VALUE;
                    ENUM_ACTION_RETCODE placeOrder;
                    if (pDir == POSITION_TYPE_BUY) placeOrder = oMan.sellStop(pSL, Volume()*AUTO_SCALEOUT_MULTIPLIER, 0, 0, true, true);
                    else placeOrder = oMan.buyStop(pSL, Volume()*AUTO_SCALEOUT_MULTIPLIER, 0, 0, true, true);
                    if (placeOrder == ACTION_ERROR) {
                        Print("Could'nt make SL order");
                        return ACTION_ERROR;
                    }
                    SLticket = oMan.ResultOrder();
                }
            }
            request.sl = 0;
            if (AUTO_SCALEOUT_INCLUDE_TP) {
                if (pTP <= 0) {
                    if (TPticket != WRONG_VALUE && oMan.deleteOrder(TPticket) == ACTION_ERROR) {
                        Print("Could'nt delete TP order");
                        return ACTION_ERROR;
                    }
                    TPticket = WRONG_VALUE;
                } else {
                    if (pTP != scaleTakeProfit() || (pTP == scaleTakeProfit() && TPticket == WRONG_VALUE)) {
                        if (TPticket != WRONG_VALUE && oMan.deleteOrder(TPticket) == ACTION_ERROR) {
                            Print("Could'nt delete TP order");
                            return ACTION_ERROR;
                        }
                        TPticket = WRONG_VALUE;
                        ENUM_ACTION_RETCODE placeOrder;
                        if (pDir == POSITION_TYPE_BUY) placeOrder = oMan.sellLimit(pTP, Volume()*AUTO_SCALEOUT_MULTIPLIER, 0, 0, true, true);
                        else placeOrder = oMan.buyLimit(pTP, Volume()*AUTO_SCALEOUT_MULTIPLIER, 0, 0, true, true);
                        if (placeOrder == ACTION_ERROR) {
                            Print("Could'nt make TP order");
                            return ACTION_ERROR;
                        }
                        TPticket = oMan.ResultOrder();
                    }
                }
                request.tp = 0;
                return ACTION_DONE;
            } else {
                if (TPticket != WRONG_VALUE) {
                    if(oMan.deleteOrder(TPticket) == ACTION_ERROR) {
                        Print("Could'nt delete TP order");
                        return ACTION_ERROR;
                    }
                    TPticket = WRONG_VALUE;
                    request.tp = pTP;
                    return sendRequest();
                } else {
                    if (scaleTakeProfit() != pTP) {
                        request.tp = pTP;
                        return sendRequest();
                    } else {
                        return ACTION_DONE;
                    }
                }
            }
        } else {
            request.sl = pSL;
            request.tp = pTP;
            return sendRequest();
        }
    }
    ENUM_ACTION_RETCODE PositionManager::sendRequest(void){
        int retryCount = 0;
        do {
            if (!OrderSend(request,result)) {
                Print("Request Structure not complete");
                return ACTION_ERROR;
            }
            ENUM_CHECK_RETCODE checkCode = CheckReturnCode(result.retcode);
            if(checkCode == CHECK_RETCODE_ERROR) {
                return(ACTION_ERROR);
            } else if(checkCode == CHECK_RETCODE_OK) {
                return(ACTION_DONE);
            } else if (checkCode == CHECK_RETCODE_RETRY) {
                Print("Server error detected, retrying...");
                Sleep(RETRY_DELAY);
                retryCount++;
            } else {
                Print("Unknown Check return code");
                return(ACTION_UNKNOWN);
            }
        } while (retryCount < MAX_RETRIES);
        if(retryCount >= MAX_RETRIES) {
            Print("Max retries exceeded");
            return (ACTION_NOTSENT);
        }
        return(ACTION_UNKNOWN);
    }
    ENUM_ACTION_RETCODE PositionManager::createNow(ENUM_ORDER_TYPE pType, double pVolume,
            int pSL=0, int pTP=0, bool keepZero=false, bool keepSLTP = true, string pComment=NULL) {
        ENUM_TRADE_REQUEST_ACTIONS action = mapOrderTypeTOrequestAction(pType);
        PriceManager priceManager;
        double SLTP_prices[2] = {0.0, 0.0};
        if (pVolume < 0) pVolume = mMan.getVolume();
        if (action == TRADE_ACTION_PENDING) {
            Print("Can't create a pending order with Position Manager");
            return ACTION_ERROR; 
        } else if (action == TRADE_ACTION_DEAL) {
            request.action = TRADE_ACTION_DEAL;
            request.type = pType;
            request.symbol = _Symbol;
            request.volume = pVolume;
            request.type_filling = ORDER_FILLING_FOK;
            request.sl = 0;
            request.tp = 0;
        }
        string orderType = mapOrderTypeTOstring(pType);
        double pPrice;
        int retryCount = 0;
        do {
            ENUM_CHECK_RETCODE checkCode;
            if (pType == ORDER_TYPE_BUY) pPrice = priceManager.currentAsk();
            else pPrice = priceManager.currentBid();
            request.price = pPrice;
            if (!OrderSend(request, result)) {
                Print("Request structure not complete");
                return ACTION_ERROR;
            }
            checkCode = CheckReturnCode(result.retcode);
            if(checkCode == CHECK_RETCODE_ERROR) {
                Print("Fatal Error occurred");
                return(ACTION_ERROR);
            } else if(checkCode == CHECK_RETCODE_OK) {
                //TODO check this
                if (!keepZero) return setSLTP(result.price, pSL, pTP, false);
                return(ACTION_DONE);
            } else if (checkCode == CHECK_RETCODE_RETRY) {
                Print("Server error detected, retrying...");
                Sleep(RETRY_DELAY);
                retryCount++;
            } else {
                Print("Unknown Check return code");
                return(ACTION_UNKNOWN);
            }  
        } while (retryCount < MAX_RETRIES);
        if(retryCount >= MAX_RETRIES) {
            //string errDesc = TradeServerReturnCodeDescription(result.retcode);
            //Alert("Max retries exceeded: Error ",result.retcode," - ",errDesc);
            Print("Max retries exceeded");
            return (ACTION_NOTSENT);
        }
        return(ACTION_UNKNOWN);
    }
    ENUM_ACTION_RETCODE PositionManager::createNow(ENUM_ORDER_TYPE pType, double pVolume,
            double pSL=0.000000, double pTP=0.000000, bool keepZero=false,
            bool keepSLTP = true, string pComment=NULL) {
        ENUM_POSITION_TYPE orderDir = mapOrderTypeTOpositionType(pType);
        ENUM_TRADE_REQUEST_ACTIONS reqAction = mapOrderTypeTOrequestAction(pType);
        PriceManager priceManager;
        double priceToUse;
        if (reqAction == TRADE_ACTION_DEAL) {
            if (pType == ORDER_TYPE_BUY) priceToUse = priceManager.currentAsk();
            else priceToUse = priceManager.currentBid();
        } else {
            Print("Can't create pending order with position manager");
            return ACTION_ERROR;
        }
        int SLTPpoints[2];
        if (mapSLTPtoPoints(orderDir, priceToUse, pSL, pTP, SLTPpoints) == ACTION_ERROR)
            return ACTION_ERROR;
        return createNow(pType, pVolume, SLTPpoints[0], SLTPpoints[1], keepZero, keepSLTP, pComment);
    }
    ENUM_ACTION_RETCODE PositionManager::openPosition(ENUM_POSITION_TYPE pPosType,
            double pVolume, uint pSL=0, uint pTP=0, bool keepZero=false, bool keepSLTP = true,
            string pComment=NULL){
        double newSL = 0.0;
        double newTP = 0.0;
        PriceManager priceManager;
        if (pPosType == POSITION_TYPE_BUY) {
            if (pSL > 0) newSL = getLowPriceFROMpoint(pSL, priceManager.currentAsk());
            if (pTP > 0) newTP = getLowPriceFROMpoint(pTP, priceManager.currentBid());
        } else if (pPosType == POSITION_TYPE_SELL) {
            if (pSL > 0) newSL = getLowPriceFROMpoint(pSL, priceManager.currentAsk());
            if (pTP > 0) newTP = getLowPriceFROMpoint(pTP, priceManager.currentBid());
        }
        return openPosition(pPosType, pVolume, newSL, newTP, keepZero, keepSLTP, pComment);
    }
    ENUM_ACTION_RETCODE PositionManager::openPosition(ENUM_POSITION_TYPE pPosType,
            double pVolume, double pSL=0.000000, double pTP=0.000000, bool keepZero=false,
            bool keepSLTP = true, string pComment=NULL) {
        if (positionIsOpen()) {
            long currentPositionType = PositionType();
            if (pPosType == POSITION_TYPE_BUY) {
                if (currentPositionType == POSITION_TYPE_BUY) {
                    if (closePosition() == ACTION_ERROR) return ACTION_ERROR;
                    return buyNow(pVolume, pSL, pTP, keepZero, keepSLTP, pComment);
                }
                else if (currentPositionType == POSITION_TYPE_SELL) {
                    return buyNow(pVolume + Volume(), pSL, pTP, keepZero, keepSLTP, pComment);
                }
            }
            else if (pPosType == POSITION_TYPE_SELL) {
                if (currentPositionType == POSITION_TYPE_SELL) {
                    if (closePosition() == ACTION_ERROR) return ACTION_ERROR;
                    return sellNow(pVolume, pSL, pTP, keepZero, keepSLTP, pComment);
                }
                else if (currentPositionType == POSITION_TYPE_BUY) {
                    return sellNow(pVolume + Volume(), pSL, pTP, keepZero, keepSLTP, pComment);
                }
            } 
        } else {
            if (pPosType == POSITION_TYPE_BUY) {
                return buyNow(pVolume, pSL, pTP, keepZero, keepSLTP, pComment);
            } else if (pPosType == POSITION_TYPE_SELL){
                return sellNow(pVolume, pSL, pTP, keepZero, keepSLTP, pComment);
            }
        }
        return ACTION_UNKNOWN;
    }
       
    public:
    ulong SLticket;
    ulong TPticket;
    PositionManager::PositionManager(OrderManager* oMMan, MoneyManager* mMMan) {
        ZeroMemory(request);
        ZeroMemory(result);
        SLticket = WRONG_VALUE;
        TPticket = WRONG_VALUE;
        oMan = oMMan;
        mMan = mMMan;
    }
    void PositionManager::setSlippage(uint pSlip) {
        request.deviation = pSlip;
    }
    void PositionManager::setFillType(ENUM_ORDER_TYPE_FILLING pFill = ORDER_FILLING_FOK) {
        request.type_filling = pFill;
    }
    double PositionManager::scaleStopLoss() {
        if (AUTO_SCALEOUT_POSITION && SLticket != WRONG_VALUE) {
            Order *order = oMan.getOwnOrder(SLticket);
            if (order != NULL) {
                double sl = order.PriceOpen();
                delete order;
                return sl;
            } else {
                //The order doesn't exist, maybe deleted or wrong or has executed
                SLticket = WRONG_VALUE;
            }
        }
        return StopLoss();
    }
    double PositionManager::scaleTakeProfit() {
        if (AUTO_SCALEOUT_POSITION && TPticket != WRONG_VALUE) {
            Order *order = oMan.getOwnOrder(TPticket);
            if (order != NULL) {
                double tp = order.PriceOpen();
                delete order;
                return tp;
            } else {
                //The order doesn't exist, maybe deleted or wrong or has executed
                TPticket = WRONG_VALUE;
            }
        }
        return TakeProfit();
    }
    bool positionIsOpen(void) {return PositionSelect(_Symbol);}
    bool OTTisNewDeal(const MqlTradeTransaction& trans) {return trans.type == TRADE_TRANSACTION_DEAL_ADD;}
    ENUM_ACTION_RETCODE sendSLTPrequest(double sl, double tp) {
        request.symbol = _Symbol;
        request.action = TRADE_ACTION_SLTP;
        request.sl = sl;
        request.tp = tp;
        ENUM_ACTION_RETCODE resAct = sendRequest();
        if (resAct == ACTION_ERROR) Print("Could'nt change SL or TP");
        return resAct;
    }
    bool OTTconvertSLTPtoScalable(bool withSLTP = true) {
        if (!positionIsOpen() || !AUTO_SCALEOUT_POSITION) return true;
        double sl = scaleStopLoss(); double tp = scaleTakeProfit();
        double normSL = StopLoss();
        double normTP = TakeProfit();
        if (normSL > 0 && SLticket != WRONG_VALUE) {
            if (sendSLTPrequest(0, normTP) == ACTION_ERROR) return false;
            if (normSL != sl && oMan.modifyOrder(SLticket, (sl + normSL)/2, 0, 0, !withSLTP) == ACTION_ERROR) {
                Print("Couldn't modify SLorder");
                return false;
            }
        }
        if (AUTO_SCALEOUT_INCLUDE_TP && normTP > 0 && TPticket != WRONG_VALUE) {
            if (sendSLTPrequest(normSL, 0) == ACTION_ERROR) return false;
            if (normTP != tp && oMan.modifyOrder(TPticket, (tp + normTP)/2, 0, 0, !withSLTP) == ACTION_ERROR) {
                Print("Couldn't modify TPorder");
                return false;
            }
        }
        sl = scaleStopLoss();
        tp = scaleTakeProfit();
        if (sl > 0) {
            if (SLticket == WRONG_VALUE) {
                if (clearSL() == ACTION_ERROR) {
                    Print("Could'nt clear SL");
                    return false;
                }
                ENUM_ACTION_RETCODE posRet;
                if (PositionType() == POSITION_TYPE_BUY) posRet = oMan.sellStop(sl, Volume()*AUTO_SCALEOUT_MULTIPLIER, 0, 0, !withSLTP);
                else posRet = oMan.buyStop(sl, Volume()*AUTO_SCALEOUT_MULTIPLIER, 0, 0, !withSLTP);
                if (posRet == ACTION_ERROR) {
                    Print("Could'nt make SL order");
                    return false;
                }
                SLticket = oMan.ResultOrder();
            } else {
                Order* SLorder = oMan.getOwnOrder(SLticket);
                if (SLorder) {
                    double cVol = Volume() * AUTO_SCALEOUT_MULTIPLIER;
                    if (SLorder.VolumeCurrent() != cVol) {
                        if (SLorder.deleteOrder() == ACTION_ERROR) {
                            Print("Could'nt delete SLorder");
                            delete SLorder;
                            return false;
                        }
                        SLticket = WRONG_VALUE;
                        ENUM_ACTION_RETCODE ordRet;
                        if (withSLTP) ordRet = oMan.createOrder(SLorder.OrderType(), SLorder.PriceOpen(), cVol, SLorder.StopLoss(), SLorder.TakeProfit(), true, true, SLorder.PriceStopLimit(), SLorder.TypeTime(), SLorder.TimeExpiration(), SLorder.Comment());
                        else ordRet = oMan.createOrder(SLorder.OrderType(), SLorder.PriceOpen(), cVol, 0, 0, true, true, SLorder.PriceStopLimit(), SLorder.TypeTime(), SLorder.TimeExpiration(), SLorder.Comment());
                        if (ordRet == ACTION_ERROR) {
                            Print("Could'nt create SL order");
                            delete SLorder;
                            return false;
                        }
                        SLticket = oMan.ResultOrder();
                    }
                    delete SLorder;
                } else {
                    SLticket = WRONG_VALUE;
                }
            }
        }
        if (tp > 0) {
            if (AUTO_SCALEOUT_INCLUDE_TP) {
                if (TPticket == WRONG_VALUE) {
                    if (clearTP() == ACTION_ERROR) {
                        Print("Could'nt clear TP");
                        return false;
                    }
                    if (TPticket == WRONG_VALUE) {
                        ENUM_ACTION_RETCODE posRet;
                        if (PositionType() == POSITION_TYPE_BUY) posRet = oMan.sellLimit(tp, Volume()*AUTO_SCALEOUT_MULTIPLIER, 0, 0, !withSLTP);
                        else posRet = oMan.buyLimit(tp, Volume()*AUTO_SCALEOUT_MULTIPLIER, 0, 0, !withSLTP);
                        if (posRet == ACTION_ERROR) {
                            Print("Could'nt make TP order");
                            return false;
                        }
                        TPticket = oMan.ResultOrder();
                    }
                } else {
                    Order* TPorder = oMan.getOwnOrder(TPticket);
                    if (TPorder) {
                        double cVol = Volume() * AUTO_SCALEOUT_MULTIPLIER;
                        if (TPorder.VolumeCurrent() != cVol) {
                            if (TPorder.deleteOrder() == ACTION_ERROR) {
                                Print("Could'nt delete TPorder");
                                delete TPorder;
                                return false;
                            }
                            TPticket = WRONG_VALUE;
                            if (oMan.createOrder(TPorder.OrderType(), TPorder.PriceOpen(), cVol, TPorder.StopLoss(),
                                    TPorder.TakeProfit(), true, true, TPorder.PriceStopLimit(), TPorder.TypeTime(), TPorder.TimeExpiration(),
                                    TPorder.Comment()) == ACTION_ERROR) {
                                Print("Could'nt create TP order");
                                delete TPorder;
                                return false;
                            }
                            TPticket = oMan.ResultOrder();
                        }
                        delete TPorder;
                    } else {
                        TPticket = WRONG_VALUE;
                    }
                }
            }
        }
        return true;
    }
    bool OTTconvertScalableToSLTP(void) {
        if (!positionIsOpen() && AUTO_SCALEOUT_POSITION) return true;
        double sl = scaleStopLoss();
        double tp = scaleTakeProfit();
        if (sl > 0) {
            if (SLticket != WRONG_VALUE) {
                if (clearSL() == ACTION_ERROR) {
                    Print("Could'nt clear SL oder");
                    return false;
                }
                SLticket = WRONG_VALUE;
                if (setSLTP_price(sl, 0) == ACTION_ERROR) {
                    Print("Could'nt set SL");
                    return false;
                }
            }
            if (TPticket != WRONG_VALUE) {
                if (clearTP() == ACTION_ERROR) {
                    Print("Could'nt clear TP order");
                    return false;
                }
                TPticket = WRONG_VALUE;
                if (setSLTP_price(0, tp) == ACTION_ERROR) {
                    Print("Could'nt set TP");
                    return false;
                }
            }
        }
        return true;
    }
    bool PositionManager::OTTclearComplementaryTriggeredSLTP(bool withSLTP = true) {
        if (positionIsOpen() && AUTO_SCALEOUT_POSITION) {
            if (SLticket != WRONG_VALUE) {
                Order* SLorder = oMan.getOwnOrder(SLticket);
                if (SLorder == NULL) {
                    //order deleted, non existing or triggered
                    SLticket = WRONG_VALUE;
                    if (AUTO_SCALEOUT_INCLUDE_TP) {
                        if (TPticket != WRONG_VALUE) {
                            if (oMan.deleteOrder(TPticket) == ACTION_ERROR) {
                                Print("Could'nt delete TP order");
                                return false;
                            }
                            TPticket = WRONG_VALUE;
                        }
                    }
                }
                delete SLorder;
            }
            if (AUTO_SCALEOUT_INCLUDE_TP) {
                if (TPticket != WRONG_VALUE) {
                    Order* TPorder = oMan.getOwnOrder(TPticket);
                    if (TPorder == NULL) {
                        //order deleted, non existing or triggered
                        TPticket = WRONG_VALUE;
                        if (SLticket != WRONG_VALUE && oMan.deleteOrder(SLticket) == ACTION_ERROR) {
                            Print("Could'nt delete SL order");
                            return false;
                        }
                        SLticket = WRONG_VALUE;        
                    }
                    delete TPorder;
                }
            } else {
                if (TakeProfit() == 0 && withSLTP) {
                    if (SLticket != WRONG_VALUE && oMan.deleteOrder(SLticket) == ACTION_ERROR) {
                        Print("Could'nt delete SL order");
                        return false;
                    }
                    SLticket = WRONG_VALUE;   
                }
            }
        }
        return true;
    }
    bool PositionManager::isWithinVolumeLimit(double pVol) {
        double totVolLim = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);
        double maxVol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
        double minVol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
        if (totVolLim == 0) {
            if (pVol >= minVol && pVol <= maxVol && verifyVolume(pVol) == pVol) return true;
            return false;
        }
        if ((Volume() + pVol) <= totVolLim && pVol >= minVol && verifyVolume(pVol) == pVol) return true;
        return false;
    }
    ENUM_ACTION_RETCODE PositionManager::closePosition(void) {
        if (!positionIsOpen()) return ACTION_NOCHANGES;
        if (PositionType() == POSITION_TYPE_BUY) return sellNow(Volume(), 0, 0, true);
        else return buyNow(Volume(), 0, 0, true);
    }

    ENUM_ACTION_RETCODE PositionManager::openBuyPosition(double pVolume,
            double pSL=0.000000, double pTP=0.000000, bool keepZero=false,
            bool keepSLTP = true, string pComment=NULL) {
        return openPosition(POSITION_TYPE_BUY, pVolume, pSL, pTP,
            keepZero, keepSLTP, pComment);
    }
    ENUM_ACTION_RETCODE PositionManager::openBuyPosition(double pVolume,
            int pSL=0.000000, int pTP=0.000000, ulong pSlippage=0,
            ENUM_ORDER_TYPE_FILLING pFillType = NULL, bool keepZero=false,
            bool keepSLTP = true, string pComment=NULL) {
        return openPosition(POSITION_TYPE_BUY, pVolume, pSL, pTP,
            keepZero, keepSLTP, pComment);
    }
    ENUM_ACTION_RETCODE PositionManager::openSellPosition(double pVolume,
            double pSL=0.000000, double pTP=0.000000, ulong pSlippage=0,
            ENUM_ORDER_TYPE_FILLING pFillType = NULL, bool keepZero=false,
            bool keepSLTP = true, string pComment=NULL) {
        return openPosition(POSITION_TYPE_SELL, pVolume, pSL, pTP,
            keepZero, keepSLTP, pComment);
    }
    ENUM_ACTION_RETCODE PositionManager::openSellPosition(double pVolume,
            int pSL=0.000000, int  pTP=0.000000, ulong pSlippage=0,
            ENUM_ORDER_TYPE_FILLING pFillType = NULL, bool keepZero=false,
            bool keepSLTP = true, string pComment=NULL) {
        return openPosition(POSITION_TYPE_SELL, pVolume, pSL, pTP,
            keepZero, keepSLTP, pComment);
    }
    ENUM_ACTION_RETCODE PositionManager::setSLTP(double pPrice, uint pStopLoss = 0, uint pTakeProfit = 0, bool keepZero = false,
            bool keepSLTP = true, bool toClear = false){
        if (pStopLoss == 0 && pTakeProfit == 0 && keepZero && keepSLTP && !toClear) return ACTION_DONE;
        if (!positionIsOpen()) return ACTION_DONE;
        ENUM_POSITION_TYPE tradeDir = PositionType();
        request.action = TRADE_ACTION_SLTP;
        request.symbol = _Symbol;
        double SLTP_prices[2] = {0.0, 0.0};
        if (getSLTP(SLTP_prices, tradeDir, pPrice, pStopLoss, pTakeProfit, keepZero) == ACTION_ERROR) {
            Print("One or more of SL/TP below stop level");
            return ACTION_ERROR;
        }
        PriceManager priceManager;
        if (tradeDir == POSITION_TYPE_BUY) {
            if (SLTP_prices[0] > 0) {
                double cSL = scaleStopLoss();
                double cBid = priceManager.currentBid();
                //50 here means minimum trailing SL
                if (SLTP_prices[0] >= cBid || (pricesTOpoint(cBid, SLTP_prices[0]) <= 50)) {
                    SLTP_prices[0] = cSL;
                    double newSL = getLowPriceFROMpoint(pStopLoss, cBid);
                    if (newSL > cSL) SLTP_prices[0] = newSL;
                    //TODO check
                    if (SLTP_prices[0] == 0) SLTP_prices[0] = getLowPriceFROMpoint(getSLpointFROM_RRR(), cBid);
                }
            }
            //if (SLTP_prices[1] > 0) {
            //    double cTP = scaleTakeProfit();
            //    double cAsk = priceManager.currentAsk();
            //    if (SLTP_prices[1] <= cAsk || (pricesTOpoint(cAsk, SLTP_prices[1]) <= 50)) {
            //        SLTP_prices[1] = cTP;
            //        double newTP = getHigPriceFROMpoint(pTakeProfit, cAsk);
            //        if (cTP == 0) cTP = newTP * 2;
            //        if (newTP < cTP) SLTP_prices[1] = newTP;
            //        if (SLTP_prices[1] == 0) SLTP_prices[1] = getHighPriceFROMpoint(getTPpointFROM_RRR(), cAsk);
            //    }
            //}
        } else {
            if (SLTP_prices[0] > 0) {
                double cSL = scaleStopLoss();
                double cAsk = priceManager.currentAsk();
                //50 here means minimum trailing SL
                if (SLTP_prices[0] <= cAsk || (pricesTOpoint(cAsk, SLTP_prices[0]) <= 50)) {
                    SLTP_prices[0] = cSL;
                    double newSL = getHighPriceFROMpoint(pStopLoss, cAsk);
                    if (cSL == 0) cSL = newSL * 2;
                    if (newSL < cSL) SLTP_prices[0] = newSL;
                    if (SLTP_prices[0] == 0) SLTP_prices[0] = getHighPriceFROMpoint(getSLpointFROM_RRR(), cAsk);
                }
            }
            //if (SLTP_prices[1] > 0) {
            //    double cTP = scaleTakeProfit();
            //    double cBid = priceManager.currentBid();
            //    if (SLTP_prices[1] >= cBid|| (pricesTOpoint(cBid, SLTP_prices[1]) <= 50)) {
            //        SLTP_prices[1] = cTP;
            //        double newTP = getLowPriceFROMpoint(pTakeProfit, cBid);
            //        if (newTP < cTP) SLTP_prices[1] = newTP;
            //        if (SLTP_prices[1] == 0) SLTP_prices[1] = getLowPriceFROMpoint(getTPpointFROM_RRR(), cBid);
            //    }
            //}
        }
        if (scaleStopLoss() == SLTP_prices[0] && scaleTakeProfit() == SLTP_prices[1]) {
            if (toClear) {
                if (SLTP_prices[0] == 0 && SLTP_prices[1] == 0) return ACTION_DONE;
            }
            else return ACTION_DONE;
        }
        return checkScaleOut(tradeDir, SLTP_prices[0], SLTP_prices[1], toClear);
    }
    ENUM_ACTION_RETCODE PositionManager::setSLTP(double pPrice, double pStopLoss = 0.0, double pTakeProfit = 0.0, bool keepZero = false,
            bool keepSLTP = true, bool toClear=false) {
        if (pStopLoss <= 0 && pTakeProfit <= 0 && keepZero && keepSLTP && !toClear) return ACTION_DONE;
        if (!positionIsOpen()) return ACTION_DONE;
        uint SLTPpoints[2];
        if (mapSLTPtoPoints(PositionType(), pPrice, pStopLoss, pTakeProfit, SLTPpoints) == ACTION_ERROR)
            return ACTION_ERROR;
       return setSLTP(pPrice, SLTPpoints[0], SLTPpoints[1], keepZero, keepSLTP, toClear);
    }
    ENUM_ACTION_RETCODE PositionManager::setSLTP_price(double pSL = 0.0, double pTP = 0.0, bool keepSLTP = true, bool toClear = false) {
        if (pSL <= 0 && pTP <= 0 && keepSLTP && !toClear) return ACTION_DONE;
        if (!positionIsOpen()) return ACTION_DONE;
        ENUM_POSITION_TYPE tradeDir = PositionType();
        request.action = TRADE_ACTION_SLTP;
        request.symbol = _Symbol;
        PriceManager priceManager = PriceManager();
        if (tradeDir == POSITION_TYPE_BUY) {
            if (pSL > 0) {
                if (pSL >= priceManager.currentBid()) return ACTION_ERROR;
            } else {
                if (keepSLTP) pSL = scaleStopLoss();
            }
            if (pTP > 0) {
                if (pTP <= priceManager.currentAsk()) return ACTION_ERROR;
            } else {
                if (keepSLTP) pTP = scaleTakeProfit();
            }
        } else {
            if (pSL > 0) {
                if (pSL <= priceManager.currentAsk()) return ACTION_ERROR;
            } else {
                if (keepSLTP) pSL = scaleStopLoss();
            }
            if (pTP > 0) {
                if (pTP >= priceManager.currentBid()) return ACTION_ERROR;
            } else {
                if (keepSLTP) pTP = scaleTakeProfit();
            }
        }
        if (scaleStopLoss() == pSL && scaleTakeProfit() == pTP) {
            return ACTION_DONE;
        }
        return checkScaleOut(tradeDir, pSL, pTP, toClear);
    }
    ENUM_ACTION_RETCODE PositionManager::clearSLTP(void) {
        if (positionIsOpen()) {
            return setSLTP(0, 0, 0, true, false, true);
        }
        return ACTION_DONE;
    }
    ENUM_ACTION_RETCODE PositionManager::clearSL(void) {
        if (positionIsOpen()) {
            PriceManager priceManager = PriceManager();
            double pPrice;
            if (PositionType() == POSITION_TYPE_BUY) pPrice = priceManager.currentBid();
            else pPrice = priceManager.currentAsk();
            return setSLTP(pPrice, 0, scaleTakeProfit(), true, false, true);
        }
        return ACTION_DONE;
    }
    ENUM_ACTION_RETCODE PositionManager::clearTP(void) {
        if (positionIsOpen()) {
            PriceManager priceManager = PriceManager();
            double pPrice;
            if (PositionType() == POSITION_TYPE_BUY) pPrice = priceManager.currentAsk();
            else pPrice = priceManager.currentBid();
            return setSLTP(pPrice, scaleStopLoss(), 0, true, false, true);
        }
        return ACTION_DONE;
    }
    ENUM_ACTION_RETCODE PositionManager::buyNow(double pVolume, int pSL=0,
            int pTP=0, bool keepZero=false, bool keepSLTP = true, string pComment=NULL) {
        return createNow(ORDER_TYPE_BUY, pVolume, pSL, pTP, keepZero, keepSLTP, pComment);
    }
    ENUM_ACTION_RETCODE PositionManager::buyNow(double pVolume, double pSL=0.000000,
            double pTP=0.000000, bool keepZero=false, bool keepSLTP = true, string pComment=NULL) {
        return createNow(ORDER_TYPE_BUY, pVolume, pSL, pTP, keepZero, keepSLTP, pComment);
    }
    ENUM_ACTION_RETCODE PositionManager::sellNow(double pVolume, int pSL=0,
            int pTP=0, bool keepZero=false, bool keepSLTP = true, string pComment=NULL) {
        return createNow(ORDER_TYPE_SELL, pVolume, pSL, pTP, keepZero, keepSLTP, pComment);
    }    
    ENUM_ACTION_RETCODE PositionManager::sellNow(double pVolume, double pSL=0.000000,
            double pTP=0.000000, bool keepZero=false, bool keepSLTP = true, string pComment=NULL) {
        return createNow(ORDER_TYPE_SELL, pVolume, pSL, pTP, keepZero, keepSLTP, pComment);
    }
    void PositionManager::OTwhatIsGoingOn(void) {
        HistorySelect(0, TimeCurrent());
        int numOfChangedOrder = 0;
        if (!oMan.hasNumofOrdersChangedV2(numOfChangedOrder)) {
            static double prevSL = 0;
            static double prevTP = 0;
            if (positionIsOpen()) {
                double cSL = scaleStopLoss();
                double cTP = scaleTakeProfit();
                if (prevSL != cSL) {
                    Print("Stoploss changed from ", prevSL, " to ", cSL);
                    prevSL = cSL;
                }
                if (prevTP != cTP) {
                    Print("Takeprofit changed from ", prevTP, " to ", cTP);
                    prevTP = cTP;
                }
            }
        } else {
            static Order* lastOrder;
            Order* order;
            OrderEx* exOrder;
            ulong tickets[];
            oMan.copyOwnPendingTickets(tickets);
            if (numOfChangedOrder > 0) { // An order has been added
                order = oMan.getOwnOrder(tickets[ArraySize(tickets)-1]); //Get last order;
                if (order.State() == ORDER_STATE_STARTED) {
                    Print("Order has arrived for processing");
                    lastOrder = order;
                }
                if (order.State() == ORDER_STATE_PLACED) Print("Order has been placed");
            } else { //An order has been removed (executed)
                exOrder = oMan.getOwnExOrder(lastOrder.Ticket());
                if (exOrder.State() == ORDER_STATE_FILLED) {
                    Print("Order executed, going to deal");
                    Deal* lastDeal = oMan.getOwnDeal(oMan.getOwnTicketFromDealPool(oMan.totalOwnDeals()-1));
                    switch(lastDeal.Entry()) {
                        case DEAL_ENTRY_IN:
                            Print("Order invoked deal");
                            switch(lastDeal.Type()) {
                                case 0:
                                    if (Volume() == lastDeal.Volume()) Print("Buy position has been opened");
                                    else if (Volume() > lastDeal.Volume()) Print("Buy position incremented");
                                    break;
                                case 1:
                                    if (Volume() == lastDeal.Volume()) Print("Sell position has been opened");
                                    else if (Volume() > lastDeal.Volume()) Print("Sell position incremented");
                                    break;
                                default:
                                    Print("Unprocessed code of type - ", lastDeal.Type(), " - ", EnumToString((ENUM_DEAL_TYPE)lastDeal.Type()));
                                    break;
                            }
                            break;
                        case DEAL_ENTRY_OUT:
                            Print("Order invoked deal");
                            switch(lastDeal.Type()) {
                                case 0:
                                    if (positionIsOpen()) Print("Part of a sell position has been closed with profit, ", lastDeal.Profit());
                                    else Print("Sell position has closed on pair with profit, ", lastDeal.Profit());
                                    break;
                                case 1:
                                    if (positionIsOpen()) Print("Part of a buy position has been closed with profit, ", lastDeal.Profit());
                                    else Print("Buy position has closed on pair with profit, ", lastDeal.Profit());
                                    break;
                                default:
                                    Print("Unprocessed code of type - ", lastDeal.Type(), " - ", EnumToString((ENUM_DEAL_TYPE)lastDeal.Type()));
                                    break;
                            }
                            break;
                        case DEAL_ENTRY_INOUT:
                            Print("Order invoked deal");
                            switch(lastDeal.Type()) {
                                case 0:
                                    Print("Sell is reversed to Buy with profit, ", lastDeal.Profit());
                                    break;
                                case 1:
                                    Print("Buy is reversed to Sell with profit, ", lastDeal.Profit());
                                    break;
                                default:
                                    Print("Unprocessed code of type - ", lastDeal.Type(), " - ", EnumToString((ENUM_DEAL_TYPE)lastDeal.Type()));
                                    break;
                            }
                            break;
                        case DEAL_ENTRY_STATE:
                            Print("Indicates the state record. Unprocessed code of type - ", lastDeal.Type(), " - ", EnumToString((ENUM_DEAL_TYPE)lastDeal.Type()));
                    }
                }
            }
        }
     }
};



//Candle stick and price managers

class Candle : public CObject {
    private:
    ENUM_CANDLE_CAT Candle::getCategory(void) {
        if (type == CANDLE_TYPE_DASH) return CANDLE_CAT_DASH;
        else if (type == CANDLE_TYPE_DOJI) return CANDLE_CAT_DOJI;
        
        uint length = lengthPoint();
        uint body = bodyPoint();
        uint upWick = upWickPoint();
        uint downWick = downWickPoint();
        
        double bodyPer = ((double)body/length) * 100;
        double upWickPer = ((double)upWick/length) * 100;
        double downWickPer = ((double)downWick/length) * 100;
        double wickPer = upWickPer + downWickPer;
        
        if (bodyPer < 62) {
            if (downWickPer >= 75) {
                if (downWickPer >= 95) return CANDLE_CAT_FLY; 
                return CANDLE_CAT_HAMMER;
            }
            if (downWickPer >= 70 && wickPer >= 75) {
                if (downWickPer >= 90) return CANDLE_CAT_FLY; 
                return CANDLE_CAT_HAMMER;
            }
            if (upWickPer >= 75) {
                if (upWickPer >= 95) return CANDLE_CAT_INVFLY; 
                return CANDLE_CAT_INVHAMMER;
            }
            if (upWickPer >= 70) {
                if (upWickPer >= 90) return CANDLE_CAT_INVFLY; 
                return CANDLE_CAT_INVHAMMER;
            }
            if (bodyPer <= 12 && MathAbs(upWickPer - downWickPer) <= 5)
                return CANDLE_CAT_DOJI;
        }
        if (type == CANDLE_TYPE_BEAR) return CANDLE_CAT_BEAR;
        return CANDLE_CAT_BULL;
    }
    ENUM_CANDLE_TYPE Candle::getType(void) {
        if (lengthPoint() == 0) return CANDLE_TYPE_DASH;
        if (open < close) return CANDLE_TYPE_BULL;
        else if (open > close) return CANDLE_TYPE_BEAR;
        return CANDLE_TYPE_DOJI;
    }
    
    public:
    datetime time;
    double open;
    double high;
    double low;
    double close;
    long tickVolume;
    int spread;
    long realVolume;
    ENUM_CANDLE_TYPE type;
    ENUM_CANDLE_CAT category;
    Candle (MqlRates &pRate) {
        time = pRate.time;
        open = NormalizeDouble(pRate.open, _Digits);
        high = NormalizeDouble(pRate.high, _Digits);
        low = NormalizeDouble(pRate.low, _Digits);
        close = NormalizeDouble(pRate.close, _Digits);
        tickVolume = pRate.tick_volume;
        spread = pRate.spread;
        realVolume = pRate.real_volume;
        refresh();
    }
    Candle (double pOpen, double pHigh, double pLow, double pClose, long pRealVolume,
            long pTickVolume, datetime pTime, int pSpread) {
        time = pTime;
        open = pOpen;
        high = pHigh;
        low = pLow;
        close = pClose;
        tickVolume = pTickVolume;
        spread = pSpread;
        realVolume = pRealVolume;
        refresh();
    }
    void Candle::refresh(void) {
        type = getType();
        category = getCategory();
    }
    uint Candle::lengthPoint(void) {
        return pricesTOpoint(high, low);
    }
    uint Candle::bodyPoint(void) {
        if (type == CANDLE_TYPE_BULL)
            return pricesTOpoint(close, open);
        if (type == CANDLE_TYPE_BEAR)
            return pricesTOpoint(open, close);
        return 0;
    }
    uint Candle::upWickPoint (void) {
        if (type == CANDLE_TYPE_BULL) {
            if (high == close) return 0;
            return pricesTOpoint(high, close);
        } else if (type == CANDLE_TYPE_BEAR) {
            if (high == open) return 0;
            return pricesTOpoint(high, open);
        } else if (type == CANDLE_TYPE_DASH) return 0;
        return pricesTOpoint(high, open);
    }
    uint Candle::downWickPoint (void) {
        if (type == CANDLE_TYPE_BULL) {
            if (open == low) return 0;
            return pricesTOpoint(open, low);
        } else if (type == CANDLE_TYPE_BEAR) {
            if (close == low) return 0;
            return pricesTOpoint(close, low);
        } else if (type == CANDLE_TYPE_DASH) return 0;
        return pricesTOpoint(close, low);
    }

};


class CandleRange : public CArrayObj {
    public:
    CandleRange::CandleRange(MqlRates &pRates[]) {
        for (int i = 0; i < ArraySize(pRates); i++) {
            if (!Add(new Candle(pRates[i])))
                Print("Could'nt add a candle");
        }
    }
};


class CandleManager : public PriceManager {
    protected:
        datetime interval;
    public:
    CandleManager(ENUM_TIMEFRAMES pTimeFrame = PERIOD_CURRENT) {
        PriceManager(pTimeFrame);
        interval = currentDate() - lastCandle().time;
    }
    CandleRange* CandleManager::lastNcandles(int n, uint pShift = 0) {
        MqlRates rates [];
        ArraySetAsSeries(rates, true);
        CopyRates(_Symbol, timeFrame, 0+pShift, n+pShift, rates);
        return new CandleRange(rates);
    }
    LongRange* CandleManager::lastNtickVolume(int n, uint pShift = 0) {
        long tVol [];
        ArraySetAsSeries(tVol, true);
        CopyTickVolume(_Symbol, timeFrame, 0+pShift, n+pShift, tVol);
        return new LongRange(tVol);
    }
    LongRange* CandleManager::lastNrealVolume(int n, uint pShift = 0) {
        long tVol [];
        ArraySetAsSeries(tVol, true);
        CopyRealVolume(_Symbol, timeFrame, 0+pShift, n+pShift, tVol);
        return new LongRange(tVol);
    }
    IntRange* CandleManager::lastNspread(int n, uint pShift = 0) {
        int tSpread [];
        ArraySetAsSeries(tSpread, true);
        CopySpread(_Symbol, timeFrame, 0+pShift, n+pShift, tSpread);
        return new IntRange(tSpread);
    }
    Candle* CandleManager::lastCandle(void) {
        return lastNcandles(1, 1).At(0);
    }
    Candle* CandleManager::currentCandle(void) {
        return lastNcandles(1).At(0);
    }
    datetime CandleManager::currentDate(void) {
        //datetime dates[];
        //ArraySetAsSeries(dates, true);
        //CopyTime(_Symbol, timeFrame, 0, 1, dates);
        //return dates[0];
        //return currentCandle().time;
        return (datetime)SeriesInfoInteger(_Symbol, timeFrame, SERIES_LASTBAR_DATE);
    }
    datetime CandleManager::lastDate(void) {
        datetime dates[];
        ArraySetAsSeries(dates, true);
        CopyTime(_Symbol, timeFrame, 1, 1, dates);
        return dates[0];
        //return lastCandle().time;
    }
    long CandleManager::currentTickVolume(void) {
        return lastNtickVolume(1).At(0);
    }
    long CandleManager::lastTickVolume(void) {
        return lastNtickVolume(1, 1).At(0);
    }
    long CandleManager::currentRealVolume(void) {
        return lastNrealVolume(1).At(0);
    }
    long CandleManager::lastTRealVolume(void) {
        return lastNrealVolume(1, 1).At(0);
    }
    bool CandleManager::isNewBar(datetime pPrevDate) {
        return (pPrevDate < currentDate());
    }
    bool CandleManager::isNewBar(int& numOfBars) {
        static datetime last_time = 0;
        datetime current_time = currentDate();
        if (last_time == 0) {
            numOfBars = 0;
            last_time = current_time;
            return false;
        }
        if (last_time < current_time) {
            numOfBars = Bars(_Symbol, timeFrame, last_time, current_time) - 1;
            last_time = current_time;
            return true;
        }
        numOfBars = 0;
        return false;
    }
    bool CandleManager::isNewBar() {
        static datetime last_time = 0;
        datetime current_time = currentDate();
        if (last_time == 0) {
            last_time = current_time;
            return false;
        }
        if (last_time < current_time) {
            last_time = current_time;
            return true;
        }
        return false;
    }
    uint CandleManager::timePercentage(void) {
        return (uint)(((TimeCurrent()-currentDate())/(double)interval)*100);
    }
    bool CandleManager::isNpercentTime(uint n, uint pLastPercent) {
        uint cPercent = timePercentage();
        if (pLastPercent < n && cPercent >= n && cPercent <= n+3) return true;
        return false;
    }
    bool CandleManager::isHalfTime(uint pLastPercent) {
        return isNpercentTime(50, pLastPercent);
    }
    bool CandleManager::is25PercentTime(uint pLastPercent) {
        return isNpercentTime(25, pLastPercent);
    }
    bool CandleManager::is75PercentTime(uint pLastPercent) {
        return isNpercentTime(75, pLastPercent);
    }
    double CandleManager::lowestLow(uint i = 10, uint pShift = 1) {
        PriceRange* lows = lastNlowPrices(i+pShift);
        double low = lows.At(lows.Minimum(0+pShift, i+pShift));
        delete lows;
        return low;
    }
    double CandleManager::highestLow(int i = 10, uint pShift = 1) {
        PriceRange* lows = lastNlowPrices(i+pShift);
        double low = lows.At(lows.Maximum(0+pShift, i+pShift));
        delete lows;
        return low;
    }
    double CandleManager::lowestHigh(int i = 10, uint pShift = 1) {
        PriceRange* lows = lastNhighPrices(i+pShift);
        double low = lows.At(lows.Minimum(0+pShift, i+pShift));
        delete lows;
        return low;
    }
    double CandleManager::highestHigh(int i = 10, uint pShift = 1) {
        PriceRange* lows = lastNhighPrices(i+pShift);
        double low = lows.At(lows.Maximum(0+pShift, i+pShift));
        delete lows;
        return low;
    }
    double CandleManager::lowestClose(int i = 10, uint pShift = 1) {
        PriceRange* lows = lastNclosePrices(i+pShift);
        double low = lows.At(lows.Minimum(0+pShift, i+pShift));
        delete lows;
        return low;
    }
    double CandleManager::highestClose(int i = 10, uint pShift = 1) {
        PriceRange* lows = lastNclosePrices(i+pShift);
        double low = lows.At(lows.Maximum(0+pShift, i+pShift));
        delete lows;
        return low;
    }
    double CandleManager::lowestOpen(int i = 10, uint pShift = 1) {
        PriceRange* lows = lastNopenPrices(i+pShift);
        double low = lows.At(lows.Minimum(0+pShift, i+pShift));
        delete lows;
        return low;
    }
    double CandleManager::highestOpen(int i = 10, uint pShift = 1) {
        PriceRange* lows = lastNopenPrices(i+pShift);
        double low = lows.At(lows.Maximum(0+pShift, i+pShift));
        delete lows;
        return low;
    }
    ENUM_CANDLE_PATTERN CandleManager::dualCandlePat(Candle* pC, Candle* cC) {
        if (cC.type == CANDLE_TYPE_BULL) {
            if (pC.type == CANDLE_TYPE_BEAR) {
                if (cC.bodyPoint() >= 1.8*pC.bodyPoint()) return CANDLE_PAT_BULLISHENG;
                else if (pC.bodyPoint() >= 1.8*cC.bodyPoint()) return CANDLE_PAT_BULLISHHARAMI;
                else if (pricesTOpoint(pC.bodyPoint(), cC.bodyPoint()) < 20) return CANDLE_PAT_TWEEZZERBOT;
            }
        } else if (cC.type == CANDLE_TYPE_BEAR) {
            if (pC.type == CANDLE_TYPE_BULL) {
                if (cC.bodyPoint() >= 1.8*pC.bodyPoint()) return CANDLE_PAT_BEARISHENG;
                else if (pC.bodyPoint() >= 1.8*cC.bodyPoint()) return CANDLE_PAT_BEARISHHARAMI;
                else if (pricesTOpoint(pC.bodyPoint(), cC.bodyPoint()) < 20) return CANDLE_PAT_TWEEZZERTOP;
            }
        }
        return CANDLE_PAT_BEARISHENG;
    }
    ENUM_CANDLE_PATTERN CandleManager::triCandlePat(Candle* ppC, Candle* pC, Candle* cC) {
        if (cC.type == CANDLE_TYPE_BULL) {
            if (ppC.type == CANDLE_TYPE_BEAR) {
                if (cC.bodyPoint() >= 2.8*pC.bodyPoint() && ppC.bodyPoint() >= 2.8*pC.bodyPoint()) return CANDLE_PAT_MORNINGSTAR;
            }
        } else if (cC.type == CANDLE_TYPE_BEAR) {
            if (ppC.type == CANDLE_TYPE_BULL) {
                if (cC.bodyPoint() >= 2.8*pC.bodyPoint() && ppC.bodyPoint() >= 2.8*pC.bodyPoint()) return CANDLE_PAT_EVENINGSTAR;
            }
        }
        return CANDLE_PAT_BEARISHENG;
    }
};
class RiskProfitManager {
    private:
    CandleManager* cMan;
    OrderManager* oMan;
    PositionManager* pMan;
    ulong takeSLtickets[];
    ulong takeTPtickets[];
    double takeSLfilled;
    double takeTPfilled;
    ENUM_POSITION_TYPE curTakeTPType;
    ENUM_POSITION_TYPE curTakeSLType;
    
    public:
    RiskProfitManager(CandleManager* cM, OrderManager* oM, PositionManager* pM) {
        cMan = cM;
        oMan = oM;
        pMan = pM;
        takeSLfilled = 0;
        takeTPfilled = 0;
        if (AUTO_TAKE_PARTIAL_PROFIT) {
            ArrayResize(takeTPtickets, AUTO_PARTIAL_COUNT);
            for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) takeTPtickets[i] = WRONG_VALUE;
        }
        if (AUTO_TAKE_PARTIAL_LOSS) {
            ArrayResize(takeSLtickets, AUTO_PARTIAL_COUNT);
            for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) takeSLtickets[i] = WRONG_VALUE;
        }
    }
    bool removeAutoTakeSLTP(bool rTP = true, bool rSL = true) {
        if (!AUTO_TAKE_PARTIAL_PROFIT && !AUTO_TAKE_PARTIAL_LOSS) return true;
        if (AUTO_TAKE_PARTIAL_PROFIT && takeTPfilled && rTP) {
            for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                if (takeTPtickets[i] != WRONG_VALUE && oMan.deleteOrder(takeTPtickets[i]) == ACTION_ERROR) {
                    Print("Could'nt delete takeTPorder");
                    return false;
                }
                takeTPtickets[i] = WRONG_VALUE;
            }
            takeTPfilled = 0;
        }
        if (AUTO_TAKE_PARTIAL_LOSS && takeSLfilled && rSL) {
            for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                if (takeSLtickets[i] != WRONG_VALUE && oMan.deleteOrder(takeSLtickets[i]) == ACTION_ERROR) {
                    Print("Could'nt delete takeSLorder");
                    return false;
                }
                takeSLtickets[i] = WRONG_VALUE;
            }
            takeSLfilled = 0;
        }
        return true;
    }
    bool autoTakeSLTP(bool isNewDeal = false) {
        if (!pMan.positionIsOpen() || (!AUTO_TAKE_PARTIAL_PROFIT && !AUTO_TAKE_PARTIAL_LOSS)) return true;
        double sl = pMan.scaleStopLoss(); double tp = pMan.scaleTakeProfit();
        if (sl == 0 && tp == 0) return true;
        if (AUTO_PARTIAL_COUNT == 0) return false;
        double stopVol = verifyVolume(pMan.Volume()/(AUTO_PARTIAL_COUNT + 1));
        if (AUTO_TAKE_PARTIAL_PROFIT && tp > 0) {
            if (pMan.PositionType() == POSITION_TYPE_BUY) {
                double cAsk = cMan.currentAsk();
                double pIncrease = (tp - cAsk) / (AUTO_PARTIAL_COUNT + 1);
                double currentStop = cAsk + pIncrease;
                if (!takeTPfilled) {
                    for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                        if (oMan.sellLimit(currentStop, stopVol, 0, 0, true) == ACTION_ERROR) {
                            Print("Could'nt create auto stops");
                            return false;
                        }
                        takeTPtickets[i] = oMan.ResultOrder();
                        currentStop += pIncrease;
                    }
                    takeTPfilled = tp;
                    curTakeTPType = POSITION_TYPE_BUY;
                } else {
                    if (curTakeTPType == POSITION_TYPE_BUY) {
                        if (takeTPfilled != tp) {
                            if (isNewDeal) {
                                if (!removeAutoTakeSLTP(true, false)) return false;
                                takeTPfilled = 0;
                                for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                                    if (oMan.sellLimit(currentStop, stopVol, 0, 0, true) == ACTION_ERROR) {
                                        Print("Could'nt create auto stops");
                                        return false;
                                    }
                                    takeTPtickets[i] = oMan.ResultOrder();
                                    currentStop += pIncrease;
                                }
                            } else {
                                for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                                    Order* order = oMan.getOwnOrder(takeTPtickets[i]);
                                    if (order != NULL && order.PriceOpen() != currentStop && order.modifyOrder(currentStop, 0, 0, true) == ACTION_ERROR) {
                                        Print("Could'nt modify takeTPorder");
                                        delete order;
                                        return false; 
                                    }
                                    currentStop += pIncrease;
                                    delete order;
                                }
                            }
                            takeTPfilled = tp;
                        }
                    } else {
                        if (!removeAutoTakeSLTP(true, false)) return false;
                        takeTPfilled = 0;
                        curTakeTPType = POSITION_TYPE_BUY;
                        return autoTakeSLTP();
                    }
                }
            } else {
                double cBid = cMan.currentBid();
                double pIncrease = (cBid - tp) / (AUTO_PARTIAL_COUNT + 1);
                double currentStop = cBid - pIncrease;
                if (!takeTPfilled) {
                    for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                        if (oMan.buyLimit(currentStop, stopVol, 0, 0, true) == ACTION_ERROR) {
                            Print("Could'nt create auto stops");
                            return false;
                        }
                        takeTPtickets[i] = oMan.ResultOrder();
                        currentStop -= pIncrease;
                    }
                    takeTPfilled = tp;
                    curTakeTPType = POSITION_TYPE_SELL;
                } else {
                    if (curTakeTPType == POSITION_TYPE_SELL) {
                        if (takeTPfilled != tp) {
                            if (isNewDeal) {
                                if (!removeAutoTakeSLTP(true, false)) return false;
                                takeTPfilled = 0;
                                for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                                    if (oMan.buyLimit(currentStop, stopVol, 0, 0, true) == ACTION_ERROR) {
                                        Print("Could'nt create auto stops");
                                        return false;
                                    }
                                    takeTPtickets[i] = oMan.ResultOrder();
                                    currentStop -= pIncrease;
                                }
                            } else {
                                for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                                    Order* order = oMan.getOwnOrder(takeTPtickets[i]);
                                    if (order != NULL && order.PriceOpen() != currentStop && order.modifyOrder(currentStop, 0, 0, true) == ACTION_ERROR) {
                                        Print("Could'nt modify takeTPorder");
                                        delete order;
                                        return false;
                                    }
                                    currentStop -= pIncrease;
                                    delete order;
                                }
                            }
                            takeTPfilled = tp;
                        }
                    } else {
                        if (!removeAutoTakeSLTP(true, false)) return false;
                        takeTPfilled = 0;
                        curTakeTPType = POSITION_TYPE_SELL;
                        return autoTakeSLTP();
                    }
                }
            }
        } else {
            if (!removeAutoTakeSLTP(true, false)) {
                Print("Could'nt remove autoTP");
                return false;
            }
        }
        if (AUTO_TAKE_PARTIAL_LOSS && sl > 0) {
            if (pMan.PositionType() == POSITION_TYPE_BUY) {
                double cBid = cMan.currentBid();
                double pIncrease = (cBid - sl) / (AUTO_PARTIAL_COUNT + 1);
                double currentStop = cBid - pIncrease;
                if (!takeSLfilled) {
                    for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                        if (oMan.sellStop(currentStop, stopVol, 0, 0, true) == ACTION_ERROR) {
                            Print("Could'nt create auto stops");
                            return false;
                        }
                        takeSLtickets[i] = oMan.ResultOrder();
                        currentStop -= pIncrease;
                    }
                    takeSLfilled = sl;
                    curTakeSLType = POSITION_TYPE_BUY;
                } else {
                    if (curTakeSLType == POSITION_TYPE_BUY) {
                        if (takeSLfilled != sl) {
                            if (isNewDeal) {
                                if (!removeAutoTakeSLTP(false, true)) return false;
                                takeSLfilled = 0;
                                for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                                    if (oMan.sellStop(currentStop, stopVol, 0, 0, true) == ACTION_ERROR) {
                                        Print("Could'nt create auto stops");
                                        return false;
                                    }
                                    takeSLtickets[i] = oMan.ResultOrder();
                                    currentStop -= pIncrease;
                                }
                            } else {
                                for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                                    Order* order = oMan.getOwnOrder(takeSLtickets[i]);
                                    if (order != NULL && order.PriceOpen() != currentStop && order.modifyOrder(currentStop, 0, 0, true) == ACTION_ERROR) {
                                        Print("Could'nt modify takeSLorder");
                                        delete order;
                                        return false; 
                                    }
                                    currentStop -= pIncrease;
                                    delete order;
                                }
                            }
                            takeSLfilled = sl;
                        }
                    } else {
                        if (!removeAutoTakeSLTP(false, true)) return false;
                        takeSLfilled = 0;
                        curTakeSLType = POSITION_TYPE_SELL;
                        return autoTakeSLTP();
                    }
                }
            } else {
                double cAsk = cMan.currentAsk();
                double pIncrease = (sl - cAsk) / (AUTO_PARTIAL_COUNT + 1);
                double currentStop = cAsk + pIncrease;
                if (!takeSLfilled) {
                    for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                        if (oMan.buyStop(currentStop, stopVol, 0, 0, true) == ACTION_ERROR) {
                            Print("Could'nt create auto stops");
                            return false;
                        }
                        takeSLtickets[i] = oMan.ResultOrder();
                        currentStop += pIncrease;
                    }
                    takeSLfilled = sl;
                    curTakeSLType = POSITION_TYPE_SELL;
                } else {
                    if (curTakeSLType == POSITION_TYPE_SELL) {
                        if (takeSLfilled != sl) {
                            if (isNewDeal) {
                                if (!removeAutoTakeSLTP(false, true)) return false;
                                takeSLfilled = 0;
                                for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                                    if (oMan.sellStop(currentStop, stopVol, 0, 0, true) == ACTION_ERROR) {
                                        Print("Could'nt create auto stops");
                                        return false;
                                    }
                                    takeSLtickets[i] = oMan.ResultOrder();
                                    currentStop -= pIncrease;
                                }
                            } else {
                                for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                                    Order* order = oMan.getOwnOrder(takeSLtickets[i]);
                                    if (order != NULL && order.PriceOpen() != currentStop && order.modifyOrder(currentStop, 0, 0, true) == ACTION_ERROR) {
                                        Print("Could'nt modify takeSLorder");
                                        delete order;
                                        return false; 
                                    }
                                    currentStop += pIncrease;
                                    delete order;
                                }
                            }
                            takeSLfilled = sl;
                        }
                    } else {
                        if (!removeAutoTakeSLTP(false, true)) return false;
                        takeSLfilled = 0;
                        curTakeSLType = POSITION_TYPE_BUY;
                        return autoTakeSLTP();
                    }
                }
            }
        } else {
            if (!removeAutoTakeSLTP(false, true)) {
                Print("Could'nt remove auto SL");
                return false;
            }
        }
        return true;
    }
};

class MarketStructureManager :public CandleManager {
    public:
    void MarketStructureManager::getHVLVoftrendingMarket(double &highs[], double& lows[], int totBars = 200,
            int maxFalse = 6, bool inOrder=true, string mode = "HL") {
        if (maxFalse > totBars) return;
        PriceRange* highRange;
        PriceRange* lowRange;
        if (mode == "HL") {
            highRange = lastNhighPrices(totBars, 1);
            lowRange = lastNlowPrices(totBars, 1);
        } else if (mode == "OC") {
            highRange = lastNopenPrices(totBars, 1);
            lowRange = lastNclosePrices(totBars, 1);
        }
        ArrayResize(highs, 0);
        ArrayResize(lows, 0);
        double highTrend = WRONG_VALUE; int highTrendCount = 0;
        double lowTrend = WRONG_VALUE; int lowTrendCount = 0;
        for (int i = totBars-1; i >= 0; i--) {
            if (highTrend == WRONG_VALUE) {
                if (highRange[i] < highRange[i+1]) {
                    highTrend = highRange[i-1];
                }
            } else {
                if (highRange[i] > highTrend) {
                    highTrend = highRange[i];
                    highTrendCount = 0;
                } else if (highRange[i] < highTrend) {
                    highTrendCount++;
                    if (highTrendCount > maxFalse) {
                        adjustPricesWithinLevel(highs, highTrend, 100, inOrder);
                        highTrendCount = 0;
                        highTrend = WRONG_VALUE;
                    }
                }
            }
            if (lowTrend == WRONG_VALUE) {
                if (lowRange[i] < lowRange[i+1]) {
                    lowTrend = lowRange[i];
                }
            } else {
                if (lowRange[i] < lowTrend) {
                    lowTrend = lowRange[i];
                    lowTrendCount = 0;
                } else if (lowRange[i] > lowTrend) {
                    lowTrendCount++;
                    if (lowTrendCount > maxFalse) {
                        adjustPricesWithinLevel(lows, lowTrend, 100, inOrder);
                        lowTrendCount = 0;
                        lowTrend = WRONG_VALUE;
                    }
                }
            }
        }
        if (highTrend != WRONG_VALUE) adjustPricesWithinLevel(highs, highTrend, 100, inOrder);
        if (lowTrend != WRONG_VALUE) adjustPricesWithinLevel(lows, lowTrend, 100, inOrder);
    }
    void MarketStructureManager::getHVLVoftrendingMarketV2(double &highs[],double &lows[],uint totBars=200,
            uint pInt=50, bool inOrder = true, string mode="HL") {
        if (pInt > totBars) return;
        PriceRange* highRange;
        PriceRange* lowRange;
        ArrayResize(highs, 0);
        ArrayResize(lows, 0);
        if (mode == "HL") {
            highRange = lastNhighPrices(totBars, 1);
            lowRange = lastNlowPrices(totBars, 1);
        } else if (mode == "OC") {
            highRange = lastNopenPrices(totBars, 1);
            lowRange = lastNclosePrices(totBars, 1);
        }
        uint whole = (uint)ceil(totBars/pInt);
        uint rem = (whole*pInt) - totBars;
        uint start = 0;
        for (int i = 1; i <= MathCeil(totBars/pInt); i++) {
            start = totBars-(i*pInt);
            if (start == 0 && rem != 0) pInt = rem;
            adjustPricesWithinLevel(highs, highRange.At(highRange.Maximum(start, pInt)), 100, inOrder);
            adjustPricesWithinLevel(lows, lowRange.At(lowRange.Minimum(start, pInt)), 100, inOrder);
        }
    }
    bool isTrendingMarket(double& hHigh[], double& lLow[], int& up) {
        int hScore = 0;
        int lScore = 0;
        for (int i = 1; i < ArraySize(hHigh); i++) {
            if (hHigh[i-1] < hHigh[i]) hScore++;
            else if (hHigh[i-1] > hHigh[i]) hScore--;
        }
        for (int i = 1; i < ArraySize(lLow); i++) {
            if (lLow[i-1] < lLow[i]) lScore++;
            if (lLow[i-1] > lLow[i]) lScore++;
        }
        double hL, lS;
        if (ArraySize(hHigh) == 1) hL = 0;
        else hL = (hScore/(ArraySize(hHigh)-1))*100;
        if (ArraySize(lLow) == 1) lS = 0;
        else lS = (lScore/(ArraySize(lLow)-1))*100;
        bool ret = false;
        if (hL >= 50 && lS >= 50) {
            up = 1;
            ret = true;
        }
        else if (hL < -50 && lS < -50) {
            up = -1;
            ret = true;
        }
        else up = 0;
        return ret;
    }
};


class MovingAverageManager : public CiMA {
    public:
    MovingAverageManager::MovingAverageManager(int pPeriod=12, ENUM_MA_METHOD pMethod=MODE_EMA,
            ENUM_APPLIED_PRICE pAppPrice=PRICE_CLOSE, int pShift=0, ENUM_TIMEFRAMES pTimeFrame=PERIOD_CURRENT) {
        if (!Create(_Symbol, pTimeFrame, pPeriod, pShift, pMethod, pAppPrice))
            Print("Could not create Moving Average Indicator");
        Refresh();
    }
    PriceRange* MovingAverageManager::lastNaverage(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 0, pRange);
        return new PriceRange(pRange);
    }
    double MovingAverageManager::currentAverage(void) {
        return lastNaverage(1).At(0);
    }
    double MovingAverageManager::lastAverage(void) {
        return lastNaverage(2).At(1);
    }
    PriceRange* MovingAverageManager::lastNvalue(int n) {
        return lastNaverage(n);
    }
    double MovingAverageManager::currentValue(void) {
        return currentAverage();
    }
    double MovingAverageManager::lastValue(void) {
        return lastAverage();
    }
};

class PSARmanager : public CiSAR {
    public:
    PSARmanager::PSARmanager(double pStep, double pMax, ENUM_TIMEFRAMES pTimeFrame=PERIOD_CURRENT) {
        if (!Create(_Symbol, pTimeFrame, pStep, pMax))
            Print("Could not create PSAR Indicator");
        Refresh();
    }
    PriceRange* PSARmanager::lastNsar(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 0, pRange);
        return new PriceRange(pRange);
    }
    double PSARmanager::currentSAR(void) {
        return lastNsar(1).At(0);
    }
    double PSARmanager::lastSAR(void) {
        return lastNsar(2).At(1);
    }
    double PSARmanager::currentValue(void) {
        return currentSAR();
    }
    double PSARmanager::lastValue(void) {
        return lastSAR();
    }
    PriceRange* PSARmanager::lastNvalue(int n) {
        return lastNsar(n);
    }
};

// --------------------------------------------

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
                Print("could'nt delete pending order");
                return false;
            }
            pTickets[i] = WRONG_VALUE;
        }
        return true;
    }
};

class SignalIn {
    private:
        CandleManager* cMan;
        OrderManager* oMan;
        PositionManager* pMan;
    public:
    SignalIn(CandleManager* cM, OrderManager* oM, PositionManager* pM) {
        cMan = cM;
        oMan = oM;
        pMan = pM;
    }
    
    bool SignalIn::createStopOrdersPointsFromLastCandleWick(uint pPOINTS, ulong &pTickets[], bool withAutoStops=true) {
        Candle* lastCandle = cMan.lastCandle();
        double stopPrice = getHighPriceFROMpoint(pPOINTS, lastCandle.high);
        if (withAutoStops) {
            if(oMan.buyStop(stopPrice, -1, 0, 0) == ACTION_ERROR) {
                delete lastCandle;
                return false;
            }
            pTickets[0] = oMan.ResultOrder();
            stopPrice = getLowPriceFROMpoint(pPOINTS, lastCandle.low);
            if(oMan.sellStop(stopPrice, -1, 0, 0) == ACTION_ERROR) {
                delete lastCandle;
                return false;
            }
            pTickets[1] = oMan.ResultOrder();
            ArrayResize(pTickets, 2);
        } else {
            if(oMan.buyStop(stopPrice, -1, 0, 0, true, false) == ACTION_ERROR) {
                delete lastCandle;
                return false;
            }
            pTickets[0] = oMan.ResultOrder();
            stopPrice = getLowPriceFROMpoint(pPOINTS, lastCandle.low);
            if(oMan.sellStop(stopPrice, -1, 0, 0, true, false) == ACTION_ERROR) {
                delete lastCandle;
                return false;
            }
            pTickets[1] = oMan.ResultOrder();
            ArrayResize(pTickets, 2);
        }
        delete lastCandle;
        return true;
    }
    bool SignalIn::createMarketOrdersFromTrendCrossover(double pPrice, double sPrice = 0,
            uint pLowDistance = 0, uint pHighDistance = 0, bool withAutoStops=false) {
        bool canBuy = true;
        bool canSell = true;
        if (sPrice <= 0) {
            double cBid = cMan.currentBid();
            double cAsk = cMan.currentAsk();
            if (pLowDistance || pHighDistance) {
                uint pointBid = pricesTOpoint(cBid, pPrice);
                uint pointAsk = pricesTOpoint(cAsk, pPrice);
                if (pLowDistance) {
                    if (pointBid < pLowDistance) canBuy = false;
                    if (pointAsk < pLowDistance) canSell = false;
                }
                if (pHighDistance) {
                    if (pointBid > pHighDistance) canBuy = false;
                    if (pointAsk > pHighDistance) canSell = false;
                }
            }
            canBuy = (cBid > pPrice && canBuy);
            canSell = (cAsk < pPrice && canSell);
        } else {
            if (pLowDistance || pHighDistance) {
                uint point = pricesTOpoint(sPrice, pPrice);
                if (pLowDistance) {
                    if (point < pLowDistance) {
                        canBuy = false; canSell = false;
                    }
                }
                if (pHighDistance) {
                    if (point > pHighDistance) {
                        canBuy = false; canSell = false;
                    }
                }
            }
            canBuy =  (sPrice > pPrice) && canBuy;
            canSell = (sPrice < pPrice) && canSell;
        }
        if (canBuy) {
            if (pMan.positionIsOpen()) {
                if (pMan.PositionType() == POSITION_TYPE_SELL) {
                    if (pMan.closePosition() == ACTION_ERROR) return false;
                } else return true;
            }
            if (pMan.buyNow(-1, 0, 0, !withAutoStops) == ACTION_ERROR) return false;
        } else if (canSell) {
            if (pMan.positionIsOpen()) {
                if (pMan.PositionType() == POSITION_TYPE_BUY) {
                    if (pMan.closePosition() == ACTION_ERROR) return false;
                } else return true;
            }
            if (pMan.sellNow(-1, 0, 0, !withAutoStops) == ACTION_ERROR) return false;
        }
        return true;
    }
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

/*//A New Bar Event handler that can be used.
int numOfNewBars = 0;
CandleManager PCcMan = CandleManager(PERIOD_CURRENT);
void OnTick(void) {
   if (PCcMan.isNewBar(numOfNewBars)) OnNewBar(numOfNewBars);
}
*/

/*// any expert that includes this should have this code

OrderManager* oMan = new OrderManager();
PositionManager* pMan = new PositionManager(oMan);
CandleManager* cMan = new CandleManager;
AccountManager* aMan = new AccountManager;
SymbolManager* sMan = new SymbolManager;

SignalIn* signalIn = new SignalIn(cMan, oMan, pMan);
SignalOut* signalOut = new SignalOut(cMan, oMan, pMan);
RiskProfitManager* rMan = new RiskProfitManager(cMan, oMan, pMan);
MoneyManager* mMan = new MoneyManager(aMan, sMan);
Utility* utility = new Utility(cMan, oMan, pMan);

void OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request,
        const MqlTradeResult& result) {
    if (trans.type == TRADE_TRANSACTION_DEAL_ADD){
        if (MONEY_MANAGEMENT_MODE == MONEY_MANAGEMENT_MARTINGALE) mMan.changeMartingale(aMan.balanceChanged());
    }
    if (pMan.positionIsOpen()) {
        if (AUTO_SCALEOUT_POSITION) {
            if (!pMan.OTTclearComplementaryTriggeredSLTP()) Print("Could'nt clear a complimentary triggered SL");
            if (!pMan.OTTconvertSLTPtoScalable()) Print("Could'nt convert to scalable");
        }
        if (AUTO_TAKE_PARTIAL_PROFIT || AUTO_TAKE_PARTIAL_LOSS) {
            if (!rMan.autoTakeSLTP(pMan.OTTisNewDeal(trans))) Print("Could'nt add or modify or remove Auto-take partials");
        }
        if (EB_RATIO) {
            if (EB_RATIO > 1) {
                if (aMan.EBratio() >= EB_RATIO) {
                    if (pMan.closePosition() == ACTION_ERROR) Print("Cannot close all position");
                }
            } else if (EB_RATIO < 1) {
                if (aMan.EBratio() <= EB_RATIO) {
                    if (pMan.closePosition() == ACTION_ERROR) Print("Cannot close all position");
                }
            }
        }
    }
}


void OnDeinit(const int reason) {
    delete pMan;
    delete oMan;
    delete cMan;
    delete aMan;
    delete sMan;
    delete signalIn;
    delete signalOut;
    delete rMan;
    delete mMan;
}
*/