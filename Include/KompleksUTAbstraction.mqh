//+------------------------------------------------------------------+
//|                                        KompleksUTAbstraction.mqh |
//|                                                       KompleksEA |
//|                                        kompleksanda.blogspot.com |
//+------------------------------------------------------------------+
#include <Arrays\ArrayDouble.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayInt.mqh>
#include <Arrays\ArrayObj.mqh>

#resource "\\Files\\Sounds\\b_notification.wav";

#define  MAX_RETRIES 3 //Maximum retries
#define  RETRY_DELAY 2000 //Retry delay

#define ForEach(index, array) for (int index = 0, max_##index=ArraySize((array)); index<max_##index; index++)
#define ForEachReverse(index, array) for (int index = ArraySize((array))-1, max_##index=-1; index>max_##index; index--)
#define ForEachRange(index, array) for (int index = 0, max_##index=(array).Total(); index<max_##index; index++)
#define ForEachReverseRange(index, array) for (int index = (array).Total(), max_##index=-1; index>max_##index; index--)

input bool AUTO_ADJUST_STOP = true; //Adjust incorrect stops?
input bool VERBOSE = true; //Verbose?
input ulong STOPPOINT = 50; // Minimum stop point
input bool DRAW = true; //Draw?
input bool DO_NOT_DRAW_CW = false; //Do not draw chart wave?
input bool TRADE = true; //Make trades?
input bool ANALYSIS = false;
input bool ALERT_ON_SIGNAL = true;

ENUM_ACCOUNT_MARGIN_MODE MARGINMODE = (ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);


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
enum ENUM_RRR_AUTOADJUST_MODE {
    RRR_AUTOADJUST_NONE,
    RRR_AUTOADJUST_BLOCK,
    RRR_AUTOADJUST_FROMTP,
    RRR_AUTOADJUST_FROMSL,
};
sinput string RISK_PROFIT_MANAGEMENT; //RISK & PROFIT MANAGEMENT
input double RR_RATIO = 0.3333; //Risk to profit ratio
input ENUM_RRR_AUTOADJUST_MODE RR_RATIO_AUTOADJUST = RRR_AUTOADJUST_NONE; //Adjust incorrect RRR
bool RRR_FOR_LOSS = false;
bool RRR_FOR_PROFIT = false;
//input bool RRR_FOR_PROFIT = true; //RRR for profit?
//input bool RRR_FOR_LOSS = true; //RRR for loss?
input uint RR_RATIO_SCALE = 100; // Risk to profit scale factor
input bool AUTO_TAKE_PARTIAL_PROFIT = false; //Take partial profits?
input bool AUTO_TAKE_PARTIAL_LOSS = false; //Take partial loses?
input uint AUTO_PARTIAL_COUNT = 1; //Number of partial takes
input double MAX_PROFIT = 0; //Maximum profit
input double MAX_LOSS = 0; //Maximum loss
input double MAX_LOSS_REVERSE = 2; //Amount of volume to reverse for loss

//Scale out SL or Scale in TP
sinput string REVENGE_MANAGEMENT; //REVENGE MANAGEMENT
input bool AUTO_SCALEOUT_POSITION = false; // Scale out SLs?
input bool AUTO_SCALEOUT_INCLUDE_TP = false; //Scale in TPs?
input double AUTO_SCALEOUT_MULTIPLIER = 2; // Stop scale multiplier

//Daily or weekly trading period
sinput string SESSION_MANAGEMENT; //TRADING SESSION MANAGEMENT
input bool USE_DAILY_TRADING_PERIOD = false; //Use daily trading period?
input int DAILY_START_HOUR = 8; //Starting hour
input int DAILY_START_MINUTE = 0; //Starting minute
input int DAILY_END_HOUR = 16; //End hour 
input int DAILY_END_MINUTE = 0; //End minute
input bool USE_WEEKLY_TRADING_PERIOD = false; //Use weekly trading period?
input ENUM_DAY_OF_WEEK WEEKLY_START_DAY = MONDAY; //Starting day
input ENUM_DAY_OF_WEEK WEEKLY_END_DAY = FRIDAY; //End day

enum EnSearchMode { //Used in chartwave
    Extremum=0, // searching for the first extremum
    Peak=1,     // searching for the next ZigZag peak
    Bottom=-1   // searching for the next ZigZag bottom
};
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
   CANDLE_TYPE_DASH,
};
enum ENUM_CANDLE_CAT {
    CANDLE_CAT_BEAR,
    CANDLE_CAT_BULL,
    CANDLE_CAT_DOJI, //bull or bear
    CANDLE_CAT_DASH,
    CANDLE_CAT_HAMMER, //bull
    CANDLE_CAT_INVHAMMER, //bear
    CANDLE_CAT_MARIBOZU,
    CANDLE_CAT_SPINNINGTOP,
};
enum ENUM_CANDLE_LENGHT {
    CANDLE_LENGTH_SHORT,
    CANDLE_LENGTH_LONG,
    CANDLE_LENGTH_NORMAL,
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
    CANDLE_PAT_DOJI, //neutral
    CANDLE_PAT_HAMMER, //bull
    CANDLE_PAT_INVHAMMER, //bear
    CANDLE_PAT_BEARISHIMP,
    CANDLE_PAT_BEARISHCOR,
    CANDLE_PAT_BULLISHIMP,
    CANDLE_PAT_BULLISHCOR,
};
enum ENUM_SIGNAL {
    SIGNAL_UNKNOWN,
    SIGNAL_BUY,
    SIGNAL_SELL,
    SIGNAL_PENDINGSELL,
    SIGNAL_PENDINGBUY,
    SIGNAL_ERROR,
};
enum ENUM_TREND_TYPE {
    TREND_TYPE_UP,
    TREND_TYPE_DOWN,
    TREND_TYPE_NOTREND,
    TREND_TYPE_UNKNOWN
};
enum ENUM_CHARTPATTERN_TYPE {
    CHARTPATTERN_TYPE_U0,
    CHARTPATTERN_TYPE_D0,
    CHARTPATTERN_TYPE_NT,
    CHARTPATTERN_TYPE_TU,
    CHARTPATTERN_TYPE_TD,
    CHARTPATTERN_TYPE_TDTU,
    CHARTPATTERN_TYPE_0D0U,
    CHARTPATTERN_TYPE_TDNT,
    CHARTPATTERN_TYPE_TDTD,
    CHARTPATTERN_TYPE_0D0D,
    CHARTPATTERN_TYPE_0D1D,
    CHARTPATTERN_TYPE_1D0D,
    CHARTPATTERN_TYPE_NTTU,
    CHARTPATTERN_TYPE_NTNT,
    CHARTPATTERN_TYPE_NTTD,
    CHARTPATTERN_TYPE_TUTU,
    CHARTPATTERN_TYPE_0U0U,
    CHARTPATTERN_TYPE_0U1U,
    CHARTPATTERN_TYPE_1U0U,
    CHARTPATTERN_TYPE_TUNT,
    CHARTPATTERN_TYPE_TUTD,
    CHARTPATTERN_TYPE_0U0D,
    CHARTPATTERN_TYPE_TDTUTU,
    CHARTPATTERN_TYPE_TDTUNT,
    CHARTPATTERN_TYPE_TDTUTD,
    CHARTPATTERN_TYPE_TDNTTU,
    CHARTPATTERN_TYPE_TDNTNT,
    CHARTPATTERN_TYPE_TDNTTD,
    CHARTPATTERN_TYPE_TDTDTU,
    CHARTPATTERN_TYPE_TDTDNT,
    CHARTPATTERN_TYPE_TDTDTD,
    CHARTPATTERN_TYPE_NTTUTU,
    CHARTPATTERN_TYPE_NTTUNT,
    CHARTPATTERN_TYPE_NTTUTD,
    CHARTPATTERN_TYPE_NTNTTU,
    CHARTPATTERN_TYPE_NTNTNT,
    CHARTPATTERN_TYPE_NTNTTD,
    CHARTPATTERN_TYPE_NTTDTU,
    CHARTPATTERN_TYPE_NTTDNT,
    CHARTPATTERN_TYPE_NTTDTD,
    CHARTPATTERN_TYPE_TUTUTU,
    CHARTPATTERN_TYPE_TUTUNT,
    CHARTPATTERN_TYPE_TUTUTD,
    CHARTPATTERN_TYPE_TUNTTU,
    CHARTPATTERN_TYPE_TUNTNT,
    CHARTPATTERN_TYPE_TUNTTD,
    CHARTPATTERN_TYPE_TUTDTU,
    CHARTPATTERN_TYPE_TUTDNT,
    CHARTPATTERN_TYPE_TUTDTD,
    CHARTPATTERN_TYPE_DOUBLETOP,
    CHARTPATTERN_TYPE_DOUBLEBOTTOM,
    CHARTPATTERN_TYPE_RISINGWEDGE,
    CHARTPATTERN_TYPE_FALLINGWEDGE,
    CHARTPATTERN_TYPE_RISINGWEDGEOPEN,
    CHARTPATTERN_TYPE_FALLINGWEDGEOPEN,
    CHARTPATTERN_TYPE_SYMMETRICALTRIANGLE,
    CHARTPATTERN_TYPE_FLAG,
    CHARTPATTERN_TYPE_FALLINGFLAG,
    CHARTPATTERN_TYPE_FALLINGTREND,
    CHARTPATTERN_TYPE_FALLINGTRENDOPEN,
    CHARTPATTERN_TYPE_RISINGFLAG,
    CHARTPATTERN_TYPE_RISINGTREND,
    CHARTPATTERN_TYPE_RISINGTRENDOPEN,
    CHARTPATTERN_TYPE_HEADSHOULDER,
    CHARTPATTERN_TYPE_INVHEADSHOULDER,
    CHARTPATTERN_TYPE_UNKNOWN,
};

ENUM_TREND_TYPE map4PointCPToTrend(ENUM_CHARTPATTERN_TYPE _cP) {
    switch (_cP) {
        case CHARTPATTERN_TYPE_1U0U:
        case CHARTPATTERN_TYPE_RISINGTREND:
        case CHARTPATTERN_TYPE_0U1U:
        case CHARTPATTERN_TYPE_RISINGTRENDOPEN:
        case CHARTPATTERN_TYPE_0U0U:
        case CHARTPATTERN_TYPE_RISINGFLAG:
            return TREND_TYPE_UP;
        case CHARTPATTERN_TYPE_1D0D:
        case CHARTPATTERN_TYPE_FALLINGTREND:
        case CHARTPATTERN_TYPE_0D1D:
        case CHARTPATTERN_TYPE_FALLINGTRENDOPEN:
        case CHARTPATTERN_TYPE_0D0D:
        case CHARTPATTERN_TYPE_FALLINGFLAG:
            return TREND_TYPE_DOWN;
        case CHARTPATTERN_TYPE_NTNT:
            return TREND_TYPE_NOTREND;
        default:
            return TREND_TYPE_UNKNOWN;
    }
}
ENUM_CHARTPATTERN_TYPE addCP (ENUM_CHARTPATTERN_TYPE _cp1, ENUM_CHARTPATTERN_TYPE _cp2, int _fM = 1, bool _combined = false, bool _forSlope = false) {
    if (_cp1 == CHARTPATTERN_TYPE_TU) {
        if (_cp2 == CHARTPATTERN_TYPE_TU) return CHARTPATTERN_TYPE_TUTU;
        else if (_cp2 == CHARTPATTERN_TYPE_NT) return (_combined || !_forSlope || _fM == -1) ? CHARTPATTERN_TYPE_TUNT : CHARTPATTERN_TYPE_NTTU;
        else if (_cp2 == CHARTPATTERN_TYPE_TD) return (_combined || !_forSlope || _fM == -1) ? CHARTPATTERN_TYPE_TUTD : CHARTPATTERN_TYPE_TDTU;
        else if (_cp2 == CHARTPATTERN_TYPE_TUTU) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_TUTUTU : CHARTPATTERN_TYPE_TUTU;
        else if (_cp2 == CHARTPATTERN_TYPE_TUNT) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_TUTUNT : (_fM == 1) ? CHARTPATTERN_TYPE_TUNT : CHARTPATTERN_TYPE_TUTU;
        else if (_cp2 == CHARTPATTERN_TYPE_TUTD) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_TUTUTD : (_fM == 1) ? CHARTPATTERN_TYPE_TUTD : CHARTPATTERN_TYPE_TUTU;
        else if (_cp2 == CHARTPATTERN_TYPE_NTTU) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_TUNTTU : (_fM == 1) ? CHARTPATTERN_TYPE_TUTU : CHARTPATTERN_TYPE_TUNT;
        else if (_cp2 == CHARTPATTERN_TYPE_NTNT) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_TUNTNT : CHARTPATTERN_TYPE_TUNT;
        else if (_cp2 == CHARTPATTERN_TYPE_NTTD) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_TUNTTD : (_fM == 1) ? CHARTPATTERN_TYPE_TUTD : CHARTPATTERN_TYPE_TUNT;
        else if (_cp2 == CHARTPATTERN_TYPE_TDTU) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_TUTDTU : (_fM == 1) ? CHARTPATTERN_TYPE_TUTU : CHARTPATTERN_TYPE_TUTD;
        else if (_cp2 == CHARTPATTERN_TYPE_TDNT) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_TUTDNT : (_fM == 1) ? CHARTPATTERN_TYPE_TUNT : CHARTPATTERN_TYPE_TUTD;
        else if (_cp2 == CHARTPATTERN_TYPE_TDTD) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_TUTDTD : CHARTPATTERN_TYPE_TUTD;
    } else if (_cp1 == CHARTPATTERN_TYPE_NT) {
        if (_cp2 == CHARTPATTERN_TYPE_TU) return (_combined || !_forSlope || _fM == -1) ? CHARTPATTERN_TYPE_NTTU : CHARTPATTERN_TYPE_TUNT;
        else if (_cp2 == CHARTPATTERN_TYPE_NT) return CHARTPATTERN_TYPE_NTNT;
        else if (_cp2 == CHARTPATTERN_TYPE_TD) return (_combined || !_forSlope || _fM == -1) ? CHARTPATTERN_TYPE_NTTD : CHARTPATTERN_TYPE_TDNT;
        else if (_cp2 == CHARTPATTERN_TYPE_TUTU) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_NTTUTU : CHARTPATTERN_TYPE_NTTU;
        else if (_cp2 == CHARTPATTERN_TYPE_TUNT) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_NTTUNT : (_fM == 1) ? CHARTPATTERN_TYPE_NTNT : CHARTPATTERN_TYPE_NTTU;
        else if (_cp2 == CHARTPATTERN_TYPE_TUTD) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_NTTUTD : (_fM == 1) ? CHARTPATTERN_TYPE_NTTD : CHARTPATTERN_TYPE_NTTU;
        else if (_cp2 == CHARTPATTERN_TYPE_NTTU) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_NTNTTU : (_fM == 1) ? CHARTPATTERN_TYPE_NTTU : CHARTPATTERN_TYPE_NTNT;
        else if (_cp2 == CHARTPATTERN_TYPE_NTNT) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_NTNTNT : CHARTPATTERN_TYPE_NTNT;
        else if (_cp2 == CHARTPATTERN_TYPE_NTTD) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_NTNTTD : (_fM == 1) ? CHARTPATTERN_TYPE_NTTD : CHARTPATTERN_TYPE_NTNT;
        else if (_cp2 == CHARTPATTERN_TYPE_TDTU) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_NTTDTU : (_fM == 1) ? CHARTPATTERN_TYPE_NTTU : CHARTPATTERN_TYPE_NTTD;
        else if (_cp2 == CHARTPATTERN_TYPE_TDNT) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_NTTDNT : (_fM == 1) ? CHARTPATTERN_TYPE_NTNT : CHARTPATTERN_TYPE_NTTD;
        else if (_cp2 == CHARTPATTERN_TYPE_TDTD) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_NTTDTD : CHARTPATTERN_TYPE_NTTD;
    } else if (_cp1 == CHARTPATTERN_TYPE_TD) {
        if (_cp2 == CHARTPATTERN_TYPE_TU) return (_combined || !_forSlope || _fM == -1) ? CHARTPATTERN_TYPE_TDTU : CHARTPATTERN_TYPE_TUTD;
        else if (_cp2 == CHARTPATTERN_TYPE_NT) return (_combined || !_forSlope || _fM == -1) ? CHARTPATTERN_TYPE_TDNT : CHARTPATTERN_TYPE_NTTD;
        else if (_cp2 == CHARTPATTERN_TYPE_TD) return CHARTPATTERN_TYPE_TDTD;
        else if (_cp2 == CHARTPATTERN_TYPE_TUTU) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_TDTUTU : CHARTPATTERN_TYPE_TDTU;
        else if (_cp2 == CHARTPATTERN_TYPE_TUNT) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_TDTUNT : (_fM == 1) ? CHARTPATTERN_TYPE_TDNT : CHARTPATTERN_TYPE_TDTU;
        else if (_cp2 == CHARTPATTERN_TYPE_TUTD) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_TDTUTD : (_fM == 1) ? CHARTPATTERN_TYPE_TDTD : CHARTPATTERN_TYPE_TDTU;
        else if (_cp2 == CHARTPATTERN_TYPE_NTTU) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_TDNTTU : (_fM == 1) ? CHARTPATTERN_TYPE_TDTU : CHARTPATTERN_TYPE_TDNT;
        else if (_cp2 == CHARTPATTERN_TYPE_NTNT) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_TDNTNT : CHARTPATTERN_TYPE_TDNT;
        else if (_cp2 == CHARTPATTERN_TYPE_NTTD) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_TDNTTD : (_fM == 1) ? CHARTPATTERN_TYPE_TDTD : CHARTPATTERN_TYPE_TDNT;
        else if (_cp2 == CHARTPATTERN_TYPE_TDTU) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_TDTDTU : (_fM == 1) ? CHARTPATTERN_TYPE_TDTU : CHARTPATTERN_TYPE_TDTD;
        else if (_cp2 == CHARTPATTERN_TYPE_TDNT) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_TDTDNT : (_fM == 1) ? CHARTPATTERN_TYPE_TDNT : CHARTPATTERN_TYPE_TDTD;
        else if (_cp2 == CHARTPATTERN_TYPE_TDTD) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_TDTDTD : CHARTPATTERN_TYPE_TDTD;
    } else {
        if (_cp2 == CHARTPATTERN_TYPE_TU || _cp2 == CHARTPATTERN_TYPE_NT || _cp2 == CHARTPATTERN_TYPE_TD) return addCP(_cp2, _cp1, _fM, _combined, _forSlope);
        //else if (_cp2 == CHARTPATTERN_TYPE_TUTU) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_NTTUTU : CHARTPATTERN_TYPE_NTTU;
        //else if (_cp2 == CHARTPATTERN_TYPE_TUNT) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_NTTUNT : CHARTPATTERN_TYPE_NTNT;
        //else if (_cp2 == CHARTPATTERN_TYPE_TUTD) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_NTTUTD : CHARTPATTERN_TYPE_NTTD;
        //else if (_cp2 == CHARTPATTERN_TYPE_NTTU) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_NTNTTU : CHARTPATTERN_TYPE_NTTU;
        //else if (_cp2 == CHARTPATTERN_TYPE_NTNT) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_NTNTNT : CHARTPATTERN_TYPE_NTNT;
        //else if (_cp2 == CHARTPATTERN_TYPE_NTTD) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_NTNTTD : CHARTPATTERN_TYPE_NTTD;
        //else if (_cp2 == CHARTPATTERN_TYPE_TDTU) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_NTTDTU : CHARTPATTERN_TYPE_NTTU;
        //else if (_cp2 == CHARTPATTERN_TYPE_TDNT) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_NTTDNT : CHARTPATTERN_TYPE_NTNT;
        //else if (_cp2 == CHARTPATTERN_TYPE_TDTD) return (_combined || !_forSlope) ? CHARTPATTERN_TYPE_NTTDTD : CHARTPATTERN_TYPE_NTTD;
    }
    return CHARTPATTERN_TYPE_UNKNOWN;
}
struct STRUCT_CHARTPATTERN_CONF {
    int firstmove;
    int confirmations;
    ENUM_CHARTPATTERN_TYPE chartpattern;
    bool detected;
};
struct STRUCT_CHARTPATTERN_PRED {
    double price;
    double tp;
    double sl;
    ENUM_POSITION_TYPE direction;
    ENUM_CHARTPATTERN_TYPE predictedCP;
};
ENUM_SIGNAL candlePatternToSignal(ENUM_CANDLE_PATTERN pType) {
    switch(pType) {
       case CANDLE_PAT_BEARISHENG:
       case CANDLE_PAT_EVENINGSTAR:
       case CANDLE_PAT_BEARISHHARAMI:
       case CANDLE_PAT_TWEEZZERTOP:
       case CANDLE_PAT_INVHAMMER:
         return SIGNAL_SELL;
       case CANDLE_PAT_BULLISHENG:
       case CANDLE_PAT_MORNINGSTAR:
       case CANDLE_PAT_BULLISHHARAMI:
       case CANDLE_PAT_TWEEZZERBOT:
       case CANDLE_PAT_HAMMER:
         return SIGNAL_BUY;
       case CANDLE_PAT_DOJI:
         return SIGNAL_UNKNOWN;
    }
    return SIGNAL_UNKNOWN;
}
ENUM_SIGNAL positionTypeToSignal(ENUM_POSITION_TYPE pType) {
    switch (pType) {
        case POSITION_TYPE_BUY:
            return SIGNAL_BUY;
        case POSITION_TYPE_SELL:
            return SIGNAL_SELL;
    }
    return SIGNAL_UNKNOWN;
}
ENUM_SIGNAL candleCatToSignal(ENUM_CANDLE_CAT pType, ENUM_TREND_TYPE _tType = TREND_TYPE_NOTREND) {
    switch(pType) {
       case CANDLE_CAT_INVHAMMER: {
         if (_tType == TREND_TYPE_DOWN) return SIGNAL_BUY;
         return SIGNAL_SELL;
       }
       case CANDLE_CAT_HAMMER: {
         if (_tType == TREND_TYPE_UP) return SIGNAL_SELL;
         return SIGNAL_BUY;
       }
       case CANDLE_CAT_DOJI:
       case CANDLE_CAT_DASH:
         return SIGNAL_UNKNOWN;
    }
    return SIGNAL_UNKNOWN;
}
bool signalToBool(ENUM_SIGNAL pSig) {
    if (pSig == SIGNAL_ERROR) return false;
    return true;
}
class Dot : public CObject {
    public:
    double price;
    datetime time;
    Dot (void) {
        price = 0;
        time = 0;
    }
    Dot(double p, datetime t) {
       price = NormalizeDouble(p, _Digits);
       time = t;
    }
    bool Dot::operator==(Dot &other) {return price == other.price;}
    bool Dot::operator!=(Dot &other) {return !operator==(other);}
    bool Dot::operator>(Dot &other) {return price > other.price;}
    bool Dot::operator<(Dot &other) {return price < other.price;}
    bool Dot::operator>=(Dot &other) {return operator>(other) || operator==(other);}
    bool Dot::operator<=(Dot &other) {return operator<(other) || operator==(other);}
    bool Dot::eq(Dot &other) {return price == other.price && time == other.time;}
    bool Dot::neq(Dot &other) {return !eq(other);}
    bool Dot::gt(Dot &other) {return price > other.price && time > other.time;}
    bool Dot::lt(Dot &other) {return price < other.price && time < other.time;}
    bool Dot::gte(Dot &other) {return gt(other) || eq(other);}
    bool Dot::lte(Dot &other) {return lt(other) || eq(other);}
    bool Dot::eqDate(Dot &other) {return time == other.time;}
    bool Dot::neqDate(Dot &other) {return !eqDate(other);}
    bool Dot::gtDate(Dot &other) {return time > other.time;}
    bool Dot::ltDate(Dot &other) {return time < other.time;}
    bool Dot::gteDate(Dot &other) {return gtDate(other) || eqDate(other);}
    bool Dot::lteDate(Dot &other) {return ltDate(other) || eqDate(other);}
    bool Dot::isOkay(void) {
        if (price == 0  || time == 0) return false;
        return true;
    }
    void Dot::operator=(Dot &other) {
       price = other.price;
       time = other.time;
    }
};
void dotToXY (Dot &dot, int& x, int&y, long chart_id=0, int sub_window=0) {ChartTimePriceToXY(chart_id, sub_window, dot.time, dot.price, x, y);}
void dotToXY (double price, datetime date, int& x, int&y, long chart_id=0, int sub_window=0) {ChartTimePriceToXY(chart_id, sub_window, date, price, x, y);}
Dot* XYtoDot (int x, int y, long chart_id = 0, int sub_window = 0) {
    datetime date = 0;
    double price = 0;
    ChartXYToTimePrice(chart_id, x, y, sub_window, date, price);
    return new Dot(price, date);
}
void XYtoDot (int x, int y, double& price, datetime& date, long chart_id = 0, int sub_window = 0) {ChartXYToTimePrice(chart_id, x, y, sub_window, date, price);}
double percentageDifference(double val1, double val2) {return (MathAbs(val1 - val2)/(double)MathMax(val1, val2))*100;}
double pointTOpriceDifference(ulong point) {
    double diff = (double)point * (double)_Point;
    return NormalizeDouble(diff, _Digits);
}
double pointTOprice(long point, double pPrice, bool invert = false) {
    double pDiff = pointTOpriceDifference(MathAbs(point));
    if (point < 0) {
        if (invert) return pPrice + pDiff;
        else return pPrice - pDiff;
    } else if (point > 0) {
        if (invert) return pPrice - pDiff;
        else return pPrice + pDiff;
    }
    return pPrice;
}
//TODO: change uint to ulong
uint pricesTOpoint(double pPriceHigh, double pPriceLow) {
    return (uint)(NormalizeDouble(MathAbs(pPriceHigh - pPriceLow) / _Point, 0));
}
uint pricesTOpoint(Dot& dot1, Dot& dot2) {
    return (uint)(NormalizeDouble(MathAbs(dot1.price - dot2.price) / _Point, 0));
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
double getPriceFromPercent(Dot& _d1, Dot& _d2, uint _percent) {
    int _pad = (int)((_percent/(double)100) * (int)pricesTOpoint(_d1, _d2));
    if (_d2 > _d1) return getHighPriceFROMpoint(_pad, _d1.price);
    else return getLowPriceFROMpoint(_pad, _d1.price);
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

template <typename T>
void addToArr(T& arr[], T elem, int sIndex = -1, bool keepConsecutive = true) {
    int arrSize = ArraySize(arr);
    if (sIndex >= arrSize) sIndex = -1;
    if (arrSize > 0) {
        if (keepConsecutive && arr[arrSize-1] == elem) return;
    }
    ArrayResize(arr, arrSize+1);
    if (sIndex == -1) {
        arr[ArraySize(arr)-1] = elem;
    } else {
        for (int i = ArraySize(arr)-1; i > sIndex; i--) arr[i] = arr[i-1];
        arr[sIndex] = elem;
    }
}
template <typename T>
void deletePointerArr(T* &arr[]) {
    for (int i = 0; i < ArraySize(arr); i++) delete arr[i];
    ArrayResize(arr, 0);
}
template <typename T>
void deletePointerArr(T* &arr[][]) {
    for (int i = 0; i < ArraySize(arr); i++) {
        for (int j = 0; j < ArraySize(arr[0]); j++) {
            delete arr[i][j];
        }
    }
    ArrayResize(arr, 0);
}
template <typename T>
void getElemWithOccurence(T &arr[], uint minNum, T &arr2[], bool inOrder = true) {
    T last = NULL;
    uint count = 0;
    for (int i = 0; i < ArraySize(arr); i++) {
        if (last == NULL) {
            last = arr[i];
            count = 1;
            continue;
        }
        if (last == arr[i]) count++;
        else {
            if (count >= minNum) adjustPricesWithinLevel(arr2, last, 100, inOrder); 
            last = arr[i];
            count = 1;
        }
    }
    if (count >= minNum) adjustPricesWithinLevel(arr2, last, 100, inOrder);
}
double getNearestPrice(double pPrice, double &pPrices[]) {
    double retPrice = pPrices[0];
    for (int i = 1; i < ArraySize(pPrices); i++) {
        if (MathAbs(pPrice - pPrices[i]) < MathAbs(pPrice - retPrice)) retPrice = pPrices[i];
    }
    return retPrice;
}
double getFarthestPrice(double pPrice, double &pPrices[]) {
    double retPrice = pPrices[0];
    for (int i = 1; i < ArraySize(pPrices); i++) {
        if (MathAbs(pPrice - pPrices[i]) > MathAbs(pPrice - retPrice)) retPrice = pPrices[i];
    }
    return retPrice;
}
double getNearestPrice(double pPrice, double pPrice1, double pPrice2) {
    if (MathAbs(pPrice - pPrice1) < MathAbs(pPrice - pPrice2)) return pPrice1;
    else return pPrice2;
}
double getFarthestPrice(double pPrice, double pPrice1, double pPrice2) {
    if (MathAbs(pPrice - pPrice1) > MathAbs(pPrice - pPrice2)) return pPrice1;
    else return pPrice2;
}
void adjustPricesWithinLevel(double& arr[], double pPrice, uint pPoint, bool lastOnly=false, int pIndex = -1) {
    int end;
    if (lastOnly) end = ArraySize(arr)-1;
    else end = 0;
    if (end < 0) {
        addToArr(arr, pPrice, pIndex);
        return;
    }
    if (lastOnly || ArraySize(arr) == 0) addToArr(arr, pPrice, pIndex);
    else {
        for (int i = ArraySize(arr)-1; i >= end; i--) {
            if (pricesTOpoint(arr[i], pPrice) <= pPoint) {
                arr[i] = (arr[i] +pPrice)/2;
                return;
            }
        }
        addToArr(arr, pPrice, pIndex);
    }
}
void reducedLines(double& arr[], double& newArr[][2], uint pPoint) {
    ArrayResize(newArr, 0);
    for (int i = 0; i < ArraySize(arr); i++) {
        if (ArraySize(newArr) <= 0) {
            ArrayResize(newArr, 1);
            newArr[0][0] = arr[i];
            newArr[0][1] = 1;
        } else {
            bool added = false;
            for (int j = (ArraySize(newArr)/2)-1; j >= 0; j--) {
                if (pricesTOpoint(newArr[j][0], arr[i]) <= pPoint) {
                    newArr[j][0] = (newArr[j][0] + arr[i])/2;
                    newArr[j][1] += 1;
                    added = true;
                    break;
                }
            }
            if (!added) {
                int ssize = ArraySize(newArr)/2;
                ArrayResize(newArr, ssize+1);
                newArr[ssize][0] = arr[i];
                newArr[ssize][1] = 1; 
            } else {
                int ssize = ArraySize(newArr)/2;
                if (ssize >= 2) {
                    for (int j = ssize-2; j >= 0; j--) {
                        if (pricesTOpoint(newArr[ssize-1][0], newArr[j][0]) <= 100) {
                            newArr[j][0] = (newArr[ssize-1][0] + newArr[j][0])/2;
                            newArr[j][1] += newArr[ssize-1][1];
                            ArrayRemove(newArr, ssize-1, 1);
                            break;
                        }
                    }
                }
            } 
        }
    } 
}
int priceMARelationship2(double pPrice1, double pPrice2) {
    //pPrice1 = fast, pPrice2 = slow
    if (pPrice1 > pPrice2) return 1; // 2 > 1
    if (pPrice1 < pPrice2) return -1;
    return 0;
}
double getSlope(double priceDiff, uint stepDiff) {return priceDiff/(double)stepDiff;}
double getChartSlope(Dot& dot1, Dot& dot2) {
    int x1, y1, x2, y2;
    dotToXY(dot1, x1, y1);
    dotToXY(dot2, x2, y2);
    x1 = x2-x1;
    y1 = y1-y2;
    if (x1 == 0) return 0;
    else return y1/(double)x1;
}
double getChartAngle(Dot& dot1, Dot& dot2) {
    int x1, y1, x2, y2;
    dotToXY(dot1, x1, y1);
    dotToXY(dot2, x2, y2);
    x1 = x2-x1;
    y1 = y1-y2;
    if (x1 == 0) return 90;
    else return radToDegrees(MathArctan(y1/(double)x1));
}
double mapRightAngleToPercent (double degs) {return degs/0.9;}
double radToDegrees(double rad) {return rad*180/M_PI;}
double degreesToRad(double deg) {return deg*M_PI/180;}
int priceMARelationship3(double pPrice1, double pPrice2, double pPrice3) {
    if (pPrice1 > pPrice2 && pPrice3 > pPrice1) return 1; //2 > 1 > 3
    if (pPrice1 < pPrice2 && pPrice3 < pPrice1) return -1;
    if (pPrice1 > pPrice3 && pPrice3 > pPrice2) return 2; //2 > 3 > 1
    if (pPrice1 < pPrice3 && pPrice3 < pPrice2) return -2;
    if (pPrice1 > pPrice2 && pPrice2 > pPrice3) return 3; // 3 > 2 > 1
    if (pPrice1 < pPrice2 && pPrice2 < pPrice3) return -3;
    return 0;
}
int priceMARelationship4(double pPrice1, double pPrice2, double pPrice3, double pPrice4) {
    if (pPrice1 > pPrice2 && pPrice3 > pPrice1  && pPrice4 > pPrice3) return 1; //2 > 1 > 3 > 4
    if (pPrice1 < pPrice2 && pPrice3 < pPrice1  && pPrice4 < pPrice3) return -1;
    if (pPrice1 > pPrice2 && pPrice2 > pPrice3  && pPrice4 > pPrice1) return 2; //3 > 2 > 1 > 4
    if (pPrice1 < pPrice2 && pPrice2 < pPrice3  && pPrice4 < pPrice1) return -2;
    if (pPrice1 > pPrice2 && pPrice2 > pPrice3  && pPrice3 > pPrice4) return 3; // 4 > 3 > 2 > 1
    if (pPrice1 < pPrice2 && pPrice2 < pPrice3  && pPrice3 < pPrice4) return -3;
    return 0;
}
datetime createDateTime(int pHour = 0, int pMinute = 0) {
    MqlDateTime timeStruct;
    TimeToStruct(TimeCurrent(), timeStruct);
    timeStruct.hour = pHour;
    timeStruct.min = pMinute;
    datetime useTime = StructToTime(timeStruct);
    return useTime;
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
ulong getMinStopPoint(void) {
    ulong stopPoint = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
    if (stopPoint == 0) stopPoint = STOPPOINT;
    return stopPoint;
}
double minimumStopLevel(double pPrice, string pDir) {
    ulong stopPoint = getMinStopPoint();
    double stopLevel = pointTOpriceDifference(stopPoint);
    if (pDir == "high") return pPrice + stopLevel;
    if (pDir == "low") return pPrice - stopLevel;
    return WRONG_VALUE;
}

bool isWithinTimeRange(datetime pTime1, datetime pTime2, bool pLocalTime = false) {
    if (pTime1 >= pTime2) return false;
    datetime cTime;
    if (pLocalTime) cTime = TimeLocal();
    else cTime = TimeCurrent();
    if (cTime >= pTime1 && cTime <= pTime2) return true;
    return false;
}
bool isWithinDailyTimeRange(int pStartHour, int pStartMin, int pEndHour, int pEndMin, ENUM_DAY_OF_WEEK pStartDay,
        ENUM_DAY_OF_WEEK pEndDay, bool pLocalTime = false) {
    static datetime sTime;
    static datetime eTime;
    datetime currentTime;
    if (pLocalTime == true) currentTime = TimeLocal();
    else currentTime = TimeCurrent();
    sTime = createDateTime(pStartHour, pStartMin);
    eTime = createDateTime(pEndHour, pEndMin);
    if (eTime <= sTime) {
        sTime -= 86400;
        if (currentTime > eTime) {
            sTime += 86400;
            eTime += 86400;
        }
    }
    if (USE_WEEKLY_TRADING_PERIOD) {
        MqlDateTime today;
        TimeToStruct(sTime, today);
        int dayShift = pStartDay - today.day_of_week;
        if(dayShift != 0) sTime += 86400 * dayShift;
        TimeToStruct(eTime, today);
        dayShift = pEndDay - today.day_of_week;
        if(dayShift != 0) eTime += 86400 * dayShift;
    }
    return isWithinTimeRange(sTime, eTime, pLocalTime);
}
bool trendToBool(ENUM_TREND_TYPE _tType) {
    if (_tType == TREND_TYPE_NOTREND) return false;
    return true;
}
ENUM_ACTION_RETCODE getSLTP(double &pArr[], ENUM_POSITION_TYPE tradeDir, double pPrice, int &pSL, int &pTP,
        bool keepZero=false) {
    double minStopHigh = minimumStopLevel(pPrice, "high");
    double minStopLow = minimumStopLevel(pPrice, "low");
    double curPrice;
    if (pSL > 0 && pTP > 0 && RR_RATIO_AUTOADJUST != RRR_AUTOADJUST_NONE) {
        if (pSL/(double)pTP > RR_RATIO) {
            if (RR_RATIO_AUTOADJUST == RRR_AUTOADJUST_BLOCK) {
                if (VERBOSE) Print("invalid RRR");
                return ACTION_ERROR;
            } else if (RR_RATIO_AUTOADJUST == RRR_AUTOADJUST_FROMSL) {
                pTP = (int)(pSL * (1/RR_RATIO));
                if (pTP == 0) pTP = 1;
                if (VERBOSE) Print("TP RRR Auto Adjusted");
            } else if (RR_RATIO_AUTOADJUST == RRR_AUTOADJUST_FROMTP) {
                pSL = (int)(pTP * RR_RATIO);
                if (pSL == 0) pSL = 1;
                if (VERBOSE) Print("SL RRR Auto Adjusted");
            }
        }
    }
    if (tradeDir == POSITION_TYPE_BUY) {
        if (pSL <= 0) {
            if (keepZero || !RRR_FOR_LOSS) {
                pArr[0] = 0;
            } else {
                pSL = (int)getSLpointFROM_RRR();
                curPrice = getLowPriceFROMpoint(pSL, pPrice);
                if (curPrice > minStopLow) {
                    if (AUTO_ADJUST_STOP) {
                        curPrice = minStopLow;
                        pSL = (int)getMinStopPoint();
                        if (VERBOSE) Print("SL Stop Auto Adjusted");
                    } else {
                        if (VERBOSE) Print("SL below stop level");
                        return ACTION_ERROR;
                    }
                }
                pArr[0] = curPrice;
            }
        } else {
            curPrice = getLowPriceFROMpoint(pSL, pPrice);
            if (curPrice > minStopLow) {
                if (AUTO_ADJUST_STOP) {
                    curPrice = minStopLow;
                    pSL = (int)getMinStopPoint();
                    if (VERBOSE) Print("SL Stop Auto Adjusted");
                } else {
                    if (VERBOSE) Print("SL below stop level");
                    return ACTION_ERROR;
                }
            }
            pArr[0] = curPrice;
        }
        if (pTP <= 0) {
            if (keepZero || !RRR_FOR_PROFIT) {
                pArr[1] = 0;
            } else {
                pTP = (int)getTPpointFROM_RRR();
                curPrice = getHighPriceFROMpoint(pTP, pPrice);
                if (curPrice < minStopHigh) {
                    if (AUTO_ADJUST_STOP) {
                        curPrice = minStopHigh;
                        pTP = (int)getMinStopPoint();
                        if (VERBOSE) Print("TP Stop Auto Adjusted");
                    } else {
                        if (VERBOSE) Print("TP below stop level");
                        return ACTION_ERROR;
                    }
                }
                pArr[1] = curPrice;
            }
        } else {
            curPrice = getHighPriceFROMpoint(pTP, pPrice);
            if (curPrice < minStopHigh) {
                if (AUTO_ADJUST_STOP) {
                    curPrice = minStopHigh;
                    pTP = (int)getMinStopPoint();
                    if (VERBOSE) Print("TP Stop Auto Adjusted");
                } else {
                    if (VERBOSE) Print("TP below stop level");
                    return ACTION_ERROR;
                }
            }
            pArr[1] = curPrice;
        }
    } else if (tradeDir == POSITION_TYPE_SELL) {
        if (pSL <= 0) {
            if (keepZero || !RRR_FOR_LOSS) {
                pArr[0] = 0;
            } else {
                pSL = (int)getSLpointFROM_RRR();
                curPrice = getHighPriceFROMpoint(pSL, pPrice);
                if (curPrice < minStopHigh) {
                    if (AUTO_ADJUST_STOP) {
                        curPrice = minStopHigh;
                        pSL = (int)getMinStopPoint();
                        if (VERBOSE) Print("SL Stop Auto Adjusted");
                    } else {
                        if (VERBOSE) Print("SL below stop level");
                        return ACTION_ERROR;
                    }
                }
                pArr[0] = curPrice;
            }
        } else {
            curPrice = getHighPriceFROMpoint(pSL, pPrice);
            if (curPrice < minStopHigh) {
                if (AUTO_ADJUST_STOP) {
                    curPrice = minStopHigh;
                    pSL = (int)getMinStopPoint();
                    if (VERBOSE) Print("SL Stop Auto Adjusted");
                } else {
                    if (VERBOSE) Print("SL below stop level");
                    return ACTION_ERROR;
                }
            }
            pArr[0] = curPrice;
        }
        if (pTP <= 0) {
            if (keepZero || !RRR_FOR_PROFIT) {
                pArr[1] = 0;
            } else {
                pTP = (int)getTPpointFROM_RRR();
                curPrice = getLowPriceFROMpoint(pTP, pPrice);
                if (curPrice > minStopLow) {
                    if (AUTO_ADJUST_STOP) {
                        curPrice = minStopLow;
                        pTP = (int)getMinStopPoint();
                        if (VERBOSE) Print("TP Stop Auto Adjusted");
                    } else {
                        if (VERBOSE) Print("TP below stop level");
                        return ACTION_ERROR;
                    }
                }
                pArr[1] = curPrice;
            }
        } else {
            curPrice = getLowPriceFROMpoint(pTP, pPrice);
            if (curPrice > minStopLow) {
                if (AUTO_ADJUST_STOP) {
                    curPrice = minStopLow;
                    pTP = (int)getMinStopPoint();
                    if (VERBOSE) Print("TP Stop Auto Adjusted");
                } else {
                    if (VERBOSE) Print("TP below stop level");
                    return ACTION_ERROR;
                }
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
        if (VERBOSE) Print("SL/TP < 0");
        return ACTION_ERROR;
    } else if (pSL == 0 && pTP == 0) return ACTION_DONE;
    if (orderDir == POSITION_TYPE_BUY) {
        if (pSL > 0) {
            if (pTP > 0 && (pSL >= pTP || pTP <= priceToUse)) {
                if (VERBOSE) Print("Illegal values of SL/TP");
                return ACTION_ERROR;
            }
            pArr[0] = pricesTOpoint(priceToUse, pSL);
        }
        if (pTP > 0) {
            if ((pSL > 0 && pSL >= pTP) || pTP <= priceToUse) {
                if (VERBOSE) Print("Illegal values of SL/TP");
                return ACTION_ERROR;
            }
            pArr[1] = pricesTOpoint(pTP, priceToUse);
        }
    } else if (orderDir == POSITION_TYPE_SELL) {
        if (pSL > 0) {
            if (pTP > 0 && (pSL <= pTP || pTP >= priceToUse)) {
                if (VERBOSE) Print("Illegal values of SL/TP");
                return ACTION_ERROR;
            }
            pArr[0] = pricesTOpoint(pSL, priceToUse);
        }
        if (pTP > 0) {
            if ((pSL > 0 && pSL <= pTP) || pTP >= priceToUse) {
                if (VERBOSE) Print("Illegal values of SL/TP");
                return ACTION_ERROR;
            }
            pArr[1] = pricesTOpoint(priceToUse, pTP);
        }
    }
    return ACTION_DONE;
}


class INTVAR {
    public:
    int EB_SWAY_DIR; //amount of loss sway in EB ratio
    int STRATEGY;
    INTVAR(void) {
        EB_SWAY_DIR = 0;
        STRATEGY = 1;
    }
};

class PriceRange : public CArrayDouble {
    public:
    PriceRange::PriceRange(void) {
        Step(1);
    }
    PriceRange::PriceRange(double &pPrices[]) {
        Step(1);
        for (int i = 0; i < ArraySize(pPrices); i++) {
            if (!Add(pPrices[i]))
                if (VERBOSE) Print("Could'nt add a price");
        }
    }
    double PriceRange::sum(void) {
        double tSum = 0;
        for (int i = 0; i < Total(); i++) {tSum += At(i);}
        return tSum;
    }
    double PriceRange::average(void) {return sum()/Total();}
    PriceRange* PriceRange::operator-(PriceRange &other) {
        if (Total() != other.Total()) return NULL;
        double pP[];
        ArraySetAsSeries(pP, true);
        ForEachRange(i, this) addToArr(pP, At(i) - other.At(i), -1, false);
        return new PriceRange(pP);
    }
    PriceRange* swingHighs(void) {
        double maxPrice[];
        for (int x = 1; x < Total()-1; x++) {
            if (At(x-1) <= At(x) && At(x) > At(x+1)) {
                addToArr(maxPrice, At(x));
            }
        }
        return new PriceRange(maxPrice);
    }
    PriceRange* swingLows(void) {
        double lowPrice[];
        for (int x = 1; x < Total()-1; x++) {
            if (At(x-1) >= At(x) && At(x) < At(x+1)) {
                addToArr(lowPrice, At(x));
            }
        }
        return new PriceRange(lowPrice);
    }
    bool UpdateAdd(const int index,const double element, const double _default=0.0) {
        if(index<0 || index>=m_data_total) {
            if (index == m_data_total) return Add(element);
            UpdateAdd(index-1, _default, _default);
            return Add(element);
        }
        m_data[index]=element;
        m_sort_mode=-1;
        return(true);
    }
    PriceRange*  slice(int start, int num) {
        if (start >= Total() || start+num > Total()) return NULL;
        PriceRange* ret = new PriceRange();
        for (int i = start; i < start+num; i++) ret.Add(At(i));
        return ret;
    }
    PriceRange* PriceRange::operator-(double _reduce) {
        double pP[];
        ArraySetAsSeries(pP, true);
        ForEachRange(i, this) addToArr(pP, At(i) - _reduce, -1, false);
        return new PriceRange(pP);
    }
    void PriceRange::toArray(double &_arr[]) {
        ArrayResize(_arr, 0);
        ForEachRange(i, this) addToArr(_arr, At(i));
    }
    void arrayPrint(void) {
        double _array[];
        toArray(_array);
        ArrayPrint(_array);
    }
    PriceRange* PriceRange::operator+(PriceRange &other) {
        if (Total() != other.Total()) return NULL;
        double pP[];
        ArraySetAsSeries(pP, true);
        ForEachRange(i, this) addToArr(pP, At(i) + other.At(i), -1, false);
        return new PriceRange(pP);
    }
    PriceRange* PriceRange::operator+(double _reduce) {
        double pP[];
        ArraySetAsSeries(pP, true);
        ForEachRange(i, this) addToArr(pP, At(i) + _reduce, -1, false);
        return new PriceRange(pP);
    }
    PriceRange* PriceRange::operator*(double _scale) {
        double pP[];
        ArraySetAsSeries(pP, true);
        ForEachRange(i, this) addToArr(pP, At(i) * _scale, -1, false);
        return new PriceRange(pP);
    }
    PriceRange* PriceRange::operator/(double _scale) {
        double pP[];
        ArraySetAsSeries(pP, true);
        ForEachRange(i, this) addToArr(pP, At(i) / _scale, -1, false);
        return new PriceRange(pP);
    }
    double operator[](int index) {
        if (index < 0) index += m_data_total;
        if (index < 0 || index >= m_data_total) return(WRONG_VALUE);
        return(m_data[index]);
    }
    
};

class LongRange : public CArrayLong {
    public:
    LongRange::LongRange(void) {
        Step(1);
    }
    LongRange::LongRange(long &pLong[]) {
        Step(1);
        for (int i = 0; i < ArraySize(pLong); i++) {
            if (!Add(pLong[i]))
                if (VERBOSE) Print("Could'nt add a long");
        }
    }
    LongRange*  slice(int start, int num) {
        if (start >= Total() || start+num > Total()) return NULL;
        LongRange* ret = new LongRange();
        for (int i = start; i < start+num; i++) ret.Add(At(i));
        return ret;
    }
    long operator[](int index) {
        if (index < 0) index += m_data_total;
        if (index < 0 || index >= m_data_total) return(WRONG_VALUE);
        return(m_data[index]);
    }
};
class IntRange : public CArrayInt {
    public:
    IntRange::IntRange(void) {
        Step(1);
    }
    IntRange::IntRange(int &pInt[]) {
        Step(1);
        for (int i = 0; i < ArraySize(pInt); i++) {
            if (!Add(pInt[i]))
                if (VERBOSE) Print("Could'nt add a int");
        }
    }
    int operator[](int index) {
        if (index < 0) index += m_data_total;
        if (index < 0 || index >= m_data_total) return(WRONG_VALUE);
        return(m_data[index]);
    }
    void toArray(int &_arr[]) {
        ArrayResize(_arr, 0);
        ForEachRange(i, this) addToArr(_arr, (int)At(i));
    }
    void toArray(double &_arr[]) {
        ArrayResize(_arr, 0);
        ForEachRange(i, this) addToArr(_arr, (double)At(i));
    }
    void arrayPrint(void) {
        int _array[];
        toArray(_array);
        ArrayPrint(_array);
    }
    IntRange*  slice(int start, int num) {
        if (start >= Total() || start+num > Total()) return NULL;
        IntRange* ret = new IntRange();
        for (int i = start; i < start+num; i++) ret.Add(At(i));
        return ret;
    }
};
class DateRange : public CArrayInt {
    public:
    DateRange::DateRange(void) {
        Step(1);
    }
    DateRange::DateRange(datetime &pInt[]) {
        Step(1);
        for (int i = 0; i < ArraySize(pInt); i++) {
            if (!Add((uint)pInt[i]))
                if (VERBOSE) Print("Could'nt add a date");
        }
    }
    void toArray(datetime &_arr[]) {
        ArrayResize(_arr, 0);
        ForEachRange(i, this) addToArr(_arr, (datetime)At(i));
    }
    void toArray(double &_arr[]) {
        ArrayResize(_arr, 0);
        ForEachRange(i, this) addToArr(_arr, (double)At(i));
    }
    void arrayPrint(void) {
        datetime _array[];
        toArray(_array);
        ArrayPrint(_array);
    }
    DateRange*  slice(int start, int num) {
        if (start >= Total() || start+num > Total()) return NULL;
        DateRange* ret = new DateRange();
        for (int i = start; i < start+num; i++) ret.Add(At(i));
        return ret;
    }
    datetime operator[](int index) {
        if (index < 0) index += m_data_total;
        if (index < 0 || index >= m_data_total) return(WRONG_VALUE);
        return(m_data[index]);
    }
};

class DotRange : public CArrayObj {
    protected:
    STRUCT_CHARTPATTERN_CONF CPinit(void) {
        STRUCT_CHARTPATTERN_CONF _CPconf = {0, 0, CHARTPATTERN_TYPE_UNKNOWN, false};
        return _CPconf;
    }
    STRUCT_CHARTPATTERN_PRED CPPREDinit(void) {
        STRUCT_CHARTPATTERN_PRED _CPpred = {0, 0, 0, POSITION_TYPE_BUY, CHARTPATTERN_TYPE_UNKNOWN};
        return _CPpred;
    }
    public:
    uint minWedgePer;
    PriceRange* priceRange;
    DateRange* dateRange;
    IntRange* countRange;
    DotRange (uint _wedge = 5) {
        Step(1);
        minWedgePer = _wedge;
        priceRange = new PriceRange();
        dateRange = new DateRange();
        countRange = new IntRange();
    }
    DotRange (PriceRange* &pR, DateRange* &_dR, uint _wedge = 5) {
        Step(1);
        priceRange = pR;
        dateRange = _dR;
        countRange = new IntRange();
        ForEachRange (i, pR) {
            if (!Add(new Dot(pR.At(i), _dR.At(i)))) {
                if (VERBOSE) Print("couldn't add dot");
            }
            countRange.Add(i);
        }
        minWedgePer = _wedge;
    }
    DotRange (PriceRange* &pR, DateRange* &_dR, IntRange* &cR, uint _wedge = 5) {
        Step(1);
        priceRange = pR;
        dateRange = _dR;
        countRange = cR;
        ForEachRange (i, pR) {
            if (!Add(new Dot(pR.At(i), _dR.At(i)))) {
                if (VERBOSE) Print("couldn't add dot");
            }
        }
        minWedgePer = _wedge;
    }
    Dot* A(int index) {
        if (index < 0) index += m_data_total;
        if (index < 0 || index >= m_data_total) return(NULL);
        return(m_data[index]);
    }
    double priceAt(datetime dt) {
        ForEachRange(i, this) {
            if (A(i).time == dt) return A(i).price;
        }
        return WRONG_VALUE;
    }
    Dot* operator[](const int index) { return(A(index));}
    void DotRange::clearAll(void) {
       priceRange.Clear();
       dateRange.Clear();
       countRange.Clear();
       Clear();
    }
    Dot* DotRange::detachAll(int index) {
       priceRange.Delete(index);
       dateRange.Delete(index);
       countRange.Delete(index);
       return Detach(index);
    }
    bool DotRange::deleteAll(int index) {
       priceRange.Delete(index);
       dateRange.Delete(index);
       countRange.Delete(index);
       return Delete(index);
    }
    bool DotRange::deleteRangeAll(int from, int to) {
       priceRange.DeleteRange(from, to);
       dateRange.DeleteRange(from, to);
       countRange.DeleteRange(from, to);
       return DeleteRange(from, to);
    }
    void DotRange::operator=(DotRange* other) {
       clearAll();
       AddArray(other);
       priceRange.AddArray(other.priceRange);
       dateRange.AddArray(other.dateRange);
       countRange.AddArray(other.countRange);
       minWedgePer = other.minWedgePer;
    }
    bool DotRange::addWithCount(Dot* dot) {
        if (dot != NULL) {
            priceRange.Add(dot.price);
            dateRange.Add((uint)dot.time);
        } else {
            priceRange.Add(0);
            dateRange.Add(0);
        }
        if (countRange.Total() > 0) {
            //countRange.Add(countRange.Total());
            countRange.Add(countRange.At(Total()-1)+1);
        } else countRange.Add(0);
        return Add(dot);
    }
    bool DotRange::addWithCount(Dot* dot, int _count) {
        priceRange.Add(dot.price);
        dateRange.Add((uint)dot.time);
        countRange.Add(_count);
        return Add(dot);
    }
    bool DotRange::insertWithCount(Dot* dot, int pos) {
        if (dot != NULL) {
            priceRange.Insert(dot.price, pos);
            dateRange.Insert((uint)dot.time, pos);
        } else {
            priceRange.Insert(0, pos);
            dateRange.Insert(0, pos);
        }
        if (countRange.Total() > 0) {
            //countRange.Add(countRange.Total());
            countRange.Insert(countRange.At(Total()-1)+1, pos);
        } else countRange.Insert(0, pos);
        return Insert(dot, pos);
    }
    bool DotRange::insertWithCount(Dot* dot, int _count, int pos) {
        priceRange.Insert(dot.price, pos);
        dateRange.Insert((uint)dot.time, pos);
        countRange.Insert(_count, pos);
        return Insert(dot, pos);
    }
    DotRange* swingHighs(void) {
        PriceRange* newPr = new PriceRange();
        DateRange* newDr = new DateRange();
        IntRange* newCr = new IntRange();
        for (int x = 1; x < priceRange.Total()-1; x++) {
            if (priceRange.At(x-1) <= priceRange.At(x) && priceRange.At(x) > priceRange.At(x+1)) {
                newPr.Add(priceRange.At(x));
                newDr.Add(dateRange.At(x));
                newCr.Add(countRange.At(x));
            }
        }
        return new DotRange(newPr, newDr, newCr, minWedgePer);
    }
    DotRange* swingLows(void) {
        PriceRange* newPr = new PriceRange();
        DateRange* newDr = new DateRange();
        IntRange* newCr = new IntRange();
        for (int x = 1; x < priceRange.Total()-1; x++) {
            if (priceRange.At(x-1) >= priceRange.At(x) && priceRange.At(x) < priceRange.At(x+1)) {
                newPr.Add(priceRange.At(x));
                newDr.Add(dateRange.At(x));
                newCr.Add(countRange.At(x));
            }
        }
        return new DotRange(newPr, newDr, newCr, minWedgePer);
    }
    void allSlopes(DotRange* _startD, DotRange* _endD, int _lineMin = 2, int _lineMax = 17, string _dir = "DOWN") {
        _startD.Clear();
        _endD.Clear();
        _startD.minWedgePer = minWedgePer;
        _endD.minWedgePer = minWedgePer;
        for (int x = 0; x < Total() - _lineMin; x++) {
            int start_day = countRange.At(x);
            int final_day = start_day + _lineMin + _lineMax;
            for (int y = x + _lineMin; y < Total(); y++) {
                if ((_dir == "UP" && priceRange.At(x) >= priceRange.At(y)) ||
                    (_dir == "DOWN" && priceRange.At(x) <= priceRange.At(y))) {break;}
                if (countRange.At(y) < final_day) {
                    double change_in_price = priceRange.At(y) - priceRange.At(x);
                    if ((_dir == "UP" && change_in_price > 0) || (_dir == "DOWN" && change_in_price <= 0)) {
                        //tLine* fdsg = new tLine("line"+IntegerToString(x)+IntegerToString(y), (Dot*)At(x), (Dot*)At(y));
                        _startD.addWithCount(At(x), countRange.At(x));
                        _endD.addWithCount(At(y), countRange.At(y));
                    }
                }
            }
        }
    }  
    bool UpdateAdd(int index, Dot* element, Dot* _default=NULL, bool _fill=true) {
        if(index<0 || index>=m_data_total) {
            if (index == m_data_total) return addWithCount(element);
            if (_fill) UpdateAdd(index-1, _default, _default);
            return addWithCount(element);
        }
        if (m_data[index] != NULL) delete m_data[index];
        m_data[index]=element;
        if (element == NULL) {
            priceRange.Update(index, 0);
            dateRange.Update(index, 0);
        } else {
            priceRange.Update(index, element.price);
            dateRange.Update(index, (uint)element.time);
        }
        m_sort_mode=-1;
        return(true);
    }
    void toArray(Dot* &_arr[]) {
        ArrayResize(_arr, 0);
        ForEachRange(i, this) addToArr(_arr, (Dot*)At(i));
    }
    void arrayPrint(void) {
        Dot* _array[];
        toArray(_array);
        ArrayPrint(_array);
    }
    DotRange* slice(int start, int num = 0) {
        int _total = Total();
        if (start < 0) start += _total;
        if (start < 0) return NULL;
        if (num == 0) num = _total - start;
        else if (num < 0) {start += num+1; num = MathAbs(num);}
        //else if (num < 0)
        //    if (start+num+1 > 0) {start += num+1; num = MathAbs(num);}
        //    else {num = (_total+num+1) - start;}
        //}
        if (start >= _total || start+num > _total) return NULL;
        DotRange* ret = new DotRange(minWedgePer);
        for (int i = start; i < start+num; i++) ret.addWithCount(At(i), countRange[i]);
        return ret;
    }
    Dot* minimum(int start = 0, int end = -1) {
        if (end == -1) end = Total();
        if (start >= Total() || start+end > Total()+1) return NULL;
        Dot* min = At(start);
        for (int i = start; i < start+end; i++) {
            if ((Dot*)At(i) < min) {
                min = At(i);
            }
        }
        return min;
    }
    Dot* minimumBox(int start = 0, int end = 0) {
        int _total = Total();
        if (start < 0) start += _total;
        if (start < 0) return NULL;
        if (end == 0) end = _total - start;
        else if (end < 0) {start += end+1; end = MathAbs(end);}
        if (start >= _total || start+end > _total) return NULL;
        Dot* min = At(start);
        Dot* hold;
        for (int i = start; i < start+end; i++) {
            hold = At(i);
            if (hold.price < min.price) {
                min.price = hold.price;
            }
        }
        return min;
    }
    Dot* maximum(int start = 0, int end = -1) {
        if (end == -1) end = Total();
        if (start >= Total() || start+end > Total()+1) return NULL;
        Dot* min = At(start);
        for (int i = start; i < start+end; i++) {
            if ((Dot*)At(i) > min) {
                min = At(i);
            }
        }
        return min;
    }
    Dot* maximumBox(int start = 0, int end = 0) {
        int _total = Total();
        if (start < 0) start += _total;
        if (start < 0) return NULL;
        if (end == 0) end = _total - start;
        else if (end < 0) {start += end+1; end = MathAbs(end);}
        if (start >= _total || start+end > _total) return NULL;
        Dot* hold = At(start);
        Dot* hold2 = At((start+end)-1);
        Dot* min = new Dot(hold.price, hold2.time);
        for (int i = start; i < start+end; i++) {
            hold = At(i);
            if (hold.price > min.price) {
                min.price = hold.price;
            }
        }
        return min;
    }
    DotRange* append(DotRange& other) {
        DotRange* _dr = new DotRange();
        ForEachRange (i, this) _dr.addWithCount(A(i), countRange[i]);
        ForEachRange (i, other) _dr.addWithCount(other[i], other.countRange[i]);
        return _dr;
    }
    void remove(int index) {
        Delete(index);
        countRange.Delete(index);
        priceRange.Delete(index);
        dateRange.Delete(index);
    }
    void removeNULL(void) {
        int indexes[];
        int count = 0;
        int total = 0;
        ArrayResize(indexes, 0);
        ForEachRange (i, this) {
            if (A(i) == NULL) {
                addToArr(indexes, i - count, -1, false);
                count += 1;
            } else total += 1;
        }
        if (ArraySize(indexes) > 0) {
            ForEach (i, indexes) remove(indexes[i]);
            Resize(total);
            priceRange.Resize(total);
            countRange.Resize(total);
            dateRange.Resize(total);
        }
    }
    double DotRange::calcLR(void) { //linear regression, datetime, values
        double X[];
        double Y[];
        countRange.toArray(X);
        priceRange.toArray(Y);
        double LR_points_array[ ];
        double LR_koeff_A, LR_koeff_B;
        double mo_X = 0, mo_Y = 0, var_0 = 0, var_1 = 0;
        int i;
        int size = ArraySize( X );
        double nmb = (double)size;
        
        if(size < 2) return WRONG_VALUE;
        
        for(i = 0; i < size; i++) {
            mo_X += X[i];
            mo_Y += Y[i];
        }
        mo_X /= nmb;
        mo_Y /= nmb;
        
        for(i = 0; i < size; i++) {
            var_0 += (X[i] - mo_X) * (Y[i] - mo_Y);
            var_1 += (X[i] - mo_X) * (X[i] - mo_X);
        }
        
        //  Value of the A coefficient:
        if(var_1 != 0.0) LR_koeff_A = var_0 / var_1;
        else LR_koeff_A = 0.0;
        
        //  Value of the B coefficient:
        LR_koeff_B = mo_Y - LR_koeff_A * mo_X;
        
        //  Fill the array of points that lie on the regression line:
        ArrayResize( LR_points_array, size );
        for( i = 0; i < size; i++ ) LR_points_array[ i ] = LR_koeff_A * X[ i ] + LR_koeff_B;
        return LR_koeff_A;
    }
    void separateWave(DotRange& _top, DotRange& _bot) {
        if (Total() < 2) return;
        _top.clearAll();
        _bot.clearAll();
        for (int i = 1; i < Total(); i ++) {
            if (i == 1) {
                if (A(i) > A(i-1)) {
                    _top.addWithCount(A(i), countRange[i]);
                    _bot.addWithCount(A(i-1), countRange[i-1]);
                } else {
                    _top.addWithCount(A(i-1), countRange[i-1]);
                    _bot.addWithCount(A(i), countRange[i]);
                }
            } else {
                if (A(i) > A(i-1)) _top.addWithCount(A(i), countRange[i]);
                else _bot.addWithCount(A(i), countRange[i]);
            }
        }
    } 
    //FOR WAVE CHART PATTERN DETECTION
    int chartWaveDirection(void) {return determineChartWaveMove(A(-2), A(-1));}
    ENUM_CANDLE_PATTERN dualWavePatDetect(uint _limit = 30) {
        double impWavee = (double)pricesTOpoint(A(-1), A(-2));
        double impWavee2 = (double)pricesTOpoint(A(-2), A(-3));
        if (A(-1) < A(-3)) {
            if ((impWavee2/impWavee)*100 <= _limit) return CANDLE_PAT_BEARISHENG;
            else if ((impWavee/impWavee2)*100 <= _limit) return CANDLE_PAT_BULLISHHARAMI;
        } else {
            if ((impWavee2/impWavee)*100 <= _limit) return CANDLE_PAT_BULLISHENG;
            else if ((impWavee/impWavee2)*100 <= _limit) return CANDLE_PAT_BEARISHHARAMI;
        }
        if (percentageDifference(impWavee, impWavee2) <= _limit) {
            if (A(-1) < A(-2)) return CANDLE_PAT_TWEEZZERTOP;
            else return CANDLE_PAT_TWEEZZERBOT;
        }
        return CANDLE_PAT_UNKNOWN;
    }
    STRUCT_CHARTPATTERN_CONF get3PointWaveCP(bool _useAngle = true, uint _minWedgePer = 0, bool includeMid = false, double midMin = 47.5, double midHigh = 52.5) {
        STRUCT_CHARTPATTERN_CONF CPconf = CPinit();
        if (Total() < 3) return CPconf;
        CPconf.firstmove = determineChartWaveMove(A(-3), A(-2));
        int secondMove = determineChartWaveMove(A(-2), A(-1));
        if (CPconf.firstmove == 0 || CPconf.firstmove == secondMove || secondMove == 0) return CPconf;
        CPconf.detected = true;
        if (_minWedgePer == 0) _minWedgePer = minWedgePer;
        uint fInpulse = pricesTOpoint(A(-2), A(-3));
        if (_useAngle) {
            //double _minAngle = 5;
            double _fAng = getChartAngle(A(-3), A(-1));
            if (MathAbs(_fAng) <= (_minWedgePer/(double)100)*90) CPconf.chartpattern = CHARTPATTERN_TYPE_NT;
            else if (_fAng > 0) {
                if (includeMid) {
                    double midPer = (pricesTOpoint(A(-1), A(-2))/(double)fInpulse)*100;
                    if ((midPer >= midMin && midPer <= midHigh) || (midPer >= 100+midMin && midPer <= 100+midHigh)) CPconf.chartpattern = CHARTPATTERN_TYPE_U0;
                    else CPconf.chartpattern = CHARTPATTERN_TYPE_TU;
                } else CPconf.chartpattern = CHARTPATTERN_TYPE_TU;
            } else {
                if (includeMid) {
                    double midPer = (pricesTOpoint(A(-1), A(-2))/(double)fInpulse)*100;
                    if ((midPer >= midMin && midPer <= midHigh) || (midPer >= 100+midMin && midPer <= 100+midHigh)) CPconf.chartpattern = CHARTPATTERN_TYPE_D0;
                    else CPconf.chartpattern = CHARTPATTERN_TYPE_TD;
                } else CPconf.chartpattern = CHARTPATTERN_TYPE_TD;
            }
        } else {
            if (((pricesTOpoint(A(-3), A(-1))/(double)fInpulse)*100) <= _minWedgePer) CPconf.chartpattern = CHARTPATTERN_TYPE_NT;
            else if (A(-1) > A(-3)) {
                if (includeMid) {
                    double midPer = (pricesTOpoint(A(-1), A(-2))/(double)fInpulse)*100;
                    if ((midPer >= midMin && midPer <= midHigh) || (midPer >= 100+midMin && midPer <= 100+midHigh)) CPconf.chartpattern = CHARTPATTERN_TYPE_U0;
                    else CPconf.chartpattern = CHARTPATTERN_TYPE_TU;
                } else CPconf.chartpattern = CHARTPATTERN_TYPE_TU;
            } else {
                if (includeMid) {
                    double midPer = (pricesTOpoint(A(-1), A(-2))/(double)fInpulse)*100;
                    if ((midPer >= midMin && midPer <= midHigh) || (midPer >= 100+midMin && midPer <= 100+midHigh)) CPconf.chartpattern = CHARTPATTERN_TYPE_D0;
                    else CPconf.chartpattern = CHARTPATTERN_TYPE_TD;
                } else CPconf.chartpattern = CHARTPATTERN_TYPE_TD;
            }
        }
        return CPconf;
    }
    void getWaveCPPredict(STRUCT_CHARTPATTERN_PRED& CPpred[], bool _useAngle = true, bool _forSlope = false, int _lenght = -1) {
        ArrayResize(CPpred, 0);
        ArrayResize(CPpred, 3);
        int _total = Total();
        if (_total < 3) return;
        if (_lenght < 0 || _lenght > _total - 2) _lenght = _total - 2;
        STRUCT_CHARTPATTERN_CONF _fAng = slice(-3).get3PointWaveCP(_useAngle);
        double _swingTop = 0, _swingMid = 0, _swingBot = 0;
        if (_fAng.firstmove == 1) {
            int _startTop = -4, _startMid = -3;
            for (int i = 0; i < _lenght; i++) {
                _startTop = -4-i; _startMid = -3-i;
                if (MathAbs(_startMid) <= _total) {
                    ENUM_CHARTPATTERN_TYPE _cT = slice(_startMid, 1).append(slice(-2)).get3PointWaveCP(_useAngle).chartpattern;
                    if ( _cT == CHARTPATTERN_TYPE_TD) {
                        if (_swingMid == 0) _swingMid = A(_startMid).price;
                        else if (A(_startMid).price < _swingMid) _swingMid = A(_startMid).price;
                    } else if (_cT == CHARTPATTERN_TYPE_TU) {
                        if (_swingBot == 0) _swingBot = A(_startMid).price;
                        else if (A(_startMid).price > _swingBot) _swingBot = A(_startMid).price;
                    }
                }
                if (MathAbs(_startTop) <= _total && slice(_startTop, 1).append(slice(-3, 2)).get3PointWaveCP(_useAngle).chartpattern == CHARTPATTERN_TYPE_TD) {
                    if (_swingTop == 0) _swingTop = A(_startTop).price;
                    else if (A(_startTop).price < _swingTop) _swingTop = A(_startTop).price;
                }
            }
            CPpred[0].direction = POSITION_TYPE_BUY;
            CPpred[0].predictedCP = addCP(_fAng.chartpattern, CHARTPATTERN_TYPE_TD, _fAng.firstmove, false, _forSlope);
            CPpred[0].sl = _swingBot == 0 ? getPriceFromPercent(A(-2), A(-1), 150) : _swingBot;
            CPpred[0].tp = _swingMid == 0 ? getPriceFromPercent(A(-1), A(-2), 50) : _swingMid;
            CPpred[1].direction = POSITION_TYPE_BUY;
            CPpred[1].predictedCP = addCP(_fAng.chartpattern, CHARTPATTERN_TYPE_NT, _fAng.firstmove, false, _forSlope);
            CPpred[1].sl = _swingBot == 0 ? getPriceFromPercent(A(-2), A(-1), 150) : _swingBot;
            CPpred[1].tp = A(-2).price;
            CPpred[2].direction = POSITION_TYPE_BUY;
            CPpred[2].predictedCP = addCP(_fAng.chartpattern, CHARTPATTERN_TYPE_TU, _fAng.firstmove, false, _forSlope);
            CPpred[2].sl = _swingBot == 0 ? getPriceFromPercent(A(-2), A(-1), 150) : _swingBot;
            CPpred[2].tp = _swingTop == 0 ? getPriceFromPercent(A(-1), A(-2), 150) : _swingTop;
        } else {
            int _startBot = -4, _startMid = -3;
            for (int i = 0; i < _lenght; i++) {
                _startBot = -4-i; _startMid = -3-i;
                if (MathAbs(_startMid) <= _total) {
                    ENUM_CHARTPATTERN_TYPE _cT = slice(_startMid, 1).append(slice(-2)).get3PointWaveCP(_useAngle).chartpattern;
                    if (_cT == CHARTPATTERN_TYPE_TU) {
                        if (_swingMid == 0) _swingMid = A(_startMid).price;
                        else if (A(_startMid).price > _swingMid) _swingMid = A(_startMid).price;
                    } else if (_cT == CHARTPATTERN_TYPE_TD) {
                        if (_swingTop == 0) _swingTop = A(_startMid).price;
                        else if (A(_startMid).price < _swingTop) _swingTop = A(_startMid).price;
                    }
                }
                if (MathAbs(_startBot) <= _total && slice(_startBot, 1).append(slice(-3, 2)).get3PointWaveCP(_useAngle).chartpattern == CHARTPATTERN_TYPE_TU) {
                    if (_swingBot == 0) _swingBot = A(_startBot).price;
                    else if (A(_startBot).price > _swingBot) _swingBot = A(_startBot).price;
                }
            }
            CPpred[0].direction = POSITION_TYPE_SELL;
            CPpred[0].predictedCP = addCP(_fAng.chartpattern, CHARTPATTERN_TYPE_TU, _fAng.firstmove, false, _forSlope);
            CPpred[0].sl = _swingTop == 0 ? getPriceFromPercent(A(-2), A(-1), 150) : _swingTop;
            CPpred[0].tp = _swingMid == 0 ? getPriceFromPercent(A(-1), A(-2), 50) : _swingMid;
            CPpred[1].direction = POSITION_TYPE_SELL;
            CPpred[1].predictedCP = addCP(_fAng.chartpattern, CHARTPATTERN_TYPE_NT, _fAng.firstmove, false, _forSlope);
            CPpred[1].sl = _swingTop == 0 ? getPriceFromPercent(A(-2), A(-1), 150) : _swingTop;
            CPpred[1].tp = A(-2).price;
            CPpred[2].direction = POSITION_TYPE_SELL;
            CPpred[2].predictedCP = addCP(_fAng.chartpattern, CHARTPATTERN_TYPE_TD, _fAng.firstmove, false, _forSlope);
            CPpred[2].sl = _swingTop == 0 ? getPriceFromPercent(A(-2), A(-1), 150) : _swingTop;
            CPpred[2].tp = _swingBot == 0 ? getPriceFromPercent(A(-1), A(-2), 150) : _swingBot;
        }
    }
    STRUCT_CHARTPATTERN_CONF get4PointWaveCPCombined(bool _useAngle = true, bool _forSlope = false, bool _other = true) {
        STRUCT_CHARTPATTERN_CONF CPconf = CPinit();
        int _total = Total();
        if (_total < 3) return CPconf;
        STRUCT_CHARTPATTERN_CONF _fAng = slice(-4, 3).get3PointWaveCP(_useAngle);
        CPconf.firstmove = _fAng.firstmove;
        STRUCT_CHARTPATTERN_CONF _sAng = slice(-3, 3).get3PointWaveCP(_useAngle);
        if (_fAng.detected && _sAng.detected) {
            CPconf.detected = true;
            if (_fAng.chartpattern == CHARTPATTERN_TYPE_TD) {
                if (_sAng.chartpattern == CHARTPATTERN_TYPE_TU) {
                    if (_forSlope) {
                        bool assy = false;
                        if (_other) {
                            if (MathAbs(MathAbs(CPconf.firstmove == 1 ? getChartAngle(A(-3), A(-1)) : getChartAngle(A(-4), A(-2))) -
                                MathAbs(CPconf.firstmove == 1 ? getChartAngle(A(-4), A(-2)) : getChartAngle(A(-3), A(-1)))) < 5) assy = true;
                        }
                        if (CPconf.firstmove == 1) {
                            if (assy && _other) CPconf.chartpattern = CHARTPATTERN_TYPE_0U0D;
                            else CPconf.chartpattern = CHARTPATTERN_TYPE_TUTD;
                        } else {
                            if (assy && _other) CPconf.chartpattern = CHARTPATTERN_TYPE_0D0U;
                            else CPconf.chartpattern = CHARTPATTERN_TYPE_TDTU;
                        }
                    } else CPconf.chartpattern = CHARTPATTERN_TYPE_TDTU;
                } else if (_sAng.chartpattern == CHARTPATTERN_TYPE_NT) {
                    if (_forSlope) {
                        if (CPconf.firstmove == 1) CPconf.chartpattern = CHARTPATTERN_TYPE_NTTD;
                        else  CPconf.chartpattern = CHARTPATTERN_TYPE_TDNT;
                    } else CPconf.chartpattern = CHARTPATTERN_TYPE_TDNT;
                } else {
                    if (_forSlope) {
                        if (_other) {
                            double topAng = MathAbs(CPconf.firstmove == 1 ? getChartAngle(A(-3), A(-1)) : getChartAngle(A(-4), A(-2)));
                            double botAng = MathAbs(CPconf.firstmove == 1 ? getChartAngle(A(-4), A(-2)) : getChartAngle(A(-3), A(-1)));
                            if (MathAbs(topAng - botAng) < 5) CPconf.chartpattern = CHARTPATTERN_TYPE_0D0D;
                            else if (topAng > botAng) CPconf.chartpattern = CHARTPATTERN_TYPE_1D0D;
                            else CPconf.chartpattern = CHARTPATTERN_TYPE_0D1D;
                        } else CPconf.chartpattern = CHARTPATTERN_TYPE_TDTD;
                    } else CPconf.chartpattern = CHARTPATTERN_TYPE_TDTD;
                }
            } else if (_fAng.chartpattern == CHARTPATTERN_TYPE_TU) {
                if (_sAng.chartpattern == CHARTPATTERN_TYPE_TU) {
                    if (_forSlope) {
                        if (_other) {
                            double topAng = MathAbs(CPconf.firstmove == 1 ? getChartAngle(A(-3), A(-1)) : getChartAngle(A(-4), A(-2)));
                            double botAng = MathAbs(CPconf.firstmove == 1 ? getChartAngle(A(-4), A(-2)) : getChartAngle(A(-3), A(-1)));
                            if (MathAbs(topAng - botAng) < 5) CPconf.chartpattern = CHARTPATTERN_TYPE_0U0U;
                            else if (topAng > botAng) CPconf.chartpattern = CHARTPATTERN_TYPE_0U1U;
                            else CPconf.chartpattern = CHARTPATTERN_TYPE_1U0U;
                        } else CPconf.chartpattern = CHARTPATTERN_TYPE_TUTU;
                    } else CPconf.chartpattern = CHARTPATTERN_TYPE_TUTU;
                } else if (_sAng.chartpattern == CHARTPATTERN_TYPE_NT) {
                    if (_forSlope) {
                        if (CPconf.firstmove == 1) CPconf.chartpattern = CHARTPATTERN_TYPE_NTTU;
                        else  CPconf.chartpattern = CHARTPATTERN_TYPE_TUNT;
                    } else CPconf.chartpattern = CHARTPATTERN_TYPE_TUNT;
                } else {
                    if (_forSlope) {
                        bool assy = false;
                        if (_other) {
                            if (MathAbs(MathAbs(CPconf.firstmove == 1 ? getChartAngle(A(-3), A(-1)) : getChartAngle(A(-4), A(-2))) -
                                MathAbs(CPconf.firstmove == 1 ? getChartAngle(A(-4), A(-2)) : getChartAngle(A(-3), A(-1)))) < 5) assy = true;
                        }
                        if (CPconf.firstmove == 1) {
                            if (assy && _other) CPconf.chartpattern = CHARTPATTERN_TYPE_0D0U;
                            else CPconf.chartpattern = CHARTPATTERN_TYPE_TDTU;
                        } else {
                            if (assy && _other) CPconf.chartpattern = CHARTPATTERN_TYPE_0U0D;
                            else CPconf.chartpattern = CHARTPATTERN_TYPE_TUTD;
                        }
                    } else CPconf.chartpattern = CHARTPATTERN_TYPE_TUTD;
                }
            } else if (_fAng.chartpattern == CHARTPATTERN_TYPE_NT) {
                if (_sAng.chartpattern == CHARTPATTERN_TYPE_TU) {
                    if (_forSlope) {
                        if (CPconf.firstmove == 1) CPconf.chartpattern = CHARTPATTERN_TYPE_TUNT;
                        else  CPconf.chartpattern = CHARTPATTERN_TYPE_NTTU;
                    } else CPconf.chartpattern = CHARTPATTERN_TYPE_NTTU;
                } else if (_sAng.chartpattern == CHARTPATTERN_TYPE_NT) {
                    CPconf.chartpattern = CHARTPATTERN_TYPE_NTNT;
                } else {
                    if (_forSlope) {
                        if (CPconf.firstmove == 1) CPconf.chartpattern = CHARTPATTERN_TYPE_TDNT;
                        else  CPconf.chartpattern = CHARTPATTERN_TYPE_NTTD;
                    } else CPconf.chartpattern = CHARTPATTERN_TYPE_NTTD;
                }
            }
        }
        return CPconf;
    }
    STRUCT_CHARTPATTERN_CONF getReal4PointWaveChartPattern(bool _useAngle = true) {
        STRUCT_CHARTPATTERN_CONF CPconf = CPinit();
        if (Total() < 3) return CPconf;
        STRUCT_CHARTPATTERN_CONF _conf = get4PointWaveCPCombined(_useAngle, true, true);
        CPconf.firstmove = _conf.firstmove;
        if (_conf.chartpattern == CHARTPATTERN_TYPE_0D0U) {
            CPconf.detected = true;
            CPconf.chartpattern = CHARTPATTERN_TYPE_SYMMETRICALTRIANGLE;
        } else if (_conf.chartpattern == CHARTPATTERN_TYPE_NTTU) {
            CPconf.detected = true;
            CPconf.chartpattern = CHARTPATTERN_TYPE_RISINGWEDGE;
        } else if (_conf.chartpattern == CHARTPATTERN_TYPE_NTTD) {
            CPconf.detected = true;
            CPconf.chartpattern = CHARTPATTERN_TYPE_FALLINGWEDGEOPEN;
        } else if (_conf.chartpattern == CHARTPATTERN_TYPE_TDNT) {
            CPconf.detected = true;
            CPconf.chartpattern = CHARTPATTERN_TYPE_FALLINGWEDGE;
        } else if (_conf.chartpattern == CHARTPATTERN_TYPE_TUNT) {
            CPconf.detected = true;
            CPconf.chartpattern = CHARTPATTERN_TYPE_RISINGWEDGEOPEN;
        } else if (_conf.chartpattern == CHARTPATTERN_TYPE_NTNT) {
            CPconf.detected = true;
            CPconf.chartpattern = CHARTPATTERN_TYPE_FLAG;
        //} else if (_conf.chartpattern == CHARTPATTERN_TYPE_1U0U) {
        //    CPconf.detected = true;
        //    CPconf.chartpattern = CHARTPATTERN_TYPE_RISINGTREND;
        //} else if (_conf.chartpattern == CHARTPATTERN_TYPE_0U1U) {
        //    CPconf.detected = true;
        //    CPconf.chartpattern = CHARTPATTERN_TYPE_RISINGTRENDOPEN;
        //} else if (_conf.chartpattern == CHARTPATTERN_TYPE_0U0U) {
        //    CPconf.detected = true;
        //    CPconf.chartpattern = CHARTPATTERN_TYPE_RISINGFLAG;
        //} else if (_conf.chartpattern == CHARTPATTERN_TYPE_1D0D) {
        //    CPconf.detected = true;
        //    CPconf.chartpattern = CHARTPATTERN_TYPE_FALLINGTREND;
        //} else if (_conf.chartpattern == CHARTPATTERN_TYPE_0D1D) {
        //    CPconf.detected = true;
        //    CPconf.chartpattern = CHARTPATTERN_TYPE_FALLINGTRENDOPEN;
        //} else if (_conf.chartpattern == CHARTPATTERN_TYPE_0D0D) {
        //    CPconf.detected = true;
        //    CPconf.chartpattern = CHARTPATTERN_TYPE_FALLINGFLAG;
        }
        return CPconf;
    }
    STRUCT_CHARTPATTERN_CONF get5PointWaveCP(bool _useAngle = true) {
        STRUCT_CHARTPATTERN_CONF CPconf = CPinit();
        if (Total() < 3) return CPconf;
        STRUCT_CHARTPATTERN_CONF _fAng = slice(-5, 3).get3PointWaveCP(_useAngle);
        STRUCT_CHARTPATTERN_CONF _sAng = slice(-3, 3).get3PointWaveCP(_useAngle);
        if (_fAng.detected && _sAng.detected) {
            CPconf.detected = true;
            CPconf.firstmove = _fAng.firstmove;
            if (_fAng.chartpattern == CHARTPATTERN_TYPE_TD) {
                if (_sAng.chartpattern == CHARTPATTERN_TYPE_TU) CPconf.chartpattern = CHARTPATTERN_TYPE_TDTU;
                else if (_sAng.chartpattern == CHARTPATTERN_TYPE_NT) CPconf.chartpattern = CHARTPATTERN_TYPE_TDNT;
                else CPconf.chartpattern = CHARTPATTERN_TYPE_TDTD;
            } else if (_fAng.chartpattern == CHARTPATTERN_TYPE_TU) {
                if (_sAng.chartpattern == CHARTPATTERN_TYPE_TU) CPconf.chartpattern = CHARTPATTERN_TYPE_TUTU;
                else if (_sAng.chartpattern == CHARTPATTERN_TYPE_NT) CPconf.chartpattern = CHARTPATTERN_TYPE_TUNT;
                else CPconf.chartpattern = CHARTPATTERN_TYPE_TUTD;
            } else {
                if (_sAng.chartpattern == CHARTPATTERN_TYPE_TU) CPconf.chartpattern = CHARTPATTERN_TYPE_NTTU;
                else if (_sAng.chartpattern == CHARTPATTERN_TYPE_NT) CPconf.chartpattern = CHARTPATTERN_TYPE_NTNT;
                else CPconf.chartpattern = CHARTPATTERN_TYPE_NTTD;
            }
        }
        return CPconf;
    }
    STRUCT_CHARTPATTERN_CONF get5PointWaveCPCombined(bool _useAngle = true) {
        STRUCT_CHARTPATTERN_CONF CPconf = CPinit();
        STRUCT_CHARTPATTERN_CONF fChart = slice(-5, 4).get4PointWaveCPCombined(_useAngle);
        STRUCT_CHARTPATTERN_CONF sChart = slice(-3, 3).get3PointWaveCP(_useAngle);
        CPconf.firstmove = fChart.firstmove;
        if (fChart.chartpattern == CHARTPATTERN_TYPE_TDTU) {
            if (sChart.chartpattern == CHARTPATTERN_TYPE_TU) {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TDTUTU;
            } else if (sChart.chartpattern == CHARTPATTERN_TYPE_NT){
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TDTUNT;
            } else {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TDTUTD;
            }
        } else if (fChart.chartpattern == CHARTPATTERN_TYPE_TDNT) {
            if (sChart.chartpattern == CHARTPATTERN_TYPE_TU) {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TDNTTU;
            } else if (sChart.chartpattern == CHARTPATTERN_TYPE_NT){
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TDNTNT;
            } else {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TDNTTD;
            }
        } else if (fChart.chartpattern == CHARTPATTERN_TYPE_TDTD) {
            if (sChart.chartpattern == CHARTPATTERN_TYPE_TU) {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TDTDTU;
            } else if (sChart.chartpattern == CHARTPATTERN_TYPE_NT){
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TDTDNT;
            } else {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TDTDTD;
            }
        } else if (fChart.chartpattern == CHARTPATTERN_TYPE_NTTU) {
            if (sChart.chartpattern == CHARTPATTERN_TYPE_TU) {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_NTTUTU;
            } else if (sChart.chartpattern == CHARTPATTERN_TYPE_NT){
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_NTTUNT;
            } else {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_NTTUTD;
            }
        } else if (fChart.chartpattern == CHARTPATTERN_TYPE_NTNT) {
            if (sChart.chartpattern == CHARTPATTERN_TYPE_TU) {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_NTNTTU;
            } else if (sChart.chartpattern == CHARTPATTERN_TYPE_NT){
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_NTNTNT;
            } else {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_NTNTTD;
            }
        } else if (fChart.chartpattern == CHARTPATTERN_TYPE_NTTD) {
            if (sChart.chartpattern == CHARTPATTERN_TYPE_TU) {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_NTTDTU;
            } else if (sChart.chartpattern == CHARTPATTERN_TYPE_NT){
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_NTTDNT;
            } else {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_NTTDTD;
            }
        } else if (fChart.chartpattern == CHARTPATTERN_TYPE_TUTU) {
            if (sChart.chartpattern == CHARTPATTERN_TYPE_TU) {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TUTUTU;
            } else if (sChart.chartpattern == CHARTPATTERN_TYPE_NT){
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TUTUNT;
            } else {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TUTUTD;
            }
        } else if (fChart.chartpattern == CHARTPATTERN_TYPE_TUNT) {
            if (sChart.chartpattern == CHARTPATTERN_TYPE_TU) {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TUNTTU;
            } else if (sChart.chartpattern == CHARTPATTERN_TYPE_NT){
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TUNTNT;
            } else {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TUNTTD;
            }
        } else if (fChart.chartpattern == CHARTPATTERN_TYPE_TUTD) {
            if (sChart.chartpattern == CHARTPATTERN_TYPE_TU) {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TUTDTU;
            } else if (sChart.chartpattern == CHARTPATTERN_TYPE_NT){
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TUTDNT;
            } else {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TUTDTD;
            }
        }
        return CPconf;
    }
    STRUCT_CHARTPATTERN_CONF getReal5PointWaveChartPattern(bool _useAngle = true, uint _minWedgePer = 20) {
        STRUCT_CHARTPATTERN_CONF CPconf = CPinit();
        STRUCT_CHARTPATTERN_CONF _conf = get5PointWaveCP(_useAngle);
        CPconf.firstmove = _conf.firstmove;
        if (_conf.detected) {
            if (_minWedgePer == 0) _minWedgePer = minWedgePer;
            if (_conf.chartpattern == CHARTPATTERN_TYPE_TUTD) {// && CPconf.firstmove == 1) {
                if (slice(-4, 3).get3PointWaveCP(_useAngle, _minWedgePer).chartpattern == CHARTPATTERN_TYPE_NT) {
                    CPconf.detected = true;
                    CPconf.chartpattern = CHARTPATTERN_TYPE_DOUBLETOP;
                }
            }
            if (_conf.chartpattern == CHARTPATTERN_TYPE_TDTU) {// && CPconf.firstmove == -1) {
                if (slice(-4, 3).get3PointWaveCP(_useAngle, _minWedgePer).chartpattern == CHARTPATTERN_TYPE_NT) {
                    CPconf.detected = true;
                    CPconf.chartpattern = CHARTPATTERN_TYPE_DOUBLEBOTTOM;
                }
            }
        }
        return CPconf;
    }
    STRUCT_CHARTPATTERN_CONF get7PointWaveCP(bool _useAngle = true) {
        STRUCT_CHARTPATTERN_CONF CPconf = CPinit();
        STRUCT_CHARTPATTERN_CONF fChart = slice(0, 5).get5PointWaveCP(_useAngle);
        STRUCT_CHARTPATTERN_CONF sChart = slice(4, 3).get3PointWaveCP(_useAngle);
        CPconf.firstmove = fChart.firstmove;
        if (fChart.chartpattern == CHARTPATTERN_TYPE_TDTU) {
            if (sChart.chartpattern == CHARTPATTERN_TYPE_TU) {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TDTUTU;
            } else if (sChart.chartpattern == CHARTPATTERN_TYPE_NT){
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TDTUNT;
            } else {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TDTUTD;
            }
        } else if (fChart.chartpattern == CHARTPATTERN_TYPE_TDNT) {
            if (sChart.chartpattern == CHARTPATTERN_TYPE_TU) {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TDNTTU;
            } else if (sChart.chartpattern == CHARTPATTERN_TYPE_NT){
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TDNTNT;
            } else {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TDNTTD;
            }
        } else if (fChart.chartpattern == CHARTPATTERN_TYPE_TDTD) {
            if (sChart.chartpattern == CHARTPATTERN_TYPE_TU) {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TDTDTU;
            } else if (sChart.chartpattern == CHARTPATTERN_TYPE_NT){
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TDTDNT;
            } else {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TDTDTD;
            }
        } else if (fChart.chartpattern == CHARTPATTERN_TYPE_NTTU) {
            if (sChart.chartpattern == CHARTPATTERN_TYPE_TU) {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_NTTUTU;
            } else if (sChart.chartpattern == CHARTPATTERN_TYPE_NT){
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_NTTUNT;
            } else {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_NTTUTD;
            }
        } else if (fChart.chartpattern == CHARTPATTERN_TYPE_NTNT) {
            if (sChart.chartpattern == CHARTPATTERN_TYPE_TU) {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_NTNTTU;
            } else if (sChart.chartpattern == CHARTPATTERN_TYPE_NT){
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_NTNTNT;
            } else {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_NTNTTD;
            }
        } else if (fChart.chartpattern == CHARTPATTERN_TYPE_NTTD) {
            if (sChart.chartpattern == CHARTPATTERN_TYPE_TU) {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_NTTDTU;
            } else if (sChart.chartpattern == CHARTPATTERN_TYPE_NT){
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_NTTDNT;
            } else {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_NTTDTD;
            }
        } else if (fChart.chartpattern == CHARTPATTERN_TYPE_TUTU) {
            if (sChart.chartpattern == CHARTPATTERN_TYPE_TU) {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TUTUTU;
            } else if (sChart.chartpattern == CHARTPATTERN_TYPE_NT){
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TUTUNT;
            } else {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TUTUTD;
            }
        } else if (fChart.chartpattern == CHARTPATTERN_TYPE_TUNT) {
            if (sChart.chartpattern == CHARTPATTERN_TYPE_TU) {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TUNTTU;
            } else if (sChart.chartpattern == CHARTPATTERN_TYPE_NT){
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TUNTNT;
            } else {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TUNTTD;
            }
        } else if (fChart.chartpattern == CHARTPATTERN_TYPE_TUTD) {
            if (sChart.chartpattern == CHARTPATTERN_TYPE_TU) {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TUTDTU;
            } else if (sChart.chartpattern == CHARTPATTERN_TYPE_NT){
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TUTDNT;
            } else {
                CPconf.detected = true;
                CPconf.chartpattern = CHARTPATTERN_TYPE_TUTDTD;
            }
        }
        return CPconf;
    }
    STRUCT_CHARTPATTERN_CONF getReal7PointWaveChartPattern(bool _useAngle = true, uint _minWedgePer = 20) {
        STRUCT_CHARTPATTERN_CONF CPconf = CPinit();
        STRUCT_CHARTPATTERN_CONF _conf1 = slice(-7, 4).get4PointWaveCPCombined(_useAngle, true, false);
        STRUCT_CHARTPATTERN_CONF _conf2 = slice(-4, 4).get4PointWaveCPCombined(_useAngle, true, false);
        CPconf.firstmove = _conf1.firstmove;
        if (_conf1.detected && _conf2.detected) {
            if (_minWedgePer == 0) _minWedgePer = minWedgePer;
            if ((_conf1.chartpattern == CHARTPATTERN_TYPE_TUTU || _conf1.chartpattern == CHARTPATTERN_TYPE_TUNT) &&
                    (_conf2.chartpattern == CHARTPATTERN_TYPE_TDTD || _conf2.chartpattern == CHARTPATTERN_TYPE_TDNT)) {
                DotRange* _mid1 = slice(-6, 2);
                _mid1.addWithCount(A(-2), countRange[-2]);
                STRUCT_CHARTPATTERN_CONF _mid = _mid1.get3PointWaveCP(_useAngle, _minWedgePer);
                if (_mid.detected && _mid.chartpattern == CHARTPATTERN_TYPE_NT) {
                    CPconf.detected = true;
                    CPconf.chartpattern = CHARTPATTERN_TYPE_HEADSHOULDER;
                }
            } else if ((_conf1.chartpattern == CHARTPATTERN_TYPE_TDTD || _conf1.chartpattern == CHARTPATTERN_TYPE_TDNT) &&
                    (_conf2.chartpattern == CHARTPATTERN_TYPE_TUTU || _conf2.chartpattern == CHARTPATTERN_TYPE_TUNT)) {
                DotRange* _mid1 = slice(-6, 2);
                _mid1.addWithCount(A(-2), countRange[-2]);
                STRUCT_CHARTPATTERN_CONF _mid = _mid1.get3PointWaveCP(_useAngle, _minWedgePer);
                if (_mid.detected && _mid.chartpattern == CHARTPATTERN_TYPE_NT) {
                    CPconf.detected = true;
                    CPconf.chartpattern = CHARTPATTERN_TYPE_INVHEADSHOULDER;
                }
            }
        }
        return CPconf;
    }
    STRUCT_CHARTPATTERN_CONF getRealXPointWaveChartPattern(bool _useAngle = true, bool lowestFirst = true) {
        STRUCT_CHARTPATTERN_CONF CPconf = CPinit();
        int _total = Total();
        if (lowestFirst) {
            if (_total >= 4) {
                CPconf = getReal4PointWaveChartPattern(_useAngle);
                if (CPconf.chartpattern != CHARTPATTERN_TYPE_UNKNOWN) return CPconf;
            }
            if (_total >= 5) {
                CPconf = getReal5PointWaveChartPattern(_useAngle);
                if (CPconf.chartpattern != CHARTPATTERN_TYPE_UNKNOWN) return CPconf;
            }
            if (_total >= 7) {
                CPconf = getReal7PointWaveChartPattern(_useAngle);
                if (CPconf.chartpattern != CHARTPATTERN_TYPE_UNKNOWN) return CPconf;
            }
        } else {
            if (_total >= 7) {
                CPconf = getReal7PointWaveChartPattern(_useAngle);
                if (CPconf.chartpattern != CHARTPATTERN_TYPE_UNKNOWN) return CPconf;
            }
            if (_total >= 5) {
                CPconf = getReal5PointWaveChartPattern(_useAngle);
                if (CPconf.chartpattern != CHARTPATTERN_TYPE_UNKNOWN) return CPconf;
            }
            if (_total >= 4) {
                CPconf = getReal4PointWaveChartPattern(_useAngle);
                if (CPconf.chartpattern != CHARTPATTERN_TYPE_UNKNOWN) return CPconf;
            }
        }
        return CPconf;
    }
    //For ChartLine
    double getLineAngle(void) {
        if (Total() < 2) return WRONG_VALUE;
        return getChartAngle(A(-2), A(-1));
    }
    bool lineLinesUp3(int _p3, int _p2, int _p1, double _dev = 5) {
        if (Total() < 3) return false;
        double ang1 = getChartAngle(A(_p2), A(_p1));
        double ang2 = getChartAngle(A(_p3), A(_p2));
        if ((ang1 > 0 && ang2 < 0) || (ang1 < 0 && ang2 > 0)) {
            if (MathAbs(ang1) + MathAbs(ang2) <= _dev*2) return (Total() == 3) ? false : true;
        } else {
            if (MathAbs(MathAbs(ang1) - MathAbs(ang2)) <= _dev) return (Total() == 3) ? false : true;
        }
        return false;
    }
    bool last3LinesUp(double _dev = 5) {return lineLinesUp3(-3, -2, -1);}
};

// Price Managers
class PriceManager {
    protected:
        ENUM_TIMEFRAMES timeFrame;
    public:
    PriceManager::PriceManager(ENUM_TIMEFRAMES pTF=PERIOD_CURRENT) {timeFrame = pTF;}
    double PriceManager::currentAsk() {return SymbolInfoDouble(_Symbol, SYMBOL_ASK);}
    double PriceManager::currentBid() {return SymbolInfoDouble(_Symbol, SYMBOL_BID);}
    double PriceManager::currentPrice() {return (currentAsk()+currentBid())/2;}
    PriceRange* PriceManager::lastNclosePrices(int n, int pShift = 0, bool series = true) {
        double prices[];
        ArraySetAsSeries(prices, series);
        CopyClose(_Symbol, timeFrame, pShift, n, prices);
        return new PriceRange(prices);
    }
    PriceRange* PriceManager::lastNopenPrices(int n, int pShift = 0, bool series = true) {
        double prices[];
        ArraySetAsSeries(prices, series);
        CopyOpen(_Symbol, timeFrame, pShift, n, prices);
        return new PriceRange(prices);
    }
    PriceRange* PriceManager::lastNhighPrices(int n, int pShift = 0, bool series = true) {
        double prices[];
        ArraySetAsSeries(prices, series);
        CopyHigh(_Symbol, timeFrame, pShift, n, prices);
        return new PriceRange(prices);
    }
    PriceRange* PriceManager::lastNlowPrices(int n, int pShift = 0, bool series = true) {
        double prices[];
        ArraySetAsSeries(prices, series);
        CopyLow(_Symbol, timeFrame, pShift, n, prices);
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

PriceRange* lastNclosePrices(ENUM_TIMEFRAMES timeFrame, int n, int pShift = 0, bool series = true) {
    double prices[];
    ArraySetAsSeries(prices, series);
    CopyClose(_Symbol, timeFrame, pShift, n, prices);
    return new PriceRange(prices);
}
PriceRange* lastNopenPrices(ENUM_TIMEFRAMES timeFrame, int n, int pShift = 0, bool series = true) {
    double prices[];
    ArraySetAsSeries(prices, series);
    CopyOpen(_Symbol, timeFrame, pShift, n, prices);
    return new PriceRange(prices);
}
PriceRange* lastNhighPrices(ENUM_TIMEFRAMES timeFrame, int n, int pShift = 0, bool series = true) {
    double prices[];
    ArraySetAsSeries(prices, series);
    CopyHigh(_Symbol, timeFrame, pShift, n, prices);
    return new PriceRange(prices);
}
PriceRange* lastNlowPrices(ENUM_TIMEFRAMES timeFrame, int n, int pShift = 0, bool series = true) {
    double prices[];
    ArraySetAsSeries(prices, series);
    CopyLow(_Symbol, timeFrame, pShift, n, prices);
    return new PriceRange(prices);
}
DotRange* nullSieveObjRange(DotRange* _buff) {
    DotRange* _rbuff = new DotRange;
    ForEachRange (i, _buff) {
        if (_buff[i] != NULL) _rbuff.addWithCount(_buff[i], _buff.countRange[i]);
    }
    return _rbuff;
}
void chartWaveToSR(DotRange& _CW, double relPrice, double& _sup[], double& _res[]) {
    ForEachRange(i, _CW) {
        if (i == 0 || i == _CW.Total() - 1) continue;
        if (_CW[i].price > relPrice) addToArr(_res, _CW[i].price, -1, false);
        else addToArr(_sup, _CW[i].price, -1, false);
    }
}
double calcLR(double& X[], double& Y[]) { //linear regression, datetime, values
    double LR_points_array[ ];
    double LR_koeff_A, LR_koeff_B;
    double mo_X = 0, mo_Y = 0, var_0 = 0, var_1 = 0;
    int i;
    int size = ArraySize( X );
    double nmb = (double)size;
    
    if(size < 2) return WRONG_VALUE;
    
    for(i = 0; i < size; i++) {
        mo_X += X[i];
        mo_Y += Y[i];
    }
    mo_X /= nmb;
    mo_Y /= nmb;
    
    for(i = 0; i < size; i++) {
        var_0 += (X[i] - mo_X) * (Y[i] - mo_Y);
        var_1 += (X[i] - mo_X) * (X[i] - mo_X);
    }
    
    //  Value of the A coefficient:
    if(var_1 != 0.0) LR_koeff_A = var_0 / var_1;
    else LR_koeff_A = 0.0;
    
    //  Value of the B coefficient:
    LR_koeff_B = mo_Y - LR_koeff_A * mo_X;
    
    //  Fill the array of points that lie on the regression line:
    ArrayResize( LR_points_array, size );
    for( i = 0; i < size; i++ ) LR_points_array[ i ] = LR_koeff_A * X[ i ] + LR_koeff_B;
    return LR_koeff_A;
}
ENUM_CANDLE_PATTERN dualWavePatDetect(double wave_3, double wave_2, double wave_1, uint _limit = 30) {
    double impWavee = (double)pricesTOpoint(wave_1, wave_2);
    double impWavee2 = (double)pricesTOpoint(wave_2, wave_3);
    if (wave_1 < wave_3) {
        if ((impWavee2/impWavee)*100 <= _limit) return CANDLE_PAT_BEARISHENG;
        else if ((impWavee/impWavee2)*100 <= _limit) return CANDLE_PAT_BULLISHHARAMI;
    } else {
        if ((impWavee2/impWavee)*100 <= _limit) return CANDLE_PAT_BULLISHENG;
        else if ((impWavee/impWavee2)*100 <= _limit) return CANDLE_PAT_BEARISHHARAMI;
    }
    if (percentageDifference(impWavee, impWavee2) <= _limit) {
        if (wave_1 < wave_2) return CANDLE_PAT_TWEEZZERTOP;
        else return CANDLE_PAT_TWEEZZERBOT;
    }
    return CANDLE_PAT_UNKNOWN;
}
ENUM_CANDLE_PATTERN dualWavePatDetect(Dot& wave_3, Dot& wave_2, Dot& wave_1, uint _limit = 30) {
    double impWavee = (double)pricesTOpoint(wave_1, wave_2);
    double impWavee2 = (double)pricesTOpoint(wave_2, wave_3);
    if (wave_1 < wave_3) {
        if ((impWavee2/impWavee)*100 <= _limit) return CANDLE_PAT_BEARISHENG;
        else if ((impWavee/impWavee2)*100 <= _limit) return CANDLE_PAT_BULLISHHARAMI;
    } else {
        if ((impWavee2/impWavee)*100 <= _limit) return CANDLE_PAT_BULLISHENG;
        else if ((impWavee/impWavee2)*100 <= _limit) return CANDLE_PAT_BEARISHHARAMI;
    }
    if (percentageDifference(impWavee, impWavee2) <= _limit) {
        if (wave_1 < wave_2) return CANDLE_PAT_TWEEZZERTOP;
        else return CANDLE_PAT_TWEEZZERBOT;
    }
    return CANDLE_PAT_UNKNOWN;
}
int determineChartWaveMove(Dot& d1, Dot& d2) {
    if (d1 == d2) return 0;
    else if (d1 > d2) return -1;
    else return 1;
}
int determineChartWaveMove(double d1, double d2) {
    if (d1 == d2) return 0;
    else if (d1 > d2) return -1;
    else return 1;
}
bool numberPairOverlap(double num11, double num12, double num21, double num22) {
    double thisMin = MathMin(num11, num12);
    double thisMax = MathMax(num11, num12);
    double thatMin = MathMin(num21, num22);
    double thatMax = MathMax(num21, num22);
    if (thisMin <= thatMax) {
        if (thisMax >= thatMax) return true;
        else if (thisMax >= thatMin) return true;
    }
    return false;
}
bool numberPairOverlap(Dot& num11, Dot& num12, Dot& num21, Dot& num22) {
    double thisMin = MathMin(num11.price, num12.price);
    double thisMax = MathMax(num11.price, num12.price);
    double thatMin = MathMin(num21.price, num22.price);
    double thatMax = MathMax(num21.price, num22.price);
    if (thisMin <= thatMax) {
        if (thisMax >= thatMax) return true;
        else if (thisMax >= thatMin) return true;
    }
    return false;
}
DotRange* dotRangesToWave(DotRange* pTop, DotRange* pLow, int pickMode = 2, uint pMaxUnturn = 0) {
    int tTotal = pTop.Total();
    int lTotal = pLow.Total();
    DotRange* wave = new DotRange;
    int countTop = 0;
    int countLow = 0;
    int turn = 0;
    int noTurnCount = 0;
    int prevTurn = turn;
    while (true) {
        if (prevTurn == 0) prevTurn = turn;
        else {
            if (prevTurn == turn) noTurnCount++;
            else {
                prevTurn = turn;
                noTurnCount = 0;
            }
        }
        int interTopCount = 0;
        int interLowCount = 0;
        
        if (countLow < lTotal) {
            while (countTop+interTopCount < tTotal && pTop[countTop+interTopCount].time <= pLow[countLow].time) interTopCount++;
        } else interTopCount = tTotal - countTop;
        if (countTop < tTotal) {
            while (countLow+interLowCount < lTotal && pLow[countLow+interLowCount].time <= pTop[countTop].time) interLowCount++;
        } else interLowCount = lTotal - countLow;
        
        if (interTopCount == 0 && interLowCount == 0) break;
        
        if (interTopCount == 0) {
            if (turn == 1) {
                if (pMaxUnturn > 0) {
                    if (pMaxUnturn == noTurnCount) {
                        Dot* last = wave.detachAll(wave.Total()-1);
                        if (interLowCount > 1) {
                            Dot* retLow = waveMulPicker(interLowCount, countLow, countTop, pLow, pTop, wave, pickMode, true);
                            if (retLow != NULL) {
                                wave.addWithCount(retLow);
                                noTurnCount = -1;
                            } else {
                                wave.addWithCount(last);
                                noTurnCount--;
                            }
                        } else {
                            if (wave.Total() > 0) {
                                if (pLow[countLow] < wave[-1]) {
                                    wave.addWithCount(pLow[countLow]);
                                    noTurnCount = -1;
                                } else {
                                    wave.addWithCount(last);
                                    noTurnCount--;
                                }
                            } else {
                                wave.addWithCount(pLow[countLow]);
                                noTurnCount = -1;
                            }
                        }
                    } else noTurnCount--;
                }
                countLow += interLowCount;
                continue;
            }
            if (countTop >= tTotal) {
                pickWave(turn, interLowCount, countLow, wave[-1], pLow, pTop, wave, pickMode, true);
            } else {
                int iinterTopCount = 0;
                if (countLow < lTotal - interLowCount) {
                    while (countTop+iinterTopCount < tTotal && pTop[countTop+iinterTopCount].time <= pLow[countLow+interLowCount].time) iinterTopCount++;
                } else iinterTopCount = tTotal - countTop;
                if (iinterTopCount > 1) {
                    Dot* retLow = waveMulPicker(interLowCount, countLow, countTop, pLow, pTop, wave, pickMode, true);
                    if (retLow == NULL) {
                        countLow += interLowCount;
                        countTop += iinterTopCount;
                        continue;
                    }
                    pickWave(turn, interLowCount, countLow, countTop, pLow, pTop, wave, pickMode, true);
                } else pickWave(turn, interLowCount, countLow, countTop, pLow, pTop, wave, pickMode, true);
            }
        } else {
            if (turn == -1) {
                if (pMaxUnturn > 0) {
                    if (pMaxUnturn == noTurnCount) {
                        Dot* last = wave.detachAll(wave.Total()-1);
                        if (interTopCount > 1) {
                            Dot* retTop = waveMulPicker(interTopCount, countTop, countLow, pTop, pLow, wave, pickMode, false);
                            if (retTop != NULL) {
                                wave.addWithCount(retTop);
                                noTurnCount = -1;
                            } else {
                                wave.addWithCount(last);
                                noTurnCount--;
                            }
                        } else {
                            if (wave.Total() > 0) {
                                if (pTop[countTop] > wave[-1]) {
                                    wave.addWithCount(pTop[countTop]);
                                    noTurnCount = -1;
                                } else {
                                    wave.addWithCount(last);
                                    noTurnCount--;
                                }
                            } else {
                                wave.addWithCount(pTop[countTop]);
                                noTurnCount = -1;
                            }
                        }
                    } else noTurnCount--;
                }
                countTop += interTopCount;
                continue;
            }
            if (countLow >= lTotal) {
                pickWave(turn, interTopCount, countTop, wave[-1], pTop, pLow, wave, pickMode, false);
            } else {
                int iinterLowCount = 0;
                if (countTop < tTotal - interTopCount) {
                    while (countLow+iinterLowCount < lTotal && pLow[countLow+iinterLowCount].time <= pTop[countTop+interTopCount].time) iinterLowCount++;
                } else iinterLowCount = lTotal - countLow;
                if (iinterLowCount > 1) {
                    Dot* retTop = waveMulPicker(interTopCount, countTop, countLow, pTop, pLow, wave, pickMode, false);
                    if (retTop == NULL) {
                        countTop += interTopCount;
                        countLow += iinterLowCount;
                        continue;
                    }
                    pickWave(turn, interTopCount, countTop, countLow, pTop, pLow, wave, pickMode, false);
                } else pickWave(turn, interTopCount, countTop, countLow, pTop, pLow, wave, pickMode, false);
                
            }
        }
    }
    return wave;
}
Dot* waveMulPicker(int iCount, int oCount, int& othCount, DotRange* pRange, DotRange* oRange, DotRange* &wave, int pickMode = 1, bool doLow = true) {
    Dot* nu = NULL;
    if (doLow) {
        if (pickMode == 1) {
            int picker = iCount-1;
            if (wave.Total() > 0) {
                while (pRange[oCount+picker] >= wave[-1] && picker >= 0) {
                    picker--;
                }
            } else {
                while (pRange[oCount+picker] >= oRange[othCount-1] && picker >= 0) {
                    picker--;
                }
            }
            if (picker >= 0) {
                if (wave.Total() > 0) {
                    if (pRange[oCount+picker] < wave[-1]) return pRange[oCount+picker];
                } else {
                    if (pRange[oCount+picker] < oRange[othCount-1]) return pRange[oCount+picker];
                }
            }
        } else if (pickMode == -1) {
            int picker = 0;
            if (wave.Total() > 0) {
                while (pRange[oCount+picker] >= wave[-1] && picker < iCount) {
                    picker++;
                }
            } else {
                while (pRange[oCount+picker] >= oRange[othCount] && picker < iCount) {
                    picker++;
                }
            }
            if (picker < iCount) {
                if (wave.Total() > 0) {
                    if (pRange[oCount+picker] < wave[-1]) return pRange[oCount+picker];
                } else {
                    if (pRange[oCount+picker] < oRange[othCount]) return pRange[oCount+picker];
                }
            }
        } else if (pickMode == 0) {
            if (wave.Total() > 0) {
                if (pRange[oCount+((iCount)/2)] < wave[-1]) return pRange[oCount+((iCount)/2)];
            } else {
                if (pRange[oCount+((iCount)/2)] < oRange[othCount-1]) return pRange[oCount+((iCount)/2)];
            }
            int picker = iCount-1;
            if (wave.Total() > 0) {
                while (pRange[oCount+picker] >= wave[-1] && picker >= 0) {
                    picker--;
                }
            } else {
                while (pRange[oCount+picker] >= oRange[othCount-1] && picker >= 0) {
                    picker--;
                }
            }
            if (picker >= 0) {
                if (wave.Total() > 0) {
                    if (pRange[oCount+picker] < wave[-1]) return pRange[oCount+picker];
                } else {
                    if (pRange[oCount+picker] < oRange[othCount-1]) return pRange[oCount+picker];
                }
            }
        } else if (pickMode == 2 || pickMode == -2) {
            Dot* lowD = pRange.slice(oCount, iCount).minimum();
            if (wave.Total() > 0) {
                if (lowD < wave[-1]) return lowD;
            } else {
                if (lowD < oRange[othCount]) return lowD;
            }
        }
    } else {
        if (pickMode == 1) {
            int picker = iCount-1;
            if (wave.Total() > 0) {
                while (pRange[oCount+picker] <= wave[-1] && picker >= 0) {
                    picker--;
                }
            } else {
                while (pRange[oCount+picker] <= oRange[othCount-1] && picker >= 0) {
                    picker--;
                }
            }
            if (picker >= 0) {
                if (wave.Total() > 0) {
                    if (pRange[oCount+picker] > wave[-1]) return pRange[oCount+picker];
                } else {
                    if (pRange[oCount+picker] > oRange[othCount-1]) return pRange[oCount+picker];
                }
            }
        } else if (pickMode == -1) {
            int picker = 0;
            if (wave.Total() > 0) {
                while (pRange[oCount+picker] <= wave[-1] && picker < iCount) {
                    picker++;
                }
            } else {
                while (pRange[oCount+picker] <= oRange[othCount] && picker < iCount) {
                    picker++;
                }
            }
            if (picker < iCount) {
                if (wave.Total() > 0) {
                    if (pRange[oCount+picker] > wave[-1]) return pRange[oCount+picker];
                } else {
                    if (pRange[oCount+picker] > oRange[othCount]) return pRange[oCount+picker];
                }
            }
        } else if (pickMode == 0) {
            if (wave.Total() > 0) {
                if (pRange[oCount+(iCount/2)] > wave[-1]) return pRange[oCount+(iCount/2)];
            } else {
                if (pRange[oCount+(iCount/2)] > oRange[othCount-1]) return pRange[oCount+(iCount/2)];
            }
            int picker = iCount-1;
            if (wave.Total() > 0) {
                while (pRange[oCount+picker] <= wave[-1] && picker >= 0) {
                    picker--;
                }
            } else {
                while (pRange[oCount+picker] <= oRange[othCount-1] && picker >= 0) {
                    picker--;
                }
            }
            if (picker >= 0) {
                if (wave.Total() > 0) {
                    if (pRange[oCount+picker] > wave[-1]) return pRange[oCount+picker];
                } else {
                    if (pRange[oCount+picker] > oRange[othCount-1]) return pRange[oCount+picker];
                }
            }
        } else if (pickMode == 2 || pickMode == -2) {
            Dot* highD = pRange.slice(oCount, iCount).maximum();
            if (wave.Total() > 0) {
                if (highD > wave[-1]) return highD;
            } else {
                if (highD > oRange[othCount]) return highD;
            }
        }
    }
    return nu;
}
Dot* waveMulPicker(int iCount, int oCount, Dot* oth, DotRange* pRange, DotRange* oRange, DotRange* &wave, int pickMode = 1, bool doLow = true) {
    Dot* nu = NULL;
    if (doLow) {
        if (pickMode == 1) {
            int picker = iCount-1;
            while (pRange[oCount+picker] >= oth && picker >= 0) {
                picker--;
            }
            if (picker >= 0 && pRange[oCount+picker] < oth) return pRange[oCount+picker];
        } else if (pickMode == -1) {
            int picker = 0;
            while (pRange[oCount+picker] >= oth && picker < iCount) {
                picker++;
            }
            if (picker < iCount && pRange[oCount+picker] < oth) return pRange[oCount+picker];
        } else if (pickMode == 0) {
            if (pRange[oCount+((iCount)/2)] < oth) return pRange[oCount+((iCount)/2)];
            else {
                int picker = iCount-1;
                while (pRange[oCount+picker] >= oth && picker >= 0) {
                    picker--;
                }
                if (picker >= 0 && pRange[oCount+picker] < oth) return pRange[oCount+picker];
            }
        } else if (pickMode == 2 || pickMode == -2) {
            Dot* lowD = pRange.slice(oCount, iCount).minimum();
            if (lowD < oth) return lowD;
        }
    } else {
        if (pickMode == 1) {
            int picker = iCount-1;
            while (pRange[oCount+picker] <= oth && picker >= 0) {
                picker--;
            }
            if (picker >= 0 && pRange[oCount+picker] > oth) return pRange[oCount+picker];
        } else if (pickMode == -1) {
            int picker = 0;
            while (pRange[oCount+picker] <= oth && picker < iCount) {
                picker++;
            }
            if (picker < iCount && pRange[oCount+picker] > oth) return pRange[oCount+picker];
        } else if (pickMode == 0) {
            if (pRange[oCount+(iCount/2)] > oth) return pRange[oCount+(iCount/2)];
            else {
                int picker = iCount-1;
                while (pRange[oCount+picker] <= oth && picker >= 0) {
                    picker--;
                }
                if (picker >= 0 && pRange[oCount+picker] > oth) return pRange[oCount+picker];
            }
        } else if (pickMode == 2 || pickMode == -2) {
            Dot* highD = pRange.slice(oCount, iCount).maximum();
            if (highD > oth) return highD;
        }
    }
    return nu;
}
void pickWave(int& turn, int iCount, int& oCount, int& othCount, DotRange* pRange, DotRange* oRange, DotRange* &wave, int pickMode = 1, bool doLow = true) {
    if (othCount < 0) {othCount = 0; oCount++;return;}
    if (iCount == 1) {
        if (doLow) {
            if (wave.Total() > 0) {
                if (pRange[oCount] < wave[-1]) {
                    wave.addWithCount(pRange[oCount]);
                    turn = 1;
                }
            } else {
                if (pRange[oCount] < oRange[othCount]) {
                    wave.addWithCount(pRange[oCount]);
                    turn = 1;
                } else {
                    if (turn == 0) {
                        wave.addWithCount(pRange[oCount]);
                        turn = 1;
                    }
                }
            }
        } else {
            if (wave.Total() > 0) {
                if (pRange[oCount] > wave[-1]) {
                    wave.addWithCount(pRange[oCount]);
                    turn = -1;
                }
            } else {
                if (pRange[oCount] > oRange[othCount]) {
                    wave.addWithCount(pRange[oCount]);
                    turn = -1;
                } else {
                    if (turn == 0) {
                        wave.addWithCount(pRange[oCount]);
                        turn = -1;
                    }
                }
            }
        }
        oCount++;
    } else if (iCount > 1)  {
        //comes first and it's many
        Dot* ret;
        if (doLow) ret = waveMulPicker(iCount, oCount, othCount, pRange, oRange, wave, pickMode, true);
        else ret = waveMulPicker(iCount, oCount, othCount, pRange, oRange, wave, pickMode, false);
        if (ret != NULL) {
            wave.addWithCount(ret);
            turn = doLow ? 1 : -1;
        }
        oCount += iCount;
    }
}
void pickWave(int& turn, int iCount, int& oCount, Dot* oth, DotRange* pRange, DotRange* oRange, DotRange* &wave, int pickMode = 1, bool doLow = true) {
    if (oth == NULL) {oCount++;return;}
    if (iCount == 1) {
        if (doLow) {
            if (wave.Total() > 0) {
                if (pRange[oCount] < wave[-1]) {
                    wave.addWithCount(pRange[oCount]);
                    turn = 1;
                }
            } else {
                if (pRange[oCount] < oth) {
                    wave.addWithCount(pRange[oCount]);
                    turn = 1;
                } else {
                    if (turn == 0) {
                        wave.addWithCount(pRange[oCount]);
                        turn = 1;
                    }
                }
            }
        } else {
            if (wave.Total() > 0) {
                if (pRange[oCount] > wave[-1]) {
                    wave.addWithCount(pRange[oCount]);
                    turn = -1;
                }
            } else {
                if (pRange[oCount] > oth) {
                    wave.addWithCount(pRange[oCount]);
                    turn = -1;
                } else {
                    if (turn == 0) {
                        wave.addWithCount(pRange[oCount]);
                        turn = -1;
                    }
                }
            }
        }
        oCount++;
    } else if (iCount > 1)  {
        //comes first and it's many
        Dot* ret;
        if (doLow) ret = waveMulPicker(iCount, oCount, oth, pRange, oRange, wave, pickMode, true);
        else ret = waveMulPicker(iCount, oCount, oth, pRange, oRange, wave, pickMode, false);
        if (ret != NULL) {
            wave.addWithCount(ret);
            turn = doLow ? 1 : -1;
        }
        oCount += iCount;
    }
}