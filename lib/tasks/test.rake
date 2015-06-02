if ENV["GENERATE_REPORTS"]
  require 'ci/reporter/rake/minitest'
  task :test => 'ci:setup:minitest'
end
