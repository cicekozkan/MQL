//+------------------------------------------------------------------+
//|                                                       kazim1.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs

input int 		inNumberOfOrders = 10;
input int 		inMagicNo = 0;
input double	inOrderLots = 1.0;
input int		inSlippage = 0;
extern double	exTakeProfitPip = 0.;
extern double	exStopLossPip = 0.;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

void OnStart()
{
	string apairs[15] =  {"EURUSD", "GBPUSD", "USDJPY", "USDCHF", "USDCAD", "AUDUSD", "NZDUSD",
						"EURJPY", "EURGBP", "EURCHF", "EURAUD", "EURNZD", "EURCAD", "GBPCHF", "GBPJPY"};

	MathSrand((uint)TimeCurrent());

	for (int k = 0; k < inNumberOfOrders; ++k) {
		string sym = apairs[MathRand() % 15];
		int optype;
		double price;

		if (MathRand() % 2 == 0) {  //ALIÞ DURUMU
			optype = OP_BUY;
			price = MarketInfo(sym, MODE_ASK);
		}
		else {   //SATIÞ DURUMU
			optype = OP_SELL;
			price = MarketInfo(sym, MODE_BID);		
		}
		double stoploss;
		double takeprofit;
		
		double point = MarketInfo(sym, MODE_POINT) * 10.;

		if (exStopLossPip == 0)
			stoploss = 0.;
		else if (optype == OP_BUY)
			stoploss = price - exStopLossPip * point;
		else
			stoploss = price + exStopLossPip * point;

		
		if (exTakeProfitPip == 0)
			takeprofit = 0.;
		else if (optype == OP_BUY)
			takeprofit = price + exTakeProfitPip * point;
		else
			takeprofit = price - exTakeProfitPip * point;
			
		string comment = NULL;

		if (inMagicNo != 0)
			comment = IntegerToString(inMagicNo);

		int result = OrderSend(sym, optype, inOrderLots, price, inSlippage, stoploss, takeprofit, comment, inMagicNo);
		if (result == -1) {
			Alert(sym, " paritesinde ", (optype == OP_BUY) ? "alýþ" : "satýþ", " emri açýlamadý... Hata kodu : ", GetLastError());
		}
	} //for
	

	

}
//+------------------------------------------------------------------+
