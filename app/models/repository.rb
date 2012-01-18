# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

class Repository

  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  FORMULA_REGEX = /^(?:Library\/)?Formula\/(.+?)\.rb$/

  field :date, type: Time
  field :name, type: String
  field :sha, type: String
  key :name

  embeds_many :formulae
  has_many :authors
  has_many :revisions

  def clone_or_pull
    last_sha = sha

    if !last_sha.nil? && File.exists?(path)
      Rails.logger.info "Pulling changes from #{name} into #{path}"
      git 'fetch --force --quiet origin master'

      log  = git('log -1 --format=format:"%H %ct" FETCH_HEAD').split
      self.sha  = log[0]

      if last_sha == sha
        Rails.logger.info "Repository #{name} is already up-to-date"
        return [], last_sha
      end

      git "--work-tree #{path} reset --hard --quiet FETCH_HEAD"
    else
      Rails.logger.info "Cloning #{name} into #{path}"
      git "clone --quiet #{url} #{path}"

      log  = git('log -1 --format=format:"%H %ct" HEAD').split
      self.sha  = log[0]

      if last_sha == sha
        Rails.logger.info "Repository #{name} is already up-to-date"
        return [], last_sha
      end
    end

    self.date = Time.at log[1].to_i

    if last_sha.nil?
      changes = git 'ls-tree --name-only HEAD Library/Formula/'
      changes = changes.lines.map { |file| ['A', file.strip] }

      Rails.logger.info "Checked out #{sha} in #{path}"
    else
      changes = git "diff --name-status #{last_sha}..HEAD"
      changes = changes.lines.map { |file| file.split }
      changes = changes.select { |file| file[1] =~ FORMULA_REGEX }

      Rails.logger.info "Updated #{name} from #{last_sha} to #{sha}:"
    end

    return changes, last_sha
  end

  def formula_files
    files = Dir.glob File.join(path, 'Library', 'Formula', '*.rb')
    files.map { |f| File.basename f, '.rb' }
  end

  def generate_history!
    clone_or_pull

    Rails.logger.info "Resetting history of #{name}"
    self.formulae.each { |f| f.revisions.nullify }
    self.revisions.destroy
    self.authors.destroy

    generate_history
  end

  def generate_history(last_sha = nil)
    ref = last_sha.nil? ? 'HEAD' : "#{last_sha}..HEAD"

    Rails.logger.info "Regenerating history for #{ref}"

    log = git "log --format=format:'%H%x00%ct%x00%aE%x00%aN%x00%s' --name-status --no-merges --reverse #{ref} -- 'Formula' 'Library/Formula'"
    revisions = []
    commits = log.split(/\n\n/)
    commits.each do |commit|
      commit = commit.lines.to_a
      info, formulae = commit.shift.strip.split("\x00"), commit
      rev = self.revisions.build sha: info[0]
      rev.author = self.authors.find_or_initialize_by email: info[2]
      rev.author.name = info[3]
      rev.author.save!
      rev.date = info[1].to_i
      rev.subject = info[4]
      rev.save!
      revisions << rev
      formulae.each do |formula|
        formula = self.formulae.where(name: formula.split[1].sub(FORMULA_REGEX, '\1')).first
        next if formula.nil?
        formula.revisions << rev
        formula.date = rev.date if formula.date.nil? || rev.date > formula.date
      end
    end
    self.revisions = revisions
    save!
  end

  def git(command)
    command = "git --git-dir #{path}/.git #{command}"
    Rails.logger.debug "Executing `#{command}`"
    `#{command}`.strip
  end

  def path
    "#{Braumeister::Application.tmp_path}/repos/#{name}"
  end

  def refresh
    changes, last_sha = clone_or_pull

    if changes.size == 0
      Rails.logger.info 'No formulae changed.'
      return
    end

    updated_formulae = []
    changes.each do |type, fpath|
      updated_formulae << fpath.match(FORMULA_REGEX)[1] unless type == 'D'
    end

    formulae_info = formulae_info updated_formulae

    added = modified = removed = 0
    changes.each do |type, fpath|
      formula = formulae.find_or_initialize_by name: fpath.match(FORMULA_REGEX)[1]
      if type == 'D'
        removed += 1
        formula.removed = true
        Rails.logger.debug "Removed formula #{formula.name}."
      else
        if type == 'A'
          added += 1
          Rails.logger.debug "Added formula #{formula.name}."
        else
          modified += 1
          Rails.logger.debug "Updated formula #{formula.name}."
        end
        formula.homepage = formulae_info[formula.name][:homepage]
        formula.removed  = false
        formula.version  = formulae_info[formula.name][:version]
      end
      formula.save
    end

    generate_history last_sha

    Rails.logger.info "#{added} formulae added, #{modified} formulae modified, #{removed} formulae removed."
  end

  def url
    "git://github.com/#{name}.git"
  end

  private

  def formulae_info(formulae)
    pipe_read, pipe_write = IO.pipe
    pid = fork do
      pipe_read.close

      $LOAD_PATH.unshift File.join(path, 'Library', 'Homebrew')

      Object.send :remove_const, :Formula

      $homebrew_path = path
      require 'sandbox_backtick'

      load File.join(path, 'Library', 'Homebrew', 'global.rb')
      load File.join(path, 'Library', 'Homebrew', 'formula.rb')

      formulae_info = {}
      formulae.each do |name|
        begin
          Rails.logger.debug name
          formula = Formula.factory name
          formulae_info[name] = {
            homepage: formula.homepage,
            version: formula.version
          }
        rescue TypeError
          const = $!.message.match(/^(.*?) is not a class/)[1].to_sym
          Object.send :remove_const, const
          redo
        end
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
