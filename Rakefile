# This is free and unencumbered software released into the public domain.

require 'yaml'
require 'active_support/core_ext/hash'  # `gem install activesupport`

def parse_examples(filepath, type)
  examples = {}
  File.open(filepath) do |file|
    name = nil
    file.readline; file.readline  # skip URL
    file.read.split("\n\n").each do |section|
      case section
        when /  \$ clarc/
          examples[name][:ok] += 1 if section.include?('STOP')
          examples[name][:err] += 1 if section.include?('clarc:')
        when /^([^:]+):\s?(.*)/
          examples[name = $1] = {type: type, ok: 0, err: 0, notes: $2.strip}
        else abort "unknown section: #{section}"
      end
    end
  end
  examples
end

def each_feature(&block)
  features = {}
  features.merge!(parse_examples('test/literals.t', 'literal'))
  features.merge!(parse_examples('test/keywords.t', 'keyword'))
  features.merge!(parse_examples('test/operators.t', 'operator'))
  features.merge!(parse_examples('test/functions.t', 'function'))
  #features.each { |k, v| p [k, v] }; exit
  features.keys.sort.each do |feature|
    block.call(feature, features[feature])
  end
end

task default: %w(README.md)

file "README.md" => %w(test/literals.t test/keywords.t test/operators.t test/functions.t) do |t|
  head = File.read(t.name).split("### Supported Clarity features\n", 2).first
  File.open(t.name, 'w') do |file|
    file.puts head
    file.puts "### Supported Clarity features"
    file.puts
    file.puts ["Feature", "Type", "Status", "Notes"].join(' | ')
    file.puts ["-------", "----", "------", "-----"].join(' | ')
    each_feature do |feature, feature_info|
        file.puts [
          "`#{feature}`",
          feature_info[:type],
          feature_info[:notes] == "Not supported." || feature_info[:notes] == "Not implemented yet." ? "❌" :
            (feature_info[:ok] > 0 ? "✅" : "🚧"),
          feature_info[:notes],
        ].join(' | ').strip
    end
    file.puts
    file.puts "**Legend**: ❌ = not supported. 🚧 = work in progress. ✅ = supported."
  end
end
