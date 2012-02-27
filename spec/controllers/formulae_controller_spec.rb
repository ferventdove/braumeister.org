# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'spec_helper'

describe FormulaeController do

  describe '#select_repository' do
    it 'sets the repository' do
      repo = mock
      Repository.expects(:find).with('adamv-fwdslsh-homebrew-alt').returns repo
      controller.expects(:params).twice.returns({ repository_id: 'adamv/homebrew-alt' })

      controller.send :select_repository

      controller.instance_variable_get(:@repository).should eq(repo)
    end

    it 'redirects to the short url for mxcl/homebrew' do
      request = mock
      request.expects(:url).twice.returns 'http://braumeister.org/repos/mxcl/homebrew/browse'
      controller.expects(:request).twice.returns request
      controller.expects(:redirect_to).with '/browse'

      controller.send :select_repository
    end

    it 'the repository defaults to mxcl/homebrew' do
      repo = mock
      Repository.expects(:find).with('mxcl-fwdslsh-homebrew').returns repo

      controller.send :select_repository

      controller.instance_variable_get(:@repository).should eq(repo)
    end
  end

  # describe '#show' do
    # context 'when formula is not found' do
      # before do
        # repo = mock
        # Repository.expects(:where).with(name: 'mxcl/homebrew').returns mock(first: repo)
      # end

      # it { should render_template(:not_found) }
    # end
  # end

end
