#include "scripts.h"
#include <fstream>
#include "Dmap.h"
#include <Hash.h>

using namespace std;
using namespace iret;


int make_word_set(char* file, char* hash)
{
  ifstream fin(file);
  if(!fin) {
    cerr << "Cannot open " << file << endl;
    return 1;
  }

  strMap Lst;
  string line;
  while( getline(fin,line) ) {
    Lst.add_count(line.c_str(), 1);
  }

  Hash Hsh(hash); //name of a hash set
  Hsh.set_path_name("Ab3P");
  Hsh.create_htable(Lst,3);

  return 0;
}


int make_word_count_hash(char* file)
{
  ifstream fin(file);
  if(!fin) {
    cout << "Cannot open " << file << endl;
    return 1;
  }

  strMap Ct;

  string word;
  long num;
  string dummy;

  long cnt = 0;
  while(getline(fin,word,'|')) {
    fin >> num;
    getline(fin,dummy);           //remove endl;
    if( word.size() <3) continue; // want length>=3
    if(num < 100) continue;        // want freq>=100
    Ct.add_count(word.c_str(),num);
    cnt++;
  }

  cout << cnt << " words selected" << endl;

  Chash Csh("wrdset3");
  Csh.set_path_name("Ab3P");
  Csh.create_ctable(Ct,3);

  return 0;
}

