# Stubs
class Boolean
end

#
# Stub class to simulate server environment
# for testing purposes
#
class EventSourcePublic


  @@config_keys = []
  @@keys = []

  def self.key(name, type)
    #keys = class_variable_get(:@@keys)
    @@keys << [name, type]
  end

  def self.configuration
    @@config_keys
  end

  def configure(keys)
    @key_values = keys
  end

  def description
    self.class.description
  end
  def self.description(val=nil)
    @@description = val if val
    @@description
  end

  def method_missing(method, *args)
    if key = @@keys.detect{|k| k[0].to_s == method.to_s}
      @key_values[key[0]]
    else
      super
    end
  end

  ##
  ## Public interface
  ##
  def add_event(attrs)
    result = true
    
    result = false unless attrs[:date]
    result = false unless attrs[:tags].kind_of? Array

    puts attrs.inspect

    result
  end
  
  #
  # fetch is invoked by a drivehub service periodically to refresh events from this source
  #
  # Drivehub automatically destroys all the events previously imported from this service!
  # Incremental
  #
  def fetch(password)
  end

  #
  # These are the persistent object event source properties
  #
  key :enabled, Boolean

  #
  # configuration keys are automatically displayed in UI and
  # available to user
  #
  configuration << :enabled

end


Find.find('lib') do |ff|
  require ff if ff =~ /\.rb/
end