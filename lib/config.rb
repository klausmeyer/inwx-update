class Config
  attr_accessor(
    :login,
    :password,
    :domain,
    :type,
    :record,
    :value,
    :logger
  )

  def initialize(attributes = {})
    attributes.each do |key, value|
      public_send("#{key}=", value)
    end
  end
end
