#!/usr/bin/ruby -I ./lib

require 'ldapreplay/parsers/openldap'
require 'ldapreplay/ldapoperation'
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
    unless op_type == 'RESULT'
      if conn_hsh.has_key?(op_conn)
        connection = conn_hsh[op_conn]
        if connection.has_key?(op_id)
          connection[op_id].add_args(op_args)
        else
          new_op = LdapReplay::LdapOperation.new(*args)
          connection[op_id] = new_op
          unless new_op.op_type == 'ACCEPT'
            op_hsh[new_op.op_time].push(new_op)
          end
        end
      else
        conn_hsh[op_conn] = {op_id => LdapReplay::LdapOperation.new(*args)}
      end
      if op_type == 'closed'
        conn_ary.push conn_hsh.delete op_conn
        # puts "--------------------"
        # puts "conn_hsh: %s" % conn_hsh.pretty_inspect
        # puts "===================="
        # puts "op_hsh: %s" % op_hsh.pretty_inspect
        # puts "conn_ary: %s" % conn_ary.pretty_inspect
        # # puts "conn_ary: #{conn_ary}"
        # puts "^^^^^^^^^^^^^^^^^^^^"
      end
    end
  rescue Errno::EPIPE
    break
  end
}

ckeys = conn_hsh.keys
ckeys.each {|kk| conn_ary.push conn_hsh.delete kk}

# puts "--------------------"
# puts "conn_hsh: %s" % conn_hsh.pretty_inspect
# puts "===================="
# puts "conn_ary: %s" % conn_ary.pretty_inspect
# # puts "conn_ary: #{conn_ary}"
# puts "^^^^^^^^^^^^^^^^^^^^"

# puts YAML.dump conn_ary
puts "op_hsh: %s" % op_hsh.pretty_inspect
