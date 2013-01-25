#!/usr/bin/ruby -I ./lib

require 'logfileparser'
require 'ldapoperation'
require 'pp'

parser = LdapReplay::LogfileParser.new( *ARGV )

conns = Hash.new()

parser.emit { |args|
  begin
    puts args.join(' ')
    conn = args[1]
    op = args[2]
    if conns.has_key?(conn)
      connection = conns[conn]
      if connection.has_key?(op)
        connection[op].add_args(*args)
      else
        connection[op]=LdapReplay::LdapOperation.new(*args)
      end
    else
      conns[conn] = {op => LdapReplay::LdapOperation.new(*args)}
    end
    if args[3] == 'closed'
      PP.pp conns
    end
  rescue Errno::EPIPE
    break
  end
}
  

