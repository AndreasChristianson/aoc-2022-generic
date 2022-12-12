using System.Diagnostics;

namespace day12;


public static class Extension
{
  public static IEnumerable<T> WhereNotNull<T>(this IEnumerable<T?> o) where T : class
  {
    return o.Where(x => x != null)!;
  }
}
internal class Program
{
  private static void Main(string[] args)
  {
    var grid = ParseFile("input.txt");
    var start = grid.Values.Where(loc => loc.IsEnd).First();
    var queue = new LinkedList<Location>();
    start.Distance = 0;
    queue.AddFirst(start);
    while (queue.Count > 0)
    {
      var curr = queue.First.Value;
      Console.WriteLine($"curr {curr})");
      queue.RemoveFirst();
      var potentials = new List<Tuple<int, int>> {
        new Tuple<int, int>(-1,0),
        new Tuple<int, int>(1,0),
        new Tuple<int, int>(0,1),
        new Tuple<int, int>(0,-1),
         }.Select(t =>
         {
           Location loc;
           if (grid.TryGetValue(new Tuple<int, int>(curr.Row + t.Item1, curr.Col + t.Item2), out loc))
           {
             return loc;
           }
           return null;
         })
         .WhereNotNull()
         .Where(x => !x.Found)
          .Where(x =>  curr.Height - x.Height <= 1)
         ;
      foreach (var pot in potentials)
      {
        pot.Distance = curr.Distance + 1;
        queue.AddLast(pot);
        if (pot.Raw=='a')
        {
          Console.WriteLine($"Found it!, {pot}");
        }
      }
    }
    Console.WriteLine(
      grid.Values.Where(loc => loc.Height==0).Where(loc => loc.Found). OrderBy(loc => loc.Distance).First()
    );
  }


  public static Dictionary<Tuple<int, int>, Location> ParseFile(string filename)
  {
    string text = File.ReadAllText(filename);

    Dictionary<Tuple<int, int>, Location> grid = new();

    var row = 0;

    foreach (var line in text.Split("\n").Where(s => !string.IsNullOrWhiteSpace(s)))
    {
      var col = 0;
      foreach (var pos in line.ToCharArray())
      {
        Location loc = new Location(pos, row, col);
        grid.Add(new Tuple<int, int>(row, col), loc);
        col++;
      }
      row++;
    }

    Console.WriteLine("grid count: " + grid.Count);
    return grid;
  }
}

public class Location
{
  public char Raw { get; }
  public int Distance { get; set; } = -1;
  public int Row { get; }
  public int Col { get; }
  public bool Found => Distance != -1;
  public bool IsStart => Raw == 'S';
  public bool IsEnd => Raw == 'E';

  private readonly Lazy<int> _height;
  public int Height => _height.Value;

  public Location(char raw, int row, int col)
  {
    Raw = raw;
    Row = row;
    Col = col;
    _height = new Lazy<int>(() => GetHeight(raw));
  }

  private static int GetHeight(char raw)
  {
    if (raw == 'S')
    {
      return ConvertHeight('a');
    }
    else if (raw == 'E')
    {
      return ConvertHeight('z');
    }
    return ConvertHeight(raw);
  }

  private static int ConvertHeight(char raw)
  {
    return raw - 'a';
  }

  public override string? ToString()
  {
    return $"{Raw}({Height}) @({Row},{Col}) distance: {Distance}";
  }
}


