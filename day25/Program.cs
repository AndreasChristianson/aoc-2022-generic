namespace day25;

internal class Program
{
  private static void Main(string[] args)
  {
    for (int i = 0; i < 10000; i++)
    {
      var asSnafu = ToSnafuNumber(i);
      var back = FromSnafuNumber(asSnafu);

      Console.WriteLine($"total: {i} => {asSnafu} => {back}");
      if (back != i)
      {
        throw new Exception();
      }
    }
    var lines = ParseFile(args[0]);
    foreach (var line in lines)
    {
      Console.WriteLine($"{line} => {FromSnafuNumber(line)}");
    }
    Int128 total = lines.Select(FromSnafuNumber).Aggregate((Int128)0 ,(l,r) => (l + r));
    Console.WriteLine($"total: {total} => {ToSnafuNumber(total)}");
  }

  private static string ToSnafuNumber(Int128 number)
  {
    if (number == 0)
    {
      return "0";
    }

    Int128 remaining = number;
    int digitCount = (int)Math.Log((double)number, 5) + 2;
    var digits = new LinkedList<int>();
    for (int power = digitCount; power >= 0; power--)
    {
      var value = (Int128)Math.Pow(5, power);
      var preferred = remaining / value;
      remaining -= preferred * value;

      digits.AddLast((int)preferred);

    }
    var carryover = 0;
    var ret = "";
    foreach (var digit in digits.Reverse())
    {
      switch (digit + carryover)
      {
        case 0:
        case 1:
        case 2:
          ret = $"{digit + carryover}{ret}";
          carryover = 0;
          break;
        case 3:
          carryover = 1;
          ret = $"={ret}";
          break;
        case 4:
          carryover = 1;
          ret = $"-{ret}";
          break;
        case 5:
          carryover = 1;
          ret = $"0{ret}";
          break;
        default: throw new Exception($"digit: {digit} carry: {carryover} ret: {ret}");
      }
    }
    return ret.TrimStart('0');
  }

  public static List<String> ParseFile(string filename)
  {
    string text = File.ReadAllText(filename);

    return text.Split("\n").Where(s => !string.IsNullOrWhiteSpace(s)).ToList();
  }

  public static Int128 FromSnafuNumber(string snafuString)
  {
    Int128 ret = 0;
    int place = snafuString.Length;
    foreach (var digit in snafuString.ToCharArray())
    {
      ret += FromSnafuChar(--place, digit);
    }
    return ret;
  }

  private static Int128 FromSnafuChar(int place, char digit)
  {
    return (Int128)(Math.Pow(5, place) * SnafuToDecimal(digit));
  }

  private static int SnafuToDecimal(char digit)
  {
    return digit switch
    {
      '-' => -1,
      '=' => -2,
      '2' => 2,
      '1' => 1,
      '0' => 0,
      _ => throw new Exception(),
    };
  }
}