# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

module Kernel

  alias_method :orig_backtick, :'`'

  def `(command)
    if command == 'which brew'
      File.join $homebrew_path, 'bin', 'brew'
    elsif command == '/usr/bin/sw_vers -productVersion'
      '10.7.2'
    elsif command == 'xcodebuild -version 2>&1'
      "Xcode 4.2\nBuild version 4D199"
    else
      orig_backtick command
    end
  end

end
