//+------------------------------------------------------------------+
//|                                                     Marubozu.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//|      This expert advisor will run only on one parity             |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

class Marubozu{
   double m_diff;
   bool m_increased;
public:
   Marubozu(double diff, bool increased): m_diff(diff), m_increased(increased){}
   Marubozu(const Marubozu &r) {
      m_diff = r.get_diff();
      m_increased = r.is_increased();
   };
   /* not supported?
   Marubozu& operator=(Marubozu &&r){
      m_diff = r.get_dif();
      m_increased = r.is_increased();
   }
   */
   
   double get_diff()const{
      return m_diff;
   }
   bool is_increased()const{
      return m_increased;
   }
   
   //Marubozu* operator=(const Marubozu &r);
};

/*
Marubozu* Marubozu::operator=(const Marubozu &r){
   m_diff = r.get_diff();
   m_increased = r.is_increased();
   return GetPointer(this);
}
*/
//+------------------------------------------------------------------+
/*!
  Parity class. baris_odevdeki isleri yapabilecek basit bir class
*/
class Parity{
   const static int msc_open_trial;
   const static int msc_close_trial;
   const static int msc_slippage;
   int m_magic;
   string m_sym;
   double m_lots;
   int msl, mtp;
   bool m_b_flag, m_s_flag;   ///< buy flag, sell flag
   const static int msc_pips_ignore_wick; ///< the amount of pips to ignore when deciding whether marubozu or not
   const static double msc_min_diff_to_open_position;
public:
   /*!
   \fn bool isNewBar()
   \brief Find out if a new bar has been created 
   \return true if the current bar is new false otherwise 
   */
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
   bool isMarubozu(int i_candle);
   static Marubozu* getMarubozu(int i_candle);
};

const int Parity::msc_open_trial = 3;
const int Parity::msc_close_trial = 3;
const int Parity::msc_slippage = 3; // slippage changed to 3
const int Parity::msc_pips_ignore_wick = 0;
const double Parity::msc_min_diff_to_open_position = 0.0;

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

bool Parity::closePosition(int ticket)
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
   Alert(m_sym, " paritesinde ", ((optype == OP_BUY) ? "alýþ" : "satýþ"), " pozisyonu açýlamiyor.... Hata kodu : ", GetLastError());
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
   if (isMarubozu(1) && isMarubozu(2)){
      Marubozu m1 = getMarubozu(1);
      Marubozu m2 = getMarubozu(2);
      if ( (m1.is_increased()) && !(m2.is_increased()) )
         if ( (m1.get_diff() >= msc_min_diff_to_open_position) && (m2.get_diff() >= msc_min_diff_to_open_position)){
            return true;
         }
   }
   return false;
}

bool Parity::isSell(void)
{
   if (isMarubozu(1) && isMarubozu(2)){
      Marubozu m1(getMarubozu(1));
      Marubozu m2(getMarubozu(2));
      if ( !(m1.is_increased()) && (m2.is_increased()) )
         if ( (m1.get_diff() >= msc_min_diff_to_open_position) && (m2.get_diff() >= msc_min_diff_to_open_position)){
            return true;
         }
   }
   return false;
}

/*!
\fn bool isMarubozu(void)
\brief Decide whether the previous candle is a marubozu or not
\param  i_candle: Candle index. 0: current candle, 1: previous, ... Bars-1
\return true if marubozu false if not
*/
bool Parity::isMarubozu(int i_candle)
{
   double open = Open[i_candle];
   double close = Close[i_candle];
   double high = High[i_candle];
   double low = Low[i_candle];
   double point = MarketInfo(m_sym, MODE_POINT)*10.;   
   double ignore = msc_pips_ignore_wick*point;
   
   if (open < close){
      // price increased
      if ( ( (open-low) <= ignore ) && ( (high-close) <= ignore ) )
         return true;
   }else if (open > close){
      // price decreased
      if ( ( (high-open) <= ignore ) && ( (close-low) <= ignore ) )
         return true;
   }
   return false;
}

/*!
\fn Marubozu Parity::getMarubozu(int i_candle)const
\brief Call this member function if i_candle is marubozu; check it with isMarubozu member function first
\return Marubozu class object
*/
Marubozu* Parity::getMarubozu(int i_candle)
{
   double open = Open[i_candle];
   double close = Close[i_candle];
   double high = High[i_candle];
   double low = Low[i_candle];
   
   if (open < close){
      // price increased
      return new Marubozu(high-low, true);
   }else if (open > close){
      // price decreased
      return new Marubozu(high-low, false);
   }
   return new Marubozu(high-low, false); // dummy return
}

class MarubozuEngine{
   Parity *m_p; ///< parity. Work only on current parity
   const static double msc_lot; 
   const static int msc_sl;
   const static int msc_tp; 
   const static int msc_no;
public:
   /**
   * Constructor
   */
   MarubozuEngine(){
      m_p = new Parity(Symbol(), msc_lot, msc_no, msc_sl, msc_tp);
      //Alert("MarubozuEngine constructed!");
   }  
   ~MarubozuEngine(){
      delete m_p;
   }
   /**
   * Display member function
   */
   void display(void)const;
   /**
   *  Trace positions
   */
   void trace(void){
      m_p.tracePositions();      
   }   
   
   void checkNewPossibilities(void){
      if(Parity::isNewBar()){
         m_p.checkBuy();
         m_p.checkSell();         
      } 
   }  
};

const double MarubozuEngine::msc_lot = 1.0; 
const int MarubozuEngine::msc_sl = 20;
const int MarubozuEngine::msc_tp = 30; 
const int MarubozuEngine::msc_no = 356979;

void MarubozuEngine::display()const
{
   double actual = 0.;
   double history = 0.;
  
   actual += m_p.getActualProfit();
   history += m_p.getHistoryProfit();      
   
   double total = actual + history;
   Comment(DoubleToStr(actual, 0), " ", DoubleToStr(history, 0), " ", DoubleToStr(total, 0));
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
MarubozuEngine engine;

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
   /*
   if (isMarubozu()) { 
      if (alert == true){ 
         Alert(Symbol(), " Paritesinde Marubozuuu!!!");
         alert = false;  
      }
   }
   if (isNewBar() && !isMarubozu())   alert = true;
   */
   engine.display();
   engine.trace();
   engine.checkNewPossibilities();
}