require 'beaker-rspec'
require 'pry'

# Don't run these tests on the following platforms
confine :except, platform: 'solaris'
confine :except, platform: 'windows'
confine :except, platform: 'aix'

hosts.each do |host|
  if host.name =~ /ubuntu.*1604/
    host.install_package('puppet')
  else
    install_puppet_on(host)
  end
end

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module
    puppet_module_install(source: module_root, module_name: 'odoo9')
    hosts.each do |host|
      on host, puppet('module', 'install',
                      'puppetlabs-apt'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install',
                      'puppetlabs-postgresql'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install',
                      'puppetlabs-inifile'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install',
                      'puppetlabs-stdlib'), acceptable_exit_codes: [0, 1]
    end
  end
end
