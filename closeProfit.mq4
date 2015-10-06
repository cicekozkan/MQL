//+------------------------------------------------------------------+
//|                                                  closeProfit.mq4 |
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
	for (int k = OrdersTotal() - 1; k >= 0; --k)  {
		if (!OrderSelect(k, SELECT_BY_POS, MODE_TRADES)) {
			Alert(k, "indeksli emir seçilemedi!!! Hata kodu : ", GetLastError());
			continue;
		}//if
		int op_type = OrderType();
		if (op_type > 1)
			continue;
		/////
		if (OrderProfit() >= 0)
			continue;
		double cl_price;

		if (op_type == OP_BUY)
			cl_price = MarketInfo(OrderSymbol(), MODE_BID);
		else
			cl_price = MarketInfo(OrderSymbol(), MODE_ASK);
	
		int ticket = OrderTicket();
		if (!OrderClose(ticket, OrderLots(), cl_price, 0)) {
			Alert(ticket, " no.lu emir kapatilamiyor... Hata kodu : ", GetLastError());
			continue;
		}
	}



   
  }
//+------------------------------------------------------------------+
