//+------------------------------------------------------------------+
//|                                       MovingAverage_VS_price.mq5 |
//|                                                       KompleksEA |
//|                                        kompleksanda.blogspot.com |
//+------------------------------------------------------------------+
#include <MT5TradingLibrary/Include/KompleksINAbstraction.mqh>
#include <MT5TradingLibrary/Include/KompleksCOAbstraction.mqh>

input int DAYS = 200; //Days
input int LINE_LEN_MIN = 2; //Minimum that line must extend
input int LINE_DIST = 2; //Minimum line dist
input int DAY_DIFF = 17; //Maximum that line can extend
input int MATCH_DIFF = 2; //Difference in days that the lines can extend
CandleManager* cMan = new CandleManager;
ChartManager* chMan = new ChartManager;
AccountManager* aMan = new AccountManager;
SymbolManager* sMan = new SymbolManager;
MoneyManager* mMan = new MoneyManager(aMan, sMan);
OrderManager* oMan = new OrderManager(mMan);
PositionManager* pMan = new PositionManager(oMan, mMan);
Utility* util = new Utility(cMan, oMan, pMan);
MarketStructureManager* msMan = new MarketStructureManager;
SignalIn* sIn = new SignalIn(msMan, oMan, pMan, util);
SignalOut* sOut = new SignalOut(cMan, oMan, pMan);
RiskProfitManager* rMan = new RiskProfitManager(cMan, oMan, pMan);

//PriceRange* highs = cMan.lastNhighPrices(DAYS, 1, false);
//PriceRange* lows = cMan.lastNlowPrices(DAYS, 1, false);
//DateRange* dates = cMan.lastNdates(DAYS, 1, false);

ellipse *ell = NULL;
arrowUp *aU = NULL;
tLine *tl = NULL;

DotRange* ZZBuffer = new DotRange;
STRUCT_CHARTPATTERN_CONF conf;
STRUCT_CHARTPATTERN_PRED _pred[3];

DotRange* startD = new DotRange();
DotRange* endD = new DotRange();
DotRange* dR = NULL;
DotRange* dR2 = NULL;
input int DEPTH = 12;
input int DEVIATION = 5;
input int BACKSTEP = 3;
int OnInit() {
    //msMan.getChartPatternTriangular(startD, endD, LINE_LEN_MIN, DAY_DIFF, DAYS, MATCH_DIFF);
    //drawChannelDotRange(startD, endD);
    return(INIT_SUCCEEDED);
}
tLine* SR[2];
void OnTick() {
    if (msMan.isNewBar()) {
        //    msMan.getChartPatternTriangular(startD, endD, LINE_LEN_MIN, DAY_DIFF, DAYS, MATCH_DIFF);
        //    drawChannelDotRange(startD, endD);
        //}
        checkChartManager(chMan);
        dR = msMan.getChartWave(DAYS, DEPTH, DEVIATION, BACKSTEP);
        dR2 = msMan.getChartWave(DAYS/BACKSTEP, DEPTH/2, BACKSTEP, BACKSTEP);
        //drawWaveDotRange(dR, "wave", clrYellow);
        //drawWaveDotRange(dR2, "dave", clrBlue);
        DotRange* dRR = dR.slice(-5, 4);
        DotRange* dRR2 = dR2.slice(-5, 4);
        ObjectsDeleteAll(ChartID(), "ranger");
        drawChannel4DotRange(dRR, "ranger", true, 3);
        ObjectsDeleteAll(ChartID(), "dranger");
        drawChannel4DotRange(dRR2, "dranger", true, 1, clrGreen, clrAliceBlue);
        //if (!sOut.fixedTrailingStopLossWhenTP(100, 50)) Print("SL not adjusted");
        //for (int i = 0; i <= ZZBuffer.Total()-4; i++) {
        //    
            //slic.minWedgePer = 5;
            //conf = slic.getReal7PointChartPattern(true, 25);
            
            //if (conf.chartpattern == CHARTPATTERN_TYPE_HEADSHOULDER) {
            //    //ring += StringSubstr(EnumToString(conf.chartpattern), 19, 1);
            //    Print(i, " ", conf.firstmove);
            //    rectangle* rect = new rectangle("rectt"+IntegerToString(i), slic.minimumBox(), slic.maximumBox());
            //    //drawChannelDotRange(slic, "poo", false);
            //}
    }
    if (pMan.positionIsOpen()) {
        if (MAX_PROFIT && MAX_PROFIT > 0) {
            if (aMan.Profit() >= MAX_PROFIT) {
                if (pMan.closePosition() == ACTION_ERROR) Print("Cannot close all position");
            }
        }
        if (MAX_LOSS && MAX_LOSS > 0) {
            if (aMan.Profit() <= -MAX_LOSS) {
                //IV.EB_SWAY_DIR++;
                //if (MathAbs(IV.EB_SWAY_DIR) > 3) {
                //    if (IV.STRATEGY == 1) IV.STRATEGY = 2;
                //    else IV.STRATEGY = 1;
                //    IV.EB_SWAY_DIR = 0;
                //}
                if (MAX_LOSS_REVERSE) {
                    if (MARGINMODE == ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) {
                        if (pMan.reversePositionHedge(MAX_LOSS_REVERSE) == ACTION_ERROR) Print("Cannot reverse position");
                    } else {
                        if (pMan.reversePositionNetting(MAX_LOSS_REVERSE) == ACTION_ERROR) Print("Cannot reverse position");
                    }
                } else {
                    if (pMan.closePosition() == ACTION_ERROR) Print("Cannot close all position");
                }
            }
        }
    }
    
}


void OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request,
        const MqlTradeResult& result) {
    //pMan.OTwhatIsGoingOn(trans, request);
    if (trans.type == TRADE_TRANSACTION_DEAL_ADD) {
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
    }
}

void OnDeinit(const int reason) {
    ObjectsDeleteAll(0);
}