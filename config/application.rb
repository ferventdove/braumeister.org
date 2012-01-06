# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require File.expand_path('../boot', __FILE__)

require 'action_controller/railtie'
require 'sprockets/railtie'

Bundler.require :default, :assets, Rails.env

module Braumeister
  class Application < Rails::Application

    config.assets.enabled = true
    config.assets.version = '1.0'

    config.encoding = "utf-8"

    def self.tmp_path
      @@tmp_path ||= File.join Rails.root, 'tmp'
    end

  end
end
