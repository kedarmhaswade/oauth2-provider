require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'haml'
require 'httparty'

#CLIENT_ID = 'abcdefgh12345678'
#CLIENT_SECRET = 'secret'
CLIENT_ID = '3c3dc5cb-6e16-4a9c-8ecd-9b305d5cd1a7'
CLIENT_SECRET = '38d35bb7-c01b-422c-83af-94cce1789f1f'
RESOURCE_HOST = 'http://localhost:3000'

enable :sessions

helpers do
  def redirect_uri
    "http://" + request.host_with_port + "/callback"
  end

  def access_token
    session[:access_token]
  end

  def get_with_access_token(path)
    HTTParty.get(RESOURCE_HOST + path, :query => {:oauth_token => access_token})
  end

  def authorize_url
    RESOURCE_HOST + "/oauth/authorize?response_type=code&client_id=#{CLIENT_ID}&client_secret=#{CLIENT_SECRET}&redirect_uri=#{redirect_uri}"
  end
  
  def access_token_url
    RESOURCE_HOST + "/oauth/access_token"
  end
end

get '/' do
  haml :home
end

get '/callback' do
  puts CLIENT_ID
  response = HTTParty.post(access_token_url, :body => {
    :client_id => CLIENT_ID, 
    :client_secret => CLIENT_SECRET, 
    :redirect_uri => redirect_uri, 
    :code => params["code"],
    :grant_type => 'authorization_code'}
  )

  session[:access_token] = response["access_token"]
  puts "server sent the access token: #{response['access_token']}"
  redirect '/account'
end

get '/account' do
  if access_token
    @resource_response = get_with_access_token("/account.json")
    haml :response
  else
    redirect authorize_url
  end
end
