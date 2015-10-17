module Puppet::Parser::Functions
  newfunction(:read_conf_fragment, :type => :rvalue, :doc => <<-EOS
    Reads the configuration file and returns it without the last </configuration> tag.
    Takes a file name as an argument.
    EOS
  ) do |arguments|
    raise(Puppet::ParseError, "read_conf_fragment(): Wrong number of arguments given (#{arguments.size} for 1)") if arguments.size != 1
    $filename = arguments[0]

    #raise(Puppet::ParseError, "read_conf_fragment(): File #{$filename} does not exist") if !File.exist?($filename)
    if !File.exist?($filename)
      return "<configuration>\n\n"
    end

    result = ""
    IO.readlines($filename).each do |line|
      break if line =~ /^\s*<\/configuration/
      result += line
    end

    result
  end
end
