#include <string>
#include <vector>
#include <iostream>
#include <format>


using namespace std;
vector<string> readLines()
{
  FILE *fp;
  char *line = NULL;
  size_t len = 0;
  ssize_t read;

  fp = fopen("test.txt", "r");
  if (fp == NULL)
  {
    printf("unable to open file\n");
    exit(-1);
  }
  vector<string> results;
  while ((read = getline(&line, &len, fp)) != -1)
  {
    std::string str(line);
    results.push_back(string(line));
  }

  free(line);
  return results;
}

int main()
{
  vector<string> data = readLines();
  for (size_t i = 0; i < data.size(); i++)
  {
    std::cout << "line: " << data[i];
  }

  return 0;
}
