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
#define MAX_LINES 1000 
int tfh = INVALID_HANDLE;
int bfh = INVALID_HANDLE;
int tline = 0;
int bline = 0;


void OpenFiles(char flags)
{

   datetime date = TimeCurrent();
   MqlDateTime str;   
   TimeToStruct(date, str); 
     
   if(!OrderSelect(0, SELECT_BY_POS, MODE_TRADES)){
      Alert("Emir secilemedi... Hata kodu: ", GetLastError());
      ExpertRemove();
   }
   
   if(flags & FILE_TXT){   
      string tfilename = OrderSymbol() + "_" + (string)str.year + (string)str.mon + (string)str.day + "_" + 
                     (string)str.hour + (string)str.min + (string)str.sec + ".txt";
      tfh = FileOpen(tfilename, FILE_WRITE | FILE_TXT); 
      if (tfh == INVALID_HANDLE){
         Alert(tfilename, " cannot be opened. The error code = ", GetLastError());
         ExpertRemove();
      }else{
         //FileWrite(tfh, AccountCompany());
      }
   }
   
   if(flags & FILE_BIN){   
      string bfilename = OrderSymbol() + "_" + (string)str.year + (string)str.mon + (string)str.day + "_" + 
                     (string)str.hour + (string)str.min + (string)str.sec + ".dat";
      bfh = FileOpen(bfilename, FILE_WRITE | FILE_BIN); 
      if (bfh == INVALID_HANDLE){
         Alert(bfilename, " cannot be opened. The error code = ", GetLastError());
         ExpertRemove();
      }else{
         FileWrite(bfh, AccountCompany());
      }
   }
   
}

int OnInit()
{   
   if(!(binary || text)){
      Alert("Binary veya text dosya modundan biri secilmedi. Baslamak icin dosya modu secin");  // gelecekte bunu extern olarak alirsak 
      ExpertRemove();
   }
   char flags = 0;
   if (binary) flags |= FILE_BIN;
   if (text)   flags |= FILE_TXT;
   OpenFiles(flags);  
      
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if (tfh != INVALID_HANDLE) FileClose(tfh);   
   if (bfh != INVALID_HANDLE) FileClose(bfh); 
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   int date = (int)TimeCurrent();  
   //FileWrite(fh, str.year, "/", str.mon, "/", str.day, " ", str.hour, ":", str.min, ":", str.sec," Tick ", ++tick);
   double bid = NormalizeDouble(MarketInfo(OrderSymbol(), MODE_BID), 5);
   double ask = NormalizeDouble(MarketInfo(OrderSymbol(), MODE_ASK), 5);
   if (text) if (FileWrite(tfh, (int)date, bid, ask))   tline++; // dosyaya yazamama durumunda simdilik hata verme
   if (binary) if (FileWrite(bfh, (int)date, bid, ask)) bline++; 
   if (++tline >= MAX_LINES)  OpenFiles(FILE_TXT);
   if (++bline >= MAX_LINES)  OpenFiles(FILE_BIN);
}
//+------------------------------------------------------------------+
