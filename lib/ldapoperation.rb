module LdapReplay
  class LdapOperation

    def initialize *args
      @op_time = args[0]
      @op_conn = args[1]
      @op_id = args[2]
      @op_args = args[4..-1]
    end

    def add_args *args
      @op_args.concat(args[4..-1])
    end

    def to_s
      "LdapOperation { @op_time: " + @op_time.to_s + ", @op_conn: " + @op_conn + ", @op_id: " + @op_id + ", @op_args: " + @op_args.to_s + " }"
    end      
  end
end
