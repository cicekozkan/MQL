#include <iostream>
#include <cstdlib>
#include <vector>
using namespace std;

int main(){

class Pair
{ 
	
public:
	string Currency1, Currency2;
	Pair(){}
	Pair(string cur1,string cur2) : Currency1(cur1), Currency2(cur2){}

};

auto Groups = vector<vector<Pair>>();


// Start
auto newPosition = Pair ("USD","JPY");

bool added = false;

for (int i = 0; i < Groups.size(); ++i)
{
 auto items = Groups[i];
 bool matchFound = false;
 
 for (int j = 0; j < items.size(); ++j)
 {
  auto item = items[j];

  //String comparing
  if (newPosition.Currency1 == item.Currency1 || newPosition.Currency2 == item.Currency2 || newPosition.Currency1 == item.Currency2 || newPosition.Currency2 == item.Currency1)
  {
   matchFound = true;
   break;
  }
 }
 
 if (!matchFound && items.size() < 4)
 {
	items.push_back(newPosition);
	added = true;
	break;
 }
}

if (!added)
{

 auto Group = vector<Pair>();
 
 Group.push_back(newPosition);

 Groups.push_back(Group);
}
	return 0;
}