module Robåt
  class WOTD
    attr_accessor :wotd
    attr_accessor :path
    attr_reader   :word_list

    def initialize file_path
      @path = file_path
      @info = JSON.parse File.read(INFO_FILE)
      
      @json = File.read @path
      @word_list = JSON.parse @json
      @wotd = @word_list[@info['wotd']]

      @scheduler = Rufus::Scheduler.new
      @scheduler.every('24h') { next }
    end

    def add en, no, notes=String.new
      @word_list << {
        'en' => en,
        'no' => no,
        'notes' => notes
      }
      File.write @path, @word_list.to_json
    end

    def remove i
      @word_list.delete_at i
      File.write @path, @word_list.to_json
    end

    def position i
      if @info['wotd'] + i < 0 || @info['wotd'] + i >= @word_list.size
        return :OUT_OF_BOUNDS
      end

      @info['wotd'] += i
      File.write INFO_FILE, @info.to_json
      @wotd = @word_list[@info['wotd']]
    end

    def next
      position 1
    end

    def previous
      position -1
    end
  end
end
