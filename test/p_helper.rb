require 'yaml'

# Overrides `p` to be pretty -- useful for tests.
module Kernel
  def p(*args)
    # Catch source
    begin
      raise Error
    rescue => e
      file, line, _ = e.backtrace[2].split(':')
      source = "%s:%s" % [ File.basename(file), line ]
    end

    # Source format
    pre = "\033[0;33m%20s |\033[0;m "
    lines = Array.new

    # YAMLify the last arg if it's YAMLable
    if args.last.is_a?(Hash) || args.last.is_a?(Array)
      lines += args.pop.to_yaml.split("\n")[1..-1]
    end

    # Inspect everything else
    lines.unshift(args.map { |a| a.is_a?(String) ? a : a.inspect }.join(' '))  if args.any?

    # Print
    print "\n"
    puts pre % [source] + lines.shift
    puts lines.map { |s| pre % [''] + "  " + s }.join("\n")  if  lines.any?
  end
end
