require 'bort'

include Bort

def response_file(action, command)
  path = File.expand_path("../responses/#{action}_#{command}.xml", __FILE__)
  File.read(path)
end
