//+------------------------------------------------------------------+
//|                                                 ReportBidAsk.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#define text true
#define binary false
int fh = INVALID_HANDLE;
int tick = 0;
int OnInit()
{
   string filename = "Report.txt";
   fh = FileOpen(filename, FILE_WRITE | FILE_TXT); 
   if (fh == INVALID_HANDLE){
     Alert(filename, " cannot be opened. The error code = ", GetLastError());
     ExpertRemove();
   }
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if (fh != INVALID_HANDLE) FileClose(fh);   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   datetime date = TimeCurrent();
   MqlDateTime str;   
   TimeToStruct(date, str);   
   FileWrite(fh, str.year, "/", str.mon, "/", str.day, " ", str.hour, ":", str.min, ":", str.sec," Tick ", ++tick);
}
//+------------------------------------------------------------------+
