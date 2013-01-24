module LdapReplay

  class LogfileParser

    require 'time'

    CONN = 'conn='
    
    def initialize path, offset = 0
      raise ArgumentError unless File.exists?( path )
      
      @log    = File.open( path )
      @offset = offset.to_i

    end
    
    def emit &block
      @log.each_line do |line|
        next unless line.include?(CONN)

        current_time = DateTime.parse( line[0,15] ).strftime('%s').to_i

        @start_time ||= current_time

        toks = line.split(' ')[5..-1]

        yield toks.insert(0,(@offset + (current_time - @start_time)))
        
      end
    end

    def main()
      parser = LogfileParser.new( *ARGV )

      parser.emit {|l| puts l.join(' ')}
    end
    
  end

end

