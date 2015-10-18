//+------------------------------------------------------------------+
//|                                                 parityReport.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#property script_show_inputs

extern string exSymbol = "EURUSD";

void OnStart()
{
	int count = 0;
	double profit = 0.;
	double lots = 0.;

	for (int k = 0; k < OrdersHistoryTotal(); ++k) {
		if (!OrderSelect(k, SELECT_BY_POS, MODE_HISTORY)) {
			Alert(k, "indeksli emir seçilemedi!!! Hata kodu : ", GetLastError());
			continue;
		}//if
		if (OrderType() > 1)
			continue;
		if (OrderSymbol() != exSymbol)
			continue;
		count++;
		profit += OrderProfit();
		lots += OrderLots();
	} 
	Alert(exSymbol, " paritesinde ", count, " emir. Toplam Lot = ", lots, " Kar/Zarar : ", profit); 
}
//+------------------------------------------------------------------+
