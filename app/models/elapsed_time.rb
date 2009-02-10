class ElapsedTime
  attr_reader :minutes
  
  include Comparable
  
  def initialize(minutes)
    @minutes = minutes.to_i
  end
  
  def to_i
    minutes
  end
  
  def <=>(another)
    case another
    when ElapsedTime then minutes <=> another.minutes
    else to_i <=> another.to_i
    end
  end
  
  def +(another)
    self.class.new(minutes + another.minutes)
  end
  
  def -(another)
    self.class.new(minutes - another.minutes)
  end
  
  def *(f)
    self.class.new(minutes * f)
  end
  
  def /(f)
    self.class.new(minutes / f)
  end
  
  def zero?
    minutes.zero?
  end
  
  def blank?
    zero?
  end
  
  def to_s(format = :hours)
    case format
    when :hours    then "%d:%.2d" % [ minutes / 60, minutes % 60 ]
    when :minutes  then minutes.to_s
    when :fraction then ("%.2f" % (minutes / 60.0)).sub /\.?0+$/, ""
    else raise ArgumentError, "unknown format: '#{format}'"
    end
  end
  
  class << self
    def hours(initializer = 0)
      case initializer
      when ElapsedTime             then new(initializer.minutes)
      when /^([0-9]+):([0-9]{2})$/ then new($1.to_i * 60 + $2.to_i)
      else                              new(initializer.to_f * 60.0)
      end
    end
  end
end
