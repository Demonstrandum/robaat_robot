using Telegram

module Robåt
  class Bot
    attr_accessor :token

    def initialize token
      @token = token
      @bot = Telegram::Bot::Client.new @token
      @start_message = nil

      @wotd = WOTD.new WORDS_FILE
      @scheduler = Rufus::Scheduler.new
    end

    def wotd_format
      return <<EOF
Word Of The Day _/ Ordet Av Dagen_

Norwegian _/ Norsk_
'*#{@wotd.wotd['no']}*'
---
English _/ Englesk_
'*#{@wotd.wotd['en']}*'


#{@wotd.wotd['notes'].empty? ? '' : "Notes _/ Notater_\n```\n" + @wotd.wotd['notes'] + "\n```"}

Queue place _/ Kø posisjon_  -  *#{(JSON.parse File.read(INFO_FILE))['wotd'] + 1 }.*
EOF
    end

    def commands
      @bot.listen do |message|
        case message.to_s
        when /\/start/
          puts "Bot has been started!"
          puts "Start message object: #<#{message.class.name}:0x#{message.object_id.to_s 16}>"
          @start_message = message.clone
          @bot.api.send_message(
            chat_id: message.chat.id,
            text: <<EOF
Ro, ro, ro din båt,
ta din åre fatt.
Vuggende, vuggende,
vuggende, vuggende
over Kattegatt!

Hei, jeg er Robåt Roboten!
Hi, I'm the Rowboat Robot!

Her for å lære deg norsk.
Here to teach you Norwegian.
EOF
          )
          schedule  # Start schedule

        when /\/help/
          @bot.api.send_message(
            chat_id: message.chat.id,
            text: <<EOF
/start  -  Start the bot in this chat
/wotd  -  Display the Word Of The Day
/listwords  -  List all WOTD words in queue
/addword  -  Add a new word to the WOTD queue
/removeword  -  Remove a word form the queue by its position (see /listwords)
/nextword  -  Move on to the next word in the WOTD queue
/previousword  -  Go back to the last word in the WOTD queu
EOF
          )

        when /\/wotd/
          @bot.api.send_message(
            chat_id: message.chat.id,
            text: wotd_format,
            parse_mode: 'Markdown'
          )
        when /\/addword/
          unless message.to_s.include? '>'
            @bot.api.send_message(
              chat_id: message.chat.id,
              text: "Please format your new word like so:\n" +
              "ENGLISH WORD > NORWEGIAN WORD > NOTES\n" +
              "\nThe notes are optional, and you must include the greater than signs ('>')\n\n" +
              "Example:\n```\n" +
              "/addword Good day > God dag > A simple greeting phrase\n```",
              parse_mode: 'Markdown'
            )
          else
            words = message.to_s.split(' ')[1..-1].join(' ').split('>').map(&:strip)
            en, no = words[0..1]
            notes = String.new
            if words.size > 2
              notes = words[2]
            end
            @wotd.add en, no, notes
            @bot.api.send_message chat_id: message.chat.id, text: "Your word has been added to the queue!"
          end

        when /\/removeword/
          word_index = message.to_s.split(' ')[-1].strip.to_i - 1
          @wotd.remove word_index
          @bot.api.send_message chat_id: message.chat.id, text: "Removed word number: #{word_index + 1}. from queue!"

        when /\/rawqueue/
          require 'pp'
          @bot.api.send_message(
            chat_id: message.chat.id,
            text: "```\n#{@wotd.word_list.pretty_inspect}\n```",
            parse_mode: 'Markdown'
          )
        
        when /\/listwords/
          list_string = String.new
          @wotd.word_list.each.with_index do |hash, i|
            list_string << "#{i + 1}. - #{hash['en']} | #{hash['no']}"
            list_string << "\n"
          end
          @bot.api.send_message chat_id: message.chat.id, text: list_string

        when /\/nextword/
          @wotd.next
          @bot.api.send_message chat_id: message.chat.id, text: wotd_format, parse_mode: 'Markdown'

        when /\/previousword/
          @wotd.previous
          @bot.api.send_message chat_id: message.chat.id, text: wotd_format, parse_mode: 'Markdown'
        end
      end
    end

    private def schedule
      puts "Private scheduler started at #{Time.now}"
      @scheduler.every '4h' do
        puts "Scheduled event at #{Time.now}"

        @bot.api.send_message(
          chat_id: @start_message.chat.id,
          text: wotd_format,
          parse_mode: 'Markdown'
        )
      end
    end

    private def say string, instance=nil, id=nil
      if intance.nil?
        Telegram::Bot::Client.run @token do |bot|
          bot.api.send_message(
            chat_id: message.chat.id,
            text: string
          )
        end
        return string
      end
      
      instance.api.send_message chat_id: id, text: string
      string
    end
  end
end
