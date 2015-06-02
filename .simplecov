# https://github.com/colszowka/simplecov#using-simplecov-for-centralized-config
# Maybe put some conditional here not to execute the code below unless ENV['COVERAGE'] == 'true'
if ENV['GENERATE_REPORTS'] == 'true'
  SimpleCov.start do
    # see https://github.com/colszowka/simplecov/blob/master/lib/simplecov/defaults.rb
    load_profile 'rails' # load_adapter < 0.8
    coverage_dir 'test/reports/coverage'
    # Use multiple 'command_names' to differentiate reports being merged in together
    command_name "rails_app_#{$$}" # $$ is the processid
    merge_timeout 3600 # 1 hour
    add_group "Jobs",        "app/jobs"
    add_group "Middleware",  "app/middleware"
    add_group "Serializers", "app/serializers"
    add_group "Engines",     "engines"
    add_group "Views",       "app/views"
    add_group "Long files" do |src_file|
      src_file.lines.count > 100
    end
    class MaxLinesFilter < SimpleCov::Filter
      def matches?(source_file)
        source_file.lines.count < filter_argument
      end
    end
    add_group "Short files", MaxLinesFilter.new(5)
  
    # Exclude these paths from analysis
    add_filter 'lib/plugins'
    add_filter 'lib/tasks'
    add_filter 'vendor'
    add_filter 'bundle'
  end
end
