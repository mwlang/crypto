module Exchanges
  module Cryptoid
    extend ExchangeMethods
    extend self

    def configured?
      !!settings["addresses"]
    end

    def pairs
      @pairs ||= Config.market.pairs(exchange_name)
    rescue NameError
      []
    end

    def btc_pair symbol
      ticker symbol
    end

    def addresses
      settings["addresses"]
    end

    def fetch_balance symbol, address
      root_url = "https://chainz.cryptoid.info/#{symbol}/api.dws"
      url = "#{root_url}?q=getbalance&a=#{address}"
      response =   Faraday.get(url)
      response = Faraday.get(response.headers["location"]) if response.status == 302
      response.status == 200 ? response.body.to_f : 0.0
    end

    def get_address_balances
      balances = {}
      addresses.each do |symbol, entry|
        balances[symbol] = { balance: fetch_balance(symbol, entry["address"]), entry: entry }
      end
      return balances
    end

    def wallets
      return [] unless configured?
      large_balances adapt_wallets(get_address_balances)
    end

    def get_btc_rate entry
      market = Cryptoexchange::Models::MarketPair.new \
        market: entry["exchange"], 
        base: entry["symbol"].upcase, 
        target: 'BTC'
      begin
        return Cryptoexchange::Client.new.ticker(market)
      rescue NoMethodError
        # NOP
      end
    end

    def adapt_wallets data
      return [] if data.nil?
      data.map do |symbol, data|
        available = data[:balance]
        pending = 0.0
        balance = available + pending
        bal_btc = get_btc_rate(data[:entry]).last * balance
        bal_usd = bal_btc * Config.btcusd_rate
        Wallet.new(self, symbol, balance, available, pending, bal_usd, bal_btc)
      end
    end

  end
end
