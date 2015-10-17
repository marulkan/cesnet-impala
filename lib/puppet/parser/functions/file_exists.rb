module Puppet::Parser::Functions
  newfunction(:file_exists, :type => :rvalue, :doc => <<-EOS
    Check, if the file exists.
    Takes a file name as an argument.
    EOS
  ) do |arguments|
    raise(Puppet::ParseError, "file_exists(): Wrong number of arguments given (#{arguments.size} for 1)") if arguments.size != 1
    $filename = arguments[0]

    File.exist?($filename)
  end
end
