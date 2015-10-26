import std.stdio;
import dtrie;

void main()
{
  auto dictionary = new dtrie.DTrie!string(["Win", "hot"], ["Lose", "cold"]);
}
