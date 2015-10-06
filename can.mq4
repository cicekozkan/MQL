//+------------------------------------------------------------------+
//|                                                          can.mq4 |
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

string GetOrderTypeStr(int otype)
{
	switch (otype)  {
		case OP_BUY : return "ALIÞ";
		case OP_SELL : return "SATIÞ";
		case OP_BUYLIMIT : return "BUYLIMIT";
		case OP_BUYSTOP : return "BUYSTOP";
		case OP_SELLLIMIT : return "SELLLIMIT";
		case OP_SELLSTOP : return "SELLSTOP";
	}
	return "";
}

void OnStart()
{
	for (int k = 0; k < OrdersTotal(); ++k) {
		if (!OrderSelect(k, SELECT_BY_POS, MODE_TRADES)) {
			Alert(k, "indeksli emir seçilemedi!!! Hata kodu : ", GetLastError());
			continue;
		}//if
		double price = OrderOpenPrice();
		string sprice = DoubleToString(price, (int)MarketInfo(OrderSymbol(), MODE_DIGITS));
		Alert(OrderTicket(), " ", OrderSymbol(), " ", GetOrderTypeStr(OrderType()), " ", sprice);

	} //for
   
}
//+------------------------------------------------------------------+
