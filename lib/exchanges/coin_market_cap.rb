module Exchanges
  module CoinMarketCap
    include ExchangeMethods
    extend self

    def exchange_name
      "cmc"
    end

    def configured?
      !!settings["coins"]
    end

    def listings
      return @listings if @listings
      response = Faraday.get("https://api.coinmarketcap.com/v2/listings/")
      return nil if response.status != 200
      @listings = JSON.parse(response.body)
    end

    def large_balances all_wallets
      all_wallets.select{ |w| w.balance_usd >= (settings["small_balance"] || SMALL_BALANCE_THRESHOLD) }
    end

    def wallets
      return [] unless configured?
      large_balances(adapt_wallets coins)
    end

    def coins
      settings["coins"]
    end

    def ticker id
      response = Faraday.get("https://api.coinmarketcap.com/v2/ticker/#{id}/")
      return nil if response.status != 200
      if json = JSON.parse(response.body)
        return json["data"]
      end
    end

    def adapt_wallets coins
      return [] if coins.nil?
      coins.map do |coin, amount|
        symbol = coin.upcase
        if meta = listings["data"].detect{|l| l["symbol"] == symbol}
          if data = ticker(meta["id"])
            balance, available = amount.to_f
            pending = nil
            usd_price = data["quotes"]["USD"]["price"] rescue nil
            bal_usd = usd_price ? balance * usd_price : nil
            bal_btc = bal_usd ? bal_usd / Config.btcusd_rate : nil
            Wallet.new(self, symbol, balance, available, pending, bal_usd, bal_btc)
          end
        end
      end.compact
    end

  end
end
