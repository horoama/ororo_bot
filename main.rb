require 'twitter'
require 'json'
require 'pp'
require 'thread'

class Ororo
    def initialize
        key_file=File.read("./key.json", :encoding => Encoding::UTF_8)
        keys = JSON.load(key_file)
	@tweets=JSON.load File.read("./tweets.json", :encoding => Encoding::UTF_8)
        @client = Twitter::REST::Client.new do |config|
            config.consumer_key     = keys['key']
            config.consumer_secret  = keys['secret']
            config.access_token      = keys['token']
            config.access_token_secret = keys['token_secret']
        end
        @userstream = Twitter::Streaming::Client.new do|config|
            config.consumer_key     = keys['key']
            config.consumer_secret  = keys['secret']
            config.access_token      = keys['token']
            config.access_token_secret = keys['token_secret']
        end

    end

    def load_tweet filepath
	@tweets=JSON.load File.read(filepath , :encoding => Encoding::UTF_8)
    end


    def tweet (text, options={})
        @client.update(text, options)
	rescue => e
	    puts e.message
    end

    def run_stream
	@stream_thread = Thread.new{
	puts "start stream"
	@userstream.user do |ob|
	    id = nil
            if ob.is_a?(Twitter::Tweet) && !ob.retweet?
        	id = ob.id
        	if ob.text.include?("吐") && ob.user.screen_name !="ororo_bot"
        	    @client.favorite(id)
        	    #rnd = Random.new(@tweets[:reply].length)
        	    #@tweets[:reply][rnd]
        	elsif ob.text.include?("オロロちゃん")
		    puts "hoge"
        	    #tweet("@#{ob.user.screen_name} なんや言うことあるんか?", in_reply_to_status_id: id)
        	end
            end
	end
	}
    end

    def stop_stream
	@stream_thread.kill if stream_is_alive?
    end

    def stream_is_alive?
	@stream_thread.alive?
    end

    def regular_tweet interval
	puts "starting regular tweet"
	loop do
	    rnd = rand(@tweets["regular"].length)
	    text = @tweets["regular"][rnd]
	    puts text
	    puts Time.now
	    tweet(text)
	    run_stream unless stream_is_alive?
	    sleep interval
	end
    end
end

ororo = Ororo.new()
ororo.run_stream
#ororo.regular_tweet 60*60*3
