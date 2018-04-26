module Exchanges
  module Exodus
    extend ExchangeMethods
    extend self

    def configured?
      !!settings["addresses"] || !!settings["coins"]
    end

    def addresses
      settings["addresses"]
    end

    def fetch_balance coin, address
      response = Faraday.get("https://chainz.cryptoid.info/#{coin}/api.dws?q=getbalance&a=#{address}")
      response = Faraday.get(response.headers["location"]) if response.status == 302
      response.status == 200 ? response.body.to_f : 0.0
    end

    def get_address_balances
      balances = {}
      addresses.each do |coin, address|
        raise [coin, address].inspect
        balances[coin] = fetch_balance coin, address
      end
      return balances
    end

    def wallets
      return [] unless configured?
      large_balances((adapt_coins_to_wallets + adapt_addresses_to_wallets).sort_by{|sb| sb.symbol})
    end

    def coin_listing
      settings["coins"]
    end

    def adapt_coins_to_wallets
      return [] if coin_listing.nil?
      wallets = []
      coin_listing.each do |w|
        symbol = w[0].upcase
        balance, available = w[1].to_f
        pending = nil
        wallets << Wallet.new(self, symbol, balance, balance, nil)
      end
      return wallets
    end

    def fetch_eth_address_data address
      endpoint = "https://api.ethplorer.io/getAddressInfo/#{address}?apiKey=freekey"
      response = Faraday.get(endpoint)
      response = Faraday.get(response.headers["location"]) if response.status == 302
      response.status == 200 ? JSON.parse(response.body) : nil
    end

    def all_coins_in_eth_address address
      data = fetch_eth_address_data(address)
      raise "#{address} is not an Ethereum address!" unless data["ETH"]
      coins = [{ symbol: "eth", balance: data["ETH"]["balance"] }]

      data["tokens"].each do |token|
        coins << {
          symbol: token["tokenInfo"]["symbol"],
          balance: token["balance"]/(10**token["tokenInfo"]["decimals"].to_f),
          usd_rate: token["tokenInfo"]["price"] ? token["tokenInfo"]["price"]["rate"].to_f : nil
        }
      end
      return coins
    end

    def coins_from_addresses
      return [] if settings["addresses"].nil?
      settings["addresses"].map do |name, address|
        if name.upcase == "ETH"
          all_coins_in_eth_address(address)
        else
          raise 'not implemented, yet'
        end
      end.flatten
    end

    def adapt_addresses_to_wallets
      coins_from_addresses.map do |values|
        symbol = values[:symbol].upcase
        balance = values[:balance]
        available = balance
        pending = nil
        bal_usd = values[:usd_rate] ? balance * values[:usd_rate] : nil
        bal_btc = bal_usd ? bal_usd / Config.btcusd_rate : nil
        Wallet.new(self, symbol, balance, available, pending, bal_usd, bal_btc)
      end.flatten.compact
    end

  end
end
