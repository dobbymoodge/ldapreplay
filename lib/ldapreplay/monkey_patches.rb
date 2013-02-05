require 'ldapreplay'

class String
  def rchomp(sep = $/)
    self.start_with?(sep) ? self[sep.size..-1] : self
  end
  def rchomp!(sep = $/)
    self.start_with?(sep) ? self.slice!(sep.size..-1) : self
  end
  def dchomp(sep = $/)
    self.chomp(sep).rchomp(sep)
  end
  def dchomp!(sep = $/)
    self.gsub!(/\A#{sep}|#{sep}\Z/, '')
  end
end
