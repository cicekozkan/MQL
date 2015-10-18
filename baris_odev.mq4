//+------------------------------------------------------------------+
//|                                                   baris_odev.mq4 |
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

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
extern int 		exLastnBars 	= 3;
extern int 		exMaxOpenTrial	= 5;
extern int 		exMaxCloseTrial	= 5;
extern int 		exSlippage		= 0;
extern int 		exMagicNumber	= -6253222;
extern int		exStoplossPip	= 10;
extern int		exTakeprofitPip	= 5;

extern double 	exLots 			= 1.0;


bool gSellFlag = false;
bool gBuyFlag = false;

void display()
{
	double actual_total = 0.;
	double history_total = 0.;
	
	for (int k = 0; k < OrdersTotal(); ++k) {
		if (!OrderSelect(k, SELECT_BY_POS, MODE_TRADES)) {
			Alert("emir secilemedi.... Hata kodu : ", GetLastError());
			continue;
		}
		if (OrderMagicNumber() == exMagicNumber && OrderSymbol() == Symbol())
			actual_total += OrderProfit();
	}

	GlobalVariableSet
	for (int k = 0; k < OrdersHistoryTotal(); ++k) {
		if (!OrderSelect(k, SELECT_BY_POS, MODE_HISTORY)) {
			Alert("emir secilemedi.... Hata kodu : ", GetLastError());
			continue;
		}
		if (OrderMagicNumber() == exMagicNumber && OrderSymbol() == Symbol())
			history_total += OrderProfit();
	}	
	double total = actual_total + history_total;
	Comment(DoubleToString(actual_total, 1), "  ", DoubleToString(history_total, 1), "  ", DoubleToString(total, 1));
}


bool closeOrder(int ticket)
{
	if (!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) {
		Alert(ticket, " No'lu emir secilemedi... Hata kodu : ", GetLastError());
		return false;
	}
	int optype = OrderType();

	for (int k = 0; k < exMaxCloseTrial; ++k) {
		double close_price;
		if (optype == OP_BUY)
			close_price = Bid;
		else
			close_price = Ask;
		if (OrderClose(ticket, OrderLots(), close_price, exSlippage))
			return true;
		Alert(ticket, " No'lu emir kapatilamadi.... Hata kodu : ", GetLastError());
		RefreshRates();
	}
	return false;
}

void tracePositions()
{
	for (int k = OrdersTotal() - 1; k >= 0; --k) {
		if (!OrderSelect(k, SELECT_BY_POS, MODE_TRADES)) {
			Alert("Emir secilemedi... Hata kodu : ", GetLastError());
			continue;
		}
		if (OrderMagicNumber() == exMagicNumber && OrderSymbol() == Symbol()) {
			
			int optype = OrderType();
			
			double open_price = OrderOpenPrice();
			double target_stop, target_profit;
		
			if (optype == OP_BUY) {
				target_stop = open_price - exStoplossPip * 10. * Point;
				target_profit = open_price + exTakeprofitPip * 10. * Point;
				if (Bid > target_profit || Ask < target_stop) {
					if (closeOrder(OrderTicket()))
						gBuyFlag = false;
				}
			}
			else {
				target_stop = open_price + exStoplossPip * 10. * Point;
				target_profit = open_price - exTakeprofitPip * 10. * Point;
				if (Ask < target_profit || Bid > target_stop) {
					if (closeOrder(OrderTicket()))
						gSellFlag = false;
				}
			}

		}
	}


}







int openPosition(int optype)
{
	int ticket = -1;
	double price;

	for (int k = 0; k < exMaxOpenTrial; ++k) {
		if (optype == OP_SELL)	
			price = Bid;
		else
			price = Ask;
		ticket = OrderSend(Symbol(), optype, exLots, price, exSlippage, 0., 0., IntegerToString(exMagicNumber), exMagicNumber);
		if (ticket != -1)
			break;
		Alert(Symbol(), " paritesinde ", ((optype == OP_BUY) ? "alýþ" : "satýþ"), " pozisyonu açýlamiyor.... Hata kodu : ", GetLastError());
		RefreshRates();
	}
	return ticket;
}


bool isBuy()
{
	for (int k = 0; k < exLastnBars; ++k)
		if (!(Close[k + 1] > Close[k + 2]))
			return false;
	
	return true;
}

bool isSell()
{
	for (int k = 0; k < exLastnBars; ++k)
		if (!(Close[k + 1] < Close[k + 2]))
			return false;
	
	return true;
}

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
bool isNewBar()
{
	static datetime dt = Time[0];

	if (dt != Time[0]) {
		dt = Time[0];
		return true;
	}
	return false;
}
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
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

   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
	display();
	tracePositions();

	if (isNewBar()) {
		if (!gBuyFlag && isBuy()) {
			if (openPosition(OP_BUY) != -1)
				gBuyFlag = true;
		}
		else if (!gSellFlag && isSell()) {
			if (openPosition(OP_SELL) != -1)
				gSellFlag = true;
		}
	}

}
//+------------------------------------------------------------------+
