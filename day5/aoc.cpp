#include <string>
#include <vector>
#include <iostream>
#include <format>
#include <regex>

using namespace std;
vector<string> readLines()
{
  FILE *fp;
  char *line = NULL;
  size_t len = 0;
  ssize_t read;

  fp = fopen("input.txt", "r");
  if (fp == NULL)
  {
    printf("unable to open file\n");
    exit(-1);
  }
  vector<string> results;
  while ((read = getline(&line, &len, fp)) != -1)
  {
    string str(line);
    if (str.length() > 1)
      results.push_back(string(line));
  }

  free(line);
  return results;
}

struct Move
{
  int count;
  int from;
  int to;
};

void debug(vector<deque<string>> stacks)
{
  int count = 0;
  for (deque<string> stack : stacks)
  {
    cout << ++count << "| ";
    for (string container : stack)
    {
      cout << container;
    }
    cout << endl;
  }
}

vector<deque<string>> parseStacks(vector<string> raw, int numStacks)
{
  vector<deque<string>> stacks(numStacks);
  for (int j = 0; j < numStacks; j++)
  {
    deque<string> v;
    stacks[j] = v;
  }
  for (string line : raw)
  {
    regex exp("([A-Z])");
    smatch res;
    string::const_iterator searchStart(line.cbegin());
    int pos = 0;
    while (regex_search(searchStart, line.cend(), res, exp))
    {
      pos += (res.position() + 1) / 4;
      stacks[pos].push_back(res[0]);
      searchStart = res.suffix().first;
    }
  }
  return stacks;
}

vector<Move> parseMoves(vector<string> raw)
{
  vector<Move> moves;
  for (string moveString : raw)
  {
    smatch matches;
    regex rgx("move (\\d+) from (\\d+) to (\\d+)", regex_constants::ECMAScript);
    regex_search(moveString, matches, rgx);

    Move move{
        stoi(matches[1]),
        stoi(matches[2]),
        stoi(matches[3])};
    moves.push_back(move);
  }
  return moves;
}

void crateMover9000(vector<deque<string>> &stacks, vector<Move> const &moves)
{
  cout << "**CrateMover9000**";

  for (Move m : moves)
  {
    for (int j = 0; j < m.count; j++)
    {
      stacks[m.to - 1].push_front(stacks[m.from - 1][0]);
      stacks[m.from - 1].pop_front();
    }
  }
}
void crateMover9001(vector<deque<string>> &stacks, vector<Move> const &moves)
{
  cout << "**CrateMover9001**" << endl;
  for (Move m : moves)
  {
    for (int j = m.count; j > 0; j--)
    {
      stacks[m.to - 1].push_front(stacks[m.from - 1][j - 1]);
    }
    for (int j = m.count; j > 0; j--)
    {
      stacks[m.from - 1].pop_front();
    }
    debug(stacks);
  }
}

int main()
{
  vector<string> data = readLines();

  int i;
  for (i = 0; data[i].substr(1, 1) != "1"; i++)
    ;
  int numStacks = stoi(data[i].substr(data[i].length() - 3, 1));
  vector<string> rawMoves(data.begin() + i + 1, data.begin() + data.size());
  vector<string> rawStacks(data.begin(), data.begin() + i);
  vector<deque<string>> stacks = parseStacks(rawStacks, numStacks);
  vector<Move> moves = parseMoves(rawMoves);
  debug(stacks);

  //  crateMover9000(stacks,moves);
  crateMover9001(stacks, moves);
  cout << "**result**" << endl;
  debug(stacks);
  for (deque<string> stack : stacks)
  {
    cout << stack[0];
  }
  cout << endl;
  return 0;
}
