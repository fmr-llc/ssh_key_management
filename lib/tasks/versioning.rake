require 'versioning'
require 'dotenv/tasks'

namespace :version do
  desc 'version:bump[:level] - default level is :patch, available levels: :major, :minor, :patch'
  task :bump, :level do |t, args|
    args.with_defaults(level: nil)
    args[:level] = args[:level].intern unless args[:level].nil?
    Versioning::VERSION.bump args[:level]
    puts "Bumped to #{Versioning::VERSION}"
  end

  desc 'version:set_env VERSION. '
  task :set_env do
    ENV["MAJOR_VERSION"] = "#{Versioning::VERSION.major}"
    ENV["MINOR_VERSION"] = "#{Versioning::VERSION.minor}"
    ENV["PATCH_VERSION"] = "#{Versioning::VERSION.patch}"
    ENV["GIT_TAGS"]      = Versioning::VERSION.tags
    ENV["GIT_BRANCH"]    = Versioning::VERSION.branch
  end

  desc 'version:update VERSION. Use MAJOR_VERSION, MINOR_VERSION, PATCH_VERSION, BUILD_VERSION to override defaults'
  task :update do
    Versioning::VERSION.major = ENV["MAJOR_VERSION"] if ENV["MAJOR_VERSION"]
    Versioning::VERSION.minor = ENV["MINOR_VERSION"] if ENV["MINOR_VERSION"]
    Versioning::VERSION.patch = ENV["PATCH_VERSION"] if ENV["PATCH_VERSION"]
    Versioning::VERSION.update
  end

  desc 'version:set_build_number_env to update BUILD_NUMBER in .env file'
  task set_build_number_env: :dotenv do
    return unless File.exist? '.env'
    return unless ENV['BUILD_NUMBER']
    envs = File.read('.env')
    if envs =~ /BUILD_NUMBER=\d+/
      envs.gsub!(/BUILD_NUMBER=\d+/, "BUILD_NUMBER=#{ENV['BUILD_NUMBER']}")
    else
      envs += "\nBUILD_NUMBER=#{ENV['BUILD_NUMBER']}"
    end
    File.open('.env', 'w') { |f| f.write envs }
  end
end
