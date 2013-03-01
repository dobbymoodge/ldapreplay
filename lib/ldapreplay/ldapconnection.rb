require 'ldapreplay'

class LdapReplay::LdapConnection

  attr_accessor :id, :op_ary, :op_hsh, :from_ip, :from_port, :to_ip, :to_port, :ldap_conn

  def initialize from_ip, from_port, to_ip, to_port
    @from_ip   = from_ip
    @from_port = from_port
    @to_ip     = to_ip
    @to_port   = to_port
    @op_ary    = []
    @op_hsh    = {}
    @ldap_conn = nil
    @deref     = '0'
  end

  def add_op op_time, op_conn, op_id, op_type, *op_args
    # @deref = op_args.fetch( :deref, @deref )
    new_op = nil
    unless op_hsh[op_id]
      new_op = LdapReplay::LdapOperation.new(op_time, op_conn, op_id, op_type, *op_args)
      @op_hsh[op_id] = new_op
      @op_ary.push new_op
    else
      @op_hsh[op_id].add_args(*op_args)
    end
    # puts op_time, op_conn, op_id, op_type, op_args
    if @op_hsh[op_id].op_args
      @deref = @op_hsh[op_id].op_args.fetch( :deref, @deref )
    end
    return new_op
  end
end
