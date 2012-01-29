# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'spec_helper'

describe Repository do

  before do
    @repo = Repository.new name: 'mxcl/homebrew'
  end

  it 'has a path' do
    @repo.path.should eq("#{Braumeister::Application.tmp_path}/repos/mxcl/homebrew")
  end

  it 'has an URL' do
    @repo.url.should eq('git://github.com/mxcl/homebrew.git')
  end

  describe 'can call Git commands' do

    before do
      @command = "git --git-dir #{@repo.path}/.git log"
    end

    it 'successfully' do
      @repo.expects(:`).with(@command).returns 'log output'
      `test 0 -eq 0`

      @repo.git('log').should eq('log output')
    end

    it 'with errors' do
      @repo.expects(:`).with(@command).returns ''
      `test 0 -eq 1`

      -> { @repo.git('log') }.should raise_error(RuntimeError, "Execution of `#{@command}` failed.")
    end

  end

end
