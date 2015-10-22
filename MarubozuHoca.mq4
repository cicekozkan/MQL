//+------------------------------------------------------------------+
//|                                                 MarubozuHoca.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define numCandles 20
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int getCandleLenPip(int index)
{
   int high = (int)NormalizeDouble(High[index], Digits) / Point;
   int low = (int)NormalizeDouble(Low[index], Digits) / Point;   
   return high - low;
}

bool isTallBar(int index)
{
   int len = getCandleLenPip(index);
   double sum = 0.0;
   for(int i = 1; i <= numCandles; ++i){
      sum += getCandleLenPip(index + i);
   }
   int aver = NormalizeDouble(sum/numCandles, Digits) / Point;
   return getCandleLenPip(index) > aver;
}

bool isMarubozu(int index)
{
   int high = (int)NormalizeDouble(High[index], Digits) / Point;
   int low = (int)NormalizeDouble(Low[index], Digits) / Point;
   int open = (int)NormalizeDouble(Open[index], Digits) / Point;
   int close = (int)NormalizeDouble(Close[index], Digits) / Point;
   
   return (high == open && close == low) || (open == low && high == close);  
}


bool isSell()
{
   if(!isMarubozu(1) || !isMarubozu(2))
      return false;
   
   if(!isTallBar(1) || !isTallBar(2))
      return false;
      
   return (Close[2] > Open[2] && Close[1] < Open[1]);
}

bool isBuy()
{
   if(!isMarubozu(1) || !isMarubozu(2))
      return false;
   
   if(!isTallBar(1) || !isTallBar(2))
      return false;
      
   return (Close[2] < Open[2] && Close[1] > Open[1]);
}

int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
