# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

def task_with_tracing(options)
  caller_method = options.keys.first.to_s

  if defined? ::NewRelic
    task options do
      include NewRelic::Agent::Instrumentation::ControllerInstrumentation

      perform_action_with_newrelic_trace name: caller_method, category: :task, force: true do
        yield
      end
    end
  else
    task options do
      yield
    end
  end
end

namespace :braumeister do

  Rails.logger = Logger.new STDOUT

  HOMEBREW = 'mxcl/homebrew'

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
