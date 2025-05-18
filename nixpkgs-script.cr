src = "@NIXPKGS_PATH@"

def usage(exitcode = 1, io = STDERR)
  io.puts "Usage: nixpkgs [COMMAND] [ARGS...]"
  io.puts ""
  io.puts "Commands:"
  io.puts "  repl, r\tStart a nix repl with nixpkgs loaded"
  io.puts "  build, b\tBuild a package from nixpkgs"
  io.puts "  [default]\tPrint path to currently loaded nixpkgs"
  exit exitcode
end

if ARGV.empty?
  puts src
  exit
end

case ARGV.shift
when "help", "h", "-h", "--help"
  usage 0, STDOUT
when "repl", "r"
  Process.exec "nix", ["repl", "-f", src, *ARGV]
when "build", "b"
  Process.exec "nix", ["build", "-f", src, *ARGV]
when "eval", "e"
  Process.exec "nix", ["eval", "-f", src, "--json", *ARGV]
else
  usage
end
