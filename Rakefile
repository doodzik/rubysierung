require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

RuboCop::RakeTask.new

desc 'Run tests and rubocop'
task default: [:test]
