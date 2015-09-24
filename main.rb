require 'twitter'
require 'json'
require 'pp'

class Ororo
    def initialize
        key_file=File.read("./key.json", :encoding => Encoding::UTF_8)
        keys = JSON.load(key_file)
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

    def tweet text
        @client.update(text)
    end

    def stream
        @userstream.user do |ob|
            id = 0
            if ob.is_a?(Twitter::Tweet) && !ob.retweet?
                id = ob.id
                if ob.text.include?("吐")
                    @client.favorite(id)
                end
            end
        end
    end
end
ororo = Ororo.new()
ororo.stream
