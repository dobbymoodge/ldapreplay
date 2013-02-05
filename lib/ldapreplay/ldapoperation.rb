class LdapReplay::LdapOperation

  def initialize *args
    # puts args[4]
    @op_time = args[0]
    @op_conn = args[1]
    @op_id = args[2]
    @op_type = args[3]
    @op_args = args[4]
  end

  def add_args op_args
    # puts "1, #{op_args}, #{@op_args}"
    if op_args
      # puts 2
      @op_args.merge! op_args
      # puts "3, #{op_args}, #{@op_args}"
    end
  end

  def to_s
    "LdapOperation { @op_time: " + @op_time.to_s + ", @op_conn: " + @op_conn + ", @op_id: " + @op_id + ", @op_type: " + @op_type + ", @op_args: " + @op_args.to_s + " }"
  end      
end
