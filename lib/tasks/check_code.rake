namespace :check_code do
  if Rails.env.development?
    require 'rubocop/rake_task'
    require 'haml_lint/rake_task'

    desc 'Execute rubocop -DR'
    RuboCop::RakeTask.new(:rubocop) do |t|
      t.options = ['-DR'] # Rails, display cop name
      t.fail_on_error = false
    end

    desc 'Execute haml-lint'
    # Does not work with jruby and windwows
    # HamlLint::RakeTask.new(:haml_lint) do |t|
    #   t.files = %w{app/views/**/*.haml}
    # end
    task haml_lint: :environment do
      puts 'Running HAML-Lint...'
      puts %x(haml-lint app)
    end

    desc 'Execute brakeman'
    task brakeman: :environment do
      puts 'Running Brakeman...'
      puts %x(brakeman)
    end

    task :all do
      %w(rubocop haml_lint).each { |task| Rake::Task["check_code:#{task}"].invoke }
    end
  end
end

desc 'Check code for linting/styling'
task :check_code do
  Rake::Task['check_code:all'].invoke
end
