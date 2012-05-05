# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'spec_helper'

describe Formula do

  context 'for a formula in a full repository' do

    let(:formula) do
      repo = Repository.new name: Repository::MAIN, full: true
      Formula.new name: 'git', repository: repo
    end

    describe '#path' do
      it 'returns the relative path' do
        formula.path.should eq('Library/Formula/git.rb')
      end
    end

    describe '#raw_url' do
      it 'returns the GitHub URL of the raw formula file' do
        formula.raw_url.should eq("https://raw.github.com/#{Repository::MAIN}/HEAD/Library/Formula/git.rb")
      end
    end

  end

  context 'for a formula in an alternative repository' do

    let(:formula) do
      repo = Repository.new name: 'adamv/homebrew-alt', full: false
      Formula.new name: 'php', path: 'duplicates', repository: repo
    end

    describe '#path' do
      it 'returns the relative path' do
        formula.path.should eq('duplicates/php.rb')
      end
    end

    describe '#raw_url' do
      it 'returns the GitHub URL of the raw formula file' do
        formula.raw_url.should eq('https://raw.github.com/adamv/homebrew-alt/HEAD/duplicates/php.rb')
      end
    end

  end

end
