//+------------------------------------------------------------------+
//|                                                      ogulcan.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern double exTargetProfit = 500.;

#define STATIC

// classlari kullandigimiz ilk ornek
// hedef: her bir pariteyi bir sinif nesnesi ile kontrol etmek
// constructolar, destructorlar, sanal functions... bir cok ozellik var
// ama tabi C++11 gibi gelismis degil


/*!
  Parity class. baris_odevdeki isleri yapabilecek basit bir class
*/
class Parity{
   const static int msc_bar;  // burada ilk deger veremiyorsun
   const static int msc_open_trial;
   const static int msc_close_trial;
   const static int msc_slippage;
   int m_magic;
   string m_sym;
   double m_lots;
   int msl, mtp;
   bool m_b_flag, m_s_flag;   // buy flag, sell flag
public:
   static bool isNewBar(){
      static datetime dt = Time[0];
      if (Time[0] != dt){
         dt = Time[0];
         return true;
      }
      return false;
   }
   Parity(string sym, double lot, int magic, int slpip, int tppip): m_sym(sym), m_lots(lot), m_magic(magic), 
   msl(slpip), mtp(tppip), m_b_flag(false), m_s_flag(false){} // {} kullanamazsin  
   bool isBuy();
   bool isSell();
   int openPosition(int optype); 
   static bool closePosition(int ticket); 
   string getInfo()const;
   double getActualProfit()const;
   double getHistoryProfit()const;
   int getMagicNumber()const{
      return m_magic;
   }
   void tracePositions(); 
   int getStopLossPip()const{
      return msl;
   }
   int getTakeProfitPip()const{
      return mtp;
   }
   string getSymbol()const{
      return m_sym;
   }
   void checkBuy();
   void checkSell();
};

const int Parity::msc_bar = 4;
const int Parity::msc_open_trial = 3;
const int Parity::msc_close_trial = 3;
const int Parity::msc_slippage = 0;

void Parity::checkBuy(void)
{
   if(!m_b_flag && isBuy() && openPosition(OP_BUY) != -1)
      m_b_flag = true;   
}

void Parity::checkSell(void)
{
   if(!m_s_flag && isSell() && openPosition(OP_SELL) != -1)
      m_s_flag = true;   
}

double Parity::getActualProfit()const
{
   double total = 0;
   for(int k = 0; k < OrdersTotal(); ++k){
      if(!OrderSelect(k, SELECT_BY_POS, MODE_TRADES)){
         Alert("Emir secilemedi... Hata kodu: ", GetLastError());
         continue;
      }
      if(OrderMagicNumber() == m_magic && OrderSymbol() == m_sym)
         total += OrderProfit();
   }//end for
   
   return total;
}

double Parity::getHistoryProfit()const
{
   double total = 0;
   for(int k = 0; k < OrdersHistoryTotal(); ++k){
      if(!OrderSelect(k, SELECT_BY_POS, MODE_HISTORY)){
         Alert("Emir secilemedi... Hata kodu: ", GetLastError());
         continue;
      }
      if(OrderMagicNumber() == m_magic && OrderSymbol() == m_sym)
         total += OrderProfit();
   }//end for
   
   return total;
}

string Parity::getInfo(void)const
{
   double actual_profit = getActualProfit();
   double history_profit = getHistoryProfit();
   double total = actual_profit + history_profit;
   
   string retval = m_sym + " " + DoubleToStr(actual_profit, 0) + " " + DoubleToStr(history_profit, 0) + " " + DoubleToStr(total, 0);
   return retval;
}

STAIC bool Parity::closePosition(int ticket)
{
   if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)){
      Alert(ticket, "No'lu emir secilemedi. Hata kodu: ", GetLastError());
      return false;
   }
   
   int optype = OrderType();  // returns the order type. OP_BUY, OP_SELL, OP_BUYLIMIT, OP_BUYSTOP, OP_SELLLIMIT, OP_SELLSTOP
   
   for(int k = 0; k < msc_close_trial; ++k){
      double close_price;
      if(optype == OP_BUY){
         close_price = Bid;   // get bid when closing a buy position
      }else{
         close_price = Ask;   // get ask when closing a sell position. the opposite when opening position
      }
      if(OrderClose(ticket, OrderLots(), close_price, msc_slippage))
         return true;
      RefreshRates();
   }//end for
   Alert(ticket, "No'lu emir kapatilamadi. Hata kodu: ", GetLastError());
   return false;
}

int Parity::openPosition(int optype)   
{
   int ticket = -1;
   double price;
   
   for(int k = 0; k < msc_open_trial; ++k){
      if(optype == OP_SELL)
         price = MarketInfo(m_sym, MODE_BID);
      else
         price = MarketInfo(m_sym, MODE_ASK);
         
      ticket = OrderSend(m_sym, optype, m_lots, price, msc_slippage, 0., 0., IntegerToString(m_magic), m_magic);
      if(ticket != -1)   
         break;
      RefreshRates();
   }//end for
   Alert(m_sym, " paritesinde ", ((optype == OP_BUY) ? "al��" : "sat��"), " pozisyonu a��lamiyor.... Hata kodu : ", GetLastError());
   return ticket;
}

void Parity::tracePositions(void)
{
   for(int k = OrdersTotal() - 1; k >= 0; --k){
      if(!OrderSelect(k, SELECT_BY_POS, MODE_TRADES)){
         Alert("Emir secilemedi... Hata kodu: ", GetLastError());
         continue;
      }
      if(OrderMagicNumber() == m_magic && OrderSymbol() == m_sym){
         int optype = OrderType();
         double open_price = OrderOpenPrice();
         double target_stop, target_profit;
         double point = MarketInfo(m_sym, MODE_POINT)*10.;
         double bid_price = MarketInfo(m_sym, MODE_BID);
         double ask_price = MarketInfo(m_sym, MODE_ASK);
         
         if(optype == OP_BUY){
            target_stop = open_price - msl * point;
            target_profit = open_price + mtp * point;
            
            if(bid_price > target_profit || ask_price < target_stop){
               if(closePosition(OrderTicket()))
                  m_b_flag = false;
            }
         }//end OP_BUY
         else{
            target_stop = open_price + msl * point;
            target_profit = open_price - mtp * point;
            
            if(ask_price < target_profit || bid_price > target_stop){
               if(closePosition(OrderTicket()))
                  m_s_flag = false;
            }            
         }// end else(OP_SELL)
      }//end if
   }//end for

}

bool Parity::isBuy(void)
{
   // Period() grafigin kendi periyodu. PERIOD_M5 gibi enum da gecebilirsin
   for(int k = 0; k < msc_bar; ++k){
      if(!(iClose(m_sym, Period(), k + 1) > iClose(m_sym, Period(), k + 2)))
         return false;
   }
   return true;
}

bool Parity::isSell(void)
{
   // Period() grafigin kendi periyodu. PERIOD_M5 gibi enum da gecebilirsin
   // Ama bu iClose hangi barin close priceini geri donuyor? Girdigimiz symbolun 
   // son bari mi? sondan bir onceki mi? burada nasil loop ediyoruz? bu for loopta
   // sondan 3 onceki bara mi bakiyor? Acik olan butun barlara mi bakiyor?
   // nasil for loop yapiyor? Her seferinde son acilan muma mi bakiyor? oyleyse
   // Period()*msc_bar kadar surede geri doner bu fonksiyon
   for(int k = 0; k < msc_bar; ++k){
      if(!(iClose(m_sym, Period(), k + 1) < iClose(m_sym, Period(), k + 2)))
         return false;
   }
   return true;
}





Parity *p[5];

int OnInit()
{
   const string pairs[5] = {"EURUS", "USDJPY", "GBPUSD", "USDCHF", "AUDUSD"};
   const double alots[5] = {1.0, 2.0, 1.5, 2.0, 0.5};
   const int asl[5] = {10, 20, 15, 10, 30};
   const int atp[5] = {5, 7, 10, 5, 15};
   const int ano[5] = {345656, 345657, 345658, 345659, 345660};
   
   for(int k = 0; k < 5; ++k){
      p[k] = new Parity(pairs[k], alots[k], ano[k], asl[k], atp[k]);
   }
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   for(int k = 0; k < 5; ++k){
      delete p[k]; 
   }
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void display()
{
   double actual = 0.;
   double history = 0.;
      
   for (int k = 0; k < 5; ++k){
      actual += p[k].getActualProfit();
      history += p[k].getHistoryProfit();      
   }//end for
   double total = actual + history;
   Comment(DoubleToStr(actual, 0), " ", DoubleToStr(history, 0), " ", DoubleToStr(total, 0));
}

void OnTick()
{
   display();
   
   for(int k=0; k<5; ++k){
      p[k].tracePositions();
   }
   
   
   if(Parity::isNewBar()){
      for(int k = 0; k<5; ++k){
         p[k].checkBuy();
         p[k].checkSell();
      }
   }   
}
//+------------------------------------------------------------------+
//magic numberla kapatan bir fonksiyon. statik fonksiyon
void Parity::close_pos(int magic)
{
   
}

void checkCloseAll()
{
   double total = 0;
   for(int k=0; k<5; ++k){
      total += p[k].getActualProfit() + p[k].getHistoryProfit();
   }
   if (total > exTargetProfit){
      for(int k=0; k<5; ++k){
         close_pos(p[k].getMagicNumber())
      }
      ExpertRemove();   // motoru tamamen durdur
   }
}