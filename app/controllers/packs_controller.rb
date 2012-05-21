class PacksController < ApplicationController
  def index

  end
  
  def show
    @pack = Pack.find_by_name(params[:id])
  end
end
