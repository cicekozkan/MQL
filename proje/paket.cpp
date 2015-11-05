#include <iostream>
#include <set>
#include <string>

using namespace std;


bool isValidPack(initializer_list<string> x)
{
	set<string> myset;
	for (const auto &r : x) {
		myset.insert(r.substr(0, 3));
		myset.insert(r.substr(3, 3));
	}
	return myset.size() == 2 * x.size();
}


int main() 
{
	cout << boolalpha;

	cout << isValidPack({ "EURUSD" }) << endl;
	cout << isValidPack({ "EURUSD", "GBPJPY", "AUDCAD", "NZDCHF"}) << endl;


	return 0;
}