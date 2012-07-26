# launch with "ruby setup.rb" (ruby 1.9 only)

def setup
  @hostname = 'sokoban.local'
  
  host_check_ruby_version()
  host_install_gems()
  host_ask_host_password()
  host_update_git_submodules()
  host_remove_logs()
  host_launch_guest_machine()
  host_create_dns()

  @terminal = app('Terminal')
  @tab1 = host_new_tab(@terminal)
  @tab2 = host_new_tab(@terminal)

  guest_bundle_install()
  guest_bundle_update()
  guest_app_reset()
  guest_git_initialize()
  guest_launch_server()
  host_open_project()
#  host_open_tools()

  display_info_message()
end

def host_check_ruby_version
  @current_rep  = `pwd`
  @ruby_version = `ruby --version`
  @gem_version  = `gem --version`
  @git_version  = `git --version`
  @guest_status = `vagrant status | grep default`.split('                  ')[1]
  @git_name     = `cat ~/.gitconfig | grep name`.split(' = ')[1]
  @git_email    = `cat ~/.gitconfig | grep email`.split(' = ')[1]
  @id_rsa       = `cat ~/.ssh/id_rsa`
  @id_rsa_pub       = `cat ~/.ssh/id_rsa.pub`
  
  puts "\n================="
  puts "Your Git is #{@git_version}"
  puts "Your Ruby is #{@ruby_version}"
  puts "Your Gem is #{@gem_version}"
  puts "Your Git Name is #{@git_name}"
  puts "Your Git Email is #{@git_email}"
  puts "Your Vagrant status is #{@guest_status}"
  
  if @ruby_version.include?('1.8') or (not @gem_version.include?('.')) or not (@git_version.include?('.'))
    puts "\nYOUR RUBY VERSION IS NOT COMPATIBLE WITH THIS SCRIPT"
    puts 'install rvm and use "rvm list" and "rvm use 1.9.3" for example'
    puts "=================\n"
    exit()
  end
  
  puts "=================\n"
end

def host_install_gems
  puts "\n================="
  puts 'Install required gems on host'
  puts "=================\n"
  
  update_gem = 'gem update --system'
  puts update_gem
  system(update_gem)
  
  gem_packages = %w(rake vagrant highline)
  gem_packages.each do |gem_package|
    if not `gem list | grep #{gem_package}`.include?(gem_package)
      puts "Installation of #{gem_package}"
      puts "gem install #{gem_package}"
      system("gem install #{gem_package}")
      puts "gem update #{gem_package}"
      system("gem update #{gem_package}")
    else
      puts "#{gem_package} is already installed, update only"
      puts "gem update #{gem_package}"
      system("gem update #{gem_package}")
    end
  end

  require 'rubygems'
  require 'appscript'
  require 'vagrant'
  require 'pty'
  require 'expect'
  require 'highline/import'
  include Appscript
end

def host_ask_host_password
  if @guest_status == "not created"
    puts "\n================="
    puts 'Required host password for nfs sharing'
    puts "=================\n"
  
    @password = ask("Host password: ") { |q| q.echo = false }
  end
end

def host_update_git_submodules
  puts "\n================="
  puts 'Install and update git submodules (puppet rules)'
  puts "=================\n"
  
  commands = [
    'git submodule update --init --recursive',
    'git submodule foreach git pull origin master',
  ].each do |command|
    puts command
    system(command)
  end
end

def host_remove_logs
  puts "\n================="
  puts 'Remove project logs'
  puts "=================\n"
  
  commands = [
    'rm log/development.log',
    'touch log/development.log',
    'rm log/production.log',
    'touch log/production.log',
  ].each do |command|
    puts command
    system(command)
  end
end

def host_launch_guest_machine  
  puts "\n================="
  puts '(re-)start guest machine'
  puts "Current status is : #{@guest_status}"
  puts "=================\n"

  puts 'vagrant up'
  PTY.spawn 'vagrant up' do |stdin,stdout,pid|
    begin
      stdin.expect("Password:") do
        stdout.write("#{@password}\n")
        puts stdin.read.lstrip
      end
    rescue Errno::EIO
      # don't care
    end
  end
end

def host_create_dns
  puts "\n================="
  puts "Your project will be accessible on #{@hostname}"
  puts "=================\n"
      
  redirection_dns = `cat /etc/hosts | grep www.#{@hostname}`.include?(@hostname)
  
  unless redirection_dns
    @password = ask("Host password: ") { |q| q.echo = false } if not @password
    
    host1 = "192.168.42.101       www.#{@hostname}"
    host2 = "192.168.42.101           #{@hostname}"
  
    commands = [
      "sudo sh -c \"echo '#{host1}' >> /etc/hosts\"",
      "sudo sh -c \"echo '#{host2}' >> /etc/hosts\""
    ].each do |command|
      PTY.spawn command do |stdin,stdout,pid|
        begin
          stdin.expect("Password:") do
            stdout.write("#{@password}\n")
            puts stdin.read.lstrip
          end
        rescue Errno::EIO
          # don't care
        end
      end
    end
  end
end

def host_new_tab(terminal)
  if @got_first_tab_already
    app("System Events").application_processes["Terminal.app"].keystroke("t", :using => :command_down)
  end
  @got_first_tab_already = true
  terminal.windows[1].tabs.last.get
end

def guest_bundle_install
  puts "\n================="
  puts 'Guest Bundle update'
  puts "=================\n"
  
  @terminal.do_script('vagrant ssh',    :in => @tab1)
  @terminal.do_script('cd /vagrant',    :in => @tab1)
  @terminal.do_script('bundle update',  :in => @tab1)
end

def guest_bundle_update
  puts "\n================="
  puts 'Guest Bundle install'
  puts "=================\n"
  
  @terminal.do_script('bundle install', :in => @tab1)
end

def guest_app_reset
  if @guest_status == "not created"
    puts "\n================="
    puts 'Guest reset and bootstrap the app (only if new guest)'
    puts "=================\n"
    
    @terminal.do_script('bundle exec rake app:reset', :in => @tab1)
  end
end

def guest_git_initialize
  if @guest_status == "not created"
    puts "\n================="
    puts 'Guest initialize git configuration'
    puts 'With copy of host name/email/SSH keys'
    puts "=================\n"
  
    commands = [
      'git config --global user.name "' + @git_name + '"',
      "git config --global user.email #{@git_email}",
      "echo '#{@id_rsa}' >> ~/.ssh/id_rsa",
      "echo '#{@id_rsa_pub}' >> ~/.ssh/id_rsa.pub",
      "chmod 600 ~/.ssh/id_rsa",
      "chmod 600 ~/.ssh/id_rsa.pub",
      "clear"
    ].each do |command|
      @terminal.do_script(command, :in => @tab1)
    end
  end
end

def guest_launch_server
  puts "\n================="
  puts 'Guest launch rails server on port 3000'
  puts "=================\n"
  
  @terminal.do_script('bundle exec rails server', :in => @tab1)
end

def host_open_project
  puts "\n================="
  puts 'Open project with TextMate'
  puts 'ERROR : TextMate is not installed !' if not File.exist?('/Applications/TextMate.app/Contents/MacOS/TextMate')
  puts "=================\n"
  
  @terminal.do_script("cd #{@current_rep}", :in => @tab2) 
  @terminal.do_script('mate .',             :in => @tab2)
  @terminal.do_script('vagrant ssh',        :in => @tab2)
  @terminal.do_script('cd /vagrant',        :in => @tab2)
  @terminal.do_script('clear',              :in => @tab2)
end

#def host_open_tools
#  sequel_pro = "/Applications/Sequel\ Pro.app/Contents/MacOS/Sequel\ Pro"
#  mock_smtp  = "/Applications/MockSmtp.app/Contents/MacOS/MockSmtpOwn"
#  
#  puts "\n================="
#  puts 'Launch Sequel Pro and MockSMTP'
#  puts 'ERROR : Sequel Pro is not installed !' if not File.exist?(sequel_pro)
#  puts 'ERROR : MockSMTP is not installed !' if not File.exist?(mock_smtp)
#  puts "=================\n"
#  
#  IO.popen("#{sequel_pro}&")
#  IO.popen("#{mock_smtp}&")
#end

def display_info_message
  puts "\n================="
  puts 'Guest is up on 192.168.42.101'
  puts "Serveur is running on http://#{@hostname}:3000"
  puts 'Database > name  : development'
  puts '         > login : development'
  puts '         > pass  : development'
  puts "=================\n"
end

setup()