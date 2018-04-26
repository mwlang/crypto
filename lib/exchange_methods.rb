module ExchangeMethods

  def exchange_name
    self.to_s.split("::").last.downcase
  end

  def settings
    Config.settings.fetch(exchange_name, {})
  end

  def defaults
    Config.settings.fetch("defaults", {})
  end

  def default_small_balances
    defaults["small_balance"] || 0.0
  end

  def ticker symbol
    %w{bittrex binance gdax kucoin cryptopia}.each do |exch|
      market = Cryptoexchange::Models::MarketPair.new market: exch, base: symbol.upcase, target: 'BTC'
      begin
        Cryptoexchange::Client.new.ticker(market)
        return market
      rescue NoMethodError
        # NOP
      end
    end
  end

  def pairs
    Config.market.pairs(exchange_name)
  rescue NameError
    []
  end

  def btc_pair symbol
    ticker symbol
  end

  def large_balances all_wallets
    all_wallets.select{ |w| w.balance_usd >= (settings["small_balance"] || default_small_balances) }
  end

end
