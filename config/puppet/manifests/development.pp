class { 'dev_rails_stack':
  ruby_version => '1.9.3-p125',
  bundler      => true,
  mysql        => true,
  mongodb      => false,
  postgresql   => true,
  redis        => false
}
