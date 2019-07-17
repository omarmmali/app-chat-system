class ClientApplicationsController < ApplicationController
  def index
    client_applications = ClientApplication.all
    render status: 200, json: {:applications => client_applications}
  end
end
