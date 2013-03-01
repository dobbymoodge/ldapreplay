require 'ldapreplay/parsers'

class LdapReplay::Parsers::OpenLDAP
  require 'time'

  def initialize path, offset = 0
    raise ArgumentError unless File.exists?( path )
    
    @log    = File.open( path )
    @offset = offset.to_i

  end
  
  def parse_arg oparg
    mm = /([^=]+)="?([^"]*)"?$/.match(oparg)
    if mm
      mm[1..2].inject{|ii,jj| [ii.to_sym, jj]}
    end
  end

  def parse_operation_args(o_args)
    Hash[o_args.map{|aa| parse_arg aa}]
  end

  def parse_accept_args(a_args)
    (a_args[1][3..-1].split(':').concat a_args[2][4..-2].split(':'))
  end

  # For "ACCEPT" lines, generates an array containing the connection
  # details; this signifies a new connection
  #
  # For "closed" and "UNBIND" lines, no additional parameters are
  # returned; this signifies that a connection is being closed, and
  # thus should have no more operations associated with it
  #
  # For "SRCH" lines, the arguments are parsed differently than for
  # other operations, to account for the presence of the "attr="
  # argument, which takes multiple parameters
  #
  # For other operation lines, arguments are parsed into a hash, with
  # the argument type expressed as a :symbol, and the parameter as a
  # string

  def parse_line(op_time, op_conn, op_id, op_type, *op_args)
    op_signature = [op_time, op_conn, op_id, op_type]
    case op_type
    when 'ACCEPT'
      return op_signature.push parse_accept_args(op_args)
    when 'closed', 'UNBIND'
      return op_signature
    when 'SRCH'
      if op_args[0][0..4] == 'attr='
        return op_signature.push({:attr => [op_args[0][5..-1], *op_args[1..-1]]})
      else
        return op_signature.push parse_operation_args(op_args)
      end
    else
      return op_signature.push parse_operation_args(op_args)
    end
  end

  def emit &block
    @log.each_line do |line|
      next unless line.include?('conn=')

      current_time = DateTime.parse( line[0,15] ).strftime('%s').to_i

      @start_time ||= current_time

      toks = line.split(' ')[5..-1]
      if toks[2..3].include? 'RESULT'
        toks = toks[0..1] << 'RESULT'
      end
      yield parse_line(*toks.insert(0,(@offset + (current_time - @start_time))))
      
    end
  end

end

