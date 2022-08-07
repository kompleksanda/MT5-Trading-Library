//+------------------------------------------------------------------+
//|                                     KompleksClassAbstraction.mqh |
//|                                       Copyright 2022, KompleksEA |
//|                            https://www.kompleksanda.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, KompleksEA"
#property link      "https://www.kompleksanda.blogspot.com"

#include <MT5TradingLibrary/Include/KompleksCOAbstraction.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\Trade.mqh>

// CANDLES
class CandleManager : public PriceManager {
    protected:
    void assignCandleTrend(int range, CandleRange& cRange, int pShift, bool series) {
        double aver;
        double averBodySize;
        Candle* cand;
        if (series) {
            ForEachRange(i, cRange) {
                aver = lastNclosePrices(range, pShift+i, false).average();
                averBodySize = getAverageCandleBodyLength(12, pShift+i);
                cand = cRange.At(i);
                //delete cand;
                if (aver < cand.close) cand.trendType = TREND_TYPE_UP;
                if (aver > cand.close) cand.trendType = TREND_TYPE_DOWN;
                if (aver == cand.close) cand.trendType = TREND_TYPE_NOTREND;
                if (cand.bodyPoint > averBodySize*1.3) cand.lengthType = CANDLE_LENGTH_LONG;
                else if (cand.bodyPoint < averBodySize*0.5) cand.lengthType = CANDLE_LENGTH_SHORT;
            }
        } else {
            ForEachReverseRange(i, cRange) {
                aver = lastNclosePrices(range, pShift+i, false).average();
                averBodySize = getAverageCandleBodyLength(12, pShift+i);
                cand = cRange.At(i);
                //delete cand;
                if (aver < cand.close) cand.trendType = TREND_TYPE_UP;
                if (aver > cand.close) cand.trendType = TREND_TYPE_DOWN;
                if (aver == cand.close) cand.trendType = TREND_TYPE_NOTREND;
                if (cand.bodyPoint > averBodySize*1.3) cand.lengthType = CANDLE_LENGTH_LONG;
                else if (cand.bodyPoint < averBodySize*0.5) cand.lengthType = CANDLE_LENGTH_SHORT;
            }
        }
    }
    public:
    datetime interval;
    CandleManager(ENUM_TIMEFRAMES pTimeFrame = PERIOD_CURRENT) {
        PriceManager(pTimeFrame);
        pTimeFrame = pTimeFrame == PERIOD_CURRENT ? _Period : pTimeFrame;
        interval = PeriodSeconds();
    }
    datetime periodToSec(ENUM_TIMEFRAMES pTimeFrame) {
        switch (pTimeFrame) {
            case PERIOD_M1: return 60;
            case PERIOD_M2: return 60*2;
            case PERIOD_M3: return 60*3;
            case PERIOD_M4: return 60*4;
            case PERIOD_M5: return 60*5;
            case PERIOD_M6: return 60*6;
            case PERIOD_M10: return 60*10;
            case PERIOD_M12: return 60*12;
            case PERIOD_M15: return 60*15;
            case PERIOD_M20: return 60*20;
            case PERIOD_M30: return 60*30;
            case PERIOD_H1: return 3600;
            case PERIOD_H2: return 3600*2;
            case PERIOD_H3: return 3600*3;
            case PERIOD_H4: return 3600*4;
            case PERIOD_H6: return 3600*6;
            case PERIOD_H8: return 3600*8;
            case PERIOD_H12: return 3600*12;
            case PERIOD_D1: return 43200;
            case PERIOD_W1: return 43200 * 7;
            case PERIOD_MN1: return 43200 * 28;
            default: return 0;
        }
    }
    Dot* CandleManager::dotsMid(Dot &dot1, Dot& dot2) {return new Dot((dot1.price+dot2.price)/2, getDate(uint((dateToNum(dot1.time)+dateToNum(dot2.time))/2)));}
    CandleRange* CandleManager::lastNcandles(int n, uint pShift = 0, bool series = true) {
        MqlRates rates [];
        ArraySetAsSeries(rates, series);
        CopyRates(_Symbol, timeFrame, pShift, n, rates);
        CandleRange* cRange = new CandleRange(rates);
        assignCandleTrend(12, cRange, pShift, series);
        return cRange;
    }
    Candle* CandleManager::getCandle(uint n, bool series = true) {return lastNcandles(1, n, series).At(0);}
    CandleRange* CandleManager::candlesBetweenDates(datetime date, datetime pDate, bool series = true) {
        MqlRates rates [];
        ArraySetAsSeries(rates, series);
        CopyRates(_Symbol, timeFrame, date, pDate, rates);
        CandleRange* cRange = new CandleRange(rates);
        assignCandleTrend(12, cRange, dateToNum(pDate), series);
        return cRange;
    }
    int CandleManager::datesToCount(datetime date1, datetime date2) {return Bars(_Symbol, timeFrame, date1, date2) - 1;}
    int CandleManager::datesToCount(Dot &dot1, Dot &dot2) {return datesToCount(dot2.time, dot1.time)+1;}
    int CandleManager::dateToNum(datetime date1) {
        //dates are in series
        return datesToCount(date1, currentDate());
        //return iBarShift(_Symbol, timeFrame, date1, true);
    }
    IntRange* CandleManager::dateRangeToIntRange(DateRange& _dR) {
        int ir[];
        ForEachRange(i, _dR) addToArr(ir, dateToNum(_dR[i]));
        return new IntRange(ir);
    }
    void CandleManager::dateRangeToArray(DateRange& _dR, int& ir[]) {
        ArrayResize(ir, 0);
        ForEachRange(i, _dR) addToArr(ir, dateToNum(_dR[i]));
    }
    void CandleManager::dateRangeToArray(DateRange& _dR, double& ir[]) {
        ArrayResize(ir, 0);
        ForEachRange(i, _dR) addToArr(ir, (double)dateToNum(_dR[i]));
    }
    datetime CandleManager::dateShiftCount(datetime date1, int pShift = 0) {
        if (pShift == 0) return currentDate();
        return date1 + (interval * pShift);
    }
    LongRange* CandleManager::lastNtickVolume(int n, uint pShift = 0, bool series = true) {
        long tVol [];
        ArraySetAsSeries(tVol, series);
        CopyTickVolume(_Symbol, timeFrame, pShift, n, tVol);
        return new LongRange(tVol);
    }
    long CandleManager::getTickVolume(uint n, bool series = true) {return lastNtickVolume(1, n, series).At(0);}
    double getCandlesSlope(Candle& pC, Candle& cC) {return getSlope(cC.close - pC.open, datesToCount(pC.time, cC.time)+1);}
    double getCandlesSlope(uint pRange, uint pShift = 1) {
        Candle* cC = getCandle(pShift);
        Candle* pC = getCandle(pRange+pShift-1);
        double ret = getSlope(cC.close - pC.open, pRange);
        //delete cC; delete pC;
        return ret;
    }
    double pointPerTime(Dot &dot1, Dot &dot2) {
        return (double)pricesTOsignedPoint(dot1, dot2) / (datesToCount(dot2.time, dot1.time)+1);
    }
    LongRange* CandleManager::lastNrealVolume(int n, uint pShift = 0, bool series = true) {
        long tVol [];
        ArraySetAsSeries(tVol, series);
        CopyRealVolume(_Symbol, timeFrame, pShift, n, tVol);
        return new LongRange(tVol);
    }
    long CandleManager::getRealVolume(uint n, bool series = true) {return lastNrealVolume(1, n, series).At(0);}
    IntRange* CandleManager::lastNspread(int n, uint pShift = 0, bool series = true) {
        int tSpread [];
        ArraySetAsSeries(tSpread, series);
        CopySpread(_Symbol, timeFrame, pShift, n, tSpread);
        return new IntRange(tSpread);
    }
    int CandleManager::getSpread(uint n, bool series = true) {return lastNspread(1, n, series).At(0);}
    DateRange* CandleManager::lastNdates(int n, uint pShift = 0, bool series = true) {
        datetime tDate [];
        ArraySetAsSeries(tDate, series);
        CopyTime(_Symbol, timeFrame, pShift, n, tDate);
        return new DateRange(tDate);
    }
    datetime CandleManager::getDate(uint n, bool series = true) {return lastNdates(1, n, series).At(0);}
    Candle* CandleManager::lastCandle(void) {return lastNcandles(1, 1).At(0);}
    Candle* CandleManager::currentCandle(void) {return lastNcandles(1).At(0);}
    datetime CandleManager::currentDate(void) {
        //datetime dates[];
        //ArraySetAsSeries(dates, true);
        //CopyTime(_Symbol, timeFrame, 0, 1, dates);
        //return dates[0];
        //return currentCandle().time;
        return iTime(_Symbol, timeFrame, 0);
        //return (datetime)SeriesInfoInteger(_Symbol, timeFrame, SERIES_LASTBAR_DATE);
    }
    datetime CandleManager::lastDate(void) {
        datetime _dates[];
        ArraySetAsSeries(_dates, true);
        CopyTime(_Symbol, timeFrame, 1, 1, _dates);
        return _dates[0];
        //return lastCandle().time;
    }
    long CandleManager::currentTickVolume(void) {return lastNtickVolume(1).At(0);}
    long CandleManager::lastTickVolume(void) {return lastNtickVolume(1, 1).At(0);}
    long CandleManager::currentRealVolume(void) {return lastNrealVolume(1).At(0);}
    long CandleManager::lastTRealVolume(void) {return lastNrealVolume(1, 1).At(0);}
    int CandleManager::currentSpread(void) {return lastNspread(1).At(0);}
    int CandleManager::lastSpread(void) {return lastNspread(1, 1).At(0);}
    bool CandleManager::isNewBar(datetime pPrevDate) {return (pPrevDate < currentDate());}
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
    uint CandleManager::timePercentage(void) {return (uint)(((TimeCurrent()-currentDate())/(double)interval)*100);}
    bool CandleManager::isNpercentTime(uint n, uint pLastPercent) {
        uint cPercent = timePercentage();
        if (pLastPercent < n && cPercent >= n && cPercent <= n+3) return true;
        return false;
    }
    bool CandleManager::isHalfTime(uint pLastPercent) {return isNpercentTime(50, pLastPercent);}
    bool CandleManager::is25PercentTime(uint pLastPercent) {return isNpercentTime(25, pLastPercent);}
    bool CandleManager::is75PercentTime(uint pLastPercent) {return isNpercentTime(75, pLastPercent);}
    double CandleManager::lowestLow(uint i = 10, uint pShift = 1) {
        PriceRange* _lows = lastNlowPrices(i, pShift);
        double low = _lows.At(_lows.Minimum(0, i));
        //delete _lows;
        return low;
    }
    double CandleManager::highestLow(int i = 10, uint pShift = 1) {
        PriceRange* _lows = lastNlowPrices(i, pShift);
        double low = _lows.At(_lows.Maximum(0, i));
        //delete _lows;
        return low;
    }
    double CandleManager::lowestHigh(int i = 10, uint pShift = 1) {
        PriceRange* _lows = lastNhighPrices(i, pShift);
        double low = _lows.At(_lows.Minimum(0, i));
        //delete _lows;
        return low;
    }
    double CandleManager::highestHigh(int i = 10, uint pShift = 1) {
        PriceRange* _lows = lastNhighPrices(i, pShift);
        double low = _lows.At(_lows.Maximum(0, i));
        //delete _lows;
        return low;
    }
    double CandleManager::lowestClose(int i = 10, uint pShift = 1) {
        PriceRange* _lows = lastNclosePrices(i, pShift);
        double low = _lows.At(_lows.Minimum(0, i));
        //delete _lows;
        return low;
    }
    double CandleManager::highestClose(int i = 10, uint pShift = 1) {
        PriceRange* _lows = lastNclosePrices(i, pShift);
        double low = _lows.At(_lows.Maximum(0, i));
        //delete _lows;
        return low;
    }
    double CandleManager::lowestOpen(int i = 10, uint pShift = 1) {
        PriceRange* _lows = lastNopenPrices(i, pShift);
        double low = _lows.At(_lows.Minimum(0, i));
        delete _lows;
        return low;
    }
    double CandleManager::highestOpen(int i = 10, uint pShift = 1) {
        PriceRange* _lows = lastNopenPrices(i, pShift);
        double low = _lows.At(_lows.Maximum(0, i));
        //delete _lows;
        return low;
    }
    bool isLowestExtremum(int bar, int side, PriceRange& pR) {
        for ( int i = 1; i <= side; i++ ) {
            if (pR.At(bar) > pR.At(bar-i) || pR.At(bar) > pR.At(bar+i)) return false;
        }
        return true;
    } 
    bool isLowestExtremumV2(int bar, int side, PriceRange& pR) {
        if (pR.At(bar) != pR.At(pR.Minimum(bar+1, side)) || pR.At(bar) != pR.At(pR.Minimum(bar-side, side))) return false;
        return true;
    }
    bool isHighestExtremum(int bar, int side, PriceRange& pR) {
        for ( int i = 1; i <= side; i++ ) {
            if (pR.At(bar) < pR.At(bar-i) || pR.At(bar) < pR.At(bar+i)) return false;
        }
        return true;
    }
    bool isHighestExtremumV2(int bar, int side, PriceRange& pR) {
        if (pR.At(bar) != pR.At(pR.Maximum(bar+1, side)) || pR.At(bar) != pR.At(pR.Maximum(bar-side, side))) return false;
        return true;
    }
    int newLowest(PriceRange& array, const int depth, const int start) {
        if(start < 0) return 0;
        
        double min = array.At(start);
        int index=start;
        //--- start searching
        for(int i = start-1; i > start-depth && i >= 0; i--) {
            if(array.At(i) < min) {
                index = i;
                min = array.At(i);
            }
        }
        //--- return index of the lowest bar
        return(index);
    }
    int newHighest(PriceRange& array, const int depth, const int start) {
        if(start<0) return(0);
        
        double max = array.At(start);
        int index=start;
        //--- start searching
        for(int i = start-1; i > start-depth && i >= 0; i--) {
            if(array.At(i) > max) {
                index = i;
                max = array.At(i);
            }
        }
        //--- return index of the highest bar
        return(index);
    }
    int getRangeCandleBodyLength(int num=10, uint pShift=0) {
        double allClose = lastNclosePrices(num, pShift).sum();
        double allOpen = lastNopenPrices(num, pShift).sum();
        if (allOpen > allClose) return -(int)pricesTOpoint(allClose, allOpen);
        else return (int)pricesTOpoint(allClose, allOpen);
    }
    double getRangeCandleLength(int num=10, uint pShift=0) {
        double allHigh = lastNhighPrices(num, pShift).sum();
        double allLow = lastNlowPrices(num, pShift).sum();
        return pricesTOpoint(allHigh, allLow);
    }
    uint getAverageCandleBodyLength(int num=10, uint pShift=0) {
        PriceRange* allClose = lastNclosePrices(num, pShift);
        PriceRange* allOpen = lastNopenPrices(num, pShift);
        uint ave = 0;
        for (int i = 0; i < allClose.Total(); i++) {
            ave += pricesTOpoint(allClose.At(i), allOpen.At(i));
        }
        //delete allClose; delete allOpen;
        return ave/num;
    }
    int getAverageCandleBodyLengthSign(int num=10, uint pShift=0) {
        PriceRange* allClose = lastNclosePrices(num, pShift);
        PriceRange* allOpen = lastNopenPrices(num, pShift);
        int ave = 0;
        for (int i = 0; i < allClose.Total(); i++) {
            ave += (int)pricesTOpoint(allClose.At(i), allOpen.At(i));
        }
        ave = ave/num;
        if (allClose.sum() < allOpen.sum()) ave = -ave;
        //delete allClose; delete allOpen;
        return ave;
    }
    uint getAverageCandleLength(int num=10, uint pShift=0) {
        PriceRange* allHigh = lastNhighPrices(num, pShift);
        PriceRange* allLow = lastNlowPrices(num, pShift);
        uint ave = 0;
        for (int i = 0; i < allHigh.Total(); i++) {
            ave += pricesTOpoint(allHigh.At(i), allLow.At(i));
        }
        //delete allHigh; delete allLow;
        return ave/num;
    }
    ENUM_CANDLE_PATTERN CandleManager::singleCandlePat(Candle* cC) {
        ENUM_CANDLE_CAT cat = cC.category;
        switch (cat) {
           case CANDLE_CAT_DOJI:
               return CANDLE_PAT_DOJI;
           case CANDLE_CAT_HAMMER:
               return CANDLE_PAT_HAMMER;
           case CANDLE_CAT_INVHAMMER:
               return CANDLE_PAT_INVHAMMER;
           default:
               return CANDLE_PAT_UNKNOWN;
        }
    }
    ENUM_CANDLE_PATTERN CandleManager::dualCandlePat(Candle* pC, Candle* cC) {
        uint pCbP = pC.bodyPoint;
        uint cCbP = cC.bodyPoint;
        if (cC.type == CANDLE_TYPE_BULL) {
            if (pC.type == CANDLE_TYPE_BEAR) {
                if (cCbP >= 2.8*pCbP) {
                    if (pC.bodyWithin2(cC, 10, "BOT")) return CANDLE_PAT_BULLISHENG;
                }
                if (pCbP >= 2.8*cCbP) {
                    if (cC.bodyWithin2(pC, 10, "BOT")) return CANDLE_PAT_BULLISHHARAMI;
                }
                if (percentageDifference(pCbP, cCbP) <= 25 && pC.bodyWithin2(cC, 25)) return CANDLE_PAT_TWEEZZERBOT;
            } else if (pC.type == CANDLE_TYPE_DASH) return CANDLE_PAT_BULLISHENG;
            else if (pC.type == CANDLE_TYPE_BULL) {
                if (cCbP >= 2.8*pCbP) return CANDLE_PAT_BULLISHIMP;
                if (pCbP >= 2.8*cCbP) return CANDLE_PAT_BULLISHCOR;
            }
        } else if (cC.type == CANDLE_TYPE_BEAR) {
            if (pC.type == CANDLE_TYPE_BULL) {
                if (cCbP >= 2.8*pCbP) {
                    if (pC.bodyWithin2(cC, 10, "TOP")) return CANDLE_PAT_BEARISHENG;
                }
                if (pCbP >= 2.8*cCbP) {
                    if (cC.bodyWithin2(pC, 10, "TOP")) return CANDLE_PAT_BEARISHHARAMI;
                }
                if (percentageDifference(pCbP, cCbP) <= 25 && pC.bodyWithin2(cC, 25)) return CANDLE_PAT_TWEEZZERTOP;
            } else if (pC.type == CANDLE_TYPE_DASH) return CANDLE_PAT_BEARISHENG;
            else if (pC.type == CANDLE_TYPE_BEAR) {
                if (cCbP >= 2.8*pCbP) return CANDLE_PAT_BEARISHIMP;
                if (pCbP >= 2.8*cCbP) return CANDLE_PAT_BEARISHCOR;
            }
        }
        return CANDLE_PAT_UNKNOWN;
    }
    ENUM_CANDLE_PATTERN CandleManager::triCandlePat(Candle* ppC, Candle* pC, Candle* cC) {
        uint ppCbP = ppC.bodyPoint;
        uint pCbP = pC.bodyPoint;
        uint cCbP = cC.bodyPoint;
        if (cC.type == CANDLE_TYPE_BULL) {
            if (ppC.type == CANDLE_TYPE_BEAR) {
                if (percentageDifference(cCbP, ppCbP) <= 25 && cCbP >= 4*pCbP && ppCbP >= 4*pCbP && (pC.bodyWithin(ppC) || pC.bodyWithin(cC)))
                    return CANDLE_PAT_MORNINGSTAR;
            }
        } else if (cC.type == CANDLE_TYPE_BEAR) {
            if (ppC.type == CANDLE_TYPE_BULL) {
                if (percentageDifference(cCbP, ppCbP) <= 25 && cCbP >= 4*pCbP && ppCbP >= 4*pCbP && (pC.bodyWithin(ppC) || pC.bodyWithin(cC)))
                    return CANDLE_PAT_EVENINGSTAR;
            }
        }
        return CANDLE_PAT_UNKNOWN;
    }
    void CandleManager::drawCandlePattern(Candle* lCand3, Candle* lCand2, Candle* lCand, string pType = "ALL") {
        ENUM_CANDLE_PATTERN pat = CANDLE_PAT_UNKNOWN;
        if (pType == "ALL" || pType == "DUAL" || pType == "DUALTRI"|| pType == "SINGDUAL") {
            pat = dualCandlePat(lCand2, lCand);
            if (candlePatternToSignal(pat) != SIGNAL_UNKNOWN) drawRectAndTexton2Cand(lCand2, lCand, StringSubstr(EnumToString(pat), 11));
        }
        if (pType == "ALL" || pType == "TRI" || pType == "DUALTRI" || pType == "SINGTRI") {
            pat = triCandlePat(lCand3, lCand2, lCand);
            if (candlePatternToSignal(pat) != SIGNAL_UNKNOWN) drawRectAndTexton3Cand(lCand3, lCand2, lCand, StringSubstr(EnumToString(pat), 11));
        }
        if (pType == "ALL" || pType == "SING" || pType == "SINGDUAL" || pType == "SINGTRI") {
            pat = singleCandlePat(lCand);
            if (candlePatternToSignal(pat) != SIGNAL_UNKNOWN) drawRectAndTexton1Cand(lCand, StringSubstr(EnumToString(pat), 11));
        }
    }
    void CandleManager::drawCandlePattern(textObject* &texts[], Candle* lCand3, Candle* lCand2, Candle* lCand, string pType = "ALL") {
        ENUM_CANDLE_PATTERN pat = CANDLE_PAT_UNKNOWN;
        if (pType == "ALL" || pType == "DUAL" || pType == "DUALTRI"|| pType == "SINGDUAL") {
            pat = dualCandlePat(lCand2, lCand);
            if (candlePatternToSignal(pat) != SIGNAL_UNKNOWN) drawRectAndTexton2Cand(lCand2, lCand, StringSubstr(EnumToString(pat), 11));
        }
        if (pType == "ALL" || pType == "TRI" || pType == "DUALTRI" || pType == "SINGTRI") {
            pat = triCandlePat(lCand3, lCand2, lCand);
            if (candlePatternToSignal(pat) != SIGNAL_UNKNOWN) drawRectAndTexton3Cand(lCand3, lCand2, lCand, StringSubstr(EnumToString(pat), 11));
        }
        if (pType == "ALL" || pType == "SING" || pType == "SINGDUAL" || pType == "SINGTRI") {
            pat = singleCandlePat(lCand);
            if (candlePatternToSignal(pat) != SIGNAL_UNKNOWN) drawRectAndTexton1Cand(lCand, StringSubstr(EnumToString(pat), 11));
        }
    }
    void CandleManager::drawCandlePattern(string pType = "ALL") {
        Candle* lCand = lastCandle();
        Candle* lCand2 = getCandle(2);
        Candle* lCand3 = getCandle(3);
        drawCandlePattern(lCand3, lCand2, lCand, pType);
        //delete lCand;delete lCand2;delete lCand3;
    }
    void drawRectAndTexton3Cand(Candle* ppC, Candle* pC, Candle* cC, string text) {
        double ll = MathMin(ppC.low, MathMin(pC.low, cC.low));
        double hh = MathMax(ppC.high, MathMax(pC.high, cC.high));
        //leaks memory
        rectangle* rect = new rectangle(text+TimeToString((ppC.time+cC.time)/2), ppC.time-interval, ll, cC.time+interval, hh);
    }
    void drawRectAndTexton3Cand(rectangle* rectt, Candle* ppC, Candle* pC, Candle* cC, string text) {
        delete rectt;
        double ll = MathMin(ppC.low, MathMin(pC.low, cC.low));
        double hh = MathMax(ppC.high, MathMax(pC.high, cC.high));
        rectt = new rectangle(text+TimeToString((ppC.time+cC.time)/2), ppC.time-interval, ll, cC.time+interval, hh);
    }
    void drawRectAndTexton2Cand(Candle* pC, Candle* cC, string text) {
        double ll = MathMin(pC.low, cC.low);
        double hh = MathMax(pC.high, cC.high);
        //leaks memory
        rectangle* rect = new rectangle(text+TimeToString((pC.time+cC.time)/2), pC.time-interval, ll, cC.time+interval, hh);
    }
    void drawRectAndTexton2Cand(rectangle* rectt, Candle* pC, Candle* cC, string text) {
        delete rectt;
        double ll = MathMin(pC.low, cC.low);
        double hh = MathMax(pC.high, cC.high);
        rectt = new rectangle(text+TimeToString((pC.time+cC.time)/2), pC.time-interval, ll, cC.time+interval, hh);
    }
    void drawRectAndTexton1Cand(Candle* cC, string text) {
        //leaks memory
        textObject* tObj = new textObject("candleText"+TimeToString((cC.time*2)/3), cC.time, cC.high);
        tObj.Description(text);
        tObj.Angle(90);
        tObj.FontSize(10);
    }
    void drawRectAndTexton1Cand(CChartObject* &rectTxt[],  Candle* cC, string text) {
        deletePointerArr(rectTxt);
        textObject* tObj = new textObject("candleText"+TimeToString((cC.time*2)/3), cC.time, cC.high);
        tObj.Description(text);
        tObj.Angle(90);
        tObj.FontSize(10);
        addToArr(rectTxt, (CChartObject*)NULL);
        addToArr(rectTxt, (CChartObject*)tObj);
    }
    void drawRect(Candle* pC, Candle* cC, rectangle* &pRect, color pColor = clrRed, uint width = 1) {
        if (pRect) delete pRect;
        int start = dateToNum(cC.time);
        int end = dateToNum(pC.time);
        if (start > end) {
            int temp = start;
            start = end;
            end = temp; 
        } 
        double ll = lowestLow(end-start+1, start);
        double hh = highestHigh(end-start+1, start);
        pRect = new rectangle(TimeToString((pC.time+cC.time)/2), pC.time-interval, ll, cC.time+interval, hh);
    }
    void drawRect(uint pRange, uint shift, rectangle* &pRect, color pColor = clrRed, uint width = 1) {
        Candle* cC = getCandle(shift);
        Candle* pC = getCandle(pRange+shift-1);
        drawRect(pC, cC, pRect, pColor, width);
        //delete cC;
        //delete pC;
    }
    void drawCandleTrendType(void) {
        Candle* candle = lastCandle();
        textObject* tObj = new textObject(TimeToString(candle.time), candle.time, candle.high);
        tObj.Description(StringSubstr(EnumToString(candle.trendType), 11));
        tObj.Angle(90);
        tObj.FontSize(10);
        //delete candle;
    }
    void drawCandleTrendType(textObject* &_tObj) {
        if (_tObj) delete _tObj;
        Candle* candle = lastCandle();
        _tObj = new textObject(TimeToString(candle.time), candle.time, candle.high);
        _tObj.Description(StringSubstr(EnumToString(candle.trendType), 11));
        _tObj.Angle(90);
        _tObj.FontSize(10);
        delete candle;
    }
    void drawCandleLengthType(void) {
        Candle* candle = lastCandle();
        textObject* tObj = new textObject(TimeToString(candle.time), candle.time, candle.high);
        tObj.Description(StringSubstr(EnumToString(candle.lengthType), 14));
        tObj.Angle(90);
        tObj.FontSize(10);
        //delete candle;
    }
    void drawCandleLengthType(textObject* &_tObj) {
        if (_tObj) delete _tObj;
        Candle* candle = lastCandle();
        _tObj = new textObject(TimeToString(candle.time), candle.time, candle.high);
        _tObj.Description(StringSubstr(EnumToString(candle.lengthType), 14));
        _tObj.Angle(90);
        _tObj.FontSize(10);
        //delete candle;
    }
    void drawCandleCat(void) {
        Candle* candle = lastCandle();
        textObject* tObj = new textObject(TimeToString(candle.time), candle.time, candle.high);
        tObj.Description(StringSubstr(EnumToString(candle.category), 11));
        tObj.Angle(90);
        tObj.FontSize(10);
        //delete candle;
    }
    void drawCandleCat(textObject* &_tObj) {
        if (_tObj) delete _tObj;
        Candle* candle = lastCandle();
        _tObj = new textObject(TimeToString(candle.time), candle.time, candle.high);
        _tObj.Description(StringSubstr(EnumToString(candle.category), 11));
        _tObj.Angle(90);
        _tObj.FontSize(10);
        //delete candle;
    }
    void drawCandleType(void) {
        Candle* candle = lastCandle();
        textObject* tObj = new textObject(TimeToString(candle.time), candle.time, candle.high);
        tObj.Description(StringSubstr(EnumToString(candle.type), 12));
        tObj.Angle(90);
        tObj.FontSize(10);
        //delete candle;
    }
    void drawCandleType(textObject* &_tObj) {
        if (_tObj) delete _tObj;
        Candle* candle = lastCandle();
        _tObj = new textObject(TimeToString(candle.time), candle.time, candle.high);
        _tObj.Description(StringSubstr(EnumToString(candle.type), 12));
        _tObj.Angle(90);
        _tObj.FontSize(10);
        //delete candle;
    }
};
class MarketStructureManager :public CandleManager {
    public:
    //Uses a minimum extremum on one side to determine points
    void MarketStructureManager::getHorizontalHVLVoftrendingMarket(double &_highs[], double& _lows[], int totBars = 200,
            int extremum = 6, bool forTrend=false,bool inOrder=true, string mode = "HL", PriceRange* pPR = NULL) {
        if (extremum > totBars) return;
        PriceRange* highRange;
        PriceRange* lowRange;
        if (mode == "HL") {
            highRange = lastNhighPrices(totBars, 1);
            lowRange = lastNlowPrices(totBars, 1);
        } else if (mode == "OC") {
            highRange = lastNopenPrices(totBars, 1);
            lowRange = lastNclosePrices(totBars, 1);
        } else if (mode == "PRICE") {
            highRange = pPR;
            lowRange = pPR;
        }
        ArrayResize(_highs, 0);
        ArrayResize(_lows, 0);
        double highTrend = WRONG_VALUE; double highFirst = WRONG_VALUE; int highTrendCount = 0;
        double lowTrend = WRONG_VALUE; double lowFirst = WRONG_VALUE; int lowTrendCount = 0;
        for (int i = totBars-2; i >= 0; i--) {
            if (highTrend == WRONG_VALUE) {
                if (highRange.At(i) > highRange.At(i+1)) highTrend = highRange.At(i);
                else {
                    if (highFirst == WRONG_VALUE) highTrend = highRange.At(i+1);
                }
            } else {
                if (highRange.At(i) > highTrend) {
                    highTrend = highRange.At(i);
                    highTrendCount = 0;
                } else if (highRange.At(i) < highTrend) {
                    highTrendCount++;
                    if (highTrendCount > extremum) {
                        if (highFirst != WRONG_VALUE) {
                            adjustPricesWithinLevel(_highs, highTrend, 100, inOrder);
                            highTrendCount = 0;
                            if (!forTrend) highTrend = WRONG_VALUE;
                        } else {
                            highFirst = highTrend;
                            highTrend = WRONG_VALUE;
                        }
                    }
                }
            }
            if (lowTrend == WRONG_VALUE) {
                if (lowRange.At(i) < lowRange.At(i+1)) lowTrend = lowRange.At(i);
                else {
                    if (lowFirst == WRONG_VALUE) lowTrend = lowRange.At(i+1);
                }
            } else {
                if (lowRange.At(i) < lowTrend) {
                    lowTrend = lowRange.At(i);
                    lowTrendCount = 0;
                } else if (lowRange.At(i) > lowTrend) {
                    lowTrendCount++;
                    if (lowTrendCount > extremum) {
                        if (lowFirst != WRONG_VALUE) {
                            adjustPricesWithinLevel(_lows, lowTrend, 100, inOrder);
                            lowTrendCount = 0;
                            if (!forTrend) lowTrend = WRONG_VALUE;
                        } else {
                            lowFirst = lowTrend;
                            lowTrend = WRONG_VALUE;
                        }
                    }
                }
            }
        }
        if (highTrendCount > extremum) adjustPricesWithinLevel(_highs, highTrend, 100, inOrder);
        if (lowTrendCount >= extremum) adjustPricesWithinLevel(_lows, lowTrend, 100, inOrder);
        //delete highRange; delete lowRange;
    }
    //divides ranges into sections and indicates lowest and highest
    void MarketStructureManager::getHorizontalHVLVoftrendingMarketV2(double &_highs[],double &_lows[],uint totBars=200,
            uint pInt=50, bool inOrder = true, string mode="HL", PriceRange* pPR = NULL) {
        if (pInt > totBars) return;
        PriceRange* highRange;
        PriceRange* lowRange;
        ArrayResize(_highs, 0);
        ArrayResize(_lows, 0);
        if (mode == "HL") {
            highRange = lastNhighPrices(totBars, 1);
            lowRange = lastNlowPrices(totBars, 1);
        } else if (mode == "OC") {
            highRange = lastNopenPrices(totBars, 1);
            lowRange = lastNclosePrices(totBars, 1);
        } else if (mode == "PRICE") {
            highRange = pPR;
            lowRange = pPR;
        }
        uint whole = (uint)ceil(totBars/pInt);
        uint rem = (whole*pInt) - totBars;
        uint start = 0;
        for (int i = 1; i <= MathCeil(totBars/pInt); i++) {
            start = totBars-(i*pInt);
            if (start == 0 && rem != 0) pInt = rem;
            adjustPricesWithinLevel(_highs, highRange.At(highRange.Maximum(start, pInt)), 100, inOrder);
            adjustPricesWithinLevel(_lows, lowRange.At(lowRange.Minimum(start, pInt)), 100, inOrder);
        }
        //delete highRange; delete lowRange;
    }
    //Uses points with extremum on sides
    void MarketStructureManager::getHorizontalHVLVoftrendingMarketV3(double &_highs[],double &_lows[],uint totBars=200,
            uint extremum=20, bool inOrder = true, string mode="HL", PriceRange* pPR = NULL) {
        uint minRequiredBars = totBars;
        if (totBars < minRequiredBars) totBars = minRequiredBars;
        PriceRange* highRange;
        PriceRange* lowRange;
        ArrayResize(_highs, 0);
        ArrayResize(_lows, 0);
        if (mode == "HL") {
            highRange = lastNhighPrices(totBars, 1, false);
            lowRange = lastNlowPrices(totBars, 1, false);
        } else if (mode == "OC") {
            highRange = lastNopenPrices(totBars, 1, false);
            lowRange = lastNclosePrices(totBars, 1, false);
        } else if (mode == "PRICE") {
            highRange = pPR;
            lowRange = pPR;
        }
        totBars = highRange.Total();
        if (totBars < minRequiredBars) return;
        uint leftIndex;
        leftIndex = extremum;
        while (leftIndex <= totBars - extremum - 1) {
            for (; !isLowestExtremum(leftIndex, extremum, lowRange) && leftIndex <= totBars - extremum - 1; leftIndex++);
            if (leftIndex <= totBars - extremum - 1) adjustPricesWithinLevel(_lows, lowRange.At(leftIndex), 100, inOrder);
            leftIndex++;
        }
        
        leftIndex = extremum;
        while (leftIndex <= totBars - extremum - 1) {
            for (; !isHighestExtremum(leftIndex, extremum, highRange) && leftIndex <= totBars - extremum - 1; leftIndex++);
            if (leftIndex <= totBars - extremum - 1) adjustPricesWithinLevel(_highs, highRange.At(leftIndex), 100, inOrder);
            leftIndex++;
        }
        //delete highRange; delete lowRange;
    }
    //Uses the Highest and lowest ranges
    void MarketStructureManager::getHorizontalHVLVoftrendingMarketV4(double &_highs[],double &_lows[],uint totBars=200,
            uint pInt=50, uint minCount=20, bool inOrder = true, string mode="HL", PriceRange* pPR = NULL) {
        uint minRequiredBars = totBars;
        if (totBars < minRequiredBars) totBars = minRequiredBars;
        PriceRange* highRange;
        PriceRange* lowRange;
        ArrayResize(_highs, 0);
        ArrayResize(_lows, 0);
        if (mode == "HL") {
            highRange = lastNhighPrices(totBars, 1, true);
            lowRange = lastNlowPrices(totBars, 1, true);
        } else if (mode == "OC") {
            highRange = lastNopenPrices(totBars, 1, true);
            lowRange = lastNclosePrices(totBars, 1, true);
        } else if (mode == "PRICE") {
            highRange = pPR;
            lowRange = pPR;
        }
        totBars = highRange.Total();
        if (totBars < minRequiredBars) return;
        double upperBuffer[];
        double lowerBuffer[];
        ArrayResize(upperBuffer, totBars);
        ArrayResize(lowerBuffer, totBars);
        for(uint i = 0; i < totBars; i++) {
            upperBuffer[i] = highRange.At(highRange.Maximum(i, pInt));
            lowerBuffer[i] = lowRange.At(lowRange.Minimum(i, pInt));
        }
        getElemWithOccurence(upperBuffer, minCount, _highs, inOrder);
        getElemWithOccurence(lowerBuffer, minCount, _lows, inOrder);
        ArrayReverse(_highs);
        ArrayReverse(_lows);
        //delete highRange; delete lowRange;
    }
    //extremum + extremum
    void MarketStructureManager::getTrendHVLVoftrendingMarket(Dot &pResistance[], Dot &pSupport[], uint extremum1 = 10,
            uint extremum2 = 10, string mode = "HL", PriceRange* pPR = NULL) {
        uint minRequiredBars = 2 * (extremum1 + extremum2);
        uint totBars = minRequiredBars*(extremum1 + extremum2);
        PriceRange* highRange;
        PriceRange* lowRange;
        DateRange* dateRange;
        ArrayResize(pResistance, 2);
        ArrayResize(pSupport, 2);
        if (mode == "HL") {
            highRange = lastNhighPrices(totBars, 1, false);
            lowRange = lastNlowPrices(totBars, 1, false);
        } else if (mode == "OC") {
            highRange = lastNopenPrices(totBars, 1, false);
            lowRange = lastNclosePrices(totBars, 1, false);
        } else if (mode == "PRICE") {
            highRange = pPR;
            lowRange = pPR;
        }
        dateRange = lastNdates(totBars, 1, false);
        totBars = highRange.Total();// - 13;
        if (totBars < minRequiredBars) return;
        //--- Support Right Point
        uint rightIndex = totBars - extremum2 - 1;
        for (; !isLowestExtremum(rightIndex, extremum2, lowRange) && rightIndex > minRequiredBars; rightIndex--);
        pSupport[1].price = lowRange.At(rightIndex);
        pSupport[1].time = dateRange.At(rightIndex);
        //--- Support Left Point
        uint leftIndex = rightIndex - extremum2;
        for (; !isLowestExtremum(leftIndex, extremum1, lowRange) && leftIndex > minRequiredBars; leftIndex--);
        pSupport[0].price = lowRange.At(leftIndex);
        pSupport[0].time =  dateRange.At(leftIndex);
        //--- Resistance Right Point
        rightIndex = totBars - extremum2 - 1;
        for (; !isHighestExtremum(rightIndex, extremum2, highRange) && rightIndex > minRequiredBars; rightIndex--);
        pResistance[1].price = highRange.At(rightIndex);
        pResistance[1].time = dateRange.At(rightIndex);
        //--- Resistance Left Point
        leftIndex = rightIndex - extremum2;
        for (; !isHighestExtremum(leftIndex, extremum1, highRange) && leftIndex > minRequiredBars; leftIndex--);
        pResistance[0].price = highRange.At(leftIndex);
        pResistance[0].time = dateRange.At(leftIndex);
        //delete highRange; delete lowRange; delete dateRange;
    }
    void MarketStructureManager::getTrendHVLVoftrendingMarket(tLine* &pSR[], uint extremum1 = 10,
            uint extremum2 = 10, string pPrefix="default", string mode = "HL", PriceRange* pPR = NULL) {
        Dot lSupport[];
        Dot lResist[];
        getTrendHVLVoftrendingMarket(lResist, lSupport, extremum1, extremum2, mode, pPR);
        if (lResist[0].isOkay() && lResist[1].isOkay()) {
            delete pSR[0];
            pSR[0] = new tLine(pPrefix+"Resistance", lResist[0].time, lResist[0].price, lResist[1].time, lResist[1].price);
            pSR[0].RayRight(true);
            pSR[0].Color(clrRed);
            pSR[0].Width(1);
        }
        if (lSupport[0].isOkay() && lSupport[1].isOkay()) {
            delete pSR[1];
            pSR[1] = new tLine(pPrefix+"Support", lSupport[0].time, lSupport[0].price, lSupport[1].time, lSupport[1].price);
            pSR[1].RayRight(true);
            pSR[1].Color(clrBlue);
            pSR[1].Width(1);
        }
    }
    //Extremum + delta
    void MarketStructureManager::getTrendHVLVoftrendingMarketV2(Dot &pResistance[], Dot &pSupport[], uint extremum1 = 10,
            uint extremum2 = 9, int pShift = 1, string mode = "HL", PriceRange* pPR = NULL) {
        uint minRequiredBars = 2 * (extremum1 + extremum2);
        uint totBars = minRequiredBars*(extremum1 + extremum2);
        PriceRange* highRange;
        PriceRange* lowRange;
        DateRange* dateRange;
        ArrayResize(pResistance, 2);
        ArrayResize(pSupport, 2);
        if (mode == "HL") {
            highRange = lastNhighPrices(totBars, pShift, false);
            lowRange = lastNlowPrices(totBars, pShift, false);
        } else if (mode == "OC") {
            highRange = lastNopenPrices(totBars, pShift, false);
            lowRange = lastNclosePrices(totBars, pShift, false);
        } else if (mode == "PRICE") {
            highRange = pPR;
            lowRange = pPR;
        }
        dateRange = lastNdates(totBars, pShift, false);
        totBars = highRange.Total();
        if (totBars < minRequiredBars) return;
        //--- Support Left Point
        uint leftIndex = totBars - extremum1 - 1;
        for (; !isLowestExtremum(leftIndex, extremum1, lowRange) && leftIndex > minRequiredBars; leftIndex--);
        pSupport[0].price = lowRange.At(leftIndex);
        pSupport[0].time =  dateRange.At(leftIndex);
        //--- Support Right Point
        uint rightIndex = totBars - extremum2 - 1;
        double delta = getSlope(lowRange.At(rightIndex) - lowRange.At(leftIndex), rightIndex - leftIndex);
        double tmpDelta;
        //leftIndex += 1;
        for (uint tmpIndex = rightIndex - 1; tmpIndex > leftIndex; tmpIndex--) {
           tmpDelta = (lowRange.At(tmpIndex) - pSupport[0].price) / (tmpIndex - leftIndex);
           if ( tmpDelta < delta ) {
              delta = tmpDelta;
              rightIndex = tmpIndex;
           }
        }
        pSupport[1].price = lowRange.At(rightIndex);
        pSupport[1].time = dateRange.At(rightIndex);

        //--- Resistance Left Point
        leftIndex = totBars - extremum1 - 1;
        for (; !isHighestExtremum(leftIndex, extremum1, highRange) && leftIndex > minRequiredBars; leftIndex--);
        pResistance[0].price = highRange.At(leftIndex);
        pResistance[0].time = dateRange.At(leftIndex);
        //--- Resistance Right Point
        rightIndex = totBars - extremum2 - 1;
        delta = getSlope(highRange.At(leftIndex) - highRange.At(rightIndex), rightIndex - leftIndex);
        //leftIndex += 1;
        for (uint tmpIndex = rightIndex - 1; tmpIndex > leftIndex; tmpIndex--) {
           tmpDelta = (pResistance[0].price - highRange.At(tmpIndex)) / (tmpIndex - leftIndex);
           if ( tmpDelta < delta ) {
              delta = tmpDelta;
              rightIndex = tmpIndex;
           }
        }
        pResistance[1].price = highRange.At(rightIndex);
        pResistance[1].time = dateRange.At(rightIndex);
        //delete highRange; delete lowRange; delete dateRange;
    }
    void MarketStructureManager::getTrendHVLVoftrendingMarketV2(tLine* &pSR[], uint extremum1 = 10,
            uint extremum2 = 9, int pShift = 1, string pPrefix="default", string mode = "HL", PriceRange* pPR = NULL) {
        Dot lSupport[];
        Dot lResist[];
        getTrendHVLVoftrendingMarketV2(lResist, lSupport, extremum1, extremum2, pShift, mode, pPR);
        if (lResist[0].isOkay() && lResist[1].isOkay()) {
            delete pSR[0];
            pSR[0] = new tLine(pPrefix+"Resistance", lResist[0].time, lResist[0].price, lResist[1].time, lResist[1].price);
            pSR[0].RayRight(true);
            pSR[0].Color(clrRed);
            pSR[0].Width(3);
        }
        if (lSupport[0].isOkay() && lSupport[1].isOkay()) {
            delete pSR[1];
            pSR[1] = new tLine(pPrefix+"Support", lSupport[0].time, lSupport[0].price, lSupport[1].time, lSupport[1].price);
            pSR[1].RayRight(true);
            pSR[1].Color(clrBlue);
            pSR[1].Width(3);
        }
    }
    void MarketStructureManager::getChartPatternTriangular(DotRange* _startD, DotRange* _endD, int _minLine = 2, int _maxLine = 17,
            int totBars = 200, int _lineDiff = 2, string mode = "HL", PriceRange* pPR = NULL, int _lineDist = 2) {
        PriceRange* highRange;
        PriceRange* lowRange;
        DateRange* dateRange;
        if (mode == "HL") {
            highRange = lastNhighPrices(totBars, 1, false);
            lowRange = lastNlowPrices(totBars, 1, false);
        } else if (mode == "OC") {
            highRange = lastNopenPrices(totBars, 1, false);
            lowRange = lastNclosePrices(totBars, 1, false);
        } else if (mode == "PRICE") {
            highRange = pPR;
            lowRange = pPR;
        }
        dateRange = lastNdates(totBars, 1, false);
        totBars = highRange.Total();
        
        DotRange* sH = new DotRange(highRange, dateRange).swingHighs();
        DotRange* sL = new DotRange(lowRange, dateRange).swingLows();
        
        DotRange* startMax = new DotRange();
        DotRange* endMax = new DotRange();
        sH.allSlopes(startMax, endMax, _minLine, _maxLine, "DOWN");
        
        DotRange* startMin = new DotRange();
        DotRange* endMin = new DotRange();
        sL.allSlopes(startMin, endMin, _minLine, _maxLine, "UP");
        
        int force_start = 0;
        for (int x = 0; x < startMax.Total(); x++) {
            for (int y = 0; y < startMin.Total(); y++) {
                if (startMax.countRange.At(x) < force_start && force_start > startMin.countRange.At(y)) break;
                if (MathAbs(startMax.countRange.At(x)-startMin.countRange.At(y)) <= _lineDiff &&
                    MathAbs(endMax.countRange.At(x)-endMin.countRange.At(y)) < _lineDiff &&
                    (MathAbs(startMax.countRange.At(x) > force_start+_lineDist) && (force_start+_lineDist < startMin.countRange.At(y)))
                ) {
                    _startD.addWithCount(startMax.At(x), startMax.countRange.At(x));
                    _startD.addWithCount(endMax.At(x), endMax.countRange.At(x));
                    _endD.addWithCount(startMin.At(y), startMin.countRange.At(y));
                    _endD.addWithCount(endMin.At(y), endMin.countRange.At(y));
                    force_start = startMax.countRange.At(x);
                }
            }
        }
        delete highRange; delete lowRange; delete dateRange;
    }
    DotRange* MarketStructureManager::getChartWave2(int totBars = 200, uint pLevel = 3, int pPickMode = 2, uint pMaxUnturn = 0, string mode = "HL", DotRange* pPR = NULL) {
        PriceRange* highRange;
        PriceRange* lowRange;
        DateRange* dateRange;
        if (mode == "HL") {
            highRange = lastNhighPrices(totBars, 1, false);
            lowRange = lastNlowPrices(totBars, 1, false);
            dateRange = lastNdates(totBars, 1, false);
        } else if (mode == "OC") {
            highRange = lastNopenPrices(totBars, 1, false);
            lowRange = lastNclosePrices(totBars, 1, false);
            dateRange = lastNdates(totBars, 1, false);
        } else if (mode == "PRICE") {
            highRange = pPR.priceRange;
            lowRange = pPR.priceRange;
            dateRange = pPR.dateRange;
        }
        
        DotRange* sH = new DotRange(highRange, dateRange);
        DotRange* sL = new DotRange(lowRange, dateRange);
        for (uint i = 0; i < pLevel; i++) {
            sH = sH.swingHighs();
            sL = sL.swingLows();
        }
        
        //drawSymbolsDotRange(sH, OBJ_ARROW_SELL, "sdfsds");
        //drawSymbolsDotRange(sL, OBJ_ARROW_BUY, "fgewf");
        
        return dotRangesToWave(sH, sL, pPickMode, pMaxUnturn);
    }
    void MarketStructureManager::getChartWave(DotRange* HighMapBuffer, DotRange* LowMapBuffer, DotRange* ZigZagBuffer, int totBars = 200,
            int inpDepth = 12, int inpDeviation = 5, int inpBackstep = 3, string mode = "HL", DotRange* pPR = NULL) {
        int minRequiredBars = 3 * inpDepth;
        if (totBars < minRequiredBars) return;
        PriceRange* highRange;
        PriceRange* lowRange;
        DateRange* dateRange;
        if (mode == "HL") {
            highRange = lastNhighPrices(totBars, 1, false);
            lowRange = lastNlowPrices(totBars, 1, false);
            dateRange = lastNdates(totBars, 1, false);
        } else if (mode == "OC") {
            highRange = lastNopenPrices(totBars, 1, false);
            lowRange = lastNclosePrices(totBars, 1, false);
            dateRange = lastNdates(totBars, 1, false);
        } else if (mode == "PRICE") {
            highRange = pPR.priceRange;
            lowRange = pPR.priceRange;
            dateRange = pPR.dateRange;
        }
        totBars = highRange.Total();
        if (totBars < minRequiredBars) return;
        
        int    start=0,extreme_search=Extremum;
        int    shift=0,back=0,last_high_pos=0,last_low_pos=0;
        Dot* res = NULL;
        double val=0,curlow=0,curhigh=0,last_high=0,last_low=0;
        for(shift=start; shift<totBars; shift++) {
            //--- low
            val=lowRange.At(newLowest(lowRange,inpDepth,shift));
            if(val==last_low) val=0.0;
            else {
                last_low=val;
                if ((lowRange.At(shift)-val) > inpDeviation*_Point) val=0.0;
                else {
                    for(back=1; back <= inpBackstep; back++) {
                       res = LowMapBuffer[shift-back];
                       if((res!=NULL) && (res.price>val)) LowMapBuffer.UpdateAdd(shift-back, NULL);
                    }
                }
            }
            if(lowRange.At(shift)==val) LowMapBuffer.UpdateAdd(shift, new Dot(val, dateRange.At(shift)));
            else LowMapBuffer.UpdateAdd(shift, NULL);
            //--- high
            val=highRange.At(newHighest(highRange,inpDepth,shift));
            if(val==last_high) val=0.0;
            else {
                last_high=val;
                if((val-highRange.At(shift))>inpDeviation*_Point) val=0.0;
                else {
                    for(back=1; back<=inpBackstep; back++) {
                       res=HighMapBuffer[shift-back];
                       if((res!=NULL) && (res.price<val)) HighMapBuffer.UpdateAdd(shift-back, NULL);
                    }
                }
            }
            if(highRange.At(shift)==val) HighMapBuffer.UpdateAdd(shift, new Dot(val, dateRange.At(shift)));
            else HighMapBuffer.UpdateAdd(shift, NULL);
        }
        //--- set last values
        if(extreme_search==0) { // undefined values
            last_low=0.0;
            last_high=0.0;
        } else {
            last_low=curlow;
            last_high=curhigh;
        }
        //--- final selection of extreme points for ZigZag
        for(shift=start; shift<totBars; shift++) {
            switch(extreme_search) {
                case Extremum:
                    if(last_low==0.0 && last_high==0.0) {
                        if(HighMapBuffer[shift]!=NULL) {
                            last_high=highRange.At(shift);
                            last_high_pos=shift;
                            extreme_search=Bottom;
                            ZigZagBuffer.UpdateAdd(shift, new Dot(last_high, dateRange.At(shift)));
                            res=new Dot;
                        }
                        if(LowMapBuffer[shift]!=NULL) {
                            last_low=lowRange.At(shift);
                            last_low_pos=shift;
                            extreme_search=Peak;
                            ZigZagBuffer.UpdateAdd(shift, new Dot(last_low, dateRange.At(shift)));
                            res=new Dot;
                        }
                    }
                    break;
                case Peak:
                    if(LowMapBuffer[shift]!=NULL && LowMapBuffer[shift].price<last_low && HighMapBuffer[shift]==NULL) {
                        ZigZagBuffer.UpdateAdd(last_low_pos, NULL);
                        last_low_pos=shift;
                        last_low=LowMapBuffer[shift].price;
                        ZigZagBuffer.UpdateAdd(shift, new Dot(last_low, dateRange.At(shift)));
                        res=new Dot;
                    }
                    if(HighMapBuffer[shift]!=NULL && LowMapBuffer[shift]==NULL) {
                        last_high=HighMapBuffer[shift].price;
                        last_high_pos=shift;
                        ZigZagBuffer.UpdateAdd(shift, new Dot(last_high, dateRange.At(shift)));
                        extreme_search=Bottom;
                        res=new Dot;
                    }
                    break;
                case Bottom:
                    if(HighMapBuffer[shift]!=NULL && HighMapBuffer[shift].price>last_high && LowMapBuffer[shift]==NULL) {
                        ZigZagBuffer.UpdateAdd(last_high_pos, NULL);
                        last_high_pos=shift;
                        last_high=HighMapBuffer[shift].price;
                        ZigZagBuffer.UpdateAdd(shift, new Dot(last_high, dateRange.At(shift)));
                    }
                    if(LowMapBuffer[shift]!=NULL && HighMapBuffer[shift]==NULL) {
                        last_low=LowMapBuffer[shift].price;
                        last_low_pos=shift;
                        ZigZagBuffer.UpdateAdd(shift, new Dot(last_low, dateRange.At(shift)));
                        extreme_search=Peak;
                    }
                    break;
            }
        }
        //delete highRange; delete lowRange; delete dateRange;
    }
    DotRange* MarketStructureManager::getChartWave(int totBars = 200, int inpDepth = 12, int inpDeviation = 5, int inpBackstep = 3,
            string mode = "HL", DotRange* pPR = NULL) { 
        DotRange* _HHighBuffer = new DotRange;
        DotRange* _LLowBuffer = new DotRange;
        DotRange* _ZZBuffer = new DotRange;
        getChartWave(_HHighBuffer, _LLowBuffer, _ZZBuffer, totBars, inpDepth, inpDeviation, inpBackstep, mode, pPR);
        delete _HHighBuffer; delete _LLowBuffer;
        _ZZBuffer.removeNULL();
        return _ZZBuffer;
    }
    DotRange* MarketStructureManager::getChartWave(DotRange* _high, DotRange* _low, int totBars = 200, int inpDepth = 12, int inpDeviation = 5, int inpBackstep = 3,
            string mode = "HL", DotRange* pPR = NULL) {
        DotRange* _ZZBuffer = new DotRange;
        _high.clearAll();
        _low.clearAll();
        getChartWave(_high, _low, _ZZBuffer, totBars, inpDepth, inpDeviation, inpBackstep, mode, pPR);
        _ZZBuffer.removeNULL();
        _high.removeNULL();
        _low.removeNULL();
        return _ZZBuffer;
    }
    void MarketStructureManager::getChartLine(DotRange* _high, DotRange* _low, int totBars = 200, int inpDepth = 12, int inpDeviation = 5, int inpBackstep = 3,
            string mode = "HL", DotRange* pPR = NULL) {
        DotRange* _ZZBuffer = new DotRange;
        getChartWave(_high, _low, _ZZBuffer, totBars, inpDepth, inpDeviation, inpBackstep, mode, pPR);
        _ZZBuffer.removeNULL();
        _ZZBuffer.separateWave(_high, _low);
        delete _ZZBuffer;
    }
    DotRange* MarketStructureManager::getChartLineTop(int totBars = 200, int inpDepth = 12, int inpDeviation = 5, int inpBackstep = 3,
            string mode = "HL", DotRange* pPR = NULL) {
        DotRange* _high = new DotRange;
        DotRange* _low = new DotRange;
        DotRange* _ZZBuffer = new DotRange;
        getChartWave(_high, _low, _ZZBuffer, totBars, inpDepth, inpDeviation, inpBackstep, mode, pPR);
        _ZZBuffer.removeNULL();
        _ZZBuffer.separateWave(_high, _low);
        delete _ZZBuffer;
        return _high;
    }
    DotRange* MarketStructureManager::getChartLineLow(int totBars = 200, int inpDepth = 12, int inpDeviation = 5, int inpBackstep = 3,
            string mode = "HL", DotRange* pPR = NULL) {
        DotRange* _high = new DotRange;
        DotRange* _low = new DotRange;
        DotRange* _ZZBuffer = new DotRange;
        getChartWave(_high, _low, _ZZBuffer, totBars, inpDepth, inpDeviation, inpBackstep, mode, pPR);
        _ZZBuffer.removeNULL();
        _ZZBuffer.separateWave(_high, _low);
        delete _ZZBuffer;
        return _low;
    }
    ENUM_TREND_TYPE isTrendingMarket(double& hHigh[], double& lLow[]) {
        if (ArraySize(hHigh) <= 0 || ArraySize(lLow) <=0) return false;
        int hScore = 0;
        int lScore = 0;
        for (int i = 1; i < ArraySize(hHigh); i++) {
            if (hHigh[i-1] < hHigh[i]) hScore++;
            else if (hHigh[i-1] > hHigh[i]) hScore--;
        }
        for (int i = 1; i < ArraySize(lLow); i++) {
            if (lLow[i-1] < lLow[i]) lScore++;
            if (lLow[i-1] > lLow[i]) lScore--;
        }
        double phL, plS;
        if (ArraySize(hHigh) == 1) phL = 0;
        else phL = ((double)hScore/(ArraySize(hHigh)-1))*100;
        if (ArraySize(lLow) == 1) plS = 0;
        else plS = ((double)lScore/(ArraySize(lLow)-1))*100;
        if ((phL >= 50 && plS >= 0) || (plS >= 50 && phL >= 0)) {
            return TREND_TYPE_UP;
        } else if ((phL <= -50 && plS <= 0) || (plS <= -50 && phL <= 0)) {
            return TREND_TYPE_DOWN;
        } else return TREND_TYPE_NOTREND;
    }
    ENUM_TREND_TYPE isTrendingMarket(Dot &hHigh[], Dot &lLow[]) {
        bool ret = false;
        int hScore = 0;
        int lScore = 0;
        uint hPip = pricesTOpoint(hHigh[0].price, hHigh[1].price);
        uint lPip = pricesTOpoint(lLow[0].price, lLow[1].price);
        if (hHigh[1].price > hHigh[0].price && hPip >= 100) hScore++;
        else if (hHigh[1].price < hHigh[0].price && hPip >= 100) hScore--;
        if (lLow[1].price > lLow[0].price && lPip >= 100) hScore++;
        else if (lLow[1].price < lLow[0].price && lPip >= 100) hScore--;
        if (hScore == 1 && lScore == 1) {
            return TREND_TYPE_UP;
        } else if (hScore == -1 && lScore == -1) {
            return TREND_TYPE_DOWN;
        } else return TREND_TYPE_NOTREND;
    }
    //Indicator-based trending market. Used like MACD indicator
    ENUM_TREND_TYPE isTrendingMarketFrom2PriceCrossover(double _turnPoint, double _fastPrice, double _slowPrice) {
        if (MathAbs(_fastPrice) > _turnPoint) { //Market is trending
            if (_fastPrice < 0 && _slowPrice > _fastPrice) {
                return TREND_TYPE_DOWN;
            } else if (_fastPrice > 0 && _slowPrice < _fastPrice) {
                return TREND_TYPE_UP;
            }
        }
        return TREND_TYPE_NOTREND;
    }
    //Used like two moving averages
    ENUM_TREND_TYPE isTrendingMarketFrom2PriceCrossoverV2(double _minDist, double _fastPrice, double _slowPrice) {
        if (pricesTOpoint(_fastPrice, _slowPrice) > _minDist) { //Market is trending
            if (_slowPrice > _fastPrice) {
                return TREND_TYPE_DOWN;
            } else if (_slowPrice < _fastPrice) {
                return TREND_TYPE_UP;
            }
        }
        return TREND_TYPE_NOTREND;
    }
};

//ORDER
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
                if (VERBOSE) Print("Error: Basic structure not complete");
                delete orderManager;
                return ACTION_ERROR;
            }
            ENUM_CHECK_RETCODE checkCode = CheckReturnCode(orderManager.ResultRetcode());
            if(checkCode == CHECK_RETCODE_ERROR) {
                if (VERBOSE) Print("Fatal Error occurred");
                delete orderManager;
                return(ACTION_ERROR);
            } else if(checkCode == CHECK_RETCODE_OK) {
                delete orderManager;
                return(ACTION_DONE);
            } else if (checkCode == CHECK_RETCODE_RETRY) {
                if (VERBOSE) Print("Server error detected, retrying...");
                Sleep(RETRY_DELAY);
                retryCount++;
            } else {
                if (VERBOSE) Print("Unknown Check return code");
                delete orderManager;
                return(ACTION_UNKNOWN);
            }  
        } while (retryCount < MAX_RETRIES);
        if(retryCount >= MAX_RETRIES) {
            //string errDesc = TradeServerReturnCodeDescription(result.retcode);
            //Alert("Max retries exceeded: Error ",result.retcode," - ",errDesc);
            if (VERBOSE) Print("Max retries exceeded");
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
        if (getSLTP(SLTP_prices, orderDir, newPrice, pSL, pTP, keepZero) == ACTION_ERROR) return ACTION_ERROR;
        if (keepSLTP) {
            if (SLTP_prices[0] == 0) SLTP_prices[0] = StopLoss();
            if (SLTP_prices[1] == 0) SLTP_prices[1] = TakeProfit();
        }
        OrderManager* orderManager = new OrderManager(NULL);
        ulong ticket = Ticket();
        int retryCount = 0;
        do {
            if (!orderManager.OrderModify(ticket, newPrice, SLTP_prices[0], SLTP_prices[1], pTypeTime, pOrderExpTime, pStopPrice)) {
                if (VERBOSE) Print("Error: Basic structure not complete");
                return ACTION_ERROR;
            }
            ENUM_CHECK_RETCODE checkCode = CheckReturnCode(orderManager.ResultRetcode());
            if(checkCode == CHECK_RETCODE_ERROR) {
                if (VERBOSE) Print("Fatal Error occurred");
                return(ACTION_ERROR);
            } else if(checkCode == CHECK_RETCODE_OK) {
                return(ACTION_DONE);
            } else if (checkCode == CHECK_RETCODE_RETRY) {
                if (VERBOSE) Print("Server error detected, retrying...");
                Sleep(RETRY_DELAY);
                retryCount++;
            } else {
                if (VERBOSE) Print("Unknown Check return code");
                return(ACTION_UNKNOWN);
            }  
        } while (retryCount < MAX_RETRIES);
        if(retryCount >= MAX_RETRIES) {
            //string errDesc = TradeServerReturnCodeDescription(result.retcode);
            //Alert("Max retries exceeded: Error ",result.retcode," - ",errDesc);
            if (VERBOSE) Print("Max retries exceeded");
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
    ENUM_ACTION_RETCODE OrderManager::deleteOrder(ulong ticket, double pPrice = 0, double pVol = 0,
            double pSL = 0, double pTP = 0) {
        Order *order = getOwnOrder(ticket);
        ENUM_ACTION_RETCODE retCode = ACTION_DONE;
        if (order != NULL) {
            bool deleteIt = true;
            if (pPrice && pPrice == order.PriceOpen()) deleteIt = false;
            if (pVol && pVol == order.VolumeCurrent()) deleteIt = false;
            if (pSL && pSL == order.StopLoss()) deleteIt = false;
            if (pTP && pTP == order.TakeProfit()) deleteIt = false;
            if (deleteIt) retCode = order.deleteOrder();
            //delete order;
        } //else retCode = ACTION_ERROR; //The order doesn't exist, maybe deleted or wrong or has executed
        return retCode;
    }
    bool OrderManager::deleteOrderBool(ulong ticket, double pPrice = 0, uint minPoint = 0) {//, double pVol = 0, double pSL = 0, double pTP = 0) {
        Order *order = getOwnOrder(ticket);
        if (order != NULL) {
            ENUM_ACTION_RETCODE retCode = ACTION_ERROR;
            bool deleteIt = true;
            if (pPrice && pricesTOpoint(NormalizeDouble(pPrice, _Digits), order.PriceOpen()) <= minPoint) deleteIt = false;
            //if (pVol && pVol == order.VolumeCurrent()) deleteIt = false;
            //if (pSL && NormalizeDouble(pSL, _Digits) == order.StopLoss()) deleteIt = false;
            //if (pTP && NormalizeDouble(pTP, _Digits) == order.TakeProfit()) deleteIt = false;
            if (deleteIt) retCode = order.deleteOrder();
            //delete order;
            if (retCode == ACTION_DONE) return true;
            return false;
        } //else retCode = ACTION_ERROR; //The order doesn't exist, maybe deleted or wrong or has executed
        return true;
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
        if (USE_DAILY_TRADING_PERIOD) {
            if (!isWithinDailyTimeRange(DAILY_START_HOUR, DAILY_START_MINUTE, DAILY_END_HOUR, DAILY_END_MINUTE, WEEKLY_START_DAY, WEEKLY_END_DAY))
                return ACTION_DONE;
        }
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
            if (getSLTP(SLTP_prices, mapOrderTypeTOpositionType(pType), pPrice, pSL, pTP, keepZero) == ACTION_ERROR) return ACTION_ERROR; 
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
                if (VERBOSE) Print("Request structure not complete");
                return ACTION_ERROR;
            }
            checkCode = CheckReturnCode(ResultRetcode());
            if(checkCode == CHECK_RETCODE_ERROR) {
                if (VERBOSE) Print("Fatal Error occurred");
                return(ACTION_ERROR);
            } else if(checkCode == CHECK_RETCODE_OK) {
                return(ACTION_DONE);
            } else if (checkCode == CHECK_RETCODE_RETRY) {
                if (VERBOSE) Print("Server error detected, retrying...");
                Sleep(RETRY_DELAY);
                retryCount++;
            } else {
                if (VERBOSE) Print("Unknown Check return code");
                return(ACTION_UNKNOWN);
            }  
        } while (retryCount < MAX_RETRIES);
        if(retryCount >= MAX_RETRIES) {
            //string errDesc = TradeServerReturnCodeDescription(result.retcode);
            //Alert("Max retries exceeded: Error ",result.retcode," - ",errDesc);
            if (VERBOSE) Print("Max retries exceeded");
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
        return createOrder(pType, pPrice, pVolume, SLTPpoints[0], SLTPpoints[1], keepZero,
            keepSLTP, pStopPrice, pTypeTime, pOrderExpTime, pComment);
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
            //delete order;
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
            //delete order;
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
            //delete order;
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
    bool OrderManager::isOwnOrderPending(ulong ticket) {
        Order *order = getOwnOrder(ticket);
        if (order != NULL) {
            //delete order;
            return true;
        } else return false;
    }
    bool OrderManager::isOwnOrderPendingV2(ulong ticket) {
        ulong pend[];
        copyOwnPendingTickets(pend);
        for (int i=0; i < ArraySize(pend); i++) {
            if (ticket == pend[i]) return true;
        }
        return false;
    }
    bool OrderManager::isOwnOrderPendingV3(ulong ticket) {
        ulong pend[];
        copyOwnHistoryTickets(pend);
        for (int i=0; i < ArraySize(pend); i++) {
            if (ticket == pend[i]) return false;
        }
        return true;
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
        for (int i = 0; i < totalDeals(); i++) {
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
    int OrderManager::totalDeals(void) {
        HistorySelect(0, TimeCurrent());
        return HistoryDealsTotal();
    }
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
        //delete order;
        return ticket;
    }
    ulong OrderManager::getOwnTicketFromHistoryPool(int i, ENUM_ORDER_TYPE pType = NULL) {
        ulong ticket = HistoryOrderGetTicket(i);
        OrderEx *order = getOwnExOrder(ticket, pType);
        if (order == NULL) ticket = WRONG_VALUE;
        //delete order;
        return ticket;
    }
    ulong OrderManager::getOwnTicketFromDealPool(int i) {
        ulong ticket = HistoryDealGetTicket(i);
        Deal *deal = getOwnDeal(ticket);
        if (deal == NULL) ticket = WRONG_VALUE;
        //else delete deal;
        return ticket;
    }
    ulong OrderManager::getTicketFromOrderPool(int i, ENUM_ORDER_TYPE pType = NULL) {
        ulong ticket = OrderGetTicket(i);
        Order *order = getOrder(ticket, pType);
        if (order == NULL) ticket = WRONG_VALUE;
        //delete order;
        return ticket;
    }
    ulong OrderManager::getTicketFromHistoryPool(int i, ENUM_ORDER_TYPE pType = NULL) {
        ulong ticket = HistoryOrderGetTicket(i);
        OrderEx *order = getExOrder(ticket, pType);
        if (order == NULL) ticket = WRONG_VALUE;
        //delete order;
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
        for (int i = 0; i < totalDeals(); i++) {
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
        for (int i = 0; i < totalDeals(); i++) {
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
    bool OrderManager::hasNumofExecutedOrdersChanged() {
        static int lastNumOfOrders = WRONG_VALUE;
        int currentNumOfOrders = totalOwnExOrders();
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
    bool OrderManager::hasNumofExecutedOrdersChangedV2(int& numDifference) {
        static int lastNumOfOrders = WRONG_VALUE;
        int currentNumOfOrders = totalOwnExOrders();
        if (lastNumOfOrders == WRONG_VALUE) {
            lastNumOfOrders = 0;
            return hasNumofExecutedOrdersChangedV2(numDifference);
        }
        if (lastNumOfOrders != currentNumOfOrders) {
            numDifference = currentNumOfOrders - lastNumOfOrders;
            lastNumOfOrders = currentNumOfOrders;
            return true;
        }
        numDifference = 0;
        return false;
    }
    bool OrderManager::isOrderTypeInOwn(ENUM_ORDER_TYPE oType) {
        ulong ticket[];
        copyOwnPendingTickets(ticket, oType);
        if (ArraySize(ticket) == 0) return false;
        return true;
    }
    bool OrderManager::getTradeResultsArray(int _max_trades, datetime _begin_date, DotRange* _profits) {
        if (_max_trades < 2) return false;
        if (HistorySelect(_begin_date, TimeCurrent()) != true) return false;
        _profits.clearAll();
        int count = totalOwnDeals();
        if (count < _max_trades) return false;
        ulong pTickets[];
        copyOwnDealTickets(pTickets);
        Deal* deal;
        //use max_trades to limit total received history
        int counter = 0;
        for (int index = count -1; index >= 0; index--) { //count
            if (counter >= _max_trades) break;
            deal = new Deal(pTickets[index]);
            if (deal.Entry() != DEAL_ENTRY_OUT) continue;
            if (deal.Type() != DEAL_TYPE_BUY && deal.Type() != DEAL_TYPE_SELL) continue;
            if (deal.Time() < _begin_date) continue;
            _profits.addWithCount(new Dot(deal.Profit(), deal.Time()));
            counter++;
            delete deal;
        }
        return true;
    }
};


//POSITION
class Position : public CPositionInfo {
    protected:
    MqlTradeRequest request;
    MqlTradeResult result;
    OrderManager* oMan;
    MoneyManager* mMan;
    ENUM_ACTION_RETCODE Position::checkScaleOut(ENUM_POSITION_TYPE pDir, double pSL, double pTP,
            bool toClear=false) {
        if (toClear) {
            if (pSL <= 0) {
                if (SLticket != WRONG_VALUE && oMan.deleteOrder(SLticket) == ACTION_ERROR) {
                    if (VERBOSE) Print("Could'nt delete SL order");
                    return ACTION_ERROR;
                }
                SLticket = WRONG_VALUE;
                request.sl = 0;
            } else {
                if (SLticket == WRONG_VALUE) request.sl = pSL;
            }
            if (pTP <= 0) {
                if (TPticket != WRONG_VALUE && oMan.deleteOrder(TPticket) == ACTION_ERROR) {
                    if (VERBOSE) Print("Could'nt delete TP order");
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
                    if (VERBOSE) Print("Could'nt delete SL order");
                    return ACTION_ERROR;
                }
                SLticket = WRONG_VALUE;
            } else {
                if (pSL != scaleStopLoss() || (pSL == scaleStopLoss() && SLticket == WRONG_VALUE)) {
                    if (SLticket != WRONG_VALUE && oMan.deleteOrder(SLticket) == ACTION_ERROR) {
                        if (VERBOSE) Print("Could'nt delete SL order");
                        return ACTION_ERROR;
                    }
                    SLticket = WRONG_VALUE;
                    ENUM_ACTION_RETCODE placeOrder;
                    if (pDir == POSITION_TYPE_BUY) placeOrder = oMan.sellStop(pSL, Volume()*AUTO_SCALEOUT_MULTIPLIER, 0, 0, true, true);
                    else placeOrder = oMan.buyStop(pSL, Volume()*AUTO_SCALEOUT_MULTIPLIER, 0, 0, true, true);
                    if (placeOrder == ACTION_ERROR) {
                        if (VERBOSE) Print("Could'nt make SL order");
                        return ACTION_ERROR;
                    }
                    SLticket = oMan.ResultOrder();
                }
            }
            request.sl = 0;
            if (AUTO_SCALEOUT_INCLUDE_TP) {
                if (pTP <= 0) {
                    if (TPticket != WRONG_VALUE && oMan.deleteOrder(TPticket) == ACTION_ERROR) {
                        if (VERBOSE) Print("Could'nt delete TP order");
                        return ACTION_ERROR;
                    }
                    TPticket = WRONG_VALUE;
                } else {
                    if (pTP != scaleTakeProfit() || (pTP == scaleTakeProfit() && TPticket == WRONG_VALUE)) {
                        if (TPticket != WRONG_VALUE && oMan.deleteOrder(TPticket) == ACTION_ERROR) {
                            if (VERBOSE) Print("Could'nt delete TP order");
                            return ACTION_ERROR;
                        }
                        TPticket = WRONG_VALUE;
                        ENUM_ACTION_RETCODE placeOrder;
                        if (pDir == POSITION_TYPE_BUY) placeOrder = oMan.sellLimit(pTP, Volume()*AUTO_SCALEOUT_MULTIPLIER, 0, 0, true, true);
                        else placeOrder = oMan.buyLimit(pTP, Volume()*AUTO_SCALEOUT_MULTIPLIER, 0, 0, true, true);
                        if (placeOrder == ACTION_ERROR) {
                            if (VERBOSE) Print("Could'nt make TP order");
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
                        if (VERBOSE) Print("Could'nt delete TP order");
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
    ENUM_ACTION_RETCODE Position::sendRequest(void){
        int retryCount = 0;
        request.position = Ticket();
        do {
            if (!OrderSend(request,result)) {
                if (VERBOSE) Print("Request Structure not complete");
                return ACTION_ERROR;
            }
            ENUM_CHECK_RETCODE checkCode = CheckReturnCode(result.retcode);
            if(checkCode == CHECK_RETCODE_ERROR) {
                return(ACTION_ERROR);
            } else if(checkCode == CHECK_RETCODE_OK) {
                return(ACTION_DONE);
            } else if (checkCode == CHECK_RETCODE_RETRY) {
                if (VERBOSE) Print("Server error detected, retrying...");
                Sleep(RETRY_DELAY);
                retryCount++;
            } else {
                if (VERBOSE) Print("Unknown Check return code");
                return(ACTION_UNKNOWN);
            }
        } while (retryCount < MAX_RETRIES);
        if(retryCount >= MAX_RETRIES) {
            if (VERBOSE) Print("Max retries exceeded");
            return (ACTION_NOTSENT);
        }
        return(ACTION_UNKNOWN);
    }
    public:
    ulong SLticket;
    ulong TPticket;
    double lastVolume;
    ulong cTicket;
    bool VALID;
        Position(void) {cTicket = 0;}
        Position(string pSymbol) {VALID = Select(pSymbol); cTicket = 0;}
        Position(int pIndex) {VALID = SelectByIndex(pIndex); cTicket = Ticket();}
        Position(string pSymbol, ulong pMagic) {VALID = SelectByMagic(pSymbol, pMagic); cTicket = Ticket();}
        Position(ulong pTicket) {VALID = SelectByTicket(pTicket); cTicket = pTicket;}
    void Position::setSlippage(uint pSlip) {request.deviation = pSlip;}
    void Position::setFillType(ENUM_ORDER_TYPE_FILLING pFill = ORDER_FILLING_FOK) {request.type_filling = pFill;}
    double Position::scaleStopLoss() {
        if (AUTO_SCALEOUT_POSITION && SLticket != WRONG_VALUE) {
            Order *order = oMan.getOwnOrder(SLticket);
            if (order != NULL) {
                double sl = order.PriceOpen();
                //delete order;
                return sl;
            } else {
                //The order doesn't exist, maybe deleted or wrong or has executed
                SLticket = WRONG_VALUE;
            }
        }
        return StopLoss();
    }
    double Position::scaleTakeProfit() {
        if (AUTO_SCALEOUT_POSITION && TPticket != WRONG_VALUE) {
            Order *order = oMan.getOwnOrder(TPticket);
            if (order != NULL) {
                double tp = order.PriceOpen();
                //delete order;
                return tp;
            } else {
                //The order doesn't exist, maybe deleted or wrong or has executed
                TPticket = WRONG_VALUE;
            }
        }
        return TakeProfit();
    }
    ENUM_ACTION_RETCODE Position::setSLTP(double pPrice, uint pStopLoss = 0, uint pTakeProfit = 0, bool keepZero = false,
            bool keepSLTP = true, bool toClear = false){
        if (pStopLoss == 0 && pTakeProfit == 0 && keepZero && keepSLTP && !toClear) return ACTION_DONE;
        if (!positionIsOpen()) return ACTION_DONE;
        ENUM_POSITION_TYPE tradeDir = PositionType();
        request.action = TRADE_ACTION_SLTP;
        request.symbol = _Symbol;
        double SLTP_prices[2] = {0.0, 0.0};
        if (getSLTP(SLTP_prices, tradeDir, pPrice, pStopLoss, pTakeProfit, keepZero) == ACTION_ERROR) return ACTION_ERROR;
        PriceManager priceManager;
        if (tradeDir == POSITION_TYPE_BUY) {
            if (SLTP_prices[0] > 0) {
                double cSL = scaleStopLoss();
                double cBid = priceManager.currentBid();
                if (SLTP_prices[0] >= cBid || (pricesTOpoint(cBid, SLTP_prices[0]) <= getMinStopPoint())) {
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
            //    if (SLTP_prices[1] <= cAsk || (pricesTOpoint(cAsk, SLTP_prices[1]) <= getMinStopPoint())) {
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
                if (SLTP_prices[0] <= cAsk || (pricesTOpoint(cAsk, SLTP_prices[0]) <= getMinStopPoint())) {
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
            //    if (SLTP_prices[1] >= cBid|| (pricesTOpoint(cBid, SLTP_prices[1]) <= getMinStopPoint())) {
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
    ENUM_ACTION_RETCODE Position::openPosition(ENUM_POSITION_TYPE pPosType,
            double pVolume, uint pSL=0, uint pTP=0, bool keepZero=false, bool keepSLTP = true,
            bool toHedge = false, string pComment=NULL){
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
        return openPosition(pPosType, pVolume, newSL, newTP, keepZero, keepSLTP, toHedge, pComment);
    }
    ENUM_ACTION_RETCODE Position::openPosition(ENUM_POSITION_TYPE pPosType,
            double pVolume, double pSL=0.000000, double pTP=0.000000, bool keepZero=false,
            bool keepSLTP = true, bool toHedge = false, string pComment=NULL) {
        if (positionIsOpen()) {
            ENUM_POSITION_TYPE currentPositionType = PositionType();
            if (pPosType == POSITION_TYPE_BUY) {
                if (currentPositionType == POSITION_TYPE_BUY) {
                    if (closePosition(toHedge) == ACTION_ERROR) return ACTION_ERROR;
                    return buyNow(pVolume, pSL, pTP, keepZero, keepSLTP, false, pComment);
                }
                else if (currentPositionType == POSITION_TYPE_SELL) {
                    if (MARGINMODE == ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) return reversePositionHedgeV2(pVolume, pSL, pTP, keepZero, keepSLTP, toHedge);
                    else return reversePositionNettingV2(pVolume, pSL, pTP, keepZero, keepSLTP);
                }
            }
            else if (pPosType == POSITION_TYPE_SELL) {
                if (currentPositionType == POSITION_TYPE_SELL) {
                    if (closePosition(toHedge) == ACTION_ERROR) return ACTION_ERROR;
                    return sellNow(pVolume, pSL, pTP, keepZero, keepSLTP, false, pComment);
                }
                else if (currentPositionType == POSITION_TYPE_BUY) {
                    if (MARGINMODE == ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) return reversePositionHedgeV2(pVolume, pSL, pTP, keepZero, keepSLTP, toHedge);
                    else return reversePositionNettingV2(pVolume, pSL, pTP, keepZero, keepSLTP);
                }
            } 
        } else {
            if (pPosType == POSITION_TYPE_BUY) {
                return buyNow(pVolume, pSL, pTP, keepZero, keepSLTP, false, pComment);
            } else if (pPosType == POSITION_TYPE_SELL){
                return sellNow(pVolume, pSL, pTP, keepZero, keepSLTP, false, pComment);
            }
        }
        return ACTION_UNKNOWN;
    }
    ENUM_ACTION_RETCODE Position::createNow(ENUM_ORDER_TYPE pType, double pVolume,
            int pSL=0, int pTP=0, bool keepZero=false, bool keepSLTP = true, bool toHedge = false, string pComment=NULL) {
        ENUM_TRADE_REQUEST_ACTIONS action = mapOrderTypeTOrequestAction(pType);
        if (USE_DAILY_TRADING_PERIOD) {
            if (!isWithinDailyTimeRange(DAILY_START_HOUR, DAILY_START_MINUTE, DAILY_END_HOUR, DAILY_END_MINUTE, WEEKLY_START_DAY, WEEKLY_END_DAY)) {
                //if (positionIsOpen()) {
                //    if (closeAtTime(createDateTime(DAILY_END_HOUR, DAILY_END_MINUTE)) == ACTION_ERROR) return ACTION_ERROR;
                //}
                return ACTION_DONE;
            }
        }
        PriceManager priceManager;
        double pPrice = pType == ORDER_TYPE_BUY ? priceManager.currentAsk() : priceManager.currentBid();
        double SLTP_prices[2] = {0.0, 0.0};
        int slSave = pSL, tpSave = pTP;
        if (getSLTP(SLTP_prices, mapOrderTypeTOpositionType(pType), pPrice, pSL, pTP, keepZero) == ACTION_ERROR) return ACTION_ERROR;
        pSL = slSave; pTP = tpSave;
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
            request.comment = pComment;
        }
        string orderType = mapOrderTypeTOstring(pType);
        int retryCount = 0;
        do {
            ENUM_CHECK_RETCODE checkCode;
            pPrice = pType == ORDER_TYPE_BUY ? priceManager.currentAsk() : priceManager.currentBid();
            request.price = pPrice;
            if (pComment == "close" && !toHedge) request.position = cTicket;
            else request.position = 0;
            if (TRADE) {
                if (!OrderSend(request, result)) {
                    if (VERBOSE) Print("Request structure not complete");
                    return ACTION_ERROR;
                }
            } else {
                ObjectsDeleteAll(ChartID(), "NoTradeSI");
                //hLine* sLine = new hLine("NoTradeSI", pPrice);
                //sLine.Color(clrGreen);
                arrowLeftPrice* aR = new arrowLeftPrice("NoTradeSI", (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE), pPrice, OBJ_ARROW_LEFT_PRICE);
                result.retcode = TRADE_RETCODE_DONE;
            }
            checkCode = CheckReturnCode(result.retcode);
            if(checkCode == CHECK_RETCODE_ERROR) {
                if (VERBOSE) Print("Fatal Error occurred");
                return(ACTION_ERROR);
            } else if(checkCode == CHECK_RETCODE_OK) {
                //TODO check this
                lastVolume = pVolume;
                cTicket = result.deal;
                if (!keepZero) {
                    if (TRADE) return setSLTP(result.price, pSL, pTP, false);
                    else {
                        ObjectsDeleteAll(ChartID(), "NoTradeSl");
                        ObjectsDeleteAll(ChartID(), "NoTradeTp");
                        hLine* sLine = new hLine("NoTradeSl", SLTP_prices[0]);
                        sLine.Color(clrRed);
                        sLine = new hLine("NoTradeTp", SLTP_prices[1]);
                        sLine.Color(clrBlue);
                        return ACTION_DONE;
                    }
                }
                return(ACTION_DONE);
            } else if (checkCode == CHECK_RETCODE_RETRY) {
                if (VERBOSE) Print("Server error detected, retrying...");
                Sleep(RETRY_DELAY);
                retryCount++;
            } else {
                if (VERBOSE) Print("Unknown Check return code");
                return(ACTION_UNKNOWN);
            }  
        } while (retryCount < MAX_RETRIES);
        if(retryCount >= MAX_RETRIES) {
            //string errDesc = TradeServerReturnCodeDescription(result.retcode);
            //Alert("Max retries exceeded: Error ",result.retcode," - ",errDesc);
            if (VERBOSE) Print("Max retries exceeded");
            return (ACTION_NOTSENT);
        }
        return(ACTION_UNKNOWN);
    }
    ENUM_ACTION_RETCODE Position::createNow(ENUM_ORDER_TYPE pType, double pVolume,
            double pSL=0.000000, double pTP=0.000000, bool keepZero=false,
            bool keepSLTP = true, bool toHedge = false, string pComment=NULL) {
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
        return createNow(pType, pVolume, SLTPpoints[0], SLTPpoints[1], keepZero, keepSLTP, toHedge, pComment);
    }
    bool positionIsOpen(void) { //picks the last opened position
        if (cTicket == 0) return Select(_Symbol);
        else return SelectByTicket(cTicket);
    }
    bool OTTisNewDeal(const MqlTradeTransaction& trans) {return trans.type == TRADE_TRANSACTION_DEAL_ADD;}
    ENUM_ACTION_RETCODE sendSLTPrequest(double sl, double tp) {
        request.symbol = _Symbol;
        request.action = TRADE_ACTION_SLTP;
        request.sl = sl;
        request.tp = tp;
        ENUM_ACTION_RETCODE resAct = sendRequest();
        if (resAct == ACTION_ERROR) {
            if (VERBOSE) Print("Could'nt change SL or TP");
        }
        return resAct;
    }
    ENUM_ACTION_RETCODE Position::closePosition(bool toHedge = true) {
        if (!positionIsOpen()) return ACTION_DONE;
        if (PositionType() == POSITION_TYPE_BUY) return sellNow(Volume(), 0, 0, true, true, toHedge, "close");
        else return buyNow(Volume(), 0, 0, true, true, toHedge, "close");
    }
    ENUM_ACTION_RETCODE Position::closeHedgePositionBy(ulong ticket_by){
        if(MARGINMODE != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) return(false);
        Position* byPos = new Position(ticket_by);
        if(!byPos.VALID)return(false);
        if(Symbol() != byPos.Symbol() || PositionType() == byPos.PositionType()) return(false);
        request.action = TRADE_ACTION_CLOSE_BY;
        request.position = cTicket;
        request.position_by = ticket_by;
        return sendRequest();
    }
    ENUM_ACTION_RETCODE Position::reversePositionHedge(double pMultiplier = 2, double pSL = 0.0, double pTP = 0.0, bool keepZero=false,
            bool keepSLTP = true, bool toHedge = true, string pComment="reverse") {
        if (!positionIsOpen()) return ACTION_DONE;
        double vol = Volume();
        ENUM_POSITION_TYPE pType = PositionType();
        if (closePosition(toHedge) == ACTION_ERROR) return ACTION_ERROR;
        if (pType == POSITION_TYPE_BUY) return sellNow(vol*pMultiplier, pSL, pTP, keepZero, keepSLTP, false, pComment);
        else return buyNow(vol*pMultiplier, pSL, pTP, keepZero, keepSLTP, false, pComment);
    }
    ENUM_ACTION_RETCODE Position::reversePositionHedgeV2(double pVolume = 1, double pSL = 0, double pTP = 0, bool keepZero=false,
            bool keepSLTP = true, bool toHedge = true, string pComment="reverse") {
        if (!positionIsOpen()) return ACTION_DONE;
        ENUM_POSITION_TYPE pType = PositionType();
        if (closePosition(toHedge) == ACTION_ERROR) return ACTION_ERROR;
        if (pType == POSITION_TYPE_BUY) return sellNow(pVolume, pSL, pTP, keepZero, keepSLTP, false, pComment);
        else return buyNow(pVolume, pSL, pTP, keepZero, keepSLTP, false, pComment);
    }
    ENUM_ACTION_RETCODE Position::closePositionPartial(uint percent = 50, bool toHedge = true) {
        if (percent == 0 || percent > 100) return ACTION_ERROR;
        if (!positionIsOpen()) return ACTION_DONE;
        if (PositionType() == POSITION_TYPE_BUY) return sellNow(verifyVolume(Volume()*((double)percent/100)), 0, 0, true, true, toHedge, "close");
        else return buyNow(verifyVolume(Volume()*((double)percent/100)), 0, 0, true, true, toHedge, "close");
    }
    ENUM_ACTION_RETCODE Position::closePositionPartial(double pVolume, bool toHedge = true) {
        if (!positionIsOpen()) return ACTION_DONE;
        if (pVolume <= 0 || pVolume > Volume()) return ACTION_ERROR;
        if (PositionType() == POSITION_TYPE_BUY) return sellNow(verifyVolume(pVolume), 0, 0, true, true, toHedge, "close");
        else return buyNow(verifyVolume(pVolume), 0, 0, true, true, toHedge, "close");
    }
    ENUM_ACTION_RETCODE Position::closePositionOnly(ENUM_POSITION_TYPE pType, bool toHedge = true) {
        if (!positionIsOpen()) return ACTION_DONE;
        if (PositionType() == POSITION_TYPE_BUY && pType == POSITION_TYPE_BUY) return sellNow(Volume(), 0, 0, true, true, toHedge, "close");
        if (PositionType() == POSITION_TYPE_SELL && pType == POSITION_TYPE_SELL) return buyNow(Volume(), 0, 0, true, true, toHedge, "close");
        return ACTION_DONE;
    }
    ENUM_ACTION_RETCODE Position::reversePositionNetting(double pMultiplier = 2, double pSL = 0, double pTP = 0, bool keepZero=false,
            bool keepSLTP = true, string pComment="reverse") {
        if (!positionIsOpen()) return ACTION_DONE;
        double vol = Volume();
        ENUM_POSITION_TYPE pType = PositionType();
        if (pMultiplier < 1 && closePosition(false) == ACTION_ERROR) return ACTION_ERROR;
        if (pType == POSITION_TYPE_BUY) return sellNow(vol*pMultiplier, pSL, pTP, keepZero, keepSLTP, false, pComment);
        else return buyNow(vol*pMultiplier, pSL, pTP, keepZero, keepSLTP, false, pComment);
    }
    ENUM_ACTION_RETCODE Position::reversePositionNettingV2(double pVolume = 1, double pSL = 0, double pTP = 0, bool keepZero=false,
            bool keepSLTP = true, string pComment="reverse") {
        if (!positionIsOpen()) return ACTION_DONE;
        if (pVolume < 0) pVolume = mMan.getVolume();
        if (PositionType() == POSITION_TYPE_BUY) return sellNow(Volume()+pVolume, pSL, pTP, keepZero, keepSLTP, false, pComment);
        else return buyNow(Volume()+pVolume, pSL, pTP, keepZero, keepSLTP, false, pComment);
    }
    ENUM_ACTION_RETCODE Position::buyNow(double pVolume, int pSL=0,
            int pTP=0, bool keepZero=false, bool keepSLTP = true, bool toHedge = false, string pComment=NULL) {
        return createNow(ORDER_TYPE_BUY, pVolume, pSL, pTP, keepZero, keepSLTP, toHedge, pComment);
    }
    ENUM_ACTION_RETCODE Position::buyNow(double pVolume, double pSL=0.000000,
            double pTP=0.000000, bool keepZero=false, bool keepSLTP = true, bool toHedge = false, string pComment=NULL) {
        return createNow(ORDER_TYPE_BUY, pVolume, pSL, pTP, keepZero, keepSLTP, toHedge, pComment);
    }
    ENUM_ACTION_RETCODE Position::sellNow(double pVolume, int pSL=0,
            int pTP=0, bool keepZero=false, bool keepSLTP = true, bool toHedge = false, string pComment=NULL) {
        return createNow(ORDER_TYPE_SELL, pVolume, pSL, pTP, keepZero, keepSLTP, toHedge, pComment);
    }    
    ENUM_ACTION_RETCODE Position::sellNow(double pVolume, double pSL=0.000000,
            double pTP=0.000000, bool keepZero=false, bool keepSLTP = true, bool toHedge = false, string pComment=NULL) {
        return createNow(ORDER_TYPE_SELL, pVolume, pSL, pTP, keepZero, keepSLTP, toHedge, pComment);
    }
    ENUM_ACTION_RETCODE Position::openBuyPosition(double pVolume,
            double pSL=0.000000, double pTP=0.000000, bool keepZero=false,
            bool keepSLTP = true, bool toHedge = false, string pComment=NULL) {
        return openPosition(POSITION_TYPE_BUY, pVolume, pSL, pTP,
            keepZero, keepSLTP, toHedge, pComment);
    }
    ENUM_ACTION_RETCODE Position::openBuyPosition(double pVolume,
            int pSL=0.000000, int pTP=0.000000, ulong pSlippage=0,
            ENUM_ORDER_TYPE_FILLING pFillType = NULL, bool keepZero=false,
            bool keepSLTP = true, bool toHedge = false, string pComment=NULL) {
        return openPosition(POSITION_TYPE_BUY, pVolume, pSL, pTP,
            keepZero, keepSLTP, toHedge, pComment);
    }
    ENUM_ACTION_RETCODE Position::openSellPosition(double pVolume,
            double pSL=0.000000, double pTP=0.000000, ulong pSlippage=0,
            ENUM_ORDER_TYPE_FILLING pFillType = NULL, bool keepZero=false,
            bool keepSLTP = true, bool toHedge = false, string pComment=NULL) {
        return openPosition(POSITION_TYPE_SELL, pVolume, pSL, pTP,
            keepZero, keepSLTP, toHedge, pComment);
    }
    ENUM_ACTION_RETCODE Position::openSellPosition(double pVolume,
            int pSL=0.000000, int  pTP=0.000000, ulong pSlippage=0,
            ENUM_ORDER_TYPE_FILLING pFillType = NULL, bool keepZero=false,
            bool keepSLTP = true, bool toHedge = false, string pComment=NULL) {
        return openPosition(POSITION_TYPE_SELL, pVolume, pSL, pTP,
            keepZero, keepSLTP, toHedge, pComment);
    }
    ENUM_ACTION_RETCODE Position::setSLTP(double pPrice, double pStopLoss = 0.0, double pTakeProfit = 0.0, bool keepZero = false,
            bool keepSLTP = true, bool toClear=false) {
        if (pStopLoss <= 0 && pTakeProfit <= 0 && keepZero && keepSLTP && !toClear) return ACTION_DONE;
        if (!positionIsOpen()) return ACTION_DONE;
        uint SLTPpoints[2];
        if (mapSLTPtoPoints(PositionType(), pPrice, pStopLoss, pTakeProfit, SLTPpoints) == ACTION_ERROR)
            return ACTION_ERROR;
       return setSLTP(pPrice, SLTPpoints[0], SLTPpoints[1], keepZero, keepSLTP, toClear);
    }
    ENUM_ACTION_RETCODE Position::setSLTP_price(double pSL = 0.0, double pTP = 0.0, bool keepSLTP = true, bool toClear = false) {
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
    ENUM_ACTION_RETCODE Position::clearSLTP(void) {
        if (positionIsOpen()) {
            return setSLTP(0, 0, 0, true, false, true);
        }
        return ACTION_DONE;
    }
    ENUM_ACTION_RETCODE Position::clearSL(void) {
        if (positionIsOpen()) {
            PriceManager priceManager = PriceManager();
            double pPrice;
            if (PositionType() == POSITION_TYPE_BUY) pPrice = priceManager.currentBid();
            else pPrice = priceManager.currentAsk();
            return setSLTP(pPrice, 0, scaleTakeProfit(), true, false, true);
        }
        return ACTION_DONE;
    }
    ENUM_ACTION_RETCODE Position::clearTP(void) {
        if (positionIsOpen()) {
            PriceManager priceManager = PriceManager();
            double pPrice;
            if (PositionType() == POSITION_TYPE_BUY) pPrice = priceManager.currentAsk();
            else pPrice = priceManager.currentBid();
            return setSLTP(pPrice, scaleStopLoss(), 0, true, false, true);
        }
        return ACTION_DONE;
    }
};
class PositionManager : public Position {   
    public:
    PositionManager::PositionManager(OrderManager* oMMan, MoneyManager* mMMan) {
        Position(_Symbol);
        ZeroMemory(request);
        ZeroMemory(result);
        SLticket = WRONG_VALUE;
        TPticket = WRONG_VALUE;
        oMan = oMMan;
        mMan = mMMan;
        lastVolume = 0;
    }
    ulong PositionManager::getPositionTicketByIndex(int i) {return PositionGetTicket(i);}
    Position* PositionManager::getPositionByIndex (int i) {return new Position(getPositionTicketByIndex(i));}
    void PositionManager::selectPositionByIndex (int i) {SelectByTicket(getPositionTicketByIndex(i));}
    ENUM_ACTION_RETCODE PositionManager::closeAtTime(datetime pTime) {
        if (TimeCurrent() >= pTime) return closePosition();
        return ACTION_DONE;
    }
    int PositionManager::totalPositions(void) {return PositionsTotal();}
    bool OTTconvertSLTPtoScalable(bool withSLTP = true) {
        if (!positionIsOpen() || !AUTO_SCALEOUT_POSITION) return true;
        double sl = scaleStopLoss(); double tp = scaleTakeProfit();
        double normSL = StopLoss();
        double normTP = TakeProfit();
        if (normSL > 0 && SLticket != WRONG_VALUE) {
            if (sendSLTPrequest(0, normTP) == ACTION_ERROR) return false;
            if (normSL != sl && oMan.modifyOrder(SLticket, (sl + normSL)/2, 0, 0, !withSLTP) == ACTION_ERROR) {
                if (VERBOSE) Print("Couldn't modify SLorder");
                return false;
            }
        }
        if (AUTO_SCALEOUT_INCLUDE_TP && normTP > 0 && TPticket != WRONG_VALUE) {
            if (sendSLTPrequest(normSL, 0) == ACTION_ERROR) return false;
            if (normTP != tp && oMan.modifyOrder(TPticket, (tp + normTP)/2, 0, 0, !withSLTP) == ACTION_ERROR) {
                if (VERBOSE) Print("Couldn't modify TPorder");
                return false;
            }
        }
        sl = scaleStopLoss();
        tp = scaleTakeProfit();
        if (sl > 0) {
            if (SLticket == WRONG_VALUE) {
                if (clearSL() == ACTION_ERROR) {
                    if (VERBOSE) Print("Could'nt clear SL");
                    return false;
                }
                ENUM_ACTION_RETCODE posRet;
                if (PositionType() == POSITION_TYPE_BUY) posRet = oMan.sellStop(sl, Volume()*AUTO_SCALEOUT_MULTIPLIER, 0, 0, !withSLTP);
                else posRet = oMan.buyStop(sl, Volume()*AUTO_SCALEOUT_MULTIPLIER, 0, 0, !withSLTP);
                if (posRet == ACTION_ERROR) {
                    if (VERBOSE) Print("Could'nt make SL order");
                    return false;
                }
                SLticket = oMan.ResultOrder();
            } else {
                Order* SLorder = oMan.getOwnOrder(SLticket);
                if (SLorder) {
                    double cVol = Volume() * AUTO_SCALEOUT_MULTIPLIER;
                    if (SLorder.VolumeCurrent() != cVol) {
                        if (SLorder.deleteOrder() == ACTION_ERROR) {
                            if (VERBOSE) Print("Could'nt delete SLorder");
                            //delete SLorder;
                            return false;
                        }
                        SLticket = WRONG_VALUE;
                        ENUM_ACTION_RETCODE ordRet;
                        if (withSLTP) ordRet = oMan.createOrder(SLorder.OrderType(), SLorder.PriceOpen(), cVol, SLorder.StopLoss(), SLorder.TakeProfit(), true, true, SLorder.PriceStopLimit(), SLorder.TypeTime(), SLorder.TimeExpiration(), SLorder.Comment());
                        else ordRet = oMan.createOrder(SLorder.OrderType(), SLorder.PriceOpen(), cVol, 0, 0, true, true, SLorder.PriceStopLimit(), SLorder.TypeTime(), SLorder.TimeExpiration(), SLorder.Comment());
                        if (ordRet == ACTION_ERROR) {
                            if (VERBOSE) Print("Could'nt create SL order");
                            //delete SLorder;
                            return false;
                        }
                        SLticket = oMan.ResultOrder();
                    }
                    //delete SLorder;
                } else {
                    SLticket = WRONG_VALUE;
                }
            }
        }
        if (tp > 0) {
            if (AUTO_SCALEOUT_INCLUDE_TP) {
                if (TPticket == WRONG_VALUE) {
                    if (clearTP() == ACTION_ERROR) {
                        if (VERBOSE) Print("Could'nt clear TP");
                        return false;
                    }
                    if (TPticket == WRONG_VALUE) {
                        ENUM_ACTION_RETCODE posRet;
                        if (PositionType() == POSITION_TYPE_BUY) posRet = oMan.sellLimit(tp, Volume()*AUTO_SCALEOUT_MULTIPLIER, 0, 0, !withSLTP);
                        else posRet = oMan.buyLimit(tp, Volume()*AUTO_SCALEOUT_MULTIPLIER, 0, 0, !withSLTP);
                        if (posRet == ACTION_ERROR) {
                            if (VERBOSE) Print("Could'nt make TP order");
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
                                if (VERBOSE) Print("Could'nt delete TPorder");
                                //delete TPorder;
                                return false;
                            }
                            TPticket = WRONG_VALUE;
                            if (oMan.createOrder(TPorder.OrderType(), TPorder.PriceOpen(), cVol, TPorder.StopLoss(),
                                    TPorder.TakeProfit(), true, true, TPorder.PriceStopLimit(), TPorder.TypeTime(), TPorder.TimeExpiration(),
                                    TPorder.Comment()) == ACTION_ERROR) {
                                if (VERBOSE) Print("Could'nt create TP order");
                                //delete TPorder;
                                return false;
                            }
                            TPticket = oMan.ResultOrder();
                        }
                        //delete TPorder;
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
                    if (VERBOSE) Print("Could'nt clear SL oder");
                    return false;
                }
                SLticket = WRONG_VALUE;
                if (setSLTP_price(sl, 0) == ACTION_ERROR) {
                    if (VERBOSE) Print("Could'nt set SL");
                    return false;
                }
            }
            if (TPticket != WRONG_VALUE) {
                if (clearTP() == ACTION_ERROR) {
                    if (VERBOSE) Print("Could'nt clear TP order");
                    return false;
                }
                TPticket = WRONG_VALUE;
                if (setSLTP_price(0, tp) == ACTION_ERROR) {
                    if (VERBOSE) Print("Could'nt set TP");
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
                                if (VERBOSE) Print("Could'nt delete TP order");
                                return false;
                            }
                            TPticket = WRONG_VALUE;
                        }
                    }
                }
                //delete SLorder;
            }
            if (AUTO_SCALEOUT_INCLUDE_TP) {
                if (TPticket != WRONG_VALUE) {
                    Order* TPorder = oMan.getOwnOrder(TPticket);
                    if (TPorder == NULL) {
                        //order deleted, non existing or triggered
                        TPticket = WRONG_VALUE;
                        if (SLticket != WRONG_VALUE && oMan.deleteOrder(SLticket) == ACTION_ERROR) {
                            if (VERBOSE) Print("Could'nt delete SL order");
                            return false;
                        }
                        SLticket = WRONG_VALUE;        
                    }
                    //delete TPorder;
                }
            } else {
                if (TakeProfit() == 0 && withSLTP) {
                    if (SLticket != WRONG_VALUE && oMan.deleteOrder(SLticket) == ACTION_ERROR) {
                        if (VERBOSE) Print("Could'nt delete SL order");
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
    void PositionManager::OTwhatIsGoingOn(const MqlTradeTransaction& trans, const MqlTradeRequest& req) {
        switch (trans.type) {
            case TRADE_TRANSACTION_DEAL_ADD: {
                switch (trans.deal_type) {
                    case DEAL_TYPE_SELL:
                        Print("Sell Deal started");
                        break;
                    case DEAL_TYPE_BUY:
                        Print("Buy deal started");
                        break;
                    default:
                        Print("Unknown deal type ", EnumToString(trans.deal_type));
                        break;
                }
                break;
            }
            case TRADE_TRANSACTION_ORDER_DELETE: {
                switch (trans.order_type) {
                    case ORDER_TYPE_BUY:
                        Print("Buy order deleted");
                        break;
                    case ORDER_TYPE_SELL:
                        Print("Sell order deleted");
                        break;
                    default:
                        Print("Unknown order type ", EnumToString(trans.order_type));
                        break;
                }
            }
            break;
            case TRADE_TRANSACTION_HISTORY_ADD: {
                switch (trans.order_type) {
                    case ORDER_TYPE_BUY:
                        Print("Buy order added to history");
                        break;
                    case ORDER_TYPE_SELL:
                        Print("Sell order added to history");
                        break;
                    default:
                        Print("Unknown order type ", EnumToString(trans.order_type));
                        break;
                }
            }
            break;
            case TRADE_TRANSACTION_REQUEST : {
                switch (req.type) {
                    case ORDER_TYPE_BUY:
                        Print("Buy order request");
                        break;
                    case ORDER_TYPE_SELL:
                        Print("Sell order request");
                        break;
                    default:
                        Print("Unknown order type ", EnumToString(trans.order_type));
                        break;
                }
            }
            break;
            default:
                Print("unknown trans type ", EnumToString(trans.type));
                break;
        }
        ulong dDeals[];
        Deal* lastDeal;
        switch (trans.type) {
            case TRADE_TRANSACTION_DEAL_ADD: {
                oMan.copyOwnDealTickets(dDeals);
                lastDeal = oMan.getOwnDeal(dDeals[ArraySize(dDeals)-1]);
                switch(lastDeal.Entry()) {
                    case DEAL_ENTRY_IN:
                        Print("Order invoked deal");
                        switch(lastDeal.DealType()) {
                            case DEAL_TYPE_BUY:
                                if (Volume() == lastDeal.Volume()) Print("Buy position has been opened");
                                else if (Volume() > lastDeal.Volume()) Print("Buy position incremented");
                                else if (Volume() == 0) Print("Position closed with buy");
                                break;
                            case DEAL_TYPE_SELL:
                                if (Volume() == lastDeal.Volume()) Print("Sell position has been opened");
                                else if (Volume() > lastDeal.Volume()) Print("Sell position incremented");
                                else if (Volume() == 0) Print("Position closed with sell");
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
                        switch(lastDeal.DealType()) {
                            case DEAL_TYPE_BUY:
                                Print("Sell is reversed to Buy with profit, ", lastDeal.Profit());
                                break;
                            case DEAL_TYPE_SELL:
                                Print("Buy is reversed to Sell with profit, ", lastDeal.Profit());
                                break;
                            default:
                                Print("Unprocessed code of type - ", lastDeal.Type(), " - ", EnumToString((ENUM_DEAL_TYPE)lastDeal.Type()));
                                break;
                        }
                        break;
                    case DEAL_ENTRY_STATE:
                        Print("Indicates the state record. Unprocessed code of type - ", lastDeal.Type(), " - ", EnumToString((ENUM_DEAL_TYPE)lastDeal.Type()));
                        break;
                }
            }
        }
        return;
        HistorySelect(0, TimeCurrent());
        int numOfChangedOrder = 0;
        if (!oMan.hasNumofOrdersChangedV2(numOfChangedOrder)) {
        //if (!oMan.hasNumofExecutedOrdersChangedV2(numOfChangedOrder)) {
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
                }
                if (order.State() == ORDER_STATE_PLACED) Print("Order has been placed");
                lastOrder = order;
            } else if (numOfChangedOrder < 0) { //An order has been removed (executed)
                exOrder = oMan.getOwnExOrder(lastOrder.Ticket());
                if (exOrder.State() == ORDER_STATE_FILLED) {
                    Print("Order executed, going to deal");
                    lastDeal = oMan.getOwnDeal(oMan.getOwnTicketFromDealPool(oMan.totalOwnDeals()-1));
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
                            break;
                    }
                }
            }
            //delete lastOrder;
            //delete order;
            //delete exOrder;
        }
        //delete lastDeal;
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
                    if (VERBOSE) Print("Could'nt delete takeTPorder");
                    return false;
                }
                takeTPtickets[i] = WRONG_VALUE;
            }
            takeTPfilled = 0;
        }
        if (AUTO_TAKE_PARTIAL_LOSS && takeSLfilled && rSL) {
            for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                if (takeSLtickets[i] != WRONG_VALUE && oMan.deleteOrder(takeSLtickets[i]) == ACTION_ERROR) {
                    if (VERBOSE) Print("Could'nt delete takeSLorder");
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
                            if (VERBOSE) Print("Could'nt create auto stops");
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
                                        if (VERBOSE) Print("Could'nt create auto stops");
                                        return false;
                                    }
                                    takeTPtickets[i] = oMan.ResultOrder();
                                    currentStop += pIncrease;
                                }
                            } else {
                                for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                                    Order* order = oMan.getOwnOrder(takeTPtickets[i]);
                                    if (order != NULL && order.PriceOpen() != currentStop && order.modifyOrder(currentStop, 0, 0, true) == ACTION_ERROR) {
                                        if (VERBOSE) Print("Could'nt modify takeTPorder");
                                        //delete order;
                                        return false; 
                                    }
                                    currentStop += pIncrease;
                                    //if (order != NULL) delete order;
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
                            if (VERBOSE) Print("Could'nt create auto stops");
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
                                        if (VERBOSE) Print("Could'nt create auto stops");
                                        return false;
                                    }
                                    takeTPtickets[i] = oMan.ResultOrder();
                                    currentStop -= pIncrease;
                                }
                            } else {
                                for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                                    Order* order = oMan.getOwnOrder(takeTPtickets[i]);
                                    if (order != NULL && order.PriceOpen() != currentStop && order.modifyOrder(currentStop, 0, 0, true) == ACTION_ERROR) {
                                        if (VERBOSE) Print("Could'nt modify takeTPorder");
                                        //delete order;
                                        return false;
                                    }
                                    currentStop -= pIncrease;
                                    //if (order != NULL) delete order;
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
                if (VERBOSE) Print("Could'nt remove autoTP");
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
                            if (VERBOSE) Print("Could'nt create auto stops");
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
                                        if (VERBOSE) Print("Could'nt create auto stops");
                                        return false;
                                    }
                                    takeSLtickets[i] = oMan.ResultOrder();
                                    currentStop -= pIncrease;
                                }
                            } else {
                                for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                                    Order* order = oMan.getOwnOrder(takeSLtickets[i]);
                                    if (order != NULL && order.PriceOpen() != currentStop && order.modifyOrder(currentStop, 0, 0, true) == ACTION_ERROR) {
                                        if (VERBOSE) Print("Could'nt modify takeSLorder");
                                        //delete order;
                                        return false; 
                                    }
                                    currentStop -= pIncrease;
                                    //if (order != NULL) delete order;
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
                            if (VERBOSE) Print("Could'nt create auto stops");
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
                                        if (VERBOSE) Print("Could'nt create auto stops");
                                        return false;
                                    }
                                    takeSLtickets[i] = oMan.ResultOrder();
                                    currentStop -= pIncrease;
                                }
                            } else {
                                for (uint i = 0; i < AUTO_PARTIAL_COUNT; i++) {
                                    Order* order = oMan.getOwnOrder(takeSLtickets[i]);
                                    if (order != NULL && order.PriceOpen() != currentStop && order.modifyOrder(currentStop, 0, 0, true) == ACTION_ERROR) {
                                        if (VERBOSE) Print("Could'nt modify takeSLorder");
                                        //delete order;
                                        return false; 
                                    }
                                    currentStop += pIncrease;
                                    //if (order != NULL) delete order;
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
                if (VERBOSE) Print("Could'nt remove auto SL");
                return false;
            }
        }
        return true;
    }
};
class DotRangee : public DotRange {
    public:
    double getLineAngle(CandleManager *_cMan) {
        if (Total() < 2) return WRONG_VALUE;
        return _cMan.pointPerTime(A(-2), A(-1));
    }
    bool lineLinesUp3(CandleManager *_cMan, int _p3, int _p2, int _p1, double _dev = 5) {
        if (Total() < 3) return false;
        double ang1 = _cMan.pointPerTime(A(_p2), A(_p1));
        double ang2 = _cMan.pointPerTime(A(_p3), A(_p2));
        if (MathAbs(ang2 - ang1) <= _dev) return true;
        return false;
    }
    bool lastLinesLineUp(CandleManager *_cMan, int pNum = 3, double _dev = 5) {
        if (pNum < 2) return false;
        if (pNum == 2) return true;
        bool res = true;
        for (int i = 0; i < pNum - 2; i++) res = res && lineLinesUp3(_cMan, -pNum+i, -pNum+(i+1), -pNum+(i+2), _dev);
        return res;
    }
};



//Functions
double getChartAngle(CandleManager* _cMan, Dot& dot1, Dot& dot2) {return _cMan.pointPerTime(dot1, dot2);}


//DotRangee toDotRangee(DotRange* _dRange) {

//}