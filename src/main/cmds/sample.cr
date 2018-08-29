module Cmds::Sample
  LOG = {{ system("cat " + env("PWD") + "/sample/log").stringify }}

  def self.run
    puts LOG
  end
end
