require 'telegram/bot'
require 'rufus-scheduler'
Dir["#{File.dirname __FILE__}/robaat_robot/*.rb"].each { |f| require f }


module Robåt
  VERSIONS = { :major => 0, :minor => 1, :tiny => 0 }
  INFO_FILE  = "#{File.dirname __FILE__}/../info.json"
  WORDS_FILE = "#{File.dirname __FILE__}/../norglish.json"

  def self.version *args
    VERSIONS.flatten.select.with_index { |val, i| i.odd? }.join '.'
  end
end

