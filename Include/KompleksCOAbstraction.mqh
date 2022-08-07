//+------------------------------------------------------------------+
//|                                        KompleksCOAbstraction.mqh |
//|                                       Copyright 2022, KompleksEA |
//|                            https://www.kompleksanda.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, KompleksEA"
#property link      "https://www.kompleksanda.blogspot.com"

#include <MT5TradingLibrary/Include/KompleksUTAbstraction.mqh>

#include  <ChartObjects\ChartObject.mqh>
#include  <ChartObjects\ChartObjectsLines.mqh>
#include  <ChartObjects\ChartObjectsChannels.mqh>
#include  <ChartObjects\ChartObjectsGann.mqh>
#include  <ChartObjects\ChartObjectsFibo.mqh>
#include  <ChartObjects\ChartObjectsElliott.mqh>
#include  <ChartObjects\ChartObjectsShapes.mqh>
#include  <ChartObjects\ChartObjectsArrows.mqh>
#include  <ChartObjects\ChartObjectsTxtControls.mqh>
#include  <ChartObjects\ChartObjectSubChart.mqh>
#include  <ChartObjects\ChartObjectsBmpControls.mqh>
#include  <Charts\Chart.mqh>

#include  <Canvas\Charts\HistogramChart.mqh>
#include  <Canvas\Charts\LineChart.mqh>
#include  <Canvas\Charts\PieChart.mqh>

class vLine : public CChartObjectVLine{
    public:
    vLine::vLine(string pName, datetime pTime, long pCID=0, int pWin=0) {
        Create(pCID, pName, pWin, pTime);
    }
    //vLine::~vLine(void) {Delete();}
};
class hLine : public CChartObjectHLine {
    public:
    hLine::hLine(string pName, double pPrice, long pCID=0, int pWin=0) {
        Create(pCID, pName, pWin, pPrice);
    }
    //hLine::~hLine(void) {Delete();}
};
class gannLine : public CChartObjectGannLine {
    public:
    gannLine(string pName, datetime pTime1, double pPrice1, datetime pTime2, double ppb, long pCID=0, int pWin=0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, ppb);
    }
    gannLine(string pName, Dot &dot1, datetime pTime2, double ppb, long pCID=0, int pWin=0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, pTime2, ppb);
    }
};

class tLine : public CChartObjectTrend {
    public:
    tLine(string pName, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, pPrice2);
    }
    tLine(string pName, Dot &dot1, Dot &dot2, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, dot2.time, dot2.price);
    }
    double valueAtTime(datetime pTime) {return ObjectGetValueByTime(ChartId(), Name(), pTime, 0);}
    double valueAtTime(void) {return ObjectGetValueByTime(ChartId(), Name(), TimeCurrent(), 0);}
    datetime timeAtPrice(double pPrice) {return ObjectGetTimeByValue(ChartId(), Name(), pPrice, 0);}
    //tLine::~tLine(void) {Delete();}
};
class tByALine : public CChartObjectTrendByAngle {
    public:
    tByALine(string pName, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, pPrice2);
    }
    tByALine(string pName, Dot &dot1, Dot &dot2, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, dot2.time, dot2.price);
    }
};

class cLine : public CChartObjectCycles {
    public:
    cLine(string pName, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, pPrice2);
    }
    cLine(string pName, Dot &dot1, Dot &dot2, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, dot2.time, dot2.price);
    }
};

class eqChannel : public CChartObjectChannel{
    public:
    eqChannel(string pName, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, datetime pTime3, double pPrice3, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, pPrice2, pTime3, pPrice3);
    }
    eqChannel(string pName, Dot &dot1, Dot &dot2, Dot &dot3, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, dot2.time, dot2.price, dot3.time, dot3.price);
    }
    double valueAtTime(datetime pTime, int lineID = 0) {return ObjectGetValueByTime(ChartId(), Name(), pTime, lineID);}
    datetime timeAtPrice(double pPrice, int lineID = 0) {return ObjectGetTimeByValue(ChartId(), Name(), pPrice, lineID);}
};
class regChannel : public CChartObjectRegression{
    public:
    regChannel(string pName, datetime pTime1, datetime pTime2, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pTime2);
    }
    double valueAtTime(datetime pTime, int lineID = 0) {return ObjectGetValueByTime(ChartId(), Name(), pTime, lineID);}
    datetime timeAtPrice(double pPrice, int lineID = 0) {return ObjectGetTimeByValue(ChartId(), Name(), pPrice, lineID);}
};
class stdChannel : public CChartObjectStdDevChannel{
    public:
    stdChannel(string pName, datetime pTime1, datetime pTime2, double pDev, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pTime2, pDev);
    }
    double valueAtTime(datetime pTime, int lineID = 0) {return ObjectGetValueByTime(ChartId(), Name(), pTime, lineID);}
    datetime timeAtPrice(double pPrice, int lineID = 0) {return ObjectGetTimeByValue(ChartId(), Name(), pPrice, lineID);}
};
class pfChannel : public CChartObjectPitchfork{
    public:
    pfChannel(string pName, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, datetime pTime3, double pPrice3, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, pPrice2, pTime3, pPrice3);
    }
    pfChannel(string pName, Dot &dot1, Dot &dot2, Dot &dot3, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, dot2.time, dot2.price, dot3.time, dot3.price);
    }
};

class gannFan : public CChartObjectGannFan{
    public:
    gannFan(string pName, datetime pTime1, double pPrice1, datetime pTime2, double ppb, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, ppb);
    }
    gannFan(string pName, Dot &dot1, datetime pTime2, double ppb, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, pTime2, ppb);
    }
};
class gannGrid : public CChartObjectGannGrid{
    public:
    gannGrid(string pName, datetime pTime1, double pPrice1, datetime pTime2, double ppb, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, ppb);
    }
    gannGrid(string pName, Dot &dot1, datetime pTime2, double ppb, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, pTime2, ppb);
    }
};
class retraceFibo : public CChartObjectFibo{
    protected:
    int valueToID(double value) {
        for (int i = 0; i < LevelsCount(); i++) {
            if (LevelValue(i) == value) return i;
        }
        return WRONG_VALUE;
    }
    int descriptionToID(string desc) {
        for (int i = 0; i < LevelsCount(); i++) {
            if (LevelDescription(i) == desc) return i;
        }
        return WRONG_VALUE;
    }
    public:
    retraceFibo(string pName, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, pPrice2);
    }
    retraceFibo(string pName, Dot& dot1, Dot& dot2, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, dot2.time, dot2.price);
    }
    double valueAt(int lineID = 0) {
        double s1 = GetDouble(OBJPROP_PRICE);
        double s2 = GetDouble(OBJPROP_PRICE, 1);
        if (s1 < s2) return NormalizeDouble(MathMax(s1, s2) - (LevelValue(lineID) * (s2 - s1)), _Digits);
        else return NormalizeDouble(MathMin(s1, s2) + (LevelValue(lineID) * (s1 - s2)), _Digits);
    }
    double valueAt(double value = 0) {
        int lineID = valueToID(value);
        if (lineID == WRONG_VALUE) return WRONG_VALUE;
        double s1 = GetDouble(OBJPROP_PRICE);
        double s2 = GetDouble(OBJPROP_PRICE, 1);
        double diff = MathAbs(s1 - s2);
        if (s1 < s2) return NormalizeDouble(MathMax(s1, s2) - (LevelValue(lineID) * (s2 - s1)), _Digits);
        else return NormalizeDouble(MathMin(s1, s2) + (LevelValue(lineID) * (s1 - s2)), _Digits);
    }
    double valueAt(string desc = "0") {
        int lineID = descriptionToID(desc);
        if (lineID == WRONG_VALUE) return WRONG_VALUE;
        double s1 = GetDouble(OBJPROP_PRICE);
        double s2 = GetDouble(OBJPROP_PRICE, 1);
        double diff = MathAbs(s1 - s2);
        if (s1 < s2) return NormalizeDouble(MathMax(s1, s2) - (LevelValue(lineID) * (s2 - s1)), _Digits);
        else return NormalizeDouble(MathMin(s1, s2) + (LevelValue(lineID) * (s1 - s2)), _Digits);
    }
};
class timeFibo : public CChartObjectFiboTimes{
    public:
    timeFibo(string pName, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, pPrice2);
    }
    timeFibo(string pName, Dot &dot1, Dot &dot2, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, dot2.time, dot2.price);
    }
};
class fanFibo : public CChartObjectFiboFan{
    public:
    fanFibo(string pName, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, pPrice2);
    }
    fanFibo(string pName, Dot &dot1, Dot &dot2, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, dot2.time, dot2.price);
    }
};
class arcFibo : public CChartObjectFiboArc{
    public:
    arcFibo(string pName, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, double pScale, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, pPrice2, pScale);
    }
    arcFibo(string pName, Dot &dot1, Dot &dot2, double pScale, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, dot2.time, dot2.price, pScale);
    }
};
class channelFibo : public CChartObjectFiboChannel{
    public:
    channelFibo(string pName, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, datetime pTime3, double pPrice3, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, pPrice2, pTime3, pPrice3);
    }
    channelFibo(string pName, Dot &dot1, Dot &dot2, Dot &dot3, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, dot2.time, dot2.price, dot3.time, dot3.price);
    }
};
class expFibo : public CChartObjectFiboExpansion{
    public:
    expFibo(string pName, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, datetime pTime3, double pPrice3, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, pPrice2, pTime3, pPrice3);
    }
    expFibo(string pName, Dot &dot1, Dot &dot2, Dot &dot3, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, dot2.time, dot2.price, dot3.time, dot3.price);
    }
};
class corWave : public CChartObjectElliottWave3{
    public:
    corWave(string pName, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, datetime pTime3, double pPrice3, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, pPrice2, pTime3, pPrice3);
    }
    corWave(string pName, Dot &dot1, Dot &dot2, Dot &dot3, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, dot2.time, dot2.price, dot3.time, dot3.price);
    }
};
class impWave : public CChartObjectElliottWave5{
    public:
    impWave(string pName, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, datetime pTime3, double pPrice3,
            datetime pTime4, double pPrice4, datetime pTime5, double pPrice5,long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, pPrice2, pTime3, pPrice3, pTime4, pPrice4, pTime5, pPrice5);
    }
    impWave(string pName, Dot &dot1, Dot &dot2, Dot &dot3, Dot &dot4, Dot &dot5, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, dot2.time, dot2.price, dot3.time, dot3.price, dot4.time, dot4.price, dot5.time, dot5.price);
    }
};

class rectangle : public CChartObjectRectangle{
    public:
    rectangle(string pName, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, pPrice2);
    }
    rectangle(string pName, Dot &dot1, Dot &dot2, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, dot2.time, dot2.price);
    }
};
class triangle : public CChartObjectTriangle{
    public:
    triangle(string pName, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, datetime pTime3, double pPrice3, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, pPrice2, pTime3, pPrice3);
    }
    triangle(string pName, Dot &dot1, Dot &dot2, Dot &dot3, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, dot2.time, dot2.price, dot3.time, dot3.price);
    }
};
class ellipse : public CChartObjectEllipse{
    public:
    ellipse(string pName, datetime pTime1, double pPrice1, datetime pTime2, double pPrice2, datetime pTime3, double pPrice3, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1, pTime2, pPrice2, pTime3, pPrice3);
    }
    ellipse(string pName, Dot &dot1, Dot &dot2, Dot &dot3, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price, dot2.time, dot2.price, dot3.time, dot3.price);
    }
};
class arrow : public CChartObjectArrow {
    public:
    arrow(string pName, Dot &dot1, ENUM_OBJECT pCode = OBJ_ARROW, long pCID = 0, int pWin = 0) {
        arrow::Create(pName, dot1.time, dot1.price, pCode, pCID, pWin);
    }
    arrow(string pName, datetime time, double price, ENUM_OBJECT pCode = OBJ_ARROW, long pCID = 0, int pWin = 0) {
        arrow::Create(pName, time, price, pCode, pCID, pWin);
    }
    bool arrow::Create(const string name, const datetime time, const double price, const ENUM_OBJECT code = OBJ_ARROW, long chart_id = 0, const int window = 0) {
        if(!ObjectCreate(chart_id, name, code, window, time, price)) return(false);
        if(!Attach(chart_id, name, window, 1)) return(false);
        if(!ArrowCode(code)) return(false);
        return(true);
    }
};
class arrowChar : public CChartObjectArrow {
    public:
    arrowChar(string pName, datetime pTime1, double pPrice1, char pCode = OBJ_ARROW, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, pTime1, pPrice1, pCode);
    }
    arrowChar(string pName, Dot &dot1, char pCode = OBJ_ARROW, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, dot1.time, dot1.price, pCode);
    }
};
class arrowCheckSign : public CChartObjectArrowCheck {
    public:
    arrowCheckSign(string pName, datetime pTime1, double pPrice1, long pCID = 0, int pWin = 0) {
        CChartObjectArrowCheck::Create(pCID, pName, pWin, pTime1, pPrice1);
    }
    arrowCheckSign(string pName, Dot &dot1, long pCID = 0, int pWin = 0) {
        CChartObjectArrowCheck::Create(pCID, pName, pWin, dot1.time, dot1.price);
    }
};
class arrowDown : public CChartObjectArrowDown {
    public:
    arrowDown(string pName, datetime pTime1, double pPrice1, long pCID = 0, int pWin = 0) {
        CChartObjectArrowDown::Create(pCID, pName, pWin, pTime1, pPrice1);
    }
    arrowDown(string pName, Dot &dot1, long pCID = 0, int pWin = 0) {
        CChartObjectArrowDown::Create(pCID, pName, pWin, dot1.time, dot1.price);
    }
};
class arrowUp : public CChartObjectArrowUp {
    public:
    arrowUp(string pName, datetime pTime1, double pPrice1, long pCID = 0, int pWin = 0) {
        CChartObjectArrowUp::Create(pCID, pName, pWin, pTime1, pPrice1);
    }
    arrowUp(string pName, Dot &dot1, long pCID = 0, int pWin = 0) {
        CChartObjectArrowUp::Create(pCID, pName, pWin, dot1.time, dot1.price);
    }
};
class arrowLeftPrice : public CChartObjectArrowLeftPrice {
    public:
    arrowLeftPrice(string pName, datetime pTime1, double pPrice1, long pCID = 0, int pWin = 0) {
        CChartObjectArrowLeftPrice::Create(pCID, pName, pWin, pTime1, pPrice1);
    }
    arrowLeftPrice(string pName, Dot &dot1, long pCID = 0, int pWin = 0) {
        CChartObjectArrowLeftPrice::Create(pCID, pName, pWin, dot1.time, dot1.price);
    }
};
class arrowRightPrice : public CChartObjectArrowRightPrice {
    public:
    arrowRightPrice(string pName, datetime pTime1, double pPrice1, long pCID = 0, int pWin = 0) {
        CChartObjectArrowRightPrice::Create(pCID, pName, pWin, pTime1, pPrice1);
    }
    arrowRightPrice(string pName, Dot &dot1, long pCID = 0, int pWin = 0) {
        CChartObjectArrowRightPrice::Create(pCID, pName, pWin, dot1.time, dot1.price);
    }
};
class arrowStopSign : public CChartObjectArrowStop {
    public:
    arrowStopSign(string pName, datetime pTime1, double pPrice1, long pCID = 0, int pWin = 0) {
        CChartObjectArrowStop::Create(pCID, pName, pWin, pTime1, pPrice1);
    }
    arrowStopSign(string pName, Dot &dot1, long pCID = 0, int pWin = 0) {
        CChartObjectArrowStop::Create(pCID, pName, pWin, dot1.time, dot1.price);
    }
};
class arrowThumbDown : public CChartObjectArrowThumbDown {
    public:
    arrowThumbDown(string pName, datetime pTime1, double pPrice1, long pCID = 0, int pWin = 0) {
        CChartObjectArrowThumbDown::Create(pCID, pName, pWin, pTime1, pPrice1);
    }
    arrowThumbDown(string pName, Dot &dot1, long pCID = 0, int pWin = 0) {
        CChartObjectArrowThumbDown::Create(pCID, pName, pWin, dot1.time, dot1.price);
    }
};
class arrowThumbUp : public CChartObjectArrowThumbUp {
    public:
    arrowThumbUp(string pName, datetime pTime1, double pPrice1, long pCID = 0, int pWin = 0) {
        CChartObjectArrowThumbUp::Create(pCID, pName, pWin, pTime1, pPrice1);
    }
    arrowThumbUp(string pName, Dot &dot1, long pCID = 0, int pWin = 0) {
        CChartObjectArrowThumbUp::Create(pCID, pName, pWin, dot1.time, dot1.price);
    }
};

class textObject: public CChartObjectText {
    public:
    textObject(string pName, datetime pTime1, double pPrice1, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime1, pPrice1);
    }
    textObject(string pName, Dot &dot1, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price);
    }
    textObject(string pName, Dot &dot1, string desc, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price);
        Description(desc);
    }
};
class labelObject: public CChartObjectLabel {
    public:
    labelObject(string pName, int X, int Y, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, X, Y);
    }
};
class editObject: public CChartObjectEdit {
    public:
    editObject(string pName, int X, int Y, int sizeX, int sizeY, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, X, Y, sizeX, sizeY);
    }
};
class buttonObject: public CChartObjectButton {
    public:
    buttonObject(string pName, int X, int Y, int sizeX, int sizeY, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, X, Y, sizeX, sizeY);
    }
};
class subchartObject: public CChartObjectSubChart {
    public:
    subchartObject(string pName, int X, int Y, int sizeX, int sizeY, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, X, Y, sizeX, sizeY);
    }
};
class bmpObject: public CChartObjectBitmap {
    public:
    bmpObject(string pName, datetime pTime, double pPrice, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, pTime, pPrice);
    }
    bmpObject(string pName, Dot &dot1, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, dot1.time, dot1.price);
    }
};
class bmplabelObject: public CChartObjectBmpLabel {
    public:
    bmplabelObject(string pName, int X, int Y, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, X, Y);
    }
};
class rectlabelObject: public CChartObjectRectLabel {
    public:
    rectlabelObject(string pName, int X, int Y, int sizeX, int sizeY, long pCID = 0, int pWin = 0) {
        Create(pCID, pName, pWin, X, Y, sizeX, sizeY);
    }
};

class histogramChart : public CHistogramChart{
    public:
    histogramChart(void);
};
class lineChart : public CLineChart{
    public:
    lineChart(void);
};
class pieChart : public CPieChart{
    public:
    pieChart(void);
};
class ChartManager: public CChart {
    public:
    ChartManager::ChartManager(void){
        Attach();
    };
};

// Draw functions
void drawChartWaveAsSR(DotRange& _CW, double relPrice, uint closeness, bool useLines = true) {
    if (closeness == 0) {
        double _S[];
        double _R[];
        chartWaveToSR(_CW, relPrice, _S, _R);
        drawHlines(_S, "SRsupport", clrBlue);
        drawHlines(_R, "SRresistance", clrRed);
    } else {
        if (useLines) {
            double _S[];
            double _R[];
            chartWaveToSR(_CW, relPrice, _S, _R);
            drawHlinesAsThick(_S, _R, closeness);
        } else {
            DotRange* _S = new DotRange;
            DotRange* _R = new DotRange;
            chartWaveToSR(_CW, relPrice, _S, _R);
            drawHlinesAsThick(_S, _R, closeness);
        }
    }
}
void drawHlines(double &pPrices[], hLine* &pLines[], string prefix, color pColor = clrRed, uint width = 1) {
    deletePointerArr(pLines);
    ObjectsDeleteAll(ChartID(), prefix);
    if (ArraySize(pPrices) != 0) {
        for (int i = 0; i < ArraySize(pPrices); i++) {
            hLine* hhl = new hLine(prefix+IntegerToString(i), pPrices[i]);
            hhl.Color(pColor);
            hhl.Width(width);
            addToArr(pLines, hhl);
        }
    }
}
void drawHlines(double &pPrices[], string prefix, color pColor = clrRed, uint width = 1) {
    ObjectsDeleteAll(ChartID(), prefix);
    if (ArraySize(pPrices) != 0) {
        for (int i = 0; i < ArraySize(pPrices); i++) {
            //Leaks memory
            hLine* hhl = new hLine(prefix+IntegerToString(i), pPrices[i]);
            hhl.Color(pColor);
            hhl.Width(width);
        }
    }
}
void drawHlinesAsThick(double& _sup[], double& _res[], uint closeness) {
    hLine* _SL[];
    hLine* _RL[];
    double _RR[][2];
    double _SR[][2];
    reducedLines(_sup, _SR, closeness);
    reducedLines(_res, _RR, closeness);
    drawThickHlines(_SR, _SL, "Tsupport", clrBlue);
    drawThickHlines(_RR, _RL, "Tresistance", clrRed);
}
void drawHlinesAsThick(DotRange &_sup, DotRange &_res, uint closeness) {
    STRUCT_RECT_AND_CENTER _RR[];
    STRUCT_RECT_AND_CENTER _SR[];
    reducedLines(_sup, _SR, closeness);
    reducedLines(_res, _RR, closeness);
    drawThickHlines(_SR, "Tsupport", clrBlue);
    drawThickHlines(_RR, "Tresistance", clrRed);
}
void drawThickHlines(double& pPrices[][2], hLine* &pLines[], string prefix, color pColor = clrRed) {
    deletePointerArr(pLines);
    ObjectsDeleteAll(ChartID(), prefix);
    if (ArraySize(pPrices) != 0) {
        for (int i = 0; i < ArraySize(pPrices)/2; i++) {
            hLine* hhl = new hLine(prefix+IntegerToString(i), pPrices[i][0]);
            hhl.Color(pColor);
            hhl.Width((int)pPrices[i][1]);
            addToArr(pLines, hhl);
        }
    }
}
void drawThickHlines(STRUCT_RECT_AND_CENTER &pPrices[], rectangle* &pLines[], string prefix, color pColor = clrRed) {
    deletePointerArr(pLines);
    ObjectsDeleteAll(ChartID(), prefix);
    if (ArraySize(pPrices) != 0) {
        for (int i = 0; i < ArraySize(pPrices); i++) {
            rectangle* rect = new rectangle(prefix+IntegerToString(i), pPrices[i].top, pPrices[i].bot);
            rect.Color(pColor);
            rect.Fill(true);
            addToArr(pLines, rect);
        }
    }
}
void drawThickHlines(double& pPrices[][2], string prefix, color pColor = clrRed) {
    ObjectsDeleteAll(ChartID(), prefix);
    if (ArraySize(pPrices) != 0) {
        for (int i = 0; i < ArraySize(pPrices)/2; i++) {
            //leaks memory
            hLine* hhl = new hLine(prefix+IntegerToString(i), pPrices[i][0]);
            hhl.Color(pColor);
            hhl.Width((int)pPrices[i][1]);
        }
    }
}
void drawThickHlines(STRUCT_RECT_AND_CENTER &pPrices[], string prefix, color pColor = clrRed) {
    ObjectsDeleteAll(ChartID(), prefix);
    if (ArraySize(pPrices) != 0) {
        for (int i = 0; i < ArraySize(pPrices); i++) {
            rectangle* rect = new rectangle(prefix+IntegerToString(i), pPrices[i].top, pPrices[i].bot);
            rect.Color(pColor);
            rect.Fill(true);
        }
    }
}
//TODO: Work on this code
void drawThickHlinesAsRectangle(double& pPrices[][2], int pSpace, string prefix, color pColor = clrRed) {
    ObjectsDeleteAll(ChartID(), prefix);
    if (ArraySize(pPrices) != 0) {
        for (int i = 0; i < ArraySize(pPrices)/2; i++) {
            //leaks memory
            hLine* hhl = new hLine(prefix+IntegerToString(i), pPrices[i][0]);
            hhl.Color(pColor);
            hhl.Width((int)pPrices[i][1]);
            //rectangle* rect = new rectangle(prefix+IntegerToString(i), pPrices[i], pPrices[i].bot);
            //rect.Color(pColor);
        }
    }
}
//Draws an upper and lower enclosing trendline on corresponding upper and lower dotrange
void drawChannelDotRange(DotRange* _startD, DotRange* _endD, string prefix="channel", color pColor = clrRed) {
    if (_startD.Total() != 0) {
        int count = 0;
        Dot* dd = NULL;
        for (int i = 0; i < _startD.Total()/2; i++) {
            count = i * 2;
            dd = _startD.At(count);
            tLine* _tl = new tLine(prefix+"top"+IntegerToString(dd.time), dd, (Dot*)_startD.At(count+1));
            dd = _endD.At(count);
            _tl = new tLine(prefix+"bot"+IntegerToString(dd.time), dd, (Dot*)_endD.At(count+1));
            _tl.Color(clrBlue);
        }
    }
}
void drawChannel4DotWave(DotRange* _startD, string prefix="channelll", bool _ray = true, int pWidth = 1, color pTopColor = clrRed, color pBotColor = clrBlue) {
    //leaks memory
    if (!CheckPointer(_startD)) return;
    if (_startD.Total() >= 4) {
        tLine* _tL;
        Dot* dd;
        int _trendUp = (_startD[0] > _startD[1]) ? false : true;
        if (_trendUp) {
            dd = _startD[1];
            _tL = new tLine(prefix+"top"+IntegerToString(dd.time), dd, (Dot*)_startD[3]);
        } else {
            dd = _startD[0];
            _tL = new tLine(prefix+"top"+IntegerToString(dd.time), dd, (Dot*)_startD[2]);
        }
        _tL.Color(pTopColor);
        _tL.RayRight(_ray);
        _tL.Width(pWidth);
        if (_trendUp) {
            dd = _startD[0];
            _tL = new tLine(prefix+"bot"+IntegerToString(dd.time), dd, (Dot*)_startD[2]);
        } else {
            dd = _startD[1];
            _tL = new tLine(prefix+"bot"+IntegerToString(dd.time), dd, (Dot*)_startD[3]);
        }
        _tL.Color(pBotColor);
        _tL.RayRight(_ray);
        _tL.Width(pWidth);
    }
}
void drawChannel4DotWave(tLine* &pSR[], DotRange* _startD, string prefix="channelll", bool _ray = true, int pWidth = 1, color pTopColor = clrRed, color pBotColor = clrBlue) {
    if (!CheckPointer(_startD)) return;
    if (_startD.Total() >= 4) {
        deletePointerArr(pSR);
        Dot* dd;
        int _trendUp = (_startD[0] > _startD[1]) ? false : true;
        if (_trendUp) {
            dd = _startD[1];
            pSR[0] = new tLine(prefix+"top"+IntegerToString(dd.time), dd, (Dot*)_startD[3]);
        } else {
            dd = _startD[0];
            pSR[0] = new tLine(prefix+"top"+IntegerToString(dd.time), dd, (Dot*)_startD[2]);
        }
        pSR[0].Color(pTopColor);
        pSR[0].RayRight(_ray);
        pSR[0].Width(pWidth);
        if (_trendUp) {
            dd = _startD[0];
            pSR[1] = new tLine(prefix+"bot"+IntegerToString(dd.time), dd, (Dot*)_startD[2]);
        } else {
            dd = _startD[1];
            pSR[1] = new tLine(prefix+"bot"+IntegerToString(dd.time), dd, (Dot*)_startD[3]);
        }
        pSR[1].Color(pBotColor);
        pSR[1].RayRight(_ray);
        pSR[1].Width(pWidth);
    }
}
void drawChannelHeadShoulder(DotRange* _startD, string prefix="channelhs", int _width = 1, bool _ray = false, color pTopColor = clrRed, color pBotColor = clrBlue) {
    if (_startD.Total() >= 7) {
        tLine* _tL;
        Dot* dd;
        int _trendUp = (_startD[-7] > _startD[-6]) ? false : true;
        if (_trendUp) {
            dd = _startD[-6];
            _tL = new tLine(prefix+"top"+IntegerToString(dd.time), dd, (Dot*)_startD[-2]);
        } else {
            dd = _startD[-5];
            _tL = new tLine(prefix+"top"+IntegerToString(dd.time), dd, (Dot*)_startD[-3]);
        }
        _tL.Color(pTopColor);
        _tL.Width(_width);
        _tL.RayRight(_ray);
        if (_trendUp) {
            dd = _startD[-5];
            _tL = new tLine(prefix+"bot"+IntegerToString(dd.time), dd, (Dot*)_startD[-3]);
        } else {
            dd = _startD[-6];
            _tL = new tLine(prefix+"bot"+IntegerToString(dd.time), dd, (Dot*)_startD[-2]);
        }
        _tL.Color(pBotColor);
        _tL.Width(_width);
        _tL.RayRight(_ray);
    }
}
void drawDoubleChartPattern(DotRange* _startD, string prefix = "channelD", int _width = 1, bool _ray = false, color pTopColor = clrRed, color pBotColor = clrBlue) {
    if (_startD.Total() >= 5) {
        if (_startD[-5] > _startD[-4]) {
            drawTlineOnDotRangeIndex(_startD, -5, -1, prefix+IntegerToString(_startD.A(-5).time), pTopColor, _ray, _width);
            drawTlineOnDotRangeIndex(_startD, -4, -2, prefix+IntegerToString(_startD.A(-4).time), pBotColor, _ray, _width);
        } else {
            drawTlineOnDotRangeIndex(_startD, -4, -2, prefix+IntegerToString(_startD.A(-4).time), pTopColor, _ray, _width);
            drawTlineOnDotRangeIndex(_startD, -5, -1, prefix+IntegerToString(_startD.A(-5).time), pBotColor, _ray, _width);
        }
    }
}
void drawLinesDotRange(DotRange* wave, string prefix="chartWave", color pColor = clrRed, long _cID = 0, int _wID = 0) {
    if (!DO_NOT_DRAW_CW) {
        ObjectsDeleteAll(_cID, prefix);
        if (wave == NULL || wave.Total() < 2) return;
        //Causes memory issues in long run
        tLine* tt;
        for (int i = 1; i < wave.Total(); i++) {
            tt = new tLine(prefix+IntegerToString(i), wave[i-1], wave[i], _cID, _wID);
            tt.Color(pColor);
        }
    }
}
void drawLinesDotRange(tLine* &lines[], DotRange* wave, string prefix="chartWave", color pColor = clrRed, long _cID = 0, int _wID = 0) {
    if (!DO_NOT_DRAW_CW) {
        deletePointerArr(lines);
        if (wave == NULL || wave.Total() < 2) return;
        for (int i = 1; i < wave.Total(); i++) {
            tLine* tt = new tLine(prefix+IntegerToString(i), wave[i-1], wave[i]);
            tt.Color(pColor);
            addToArr(lines, tt, -1, false);
        }
    }
}
void drawLinesPairAcrossDotRange(DotRange* fPair, DotRange* sPair, string prefix="chartWave", color pColor = clrRed, long _cID = 0, int _wID = 0) {
    if (fPair.Total() < 2 || fPair.Total() != sPair.Total()) return;
    for (int i = 0; i < fPair.Total(); i++) {
        tLine* tt = new tLine(prefix+IntegerToString(i), fPair[i], sPair[i]);
        tt.Color(pColor);
    }
}
void drawLinesPairWithinDotRange(DotRange* fPair, string prefix="chartWave", color pColor = clrRed, long _cID = 0, int _wID = 0) {
    if (fPair.Total() < 2) return;
    ObjectsDeleteAll(ChartID(), prefix);
    int count = 0;
    for (int i = 0; i < fPair.Total()/2; i++) {
        count = i * 2;
        tLine* tt = new tLine(prefix+IntegerToString(count), fPair[count], fPair[count+1]);
        tt.Color(pColor);
    }
}
void drawSymbolsDotRange(DotRange* wave, ENUM_OBJECT obj = OBJ_ARROW, string prefix="chartbols", long _cID = 0, int _wID = 0) {
    if (wave.Total() < 2) return;
    ObjectsDeleteAll(_cID, prefix);
    //Causes memory issues in long run
    arrow* aDown;
    for (int i = 0; i < wave.Total(); i++) {
        aDown = new arrow(prefix+IntegerToString(i), wave[i], obj);
    }
}
void drawSymbolsDotWave(DotRange* wave, string prefix="chartbols", ENUM_OBJECT objtop = OBJ_ARROW_SELL, ENUM_OBJECT objbot = OBJ_ARROW_BUY, long _cID = 0, int _wID = 0) {
    if (wave.Total() < 2) return;
    DotRange* _top = new DotRange;
    DotRange* _bot = new DotRange;
    wave.separateWave(_top, _bot);
    drawSymbolsDotRange(_top, objtop, prefix + "top");
    drawSymbolsDotRange(_bot, objbot, prefix + "bot");
}
void drawTlineOnDotRangeIndex(DotRange& _dR, int _p2 = -3, int _p1 = -1, string prefix="TrendChartLine", color pColor = clrRed, bool ray = true, int _width = 1) {
    tLine* tL = new tLine(prefix+IntegerToString(MathRand()), _dR.A(_p2), _dR.A(_p1));
    tL.Color(pColor);
    tL.Width(_width);
    tL.RayRight(ray);
}
void drawTopTlineonChartLine(DotRange& _dR, DotRange* _top, int pNum = 3, double _dev = 5) {
    if (_dR.chartWaveDirection() == 1) _top = _top.slice(0, _top.Total()-1);
    if (_top.lastLinesLineUp(pNum, _dev)) drawTlineOnDotRangeIndex(_top, -pNum, -1, "TopTCL", clrRed);
}
void drawBotTlineonChartLine(DotRange& _dR, DotRange* _bot, int pNum = 3, double _dev = 5) {
    if (_dR.chartWaveDirection() == -1) _bot = _bot.slice(0, _bot.Total()-1);
    if (_bot.lastLinesLineUp(pNum, _dev)) drawTlineOnDotRangeIndex(_bot, -pNum, -1, "BotTCL", clrBlue);
}
void drawTopBotTlineonChartLine(DotRange& _dR, DotRange* _top, DotRange* _bot, int pNum = 3, double _dev = 5, int _min = 0) {
    bool topLined = false, botLined = false;
    if (_dR.chartWaveDirection() == 1) _top = _top.slice(0, _top.Total()-1);
    else _bot = _bot.slice(0, _bot.Total()-1);
    if (_min > 0 && _min < pNum) {
        for (int i = pNum; i > _min; i--) {
            if (_top.lastLinesLineUp(i, _dev)) {
                drawTlineOnDotRangeIndex(_top, i, -1, "TopTCL", clrRed, true, i-1);
                break;
            }
        }
        for (int i = pNum; i > _min; i--) {
            if (_bot.lastLinesLineUp(i, _dev)) {
                drawTlineOnDotRangeIndex(_bot, -i, -1, "BotTCL", clrBlue, true, i);
                break;
            }
        }
    } else {
        if (_top.lastLinesLineUp(pNum, _dev)) {
            ObjectDelete(ChartID(), "TempTCL"+IntegerToString(_top[-pNum].time));
            drawTlineOnDotRangeIndex(_top, -pNum, -1, "TopTCL", clrRed);
            topLined = true;
        }
        if (_bot.lastLinesLineUp(pNum, _dev)) {
            ObjectDelete(ChartID(), "TempTCL"+IntegerToString(_bot[-3].time));
            drawTlineOnDotRangeIndex(_bot, -pNum, -1, "BotTCL", clrBlue);
            botLined = true;
            if (!topLined) {
                ObjectDelete(ChartID(), "TempTCL"+IntegerToString(_top[-3].time));
                drawTlineOnDotRangeIndex(_top, -pNum+1, -1, "TempTCL", clrCyan);
            }
        }
        if (topLined && !botLined) {
            ObjectDelete(ChartID(), "TempTCL"+IntegerToString(_bot[-3].time));
            drawTlineOnDotRangeIndex(_bot, -pNum+1, -1, "TempTCL", clrCyan);
        }
    }
}
void drawTopBotTlineonChartLine(DotRange& _dR, int pNum = 3, double _dev = 5, bool _all = false) {
    DotRange* _top = new DotRange;
    DotRange* _bot = new DotRange;
    _dR.separateWave(_top, _bot);
    drawTopBotTlineonChartLine(_dR, _top, _bot, pNum, _dev, _all);
}
void drawTopBotTlineonChartLine2(DotRange& _dR, int pNum = 3, double _dev = 5, int _min = 0) {
    DotRange* _top = new DotRange;
    DotRange* _bot = new DotRange;
    _dR.separateWave(_top, _bot);
    if (_min > 0 && _min < pNum) {
        int i = 0;
        Print(_top.Total());
        while (i < _top.Total() - _min) {
            int j;
            if (_top.Total() - i > pNum) j = pNum;
            else j = _top.Total() - i;
            for (int k = j; k > _min; k--) {
                DotRange* lastSlice = _top.slice(i, k);
                if (lastSlice.lastLinesLineUp(k, _dev)) {
                    drawTlineOnDotRangeIndex(lastSlice, -k, -1, "TopTCL", clrBlue, true, k-1);
                    i += k-1;
                    break;
                }
            }
            i += 1;
        }
        i = 0;
        while (i < _bot.Total() - _min) {
            int j;
            if (_bot.Total() - i > pNum) j = pNum;
            else j = _bot.Total() - i;
            for (int k = j; k > _min; k--) {
                DotRange* lastSlice = _bot.slice(i, k);
                if (lastSlice.lastLinesLineUp(k, _dev)) {
                    drawTlineOnDotRangeIndex(lastSlice, -k, -1, "BotTCL", clrRed, true, k-1);
                    i += k-1;
                    break;
                }
            }
            i += 1;
        }
    } else {
        for (int i = 0; i < _top.Total() - pNum; i++) {
            DotRange* lastSlice = _top.slice(i, pNum+1);
            if (lastSlice.lastLinesLineUp(pNum, _dev)) drawTlineOnDotRangeIndex(lastSlice, -pNum, -1, "TopTCL", clrRed);
        }
        for (int i = 0; i < _bot.Total() - pNum; i++) {
            DotRange* lastSlice = _bot.slice(i, pNum+1);
            if (lastSlice.lastLinesLineUp(pNum, _dev)) drawTlineOnDotRangeIndex(lastSlice, -pNum, -1, "BotTCL", clrBlue);
        }
    }
}
double getNearestPrice(double pPrice, hLine* &pLines[]) {
    double retPrice[];
    ArrayResize(retPrice, ArraySize(pLines));
    for (int i = 0; i < ArraySize(pLines); i++) retPrice[i] = pLines[i].Price(0);
    return getNearestPrice(pPrice, retPrice);
}
void checkChartManager(ChartManager* &_cMM) {
    if (_cMM == NULL) _cMM = new ChartManager;
}