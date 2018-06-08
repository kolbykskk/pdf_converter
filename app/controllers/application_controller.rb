require "./lib/google_drive.rb"
require "./lib/pdf_converter.rb"

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :google_login, except: [:set_google_drive_token]

  def google_login
    unless $drive.get_credentials
      redirect_to('/oauth2callback')
    end
  end
end
