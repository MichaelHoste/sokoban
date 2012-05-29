class PacksController < ApplicationController
  def index
    @packs = Pack.all
  end
  
  def show
    @pack = Pack.find_by_name(params[:id])
    @selected_level_name = @pack.levels.first.name
  end
end
