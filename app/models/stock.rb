require "httparty"

class Stock < ApplicationRecord
  has_many :user_stocks
  has_many :users, through: :user_stocks

  validates :name, :ticker, presence: true

  def self.new_lookup(ticker_symbol)
    api_key = Rails.application.credentials.api_finance_tracker[:key]

    quote_url = "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=#{ticker_symbol}&apikey=#{api_key}"
    overview_url = "https://www.alphavantage.co/query?function=OVERVIEW&symbol=#{ticker_symbol}&apikey=#{api_key}"

    quote_response = HTTParty.get(quote_url)
    overview_response = HTTParty.get(overview_url)

    # Check for API rate limit message
    if quote_response.parsed_response["Note"] || overview_response.parsed_response["Note"]
      Rails.logger.warn("Alpha Vantage API limit reached or service unavailable")
      return nil
    end

    if quote_response.code == 200 && overview_response.code == 200
      quote_data = quote_response.parsed_response["Global Quote"]
      overview_data = overview_response.parsed_response

      if quote_data && overview_data && quote_data["05. price"] && overview_data["Name"]
        price = quote_data["05. price"]
        name = overview_data["Name"]

        begin
          new(ticker: ticker_symbol, name: name, last_price: price)
        rescue => exception
          nil
        end
      else
        nil
      end
    else
      nil
    end
  end

  def self.check_db(ticker)
    where(ticker: ticker).first
  end
end
