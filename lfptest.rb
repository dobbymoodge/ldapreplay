#!/usr/bin/ruby -I ./lib

require 'logfileparser'

parser = LdapReplay::LogfileParser.new( *ARGV )

parser.emit { |l|
  begin
    puts l.join(' ')
  rescue Errno::EPIPE
    break
  end
}
  

