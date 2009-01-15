
require 'stateful'
require 'vendor/cucumber/lib/cucumber/rake/task'

# Try these:
#
# rake features
# rake features PROFILE=html

Cucumber::Rake::Task.new do |t|
  profile = ENV['PROFILE'] || 'default'
  t.cucumber_opts = "--profile #{profile}"
end

task :default do
  Rake::Task['run_specs'].invoke
end

task :autospec do
  puts `ruby rstakeout.rb "spec **/*_spec.rb" specs/* lib/*`
end

task :run_specs do
  puts `spec --color --format specdoc specs/*_spec.rb`
  raise "specs failed" if $?.exitstatus != 0
end

task :run_specs_without_specdoc do
  puts `spec --require specs/bootstrap.rb --color specs/*_spec.rb`
  raise "specs failed" if $?.exitstatus != 0
end

task :loc do
  loc, nf, blank = 0, 0, /^\s+?$/
  Dir['**/*.rb'].each do |path|
    open(path) { |f| nf += 1; f.each { |line| loc += 1 unless line =~ blank } }
  end
  puts "There are #{loc} non-blank line(s) across #{nf} file(s)."
end
