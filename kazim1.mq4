//+------------------------------------------------------------------+
//|                                                       kazim1.mq4 |
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
int gMagicNo = 7865;

void OnStart()
{
	string apairs[10] =  {"EURUSD", "GBPUSD", "USDJPY", "EURCHF", "USDCAD", "USDCHF", "AUDUSD", "NZDUSD",
						"EURJPY", "GBPJPY"};
	MathSrand((uint)TimeCurrent());

	for (int k = 0; k < 10; ++k)  {
		int optype;
		double price;
		if (MathRand() % 2 == 0) {
			optype = OP_BUY;
			price = MarketInfo(apairs[k], MODE_ASK);
		}
		else {
			optype = OP_SELL;
			price = MarketInfo(apairs[k], MODE_BID);
		}
		int val = OrderSend(apairs[k], optype, 1.0, price, 0, 0., 0., "kazim", gMagicNo);
		if (val == -1) {
			Alert(apairs[k], " paritesinde ", (optype == OP_BUY) ? "alýþ" : "satýþ", "emri açýlamýyor... Hata Kodu : ", GetLastError());
			continue;
		}
		//
	}


}
//+------------------------------------------------------------------+
