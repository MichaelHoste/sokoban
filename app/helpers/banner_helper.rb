module BannerHelper
  def facebook_send_message_url(user)
    options = { :app_id       => ENV['SOKOBAN_FACEBOOK_KEY'],
                :name         => 'Sokoban.be',
                :picture      => '',
                :description  => 'Join me to play Sokoban, a great puzzle-game !',
                :link         => "http://www.sokoban.be",
                :redirect_uri => 'http://www.sokoban.be', 
                :display      => 'popup',
                :to           => '' } #user.friends.limit(1).pluck(:f_id)

    return 'http://www.facebook.com/dialog/send?' + options.collect { |key, value| "#{key}=#{value}" }.join('&')
  end
end
