class WorkflowsController < ApplicationController
  def show_welcome
    render 'show_welcome', :layout => false
  end
  
  def show_rules
    render 'show_rules', :layout => false
  end
  
  def show_inputs
    render 'show_inputs', :layout => false
  end
  
  def show_challenges_and_packs
    render 'show_challenges_and_packs', :layout => false
  end
  
  def show_next_level    
    @pack_name = params[:pack_name]
    @level_name = params[:level_name]

    @pack = Pack.find_by_name(@pack_name)
    @level = @pack.levels.find_by_name(@level_name)
    @score = LevelUserLink.find(params[:score_id])

    @next_level = @level.next_level
    
    render 'show_next_level', :layout => false
  end
end
