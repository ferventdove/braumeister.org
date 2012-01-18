# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

if defined? ::NewRelic
  def task_with_tracing(options)
    caller_method = options.keys.first.to_s

    task options do
      include NewRelic::Agent::Instrumentation::ControllerInstrumentation

      perform_action_with_newrelic_trace name: caller_method, category: :task, force: true do
        yield
      end
    end
  end
else
  class << self
    alias_method :task_with_tracing, :task
  end
end

namespace :braumeister do

  Rails.logger = Logger.new STDOUT

  HOMEBREW = 'mxcl/homebrew'

  desc 'Completely regenerates the repository and all its formulae'
  task_with_tracing regenerate: :environment do
    repo = Repository.find_or_create_by name: HOMEBREW
    repo.authors.clear
    repo.formulae.clear
    repo.revisions.clear
    repo.sha = nil
    FileUtils.rm_rf repo.path
    repo.refresh
    repo.save!
  end

  desc 'Regenerates the history of all formulae in the repository'
  task_with_tracing regenerate_history: :environment do
    repo = Repository.find_or_create_by name: HOMEBREW
    repo.generate_history!
  end

  desc 'Pulls the latest changes from or clones the repository'
  task_with_tracing update: :environment do
    repo = Repository.find_or_create_by name: HOMEBREW
    repo.refresh
    repo.save!
  end

end
