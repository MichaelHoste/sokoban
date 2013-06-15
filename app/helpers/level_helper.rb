# encoding: utf-8

module LevelHelper
  def level_datas(level)
    render 'helpers/level_datas', :level => level
  end
end
