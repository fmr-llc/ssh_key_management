# enables versioning of application
module Versioning
  VERSION_FILE = Rails.root + 'VERSION'
  FileUtils.touch VERSION_FILE unless File.exist? VERSION_FILE

  # holds methods/vars for versioning
  class Version
    attr_accessor :file, :major, :minor, :patch

    def initialize(file)
      @file = file
      values = parse(File.read(@file))
      return if values.nil?
      @major = values[0] || 0
      @minor = values[1] < 1 ? 1 : values[1]
      @patch = values[2] || 0
    end

    def build_number
      ENV['BUILD_NUMBER'] || '?'
    end

    def tags
      tags = `git describe --always --tags`.chomp
      tags.blank? ? nil : tags
    end

    def bump(field = :patch)
      field = :patch if field.nil?
      return unless [:major, :minor, :patch].include? field
      current_value = send field
      send "#{field}=".intern, current_value + 1
      update
    end

    def update
      File.open(@file, 'w') { |f| f.write self } > 0
    end

    def to_s(long = false)
      string = "#{major}.#{minor}.#{patch}"
      string << " [##{build_number}] (#{tags})" if long
      string
    end

    def branch
      `git rev-parse --abbrev-ref HEAD`.chomp
    end

    private

    def parse(string)
      values = string.split(/^(\d*)\.(\d*)\.(.+?)$/)
      [values[1].to_i, values[2].to_i, values[3].to_i] if values[0].blank?
    end
  end

  VERSION = Version.new VERSION_FILE
end
