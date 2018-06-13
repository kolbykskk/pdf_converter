require 'httmultiparty'
class PageTextReceiver
  def initialize(params = {})
    @params = params
  end

  include HTTMultiParty
  if ENV['REDIS_URL']
    base_uri 'https://dry-forest-25428.herokuapp.com'
  else
    base_uri 'http://localhost:3000'
  end
  
  def index(value)
    value
  end
  def run(file)
    response = PageTextReceiver.post('https://pdftables.com/api?key=nnu16oof0hsn&format=csv', :query => { f: File.new("#{file}", "rb") })
    index = self.index(@params[:index])
    File.open("response_#{self.index(@params[:index])}.csv", 'w') do |f|
      f.puts response.body
    end
  end
end
