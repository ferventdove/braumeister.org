# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

class Repository

  include Mongoid::Document

  FORMULA_REGEX = /^Library\/Formula\/(.+?)\.rb$/

  field :date, :type => Time, :default => Time.at(0)
  field :name, :type => String
  field :sha, :type => String, :default => 'unknown'
  key :name

  embeds_many :formulae

  def clone_or_pull
    if File.exists? path
      Rails.logger.info "Pulling changes from #{name} into #{path}"
      git 'fetch --force --quiet origin master'

      last_sha = sha
      log  = git('log -1 --format=format:"%H %ct" FETCH_HEAD').split
      self.sha  = log[0]

      if last_sha == sha
        Rails.logger.info "Repository #{name} is already up-to-date"
        return []
      end

      self.date = Time.at log[1].to_i

      git 'reset --hard --quiet FETCH_HEAD'
      changes = git "diff --name-status #{last_sha}..HEAD"
      changes = changes.lines.map { |file| file.split }
      changes = changes.select { |file| file[1] =~ FORMULA_REGEX }

      Rails.logger.info "Updated #{name} from #{last_sha} to #{sha}:"
    else
      Rails.logger.info "Cloning #{name} into #{path}"
      git "clone --depth 1 --quiet #{url} #{path}"

      log  = git('log -1 --format=format:"%H %ct" HEAD').split
      self.sha  = log[0]
      self.date = Time.at log[1].to_i

      changes = git 'ls-tree --name-only HEAD Library/Formula/*.rb'
      changes = changes.lines.map { |file| ['A', file.strip] }

      Rails.logger.info "Checked out #{sha} in #{path}"
    end

    changes
  end

  def formula_files
    files = Dir.glob File.join(path, 'Library', 'Formula', '*.rb')
    files.map { |f| File.basename f, '.rb' }
  end

  def path
    "#{Braumeister::Application.tmp_path}/repos/#{name}"
  end

  def refresh
    changes = clone_or_pull

    added    = changes.select { |file| file[0] == 'A' }
    modified = changes.select { |file| file[0] == 'M' }
    removed  = changes.select { |file| file[0] == 'D' }

    if changes.size == 0
      Rails.logger.info 'No formulae changed.'
      return
    end

    updated_formulae = []
    changes.each do |type, fpath|
      updated_formulae << fpath.match(FORMULA_REGEX)[1] unless type == 'D'
    end

    formulae_info = formulae_info updated_formulae

    changes.each do |type, fpath|
      formula = formulae.find_or_create_by :name => fpath.match(FORMULA_REGEX)[1]
      formula.repository = self if formula.new_record?
      if type == 'D'
        formula.removed = true
      else
        formula.homepage = formulae_info[formula.name][:homepage]
        formula.removed  = false
        formula.version  = formulae_info[formula.name][:version]
      end
      formula.save
    end

    Rails.logger.info "#{added.size} formulae added, #{modified.size} formulae modified, #{removed.size} formulae removed."
  end

  def refresh_formula(formula)
    original_formula = @sandbox::Formula.factory formula.name
    formula.homepage = original_formula.homepage
    formula.version = original_formula.version
  end

  def url
    "git://github.com/#{name}.git"
  end

  private

  def git(command)
    command = "git --git-dir #{path}/.git #{command}"
    Rails.logger.debug "Executing `#{command}`"
    `#{command}`.strip
  end

  def formulae_info(formulae)
    pipe_read, pipe_write = IO.pipe
    pid = fork do
      pipe_read.close

      $LOAD_PATH.unshift File.join(path, 'Library', 'Homebrew')
      Object.send :remove_const, :Base64
      Object.send :remove_const, :Formula
      Object.send :remove_const, :Syck

      $homebrew_path = path
      require 'sandbox_backtick'

      require 'global'
      require 'formula'

      formulae_info = {}
      formulae.each do |name|
        formula = Formula.factory name
        formulae_info[name] = {
          :homepage => formula.homepage,
          :version => formula.version
        }
      end

      Marshal.dump formulae_info, pipe_write
      pipe_write.close

      exit!
    end

    pipe_write.close
    formulae_info = Marshal.load pipe_read
    pipe_read.close

    Process.wait pid

    formulae_info
  end

end
