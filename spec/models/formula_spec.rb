# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'spec_helper'

describe Formula do

  before do
    @formula = Formula.new name: 'git'
  end

  it 'has a path' do
    @formula.path.should eq('Library/Formula/git.rb')
  end

end
