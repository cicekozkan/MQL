//+------------------------------------------------------------------+
//|                                                         necc.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
	double myask = Ask;
	double pip = 20;
	
	string s1 = DoubleToString(myask, 5);
	myask + pip * Point * 10;
	Alert(s1);
   
  }
//+------------------------------------------------------------------+
