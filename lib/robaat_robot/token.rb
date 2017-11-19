module Robåt
  def self.load_token
    if ARGV.include? '--token'
      return ARGV[ARGV.index('--token') + 1]
    end
    
    file_path = Dir.glob "#{File.expand_path(File.dirname(__FILE__))}/../../*.key"
    File.read("#{file_path[0]}").strip
  end
end
