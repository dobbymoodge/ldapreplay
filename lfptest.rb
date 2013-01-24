require 'logfileparser'

parser = LdapReplay::LogfileParser.new( *ARGV )

parser.emit {|l| puts l.join(' ')}

