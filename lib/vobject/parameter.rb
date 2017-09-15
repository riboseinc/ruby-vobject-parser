module Vobject


  class Parameter

    attr_accessor :param_name, :value, :multiple

    def initialize key, options
      self.param_name = key
      if options.class == Array 
	self.multiple = []
	options.each {|v|
          self.multiple << parameter_base_class.new(key, v)
          self.param_name = key
	}
      else
        self.value = options
     end

      raise_invalid_initialization(key, name) if key != name
    end

    def to_s
      # we made param names have underscore instead of dash as symbols
      line = "#{param_name.to_s.gsub(/_/,'-')}"
      line << "=" 
      if self.multiple
	        arr = []
      		self.value.each {|v|
			arr << to_s_line(v.value.to_s)
		}
		line << arr.join(',')
      else
	      	line << to_s_line(self.value.to_s)
      end
      line
    end

    def to_s_line(val)
      # RFC 6868
      val.to_s.gsub(/\^/,"^^").gsub(/\n/,"^n").gsub(/"/,"^'")
    end

  def to_hash
    a = {}
    if self.multiple
        val = []
        self.multiple.each do |c|
            val << c.value
        end
        return {param_name => val}
    else
        return {param_name => value}
    end
  end

    private

    def name
      param_name
    end

    def parse_value value
      parse_method = :"parse_#{value_type}_value"
      parse_method = respond_to?(parse_method, true) ? parse_method : :parse_text_value
      send(parse_method, value)
    end

    def parse_text_value value
      value
    end

    def value_type
      (params || {})[:VALUE] || default_value_type
    end

    def default_value_type
      "text"
    end

          def parameter_base_class
		                Vobject::Parameter
	  end


    def raise_invalid_initialization(key, name)
      raise "vObject property initialization failed (#{key}, #{name})"
    end

  end

 end
