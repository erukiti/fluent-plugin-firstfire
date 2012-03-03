# coding: utf-8

class Fluent::FirstfireOutput < Fluent::Output
  Fluent::Plugin.register_output('firstfire', self)

  # config_param :hoge, :string, :default => 'hoge'

  config_param :fire_key, :string
  config_param :fire_count, :integer, :default => 60

  def init_buffering
    @buffer = {}
  end

  def first_fire(time, record)
    key = record[@fire_key]

    unless @buffer[key]
      @buffer[key] = time
      true
    else
      if time >= @buffer[key] + @fire_count
        @buffer[key] = time
        true
      else
        false
      end
    end
  end


  def initialize
    super
  end

  def configure(cnf)
    super
  end

  def start
    super
    init_buffering
  end

  def shutdown
    super
  end

  def format(tag, time, record)
    [tag, time, record].to_msgpack
  end

  def emit(tag, es, chain)
    es.each do |time, record|
      Fluent::Engine.emit(tag, time, record) if first_fire(time, record)
    end
    chain.next
  end
end
