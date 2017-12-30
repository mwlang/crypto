module Config
  extend self

  def settings
    config
  end

  def market
    @market ||= Cryptoexchange::Client.new
  end

  def btcusd_rate
    return @btcusd_rate if @btcusd_rate
    return 0.0 unless pair = Exchanges::Gdax.usd_pair("BTC")
    return 0.0 unless ticker = market.ticker(pair)
    @btcusd_rate = ticker.last
  end

  private

  def root_path
    File.dirname(__FILE__)
  end

  def config_filename
    File.expand_path File.join(root_path, '..', 'config', 'exchanges.yml')
  end

  def config
    @config ||= YAML.load_file(config_filename)
  end
end
