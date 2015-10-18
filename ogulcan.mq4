//+------------------------------------------------------------------+
//|                                                      ogulcan.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


#define		STATIC




class Parity {
	const static int msc_bar;
	const static int msc_close_trial;
	const static int msc_open_trial;
	const static int msc_slippage;
	string m_sym;
	double m_lots;
	int m_magic;
	int msl, mtp;
	bool m_b_flag, m_s_flag;
public:
	static bool isNewBar()
	{
		static datetime dt = Time[0];
		if (Time[0] != dt) {
			dt = Time[0];
			return true;
		}
		return false;
	}
	Parity(string sym, double lot, int magic, int slpip, int tppip) : m_sym(sym), m_lots(lot), 
	m_magic(magic), msl(slpip), mtp(tppip), m_b_flag(false), m_s_flag(false) {}
	bool isBuy();
	bool isSell();
	int openPosition(int optype);
	static bool closePosition(int ticket);
	void tracePositions();
	void checkBuy();
	void checkSell();
	
double getActualProfit()const;	
	double getHistoryProfit()const;
	string getInfo()const;
	
	int getMagicNumber()const
	{
		return m_magic;
	}
	
	int getStopLossPip()const 
	{
		return msl;
	}
		
	int getTakeProfitPip()const
	{
		return mtp;
	}
	string getSymbol()const
	{
		return m_sym;
	}
};

const int Parity::msc_bar = 4;
const int Parity::msc_slippage = 0;
const int Parity::msc_close_trial = 3;
const int Parity::msc_open_trial = 3;

void Parity::checkBuy()
{
	if (!m_b_flag && isBuy() && openPosition(OP_BUY) != -1)
		m_b_flag = true;
}

void Parity::checkSell()
{
	if (!m_s_flag && isSell() && openPosition(OP_SELL) != -1)
		m_s_flag = true;
}

double Parity::getActualProfit()const
{
	double total = 0.;
	for (int k = 0; k < OrdersTotal(); ++k) {
		if (!OrderSelect(k, SELECT_BY_POS, MODE_TRADES)) {
			Alert("emir secilemedi.... Hata kodu : ", GetLastError());
			continue;
		}
		if (OrderMagicNumber() == m_magic && OrderSymbol() == m_sym)
			total += OrderProfit();
	}	
	return total;
}

double Parity::getHistoryProfit()const
{
	double total = 0.;
	for (int k = 0; k < OrdersHistoryTotal(); ++k) {
		if (!OrderSelect(k, SELECT_BY_POS, MODE_HISTORY)) {
			Alert("emir secilemedi.... Hata kodu : ", GetLastError());
			continue;
		}
		if (OrderMagicNumber() == m_magic && OrderSymbol() == m_sym)
			total += OrderProfit();
	}	
	return total;
}

string Parity::getInfo()const
{
	double actual_profit = getActualProfit();
	double history_profit = getHistoryProfit();
	double total = actual_profit + history_profit;

	string retval = m_sym + "  " + DoubleToString(actual_profit, 0) + "  " + DoubleToString(history_profit, 0) + 
	"   " + DoubleToString(total, 0);

	return retval;
}

STATIC bool Parity::closePosition(int ticket)
{
	if (!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) {
		Alert(ticket, " No'lu emir secilemedi... Hata kodu : ", GetLastError());
		return false;
	}
	int optype = OrderType();

	for (int k = 0; k < msc_close_trial; ++k) {
		double close_price;
		if (optype == OP_BUY)
			close_price = Bid;
		else
			close_price = Ask;
		if (OrderClose(ticket, OrderLots(), close_price, msc_slippage))
			return true;
		Alert(ticket, " No'lu emir kapatilamadi.... Hata kodu : ", GetLastError());
		RefreshRates();
	}
	return false;
}

int Parity::openPosition(int optype)
{
	int ticket = -1;
	double price;

	for (int k = 0; k < msc_open_trial; ++k) {
		if (optype == OP_SELL)	
			price = MarketInfo(m_sym, MODE_BID);
		else
			price = MarketInfo(m_sym, MODE_ASK);
		ticket = OrderSend(m_sym, optype, m_lots, price, msc_slippage, 0., 0., IntegerToString(m_magic), m_magic);
		if (ticket != -1)
			break;
		Alert(m_sym, " paritesinde ", ((optype == OP_BUY) ? "alýþ" : "satýþ"), " pozisyonu açýlamiyor.... Hata kodu : ", GetLastError());
		RefreshRates();
	}
	return ticket;

}






void Parity::tracePositions()
{
	for (int k = OrdersTotal() - 1; k >= 0; --k) {
		if (!OrderSelect(k, SELECT_BY_POS, MODE_TRADES)) {
			Alert("Emir secilemedi... Hata kodu : ", GetLastError());
			continue;
		}
		if (OrderMagicNumber() == m_magic && OrderSymbol() == m_sym) {
			int optype = OrderType();
			double open_price = OrderOpenPrice();
			double target_stop, target_profit;
			double point = MarketInfo(m_sym, MODE_POINT) * 10.;
			double bid_price = MarketInfo(m_sym, MODE_BID);
			double ask_price = MarketInfo(m_sym, MODE_ASK);
			if (optype == OP_BUY) {
				target_stop = open_price - msl * point;
				target_profit = open_price + mtp * point;
				

				if (bid_price > target_profit || ask_price < target_stop) {
					if (closePosition(OrderTicket()))
						m_b_flag = false;
				}
			}
			else {
				target_stop = open_price + msl * point;
				target_profit = open_price - mtp * point;
				if (ask_price < target_profit || bid_price > target_stop) {
					if (closePosition(OrderTicket()))
						m_s_flag = false;
				}
			}

		}
	}



}

bool Parity::isBuy()
{
	for (int k = 0; k < msc_bar; ++k) {
		if (!(iClose(m_sym, Period(), k + 1) > iClose(m_sym, Period(), k + 2)))
			return false;
	}
	return true;
}

bool Parity::isSell()
{
	for (int k = 0; k < msc_bar; ++k) {
		if (!(iClose(m_sym, Period(), k + 1) < iClose(m_sym, Period(), k + 2)))
			return false;
	}
	return true;
}

Parity *p[5];

int OnInit()
{
	const string apairs[5] = {"EURUSD", "USDJPY", "GBPUSD", "USDCHF", "AUDUSD"};
	const double alots[5] = {1.0, 2., 1.5, 2., 0.5};
	const int asl[5] = {10, 20, 15, 10, 30};
	const int atp[5] = {5, 7, 10, 5, 15};
	const int ano[5] = {345656, 345657, 345658, 345659, 345660};

	for (int k = 0; k < 5; k++) {
		p[k] = new Parity(apairs[k], alots[k], ano[k], asl[k], atp[k]);	
	}
	
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
		for (int k = 0; k < 5; k++) 
			delete p[k];   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void display()
{
	double actual = 0.;
	double history = 0;
	
	for (int k = 0; k < 5; ++k) {
		actual += p[k].getActualProfit();
		history += p[k].getHistoryProfit();
	}
	double total = actual + history;
	Comment(DoubleToString(actual, 0), "   ",  DoubleToString(history, 0), "   ", DoubleToString(total, 0));	
}

void OnTick()
{
	display();

	for (int k = 0; k < 5; ++k) 
		p[k].tracePositions();
	
	if (Parity::isNewBar()) {
		for (int k = 0; k < 5; ++k) {
			p[k].checkBuy();
			p[k].checkSell();
		}
	}
   
}
//+------------------------------------------------------------------+
