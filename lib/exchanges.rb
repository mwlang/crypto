require_relative 'exchange_methods'

require_relative 'exchanges/coinbase'
require_relative 'exchanges/gdax'
require_relative 'exchanges/binance'
require_relative 'exchanges/bittrex'
require_relative 'exchanges/kucoin'
require_relative 'exchanges/cryptoid'
require_relative 'exchanges/exodus'

SMALL_BALANCE_THRESHOLD = 1.0 # USD

EXCHANGES = [
  Exchanges::Gdax,
  Exchanges::Coinbase,
  Exchanges::Bittrex,
  Exchanges::Binance,
  Exchanges::Kucoin,
  Exchanges::Cryptoid,
  Exchanges::Exodus,
]

require_relative 'exchanges/yaml_wallet'

Config.settings.keys.each do |exchange_name|
  next if EXCHANGES.map{|ex| ex.exchange_name}.include? exchange_name
  EXCHANGES << Exchanges::YamlWallet.new(exchange_name)
end
