# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'spec_helper'

describe Repository do

  let(:repo) { Repository.new name: 'mxcl/homebrew', full: true }

  describe '.main' do
    it 'returns the repository object for mxcl/homebrew' do
      repo = mock
      Repository.expects(:find).with('mxcl/homebrew'.identify).returns repo

      Repository.main.should eq(repo)
    end
  end

  describe '#main?' do
    it 'returns true for mxcl/homebrew' do
      repo.main?.should be_true
    end

    it 'returns false for other repositories' do
      Repository.new(name: 'adamv/homebrew-alt').main?.should be_false
    end
  end

  describe '#path' do
    it 'returns the filesystem path of the Git repository' do
      repo.path.should eq("#{Braumeister::Application.tmp_path}/repos/mxcl/homebrew")
    end
  end

  describe '#url' do
    it 'returns the Git URL of the GitHub repository' do
      repo.url.should eq('git://github.com/mxcl/homebrew.git')
    end
  end

  describe '#git' do

    context 'can call Git commands' do

      let(:command) { "git --git-dir #{repo.path}/.git log" }

      it 'successfully' do
        repo.expects(:`).with(command).returns 'log output'
        `test 0 -eq 0`

        repo.git('log').should eq('log output')
      end

      it 'with errors' do
        repo.expects(:`).with(command).returns ''
        `test 0 -eq 1`

        -> { repo.git('log') }.should raise_error(RuntimeError, "Execution of `#{command}` failed.")
      end

    end

  end

  describe '#clone_or_pull' do

    it 'clones a new repository' do
      File.expects(:exists?).with(repo.path).returns false
      repo.expects(:git).with "clone --quiet #{repo.url} #{repo.path}"
      repo.expects(:git).with('log -1 --format=format:"%H %ct" HEAD').
        returns 'deadbeef 1325844635'
      repo.expects(:git).with('ls-tree --name-only HEAD Library/Formula/').
        returns "Library/Formula/bazaar.rb\nLibrary/Formula/git.rb\nLibrary/Formula/mercurial.rb"
      repo.expects(:git).with('ls-tree --name-only HEAD Library/Aliases/').
        returns "Library/Aliases/bzr\nLibrary/Aliases/hg"

      formulae, aliases, last_sha = repo.clone_or_pull

      formulae.should eq([%w{A Library/Formula/bazaar.rb}, %w{A Library/Formula/git.rb}, %w{A Library/Formula/mercurial.rb}])
      aliases.should eq([%w{A Library/Aliases/bzr}, %w{A Library/Aliases/hg}])
      last_sha.should be_nil

      repo.sha.should eq('deadbeef')
      repo.date.should eq(Time.at 1325844635)
    end

    context 'updates an already known repository' do

      before do
        repo.sha = '01234567'
        repo.expects(:git).with('diff --name-status 01234567..HEAD').
          returns "D\tLibrary/Aliases/bzr\nA\tLibrary/Aliases/hg\nD\tLibrary/Formula/bazaar.rb\nM\tLibrary/Formula/git.rb\nA\tLibrary/Formula/mercurial.rb"
      end

      it 'and clones it if it doesn\'t exist yet' do
        File.expects(:exists?).with(repo.path).returns false
        repo.expects(:git).with "clone --quiet #{repo.url} #{repo.path}"
        repo.expects(:git).with('log -1 --format=format:"%H %ct" HEAD').
          returns 'deadbeef 1325844635'
      end

      it 'and fetches updates if it already exists' do
        File.expects(:exists?).with(repo.path).returns true
        repo.expects(:git).with('fetch --force --quiet origin master')
        repo.expects(:git).with('log -1 --format=format:"%H %ct" FETCH_HEAD').
          returns 'deadbeef 1325844635'
        repo.expects(:git).with("--work-tree #{repo.path} reset --hard --quiet FETCH_HEAD")
      end

      after do
        formulae, aliases, last_sha = repo.clone_or_pull

        formulae.should eq([%w{D Library/Formula/bazaar.rb}, %w{M Library/Formula/git.rb}, %w{A Library/Formula/mercurial.rb}])
        aliases.should eq([%w{D Library/Aliases/bzr}, %w{A Library/Aliases/hg}])
        last_sha.should eq('01234567')

        repo.sha.should eq('deadbeef')
        repo.date.should eq(Time.at 1325844635)
      end

    end

  end

  describe '#generate_history!' do
    it 'resets the repository and generates the history from scratch' do
      repo.revisions << Revision.new(sha: '01234567')
      repo.revisions << Revision.new(sha: 'deadbeef')
      repo.formulae << Formula.new(name: 'bazaar', revisions: repo.revisions)
      repo.formulae << Formula.new(name: 'git', revisions: repo.revisions)
      repo.authors << Author.new(name: 'Sebastian Staudt')

      repo.expects :clone_or_pull
      repo.expects :generate_history

      repo.generate_history!

      repo.revisions.should be_empty
      repo.authors.should be_empty
      repo.formulae.each { |formula| formula.revisions.should be_empty }
    end
  end

  describe '#refresh' do
    it 'does nothing when nothing has changed' do
      repo.expects(:clone_or_pull).returns [[], [], 'deadbeef']
      Rails.logger.expects(:info).with 'No formulae changed.'
      repo.expects(:generate_history).never

      repo.refresh
    end
  end

  describe '#formula_info' do

    before do
      def repo.fork
        yield
        1234
      end

      repo.expects :exit!
      Process.expects(:wait).with 1234

      io = StringIO.new
      io.expects(:close).times(4).with { io.rewind }
      IO.expects(:pipe).returns [io, io]

      Object.expects(:remove_const).with :Formula
      repo.expects(:load).with 'global.rb'
      repo.expects(:load).with 'formula.rb'
    end

    it 'uses a forked process to load formula information' do
      git = mock deps: [], homepage: 'http://git-scm.com', keg_only?: false, name: 'git', version: '1.7.9'
      memcached = mock deps: %w(libevent), homepage: 'http://memcached.org/', keg_only?: false, name: 'memcached', version: '1.4.11'

      Formula.expects(:factory).with('git').returns git
      Formula.expects(:factory).with('memcached').returns memcached

      formulae_info = repo.send :formulae_info, %w{git memcached}
      formulae_info.should eq({
        'git' => { deps: [], homepage: 'http://git-scm.com', keg_only: false, version: '1.7.9' },
        'memcached' => { deps: %w(libevent), homepage: 'http://memcached.org/', keg_only: false, version: '1.4.11' }
      })
    end

    it 'reraises errors caused by the subprocess' do
      Formula.expects(:factory).with('git').raises RuntimeError.new('subprocess failed')

      ->() { repo.send :formulae_info, %w{git} }.should raise_error(RuntimeError, 'RuntimeError: subprocess failed')
    end

  end

end
