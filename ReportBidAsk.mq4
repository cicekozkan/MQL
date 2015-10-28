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
      string tfilename = OrderSymbol() + "_" + IntegerToString(str.year) + IntegerToString(str.mon,2, '0')
                         + IntegerToString(str.day,2, '0') + "_" + IntegerToString(str.hour,2, '0') + 
                         IntegerToString(str.min,2, '0') + IntegerToString(str.sec,2, '0') + ".txt";
      tfh = FileOpen(tfilename, FILE_WRITE | FILE_TXT); 
      if (tfh == INVALID_HANDLE){
         Alert(tfilename, " cannot be opened. The error code = ", GetLastError());
         ExpertRemove();
      }else{
         //FileWrite(tfh, AccountCompany());
      }
   }
   
   if(flags & FILE_BIN){   
      string bfilename = OrderSymbol() + "_" + IntegerToString(str.year) + IntegerToString(str.mon,2, '0')
                         + IntegerToString(str.day,2, '0') + "_" + IntegerToString(str.hour,2, '0') + 
                         IntegerToString(str.min,2, '0') + IntegerToString(str.sec,2, '0') + ".dat";
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
      Alert("Binary veya text dosya modundan biri secilmedi. Baslamak icin dosya modu secin");  // gelecekte bunu extern olarak alirsak lazim olacak
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
   int date = (int)(TimeCurrent());  
   double bid = MarketInfo(OrderSymbol(), MODE_BID);
   double ask = MarketInfo(OrderSymbol(), MODE_ASK);
   if (text) if (FileWrite(tfh, date, DoubleToStr(bid, Digits), DoubleToStr(ask, Digits)))   tline++; // dosyaya yazamama durumunda simdilik hata verme
   if (binary) if (FileWrite(bfh, date, DoubleToStr(bid, Digits), DoubleToStr(ask, Digits))) bline++; 
   if (tline >= MAX_LINES)  {OpenFiles(FILE_TXT); tline = 0;}
   if (bline >= MAX_LINES)  {OpenFiles(FILE_BIN); bline = 0;}
}
//+------------------------------------------------------------------+
