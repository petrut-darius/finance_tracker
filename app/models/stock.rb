require "httparty"

class Stock < ApplicationRecord

  def self.new_lookup(ticker_symbol)
    response = HTTParty.get("https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=#{ticker_symbol}&apikey=#{Rails.application.credentials.api_finance_tracker[:key]}")
    if response.code == 200 && response.parsed_response['Global Quote']
      response.parsed_response['Global Quote']['05. price']
    else
      nil
    end
  end

end
