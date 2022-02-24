//+------------------------------------------------------------------+
//|                                        KompleksCOAbstraction.mqh |
//|                                                       KompleksEA |
//|                                        kompleksanda.blogspot.com |
//+------------------------------------------------------------------+
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

#include <MT5TradingLibrary/Include/KompleksUTAbstraction.mqh>
// Graphical Objects

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
    arrow(string pName, datetime pTime1, double pPrice1, char pCode = OBJ_ARROW, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, pTime1, pPrice1, pCode);
    }
    arrow(string pName, Dot &dot1, char pCode = OBJ_ARROW, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, dot1.time, dot1.price, pCode);
    }
};
class arrowCheckSign : public CChartObjectArrowCheck {
    public:
    arrowCheckSign(string pName, datetime pTime1, double pPrice1, char pCode = OBJ_ARROW_CHECK, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, pTime1, pPrice1, pCode);
    }
    arrowCheckSign(string pName, Dot &dot1, char pCode = OBJ_ARROW_CHECK, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, dot1.time, dot1.price, pCode);
    }
};
class arrowDown : public CChartObjectArrowDown {
    public:
    arrowDown(string pName, datetime pTime1, double pPrice1, char pCode = OBJ_ARROW_DOWN, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, pTime1, pPrice1, pCode);
    }
    arrowDown(string pName, Dot &dot1, char pCode = OBJ_ARROW_DOWN, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, dot1.time, dot1.price, pCode);
    }
};
class arrowUp : public CChartObjectArrowUp {
    public:
    arrowUp(string pName, datetime pTime1, double pPrice1, char pCode = OBJ_ARROW_UP, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, pTime1, pPrice1, pCode);
    }
    arrowUp(string pName, Dot &dot1, char pCode = OBJ_ARROW_UP, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, dot1.time, dot1.price, pCode);
    }
};
class arrowLeftPrice : public CChartObjectArrowLeftPrice {
    public:
    arrowLeftPrice(string pName, datetime pTime1, double pPrice1, char pCode = OBJ_ARROW_LEFT_PRICE, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, pTime1, pPrice1, pCode);
    }
    arrowLeftPrice(string pName, Dot &dot1, char pCode = OBJ_ARROW_LEFT_PRICE, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, dot1.time, dot1.price, pCode);
    }
};
class arrowRightPrice : public CChartObjectArrowRightPrice {
    public:
    arrowRightPrice(string pName, datetime pTime1, double pPrice1, char pCode = OBJ_ARROW_RIGHT_PRICE, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, pTime1, pPrice1, pCode);
    }
    arrowRightPrice(string pName, Dot &dot1, char pCode = OBJ_ARROW_RIGHT_PRICE, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, dot1.time, dot1.price, pCode);
    }
};
class arrowStopSign : public CChartObjectArrowStop {
    public:
    arrowStopSign(string pName, datetime pTime1, double pPrice1, char pCode = OBJ_ARROW_STOP, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, pTime1, pPrice1, pCode);
    }
    arrowStopSign(string pName, Dot &dot1, char pCode = OBJ_ARROW_STOP, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, dot1.time, dot1.price, pCode);
    }
};
class arrowThumbDown : public CChartObjectArrowThumbDown {
    public:
    arrowThumbDown(string pName, datetime pTime1, double pPrice1, char pCode = OBJ_ARROW_THUMB_DOWN, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, pTime1, pPrice1, pCode);
    }
    arrowThumbDown(string pName, Dot &dot1, char pCode = OBJ_ARROW_THUMB_DOWN, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, dot1.time, dot1.price, pCode);
    }
};
class arrowThumbUp : public CChartObjectArrowThumbUp {
    public:
    arrowThumbUp(string pName, datetime pTime1, double pPrice1, char pCode = OBJ_ARROW_THUMB_UP, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, pTime1, pPrice1, pCode);
    }
    arrowThumbUp(string pName, Dot &dot1, char pCode = OBJ_ARROW_THUMB_UP, long pCID = 0, int pWin = 0) {
        CChartObjectArrow::Create(pCID, pName, pWin, dot1.time, dot1.price, pCode);
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
class ObjectManager {
    public:
    
};

void drawChartWaveAsThickSR (DotRange& _CW, double relPrice, uint closeness) {
    double _S[];
    double _R[];
    chartWaveToSR(_CW, relPrice, _S, _R);
    drawHlinesAsThick(_S, _R, closeness);
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
void drawThickHlines(double& pPrices[][2], hLine* &pLines[], string prefix, color pColor = clrRed) {
    deletePointerArr(pLines);
    if (ArraySize(pPrices) != 0) {
        for (int i = 0; i < ArraySize(pPrices)/2; i++) {
            hLine* hhl = new hLine(prefix+IntegerToString(i), pPrices[i][0]);
            hhl.Color(pColor);
            hhl.Width((int)pPrices[i][1]);
            addToArr(pLines, hhl);
        }
    }
}
void drawThickHlines(double& pPrices[][2], string prefix, color pColor = clrRed) {
    if (ArraySize(pPrices) != 0) {
        for (int i = 0; i < ArraySize(pPrices)/2; i++) {
            hLine* hhl = new hLine(prefix+IntegerToString(i), pPrices[i][0]);
            hhl.Color(pColor);
            hhl.Width((int)pPrices[i][1]);
        }
    }
}
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
void drawChannel4DotRange(DotRange* _startD, string prefix="channelll", bool _ray = true, int pWidth = 1, color pTopColor = clrRed, color pBotColor = clrBlue) {
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
void drawChannel4DotRange(tLine* &pSR[], DotRange* _startD, string prefix="channelll", bool _ray = true, int pWidth = 1, color pTopColor = clrRed, color pBotColor = clrBlue) {
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
void drawChannelHeadShoulder(DotRange* _startD, string prefix="channelhs", bool _ray = false, color pTopColor = clrRed, color pBotColor = clrBlue) {
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
        _tL.RayRight(_ray);
        if (_trendUp) {
            dd = _startD[-5];
            _tL = new tLine(prefix+"bot"+IntegerToString(dd.time), dd, (Dot*)_startD[-3]);
        } else {
            dd = _startD[-6];
            _tL = new tLine(prefix+"bot"+IntegerToString(dd.time), dd, (Dot*)_startD[-2]);
        }
        _tL.Color(pBotColor);
        _tL.RayRight(_ray);
    }
}
void drawDoubleChartPattern(DotRange* _startD, string prefix = "channelD", int _width = 1, bool _ray = false, color pTopColor = clrRed, color pBotColor = clrBlue) {
    if (_startD.Total() >= 5) {
        if (_startD[-5] > _startD[-4]) {
            drawTlineOnChartLineIndex(_startD, -5, -1, prefix+IntegerToString(_startD.A(-5).time), pTopColor, _ray, _width);
            drawTlineOnChartLineIndex(_startD, -4, -2, prefix+IntegerToString(_startD.A(-4).time), pBotColor, _ray, _width);
        } else {
            drawTlineOnChartLineIndex(_startD, -4, -2, prefix+IntegerToString(_startD.A(-4).time), pTopColor, _ray, _width);
            drawTlineOnChartLineIndex(_startD, -5, -1, prefix+IntegerToString(_startD.A(-5).time), pBotColor, _ray, _width);
        }
    }
}
void drawWaveDotRange(DotRange* wave, string prefix="chartWave", color pColor = clrRed, long _cID = 0, int _wID = 0) {
    if (!DO_NOT_DRAW_CW) {
        if (wave.Total() < 2) return;
        ObjectsDeleteAll(_cID, prefix);
        //Causes memory issues in long run
        tLine* tt;
        for (int i = 1; i < wave.Total(); i++) {
            tt = new tLine(prefix+IntegerToString(i), wave[i-1], wave[i], _cID, _wID);
            tt.Color(pColor);
        }
    }
}
void drawWaveDotRange(tLine* &lines[], DotRange* wave, string prefix="chartWave", color pColor = clrRed, long _cID = 0, int _wID = 0) {
    if (!DO_NOT_DRAW_CW) {
        if (wave.Total() < 2) return;
        deletePointerArr(lines);
        for (int i = 1; i < wave.Total(); i++) {
            tLine* tt = new tLine(prefix+IntegerToString(i), wave[i-1], wave[i]);
            tt.Color(pColor);
            addToArr(lines, tt, -1, false);
        }
    }
}
void drawTlineOnChartLineIndex(DotRange& _dR, int _p2 = -3, int _p1 = -1, string prefix="TrendChartLine", color pColor = clrRed, bool ray = true, int _width = 1) {
    tLine* tL = new tLine(prefix+IntegerToString(_dR.A(_p2).time), _dR.A(_p2), _dR.A(_p1));
    tL.Color(pColor);
    tL.Width(_width);
    tL.RayRight(ray);
}
void drawTopTlineonChartLine(DotRange& _dR, DotRange* _top) {
    if (_dR.chartWaveDirection() == 1) _top = _top.slice(0, _top.Total()-1);
    if (_top.last3LinesUp()) drawTlineOnChartLineIndex(_top, -3, -1, "TopTCL", clrRed);
}
void drawBotTlineonChartLine(DotRange& _dR, DotRange* _bot) {
    if (_dR.chartWaveDirection() == -1) _bot = _bot.slice(0, _bot.Total()-1);
    if (_bot.last3LinesUp()) drawTlineOnChartLineIndex(_bot, -3, -1, "BotTCL", clrBlue);
}
void drawTopBotTlineonChartLine(DotRange& _dR, DotRange* _top, DotRange* _bot) {
    bool topLined = false, botLined = false;
    if (_dR.chartWaveDirection() == 1) _top = _top.slice(0, _top.Total()-1);
    else _bot = _bot.slice(0, _bot.Total()-1);
    if (_top.last3LinesUp()) {
        ObjectDelete(ChartID(), "TempTCL"+IntegerToString(_top[-3].time));
        drawTlineOnChartLineIndex(_top, -3, -1, "TopTCL", clrRed);
        topLined = true;
    }
    if (_bot.last3LinesUp()) {
        ObjectDelete(ChartID(), "TempTCL"+IntegerToString(_bot[-3].time));
        drawTlineOnChartLineIndex(_bot, -3, -1, "BotTCL", clrBlue);
        botLined = true;
        if (!topLined) {
            ObjectDelete(ChartID(), "TempTCL"+IntegerToString(_top[-3].time));
            drawTlineOnChartLineIndex(_top, -2, -1, "TempTCL", clrCyan);
        }
    }
    if (topLined && !botLined) {
        ObjectDelete(ChartID(), "TempTCL"+IntegerToString(_bot[-3].time));
        drawTlineOnChartLineIndex(_bot, -2, -1, "TempTCL", clrCyan);
    }
}
void drawTopBotTlineonChartLine(DotRange& _dR) {
    bool topLined = false, botLined = false;
    DotRange* _top = new DotRange;
    DotRange* _bot = new DotRange;
    _dR.separateWave(_top, _bot);
    drawTopBotTlineonChartLine(_dR, _top, _bot);
}
void drawTopBotTlineonChartLine2(DotRange& _dR) {
    DotRange* _top = new DotRange;
    DotRange* _bot = new DotRange;
    _dR.separateWave(_top, _bot);
    for (int i = 0; i < _top.Total() - 3; i++) {
        DotRange* lastSlice = _top.slice(i, 4);
        if (lastSlice.last3LinesUp()) drawTlineOnChartLineIndex(lastSlice, -3, -1, "TopTCL", clrRed);
    }
    for (int i = 0; i < _bot.Total() - 3; i++) {
        DotRange* lastSlice = _bot.slice(i, 4);
        if (lastSlice.last3LinesUp()) drawTlineOnChartLineIndex(lastSlice, -3, -1, "BotTCL", clrBlue);
    }
}
class ChartManager: public CChart {
    public:
    ChartManager::ChartManager(void){
        Attach();
    };
};
void checkChartManager(ChartManager* &_cMM) {
    if (_cMM == NULL) _cMM = new ChartManager;
}
