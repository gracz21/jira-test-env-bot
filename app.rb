require 'json'
require 'pry'
require 'sinatra'

post '/installed' do
  request.body.rewind
  request_payload = JSON.parse(request.body.read)
  puts request_payload['sharedSecret']
end

end
