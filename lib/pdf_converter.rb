require 'httmultiparty'
class PageTextReceiver
  def initialize(params = {})
    @params = params
  end

  include HTTMultiParty
  base_uri 'http://localhost:3000'
  def index(value)
    value
  end
  def run(file)
    response = PageTextReceiver.post('https://pdftables.com/api?key=nnu16oof0hsn&format=csv', :query => { f: File.new("#{file}", "rb") })
    File.open("response_#{self.index(@params[:index])}.csv", 'w') do |f|
      f.puts response.body
    end
  end
end
