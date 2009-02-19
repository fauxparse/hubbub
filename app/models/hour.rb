class Hour
  attr_reader :minutes
  
  include Comparable
  
  def initialize(minutes)
    @minutes = minutes.blank? ? nil : minutes.to_i
  end
  
  def to_i
    @minutes || 0
  end
  
  def <=>(another)
    case another
    when Hour then minutes <=> another.minutes
    else to_i <=> another.to_i
    end
  end
  
  def +(another)
    self.class.new(to_i + another.to_i)
  end
  
  def -(another)
    self.class.new(to_i - another.to_i)
  end
  
  def *(f)
    nil? ? self.class.new(nil) : self.class.new(to_i * f)
  end
  
  def /(f)
    nil? ? self.class.new(nil) : self.class.new(to_i / f)
  end
  
  def zero?
    minutes && minutes.zero?
  end
  
  def blank?
    nil? || zero?
  end
  
  def nil?
    minutes.nil?
  end
  
  def hours
    minutes && (minutes / 60.0)
  end
  
  def to_s(format = :hours)
    return "" if minutes.blank?
    case format
    when :hours    then "%d:%.2d" % [ to_i / 60, to_i % 60 ]
    when :minutes  then to_i.to_s
    when :fraction then ("%.2f" % (minutes / 60.0)).sub /(\.\d+)0$/, "\\1"
    else raise ArgumentError, "unknown format: '#{format}'"
    end
  end
  
  class << self
    def hours(initializer = 0)
      case initializer
      when nil, ""                 then new(nil)
      when Hour                    then new(initializer.minutes)
      when /^([0-9]+):([0-9]{2})$/ then new($1.to_i * 60 + $2.to_i)
      else                              new(initializer.to_f * 60.0)
      end
    end
    
    def [](i)
      hours(i)
    end
  end
end
