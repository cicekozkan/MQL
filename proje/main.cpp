#include <iostream>
#include <set>
#include <string>
#include <vector>
#include <utility>
#include <cstdlib>
#include <ctime>

using namespace std;

using Packs = vector<vector<string>>;
extern vector<string> validParities;
bool isValidPack(const vector<string> &pack);
string randomParity();
Packs reOrginize(const vector<string> &orders);

int main()
{
	srand(static_cast<unsigned int>(time(nullptr)));
	
	vector<string> orders;
	Packs orderPacks;
	while (true) {
		
		getchar();
		orders.push_back(randomParity());

		cout << "ORDERS: ";
		for (const auto &order : orders)
			cout << order.substr(0,3) << "/" << order.substr(3, 3) << " ";
		cout << endl;

		auto packs = reOrginize(orders);

		int i = 0;
		for (const auto &pack : packs) {
			cout << "pack " << ++i << ":" << endl;
			int k = 0;
			vector<string> validity;
			for (const auto &cur : pack) {
				validity.push_back(cur);
				cout << "cur " << ++k << ": " << cur.substr(0, 3) << "/" << cur.substr(3, 3) << endl;
			}
			cout << boolalpha;
			cout << isValidPack(validity) << endl;
			cout << "--------------" << endl;
		}
		cout << "number of orders is, " << orders.size() << endl;
		cout << "number of packs is, " << packs.size() << endl;
		cout << "=======================" << endl;
	}

	return 0;
}

bool isValidPack(const vector<string> &pack)
{
	set<string> myset;
	for (const auto &r : pack) {
		myset.insert(r.substr(0, 3));
		myset.insert(r.substr(3, 3));
	}
	return myset.size() == 2 * pack.size();
}

string randomParity()
{
	int random = rand() % validParities.size();
	return string(validParities[random]);
}

Packs reOrginize(const vector<string> &orders)
{
	Packs packs;
	for (const auto &order : orders) {
		if (packs.empty()) {
			packs.emplace_back(vector<string>{order});
			continue;
		}
		bool hasPlaced = false;
		for (int priority = 3; priority != 0 && hasPlaced == false; --priority) {
			for (auto &pack : packs) {
				if (pack.size() != priority)
					// if pack size is not same with priority
					continue;
				const string stCur = order.substr(0, 3);
				const string ndCur = order.substr(3, 3);
				auto parity = pack.begin();
				while (parity != pack.end()) {
					if (parity->find(stCur) != string::npos || parity->find(ndCur) != string::npos)
						// if pack has same currency
						break;
					++parity;
				}
				if (parity == pack.end()) {
					pack.push_back(order);
					hasPlaced = true;
					break;
				}
			}
		}
		if (hasPlaced == false)
			packs.emplace_back(vector<string>{order});
	}
	return packs;
}

vector<string> validParities{
	{"EURUSD"}, {"GBPUSD"}, {"USDJPY"}, {"AUDUSD"}, {"USDCAD"}, {"NZDUSD"}, {"USDCHF"},
				{"EURGBP"}, {"EURJPY"}, {"EURAUD"}, {"EURCAD"}, {"EURNZD"}, {"EURCHF"},
							{"GBPJPY"}, {"GBPAUD"}, {"GBPCAD"}, {"GBPNZD"}, {"GBPCHF"},
										{"AUDJPY"}, {"CADJPY"}, {"NZDJPY"}, {"CHFJPY"},
													{"AUDCAD"}, {"AUDNZD"}, {"AUDCHF"},
																{"NZDCAD"}, {"CADCHF"},
																			{"NZDCHF"}
};