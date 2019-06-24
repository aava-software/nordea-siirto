require 'nordea/siirto'

# Logger that can be injected into the tests
class MyLogger
  def info(message); end
end

def siirto_params
  {
    server: :test,
    username: 'my_company',
    api_token: 'ASDF-1234-QWER-1234',
    logger: MyLogger.new,
    redis: Object.new
  }
end

def reset_siirto
  Nordea::Siirto.instance_variables.each do |var|
    Nordea::Siirto.send(:remove_instance_variable, var)
  end
end

def initialize_siirto_unless_initialized
  return if Nordea::Siirto.initialized?

  Nordea::Siirto.setup(siirto_params)
end
