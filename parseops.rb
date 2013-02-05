#!/usr/bin/ruby -I ./lib

require 'ldapreplay/parsers/openldap'
require 'ldapreplay/ldapoperation'
require 'pp'

parser = LdapReplay::Parsers::OpenLDAP.new( *ARGV )

conns = Hash.new()

parser.emit { |args|
  begin
    op_time, op_conn, op_id, op_type, op_args = *args
    puts "args: #{args.join(' ')}"
    if conns.has_key?(op_conn)
      connection = conns[op_conn]
      if connection.has_key?(op_id)
        connection[op_id].add_args(op_args)
      else
        connection[op_id]=LdapReplay::LdapOperation.new(*args)
      end
    else
      conns[op_conn] = {op_id => LdapReplay::LdapOperation.new(*args)}
    end
    if op_type == 'closed'
      puts"conns:"
      PP.pp conns
    end
  rescue Errno::EPIPE
    break
  end
}
  

