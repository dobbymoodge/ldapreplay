#!/usr/bin/ruby -I ./lib

require 'ldapreplay/parsers/openldap'

parser = LdapReplay::Parsers::OpenLDAP.new( *ARGV )

parser.emit { |l|
  begin
    puts "[#{l.join('] [')}]"
  rescue Errno::EPIPE
    break
  end
}
  

