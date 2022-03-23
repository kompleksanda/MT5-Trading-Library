//+------------------------------------------------------------------+
//|                                        KompleksINAbstraction.mqh |
//|                                                       KompleksEA |
//|                                        kompleksanda.blogspot.com |
//+------------------------------------------------------------------+
#include <MT5TradingLibrary/Include/KompleksEAAbstraction.mqh>
#include <Indicators\Trend.mqh>
#include <Indicators\Oscilators.mqh>
#include <Indicators\BillWilliams.mqh>

class MovingAverageManager : public CiMA {
    public:
    MovingAverageManager::MovingAverageManager(int pPeriod=12, ENUM_MA_METHOD pMethod=MODE_EMA,
            ENUM_APPLIED_PRICE pAppPrice=PRICE_CLOSE, int pShift=0, ENUM_TIMEFRAMES pTimeFrame=PERIOD_CURRENT) {
        if (!Create(_Symbol, pTimeFrame, pPeriod, pShift, pMethod, pAppPrice))
            if (VERBOSE) Print("Could not create Moving Average Indicator");
    }
    PriceRange* MovingAverageManager::lastNaverage(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 0, pRange);
        return new PriceRange(pRange);
    }
    PriceRange* MovingAverageManager::lastNvalue(int n) {return lastNaverage(n);}
    double MovingAverageManager::currentAverage(void) {return lastNaverage(1).At(0);}
    double MovingAverageManager::lastAverage(void) {return lastNaverage(2).At(1);}
    double MovingAverageManager::currentValue(void) {return currentAverage();}
    double MovingAverageManager::lastValue(void) {return lastAverage();}
};

class PSARmanager : public CiSAR {
    public:
    PSARmanager::PSARmanager(double pStep, double pMax, ENUM_TIMEFRAMES pTimeFrame=PERIOD_CURRENT) {
        if (!Create(_Symbol, pTimeFrame, pStep, pMax))
            if (VERBOSE) Print("Could not create PSAR Indicator");
    }
    PriceRange* PSARmanager::lastNsar(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 0, pRange);
        return new PriceRange(pRange);
    }
    double PSARmanager::currentSAR(void) {return lastNsar(1).At(0);}
    double PSARmanager::lastSAR(void) {return lastNsar(2).At(1);}
    double PSARmanager::currentValue(void) {return currentSAR();}
    double PSARmanager::lastValue(void) {return lastSAR();}
    PriceRange* PSARmanager::lastNvalue(int n) {return lastNsar(n);}
};

class RSImanager : public CiRSI{
    public:
    CandleManager cMan;
    RSImanager::RSImanager(int pPeriod, int app, CandleManager* _cMan, ENUM_TIMEFRAMES pTimeFrame=PERIOD_CURRENT) {
        if (!Create(_Symbol, pTimeFrame, pPeriod, app)) {
            if (VERBOSE) Print("Could not create RSI Indicator");
        }
        cMan = _cMan;
    }
    PriceRange* RSImanager::lastNvalue(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 0, pRange);
        return new PriceRange(pRange);
    }
    DotRange* RSImanager::lastNDotRange(int n, uint _wedge = 5) {
        PriceRange* _pR = lastNvalue(n);
        DateRange* _dR = cMan.lastNdates(n);
        return new DotRange(_pR, _dR, _wedge);
    }
    double RSImanager::currentValue(void) {return lastNvalue(1).At(0);}
    double RSImanager::lastValue(void) {return lastNvalue(2).At(1);}
};

class Stochmanager : public CiStochastic{
    public:
    CandleManager cMan;
    Stochmanager::Stochmanager(int kPeriod, int dPeriod, int slowing, ENUM_MA_METHOD meth, ENUM_STO_PRICE priField,
            CandleManager* _cMan, ENUM_TIMEFRAMES pTimeFrame=PERIOD_CURRENT) {
        if (!Create(_Symbol, pTimeFrame, kPeriod, dPeriod, slowing, meth, priField)) {
            if (VERBOSE) Print("Could not create PSAR Indicator");
        }
        cMan = _cMan;
    }
    PriceRange* Stochmanager::lastNmain(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 0, pRange);
        return new PriceRange(pRange);
    }
    DotRange* Stochmanager::lastNmainDotRange(int n, uint _wedge = 5) {
        PriceRange* _pR = lastNmain(n);
        DateRange* _dR = cMan.lastNdates(n);
        return new DotRange(_pR, _dR, _wedge);
    }
    PriceRange* Stochmanager::lastNsignal(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 1, pRange);
        return new PriceRange(pRange);
    }
    DotRange* Stochmanager::lastNsignalDotRange(int n, uint _wedge = 5) {
        PriceRange* _pR = lastNsignal(n);
        DateRange* _dR = cMan.lastNdates(n);
        return new DotRange(_pR, _dR, _wedge);
    }
    double Stochmanager::currentMain(void) {return lastNmain(1).At(0);}
    double Stochmanager::currentSignal(void) {return lastNsignal(1).At(0);}
    double Stochmanager::lastMain(void) {return lastNmain(2).At(1);}
    double Stochmanager::lastSignal(void) {return lastNsignal(2).At(1);}
    double Stochmanager::currentValue(void) {return currentMain();}
    double Stochmanager::lastValue(void) {return lastMain();}
};

class ADXmanager : public CiADX{
    public:
    ADXmanager::ADXmanager(int pPeriod, ENUM_TIMEFRAMES pTimeFrame=PERIOD_CURRENT) {
        if (!Create(_Symbol, pTimeFrame, pPeriod))
            if (VERBOSE) Print("Could not create ADX Indicator");
    }
    PriceRange* ADXmanager::lastNvalue(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 0, pRange);
        return new PriceRange(pRange);
    }
    double ADXmanager::currentValue(void) {return lastNvalue(1).At(0);}
    double ADXmanager::lastValue(void) {return lastNvalue(2).At(1);}
};

class BBmanager : public CiBands{
    public:
    BBmanager::BBmanager(int pPeriod, double pDev, int pApp, int pShift = 0, ENUM_TIMEFRAMES pTimeFrame=PERIOD_CURRENT) {
        if (!Create(_Symbol, pTimeFrame, pPeriod, pShift, pDev, pApp))
            if (VERBOSE) Print("Could not create Bollinger Bands Indicator");
    }
    PriceRange* BBmanager::lastNupper(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 1, pRange);
        return new PriceRange(pRange);
    }
    PriceRange* BBmanager::lastNlower(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 2, pRange);
        return new PriceRange(pRange);
    }
    PriceRange* BBmanager::lastNmiddle(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 0, pRange);
        return new PriceRange(pRange);
    }
    PriceRange* BBmanager::lastNvalue(int n) {return lastNmiddle(n);}
    double BBmanager::currentMiddle(void) {return lastNmiddle(1).At(0);}
    double BBmanager::lastMiddle(void) {return lastNmiddle(2).At(1);}
    double BBmanager::currentValue(void) {return currentMiddle();}
    double BBmanager::lastValue(void) {return lastMiddle();}
    double BBmanager::lastUpper(void) {return lastNupper(2).At(1);}
    double BBmanager::lastLower(void) {return lastNlower(2).At(1);}
    double BBmanager::currentUpper(void) {return lastNupper(1).At(0);}
    double BBmanager::currentLower(void) {return lastNlower(1).At(0);}
};

class MACDmanager : public CiMACD {
    public:
    CandleManager* cMan;
    MACDmanager::MACDmanager(int fastPeriod, int slowPeriod, int sigPeriod, int pApp, CandleManager* _cMan, ENUM_TIMEFRAMES pTimeFrame=PERIOD_CURRENT) {
        if (!Create(_Symbol, pTimeFrame, fastPeriod, slowPeriod, sigPeriod, pApp)) {
            if (VERBOSE) Print("Could not create MACD Indicator");
        }
        cMan = _cMan;
    }
    PriceRange* MACDmanager::lastNmain(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 0, pRange);
        return new PriceRange(pRange);
    }
    DotRange* MACDmanager::lastNmainDotRange(int n, uint _wedge = 5) {
        PriceRange* _pR = lastNmain(n);
        DateRange* _dR = cMan.lastNdates(n);
        return new DotRange(_pR, _dR, _wedge);
    }
    PriceRange* MACDmanager::lastNsignal(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 1, pRange);
        return new PriceRange(pRange);
    }
    DotRange* MACDmanager::lastNsignalDotRange(int n, uint _wedge = 5) {
        PriceRange* _pR = lastNsignal(n);
        DateRange* _dR = cMan.lastNdates(n);
        return new DotRange(_pR, _dR, _wedge);
    }
    double MACDmanager::lastMain(void) {return lastNmain(2).At(1);}
    double MACDmanager::lastSignal(void) {return lastNsignal(2).At(1);;}
    double MACDmanager::currentMain(void) {return lastNmain(1).At(0);}
    double MACDmanager::currentSignal(void) {return lastNsignal(1).At(0);}
};

class CCImanager : public CiCCI {
    public:
    CCImanager::CCImanager(int pPeriod, int pApp, ENUM_TIMEFRAMES pTimeFrame=PERIOD_CURRENT) {
        if (!Create(_Symbol, pTimeFrame, pPeriod, pApp))
            if (VERBOSE) Print("Could not create CCI Indicator");
    }
    PriceRange* CCImanager::lastNmain(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 0, pRange);
        return new PriceRange(pRange);
    }
    PriceRange* CCImanager::lastNvalue(int n) {return lastNmain(n);}
    double CCImanager::lastMain(void) {return lastNmain(2).At(1);}
    double CCImanager::currentMain(void) {return lastNmain(1).At(0);}
    double CCImanager::lastValue(void) {return lastMain();}
    double CCImanager::currentValue(void) {return currentMain();}
};

class WPRmanager : public CiWPR {
    public:
    WPRmanager::WPRmanager(int pPeriod, ENUM_TIMEFRAMES pTimeFrame=PERIOD_CURRENT) {
        if (!Create(_Symbol, pTimeFrame, pPeriod))
            if (VERBOSE) Print("Could not create WPR Indicator");
    }
    PriceRange* WPRmanager::lastNmain(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 0, pRange);
        return new PriceRange(pRange);
    }
    PriceRange* WPRmanager::lastNvalue(int n) {return lastNmain(n);}
    double WPRmanager::lastMain(void) {return lastNmain(2).At(1);}
    double WPRmanager::currentMain(void) {return lastNmain(1).At(0);}
    double WPRmanager::lastValue(void) {return lastMain();}
    double WPRmanager::currentValue(void) {return currentMain();}
};

class AlligatorManager : public CiAlligator {
    public:
    AlligatorManager::AlligatorManager(int jaw_period, int jaw_shift, int teeth_period, int teeth_shift, int lips_period, int lips_shift, ENUM_MA_METHOD ma_mathod, int pApp, ENUM_TIMEFRAMES pTimeFrame=PERIOD_CURRENT) {
        if (!Create(_Symbol, pTimeFrame, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_mathod, pApp))
            if (VERBOSE) Print("Could not create Aliigator Indicator");
    }
    PriceRange* AlligatorManager::lastNjaws(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 0, pRange);
        return new PriceRange(pRange);
    }
    PriceRange* AlligatorManager::lastNteeth(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 1, pRange);
        return new PriceRange(pRange);
    }
    PriceRange* AlligatorManager::lastNlips(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 2, pRange);
        return new PriceRange(pRange);
    }
    double AlligatorManager::lastJaws(void) {return lastNjaws(2).At(1);}
    double AlligatorManager::lastTeeth(void) {return lastNteeth(2).At(1);}
    double AlligatorManager::lastLips(void) {return lastNlips(2).At(1);}
    double AlligatorManager::currentJaws(void) {return lastNjaws(1).At(0);}
    double AlligatorManager::currentTeeth(void) {return lastNteeth(1).At(0);}
    double AlligatorManager::currentLips(void) {return lastNlips(1).At(0);}
    
};

class AMAmanager : public CiAMA {
    public:
    AMAmanager::AMAmanager(int ma_period, int fast_ema_period, int slow_ema_period, int ind_shift, int pApp, ENUM_TIMEFRAMES pTimeFrame = PERIOD_CURRENT) {
        if (!Create(_Symbol, pTimeFrame, ma_period, fast_ema_period, slow_ema_period, ind_shift, pApp)) {
            if (VERBOSE) Print("Could'nt create AMA indicator");
        }
    }
    PriceRange* AMAmanager::lastNvalue(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 0, pRange);
        return new PriceRange(pRange);
    }
    double AMAmanager::lastValue(void) {return lastNvalue(2).At(1);}
    double AMAmanager::currentValue(void) {return lastNvalue(1).At(0);}
};

class AOmanager : public CiAO {
    public:
    AOmanager::AOmanager(ENUM_TIMEFRAMES pTimeFrame = PERIOD_CURRENT) {
        if (!Create(_Symbol, pTimeFrame)) {
            if (VERBOSE) Print("Could'nt create Awesome Oscillator");
        }
    }
    PriceRange* AOmanager::lastNvalue(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 0, pRange);
        return new PriceRange(pRange);
    }
    PriceRange* AOmanager::lastNcolor(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 1, pRange);
        return new PriceRange(pRange);
    }
    double AOmanager::lastValue(void) {return lastNvalue(2).At(1);}
    double AOmanager::currentValue(void) {return lastNvalue(1).At(0);}
    double AOmanager::lastColor(void) {return lastNcolor(2).At(1);}
    double AOmanager::currentColor(void) {return lastNcolor(1).At(0);}
};

class ICHImanager : public CiIchimoku {
    public:
    ICHImanager::ICHImanager(int tenkan_sen, int kijun_sen, int senkou_span_b, ENUM_TIMEFRAMES pTimeFrame = PERIOD_CURRENT) {
        if (!Create(_Symbol, pTimeFrame, tenkan_sen, kijun_sen, senkou_span_b)) {
            if (VERBOSE) Print("Could'nt create Ichimoku indicator");
        }
    }
    PriceRange* ICHImanager::lastNtenkan(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 0, pRange);
        return new PriceRange(pRange);
    }
    PriceRange* ICHImanager::lastNkijun(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 1, pRange);
        return new PriceRange(pRange);
    }
    PriceRange* ICHImanager::lastNspanA(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 2, pRange);
        return new PriceRange(pRange);
    }
    PriceRange* ICHImanager::lastNspanB(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 3, pRange);
        return new PriceRange(pRange);
    }
    PriceRange* ICHImanager::lastNspan(int n) {
        double pRange[];
        ArraySetAsSeries(pRange, true);
        Refresh();
        GetData(0, n, 4, pRange);
        return new PriceRange(pRange);
    }
    double ICHImanager::lastTenkan(void) {return lastNtenkan(2).At(1);}
    double ICHImanager::currentTenkan(void) {return lastNtenkan(1).At(0);;}
    double ICHImanager::lastKijun(void) {return lastNkijun(2).At(1);}
    double ICHImanager::currentKijun(void) {return lastNkijun(1).At(0);}
    double ICHImanager::lastSpanA(void) {return lastNspanA(2).At(1);}
    double ICHImanager::currentSpanA(void) {return lastNspanA(1).At(0);}
    double ICHImanager::lastSpanB(void) {return lastNspanB(2).At(1);}
    double ICHImanager::currentSpanB(void) {return lastNspanB(1).At(0);}
    double ICHImanager::lastSpan(void) {return lastNspan(2).At(1);}
    double ICHImanager::currentSpan(void) {return lastNspan(1).At(0);}
};