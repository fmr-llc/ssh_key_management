require 'versioning'
require 'dotenv/tasks'
require 'cocaine'
require 'securerandom'

TEMPLATE_DIR = Rails.root + 'packages' + 'templates'
WORKING_DIR = Rails.root + 'packages' + 'working'
OUTPUT_DIR = Rails.root + 'packages' + 'built'

AUTHORIZED_KEYS_SSHD_SH  = WORKING_DIR + 'authorized_keys.sh'
REGISTER_HOST_SH         = WORKING_DIR + 'register_host.sh'

AUTHORIZED_KEYS_CRON_SH  = WORKING_DIR + 'authorized_keys_cron.sh'
AUTHORIZED_KEYS_TASK_PS1 = WORKING_DIR + 'authorized_keys_task.ps1'

PACKAGE_INSTALL_SH       = WORKING_DIR + 'post_install.sh'
PACKAGE_UNINSTALL_SH     = WORKING_DIR + 'post_uninstall.sh'

AUTHORIZED_KEYS_WIX = WORKING_DIR + 'authorized_keys'

namespace :sshkm_packages do
  namespace :unix do
    require 'fpm'

    desc 'Build authorized_keys.sh script'
    task authorized_keys_script: :setup do
      puts 'Building authorized_keys.sh script'
      template = TEMPLATE_DIR + 'authorized_keys.sh.erb'
      File.open(AUTHORIZED_KEYS_SSHD_SH, 'w') {|file| file.write ERB.new(template.read).result }
      File.chmod 0644, AUTHORIZED_KEYS_SSHD_SH
      raise "! Error in building #{AUTHORIZED_KEYS_SSHD_SH}" unless File.exist?(AUTHORIZED_KEYS_SSHD_SH)
    end

    desc 'Build register_host.sh script'
    task register_host_script: :setup do
      puts 'Building register_host.sh script'
      template = TEMPLATE_DIR + 'register_host.sh.erb'
      File.open(REGISTER_HOST_SH, 'w') {|file| file.write ERB.new(template.read).result }
      File.chmod 0644, REGISTER_HOST_SH
      raise "! Error in building #{REGISTER_HOST_SH}" unless File.exist?(REGISTER_HOST_SH)
    end

    desc 'Build cron script'
    task cron_script: :setup do
      puts 'Building cron script'
      template = TEMPLATE_DIR + 'authorized_keys_cron.sh.erb'
      File.open(AUTHORIZED_KEYS_CRON_SH, 'w') {|file| file.write ERB.new(template.read).result }
      File.chmod 0644, AUTHORIZED_KEYS_CRON_SH
      raise "! Error in building #{AUTHORIZED_KEYS_CRON_SH}" unless File.exist?(AUTHORIZED_KEYS_CRON_SH)
    end

    desc 'Build rpm package'
    task rpm: [:cron_script, :authorized_keys_script, :register_host_script] do
      puts 'Building rpm package for RedHat/Enterprise Linux/CentOS'
      FileUtils.copy TEMPLATE_DIR + 'sshd_config.rhel6', WORKING_DIR
      FileUtils.copy TEMPLATE_DIR + 'sshd_config.unix', WORKING_DIR
      FileUtils.copy TEMPLATE_DIR + 'post_install_rpm.sh', PACKAGE_INSTALL_SH
      FileUtils.copy TEMPLATE_DIR + 'post_uninstall_rpm.sh', PACKAGE_UNINSTALL_SH
      File.chmod 0644, PACKAGE_INSTALL_SH
      File.chmod 0644, PACKAGE_UNINSTALL_SH
      fpm_command 'rpm'
    end

    desc 'Build Ubuntu deb package'
    task deb: [:authorized_keys_script, :register_host_script] do
      puts 'Building deb package for Debian/Ubuntu'
      FileUtils.copy TEMPLATE_DIR + 'sshd_config.unix', WORKING_DIR
      FileUtils.copy TEMPLATE_DIR + 'post_install_deb.sh', PACKAGE_INSTALL_SH
      FileUtils.copy TEMPLATE_DIR + 'post_uninstall_deb.sh', PACKAGE_UNINSTALL_SH
      File.chmod 0644, PACKAGE_INSTALL_SH
      File.chmod 0644, PACKAGE_UNINSTALL_SH
      fpm_command 'deb'
    end

    def fpm_command(type)
      fpm = Cocaine::CommandLine.new("fpm", "--force -a all --maintainer :maintainer --description :description -s dir -C #{WORKING_DIR} -t :type -n :name -v :version -d openssh-server --prefix /etc/ssh --after-install :install --after-remove :uninstall :files")
      arguments = {
          type: type,
          description: @options[:description],
          maintainer: @options[:maintainer],
          name: @options[:name],
          version: @options[:version],
          install: PACKAGE_INSTALL_SH.to_s,
          uninstall: PACKAGE_UNINSTALL_SH.to_s,
          files: Dir.chdir(WORKING_DIR) {Dir.glob('*') - ['post_install.sh']}
      }
      fpm.run arguments
      package = Dir.glob("*.#{type}").first
      FileUtils.mv package, OUTPUT_DIR
      puts "Built #{type} package: #{OUTPUT_DIR + package}"
    rescue Cocaine::ExitStatusError => e
      # bail because something has gone horribly wrong
      puts "! ERROR: #{e.message}"
    end
  end if RbConfig::CONFIG['host_os'] !~ /mingw|mswin|cygwin/i

  namespace :windows do
    desc 'Build powershell task'
    task powershell_task: :setup do
      puts 'Building powershell task'
      template = TEMPLATE_DIR + 'authorized_keys_task.ps1.erb'
      File.open(AUTHORIZED_KEYS_TASK_PS1, 'w') {|file| file.write ERB.new(template.read).result }
      raise "! Error in building #{AUTHORIZED_KEYS_TASK_PS1}" unless File.exist?(AUTHORIZED_KEYS_TASK_PS1)
    end

    desc 'Build Windows MSI package for BitVise integration'
    task msi: [:setup, :powershell_task] do
      puts 'Building MSI package for Windows BitVise integration'
      raise "ERROR: Can't find \"candle.exe\" in %PATH%. Must install Wix Toolset and set PATH to build MSI packages" if `where candle 2>NUL`.empty?
      raise "ERROR: Can't find \"light.exe\" in %PATH%. Must install Wix Toolset and set PATH to build MSI packages" if `where light 2>NUL`.empty?
      template = TEMPLATE_DIR + 'authorized_keys.wxs.erb'
      File.open("#{AUTHORIZED_KEYS_WIX}.wxs", 'w') {|file| file.write ERB.new(template.read).result }

      candle = Cocaine::CommandLine.new("candle", ":input -o :output")
      candle.run input: "#{AUTHORIZED_KEYS_WIX}.wxs", output: "#{AUTHORIZED_KEYS_WIX}.wixobj"

      light = Cocaine::CommandLine.new("light", ":input -o :output")
      light.run input: "#{AUTHORIZED_KEYS_WIX}.wixobj", output: "#{AUTHORIZED_KEYS_WIX}.msi"

      FileUtils.mv "#{AUTHORIZED_KEYS_WIX}.msi", OUTPUT_DIR
      puts "Built MSI package: #{OUTPUT_DIR + 'authorized_keys.msi'}"
    end
  end if RbConfig::CONFIG['host_os'] =~ /mingw|mswin|cygwin/i

  task setup: [:environment, :clean] do
    raise "ERROR: Must set 'KEYSERVER_URL' in .env file" if ENV['KEYSERVER_URL'].nil?
    raise "ERROR: Must set 'COMPANY' in .env file" if ENV['COMPANY'].nil?
    include Rails.application.routes.url_helpers
    puts 'Setting up build environment'
    default_url_options[:host] = ENV['KEYSERVER_URL']
    @authorized_keys_url = authorized_keys_url('')
    @register_host_url = register_host_url('')
    @options = {
      name: Rails.application.class.parent_name,
      version: Versioning::VERSION.to_s,
      maintainer: ENV['COMPANY'],
      description: 'Provides support for retrieving authorized_keys from a manager application server'
    }
  end

  desc 'Clean working directories'
  task :clean do
    puts 'Cleaning build environment'
    FileUtils.rm_rf WORKING_DIR
    FileUtils.mkdir_p WORKING_DIR
    FileUtils.mkdir_p OUTPUT_DIR
  end
end
