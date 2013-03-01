require 'ldapreplay'

class LdapReplay::LdapOperation

  attr_accessor :op_time, :op_conn, :op_id, :op_type, :op_args

  def initialize *args
    # puts args[4]
    @op_time = args[0]
    @op_conn = args[1]
    @op_id = args[2]
    @op_type = args[3]
    @op_args = args[4]
  end

  def add_args op_args
    if op_args
      @op_args.merge! op_args
    end
  end

  def to_s
    oa = @op_args ? @op_args.to_s : 'nil'
    "LdapReplay::LdapOperation[{ :op_time => " + @op_time.to_s + ", :op_conn => \"" + @op_conn + "\", :op_id => \"" + @op_id + "\", :op_type => \"" + @op_type + "\", :op_args => " + oa + " }]"
  end
end

class LdapReplay
  def LdapOperation.[] (min_arg, *args)
    unless min_arg.is_a? Hash
      LdapOperation.new(min_arg, *args)
    else
      LdapOperation.new(*[:op_time, :op_conn, :op_id, :op_type, :op_args].map {
                          |kk| min_arg.fetch kk })
    end
  end
end
