# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'spec_helper'

describe FormulaeController do

  describe '#select_repository' do
    it 'sets the repository to mxcl/homebrew' do
      repo = mock
      Repository.expects(:find).with('mxcl-fwdslsh-homebrew').returns repo

      controller.send :select_repository

      controller.instance_variable_get(:@repository).should eq(repo)
    end
  end

end
