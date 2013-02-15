#!/usr/bin/ruby -I ./lib

require 'ldapreplay/parsers/openldap'
require 'ldapreplay/ldapoperation'
require 'ldapreplay/ldapconnection'
require 'pp'
require 'yaml'

parser = LdapReplay::Parsers::OpenLDAP.new( *ARGV )

conn_hsh = {}
conn_ary = []
op_hsh   = Hash.new { |hh, kk| hh[kk] = [] }

parser.emit { |args|
  begin
    op_time, op_conn, op_id, op_type, op_args = *args
    # puts "args: #{args.join(' ')}"
    case op_type
    when 'ACCEPT'
      nc = LdapReplay::LdapConnection.new( op_args[:from_ip], op_args[:from_port], op_args[:to_ip], op_args[:to_port] )
      nc.id = (conn_ary.push(nc).size) - 1
      conn_hsh[op_conn] = nc.id
    when 'closed'
      conn_hsh.delete op_conn
    when 'RESULT'
      
    else
      if conn_hsh[op_conn] and conn = conn_ary[conn_hsh[op_conn]]
        if new_op = conn.add_op(*args)
          op_hsh[new_op.op_time].push(new_op)
        end
      end
    end
  rescue Errno::EPIPE
    break
  end
}


puts "--------------------"
puts "conn_hsh: %s" % conn_hsh.pretty_inspect
puts "===================="
puts "conn_ary: %s" % conn_ary.pretty_inspect
# puts "conn_ary: #{conn_ary}"
puts "^^^^^^^^^^^^^^^^^^^^"

# puts YAML.dump conn_ary
puts "op_hsh: %s" % op_hsh.pretty_inspect
