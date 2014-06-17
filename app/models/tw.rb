class Tw < ActiveRecord::Base
  require 'twitter'

  def self.tweet(msg)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = "Tli6mWsBhcJgJORYcknP2ts0l"
      config.consumer_secret     = "3TJSb4Y4DNg4kJt1cZcjvCe7bLQ7PKs78ZHKfjJQV6gxD5mzIi"
      config.access_token        = "2573196487-KltYXKzalSomXuJlZLYSYiNnez8PV7eAXkZJzFz"
      config.access_token_secret = "sEfhHCzsEUgnhhTCr7mbP26m4WGKvwU7OTGsXtb5l09uy"
    end

    client.update(msg)
  end

end
