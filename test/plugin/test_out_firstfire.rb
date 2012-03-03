require 'helper.rb'

class FirstfireOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    fire_key key
    fire_count 60
  ]
  # CONFIG = %[
  #   path #{TMP_DIR}/out_file_test
  #   compress gz
  #   utc
  # ]

  def create_driver(conf = CONFIG, tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::FirstfireOutput, tag).configure(conf)
  end

  def test_first_fire
    d = create_driver
    d.instance.init_buffering
    assert_equal true, d.instance.first_fire(Time.parse("2012-03-03 00:00:00 UTC").to_i, {'key' => 'hoge'})
    assert_equal true, d.instance.first_fire(Time.parse("2012-03-03 00:00:00 UTC").to_i, {'key' => 'fuga'})
    assert_equal false, d.instance.first_fire(Time.parse("2012-03-03 00:00:00 UTC").to_i, {'key' => 'hoge'})
    assert_equal false, d.instance.first_fire(Time.parse("2012-03-03 00:00:59 UTC").to_i, {'key' => 'hoge'})
    assert_equal true, d.instance.first_fire(Time.parse("2012-03-03 00:01:00 UTC").to_i, {'key' => 'hoge'})
  end


  def test_configure
    d = create_driver
    assert_equal 'key', d.instance.fire_key
    assert_equal 60, d.instance.fire_count

    #### set configurations
    # d = create_driver %[
    #   path test_path
    #   compress gz
    # ]
    #### check configurations
    # assert_equal 'test_path', d.instance.path
    # assert_equal :gz, d.instance.compress
  end

  def test_format
    d = create_driver

    # time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    # d.emit({"a"=>1}, time)
    # d.emit({"a"=>2}, time)

    # d.expect_format %[2011-01-02T13:14:15Z\ttest\t{"a":1}\n]
    # d.expect_format %[2011-01-02T13:14:15Z\ttest\t{"a":2}\n]

    # d.run
  end

  def test_write
    d = create_driver

    # time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    # d.emit({"a"=>1}, time)
    # d.emit({"a"=>2}, time)

    # ### FileOutput#write returns path
    # path = d.run
    # expect_path = "#{TMP_DIR}/out_file_test._0.log.gz"
    # assert_equal expect_path, path
  end

  def test_emit
    d = create_driver
    d.run do 
      d.emit({'key' => 'hoge'}, Time.parse("2012-03-03 00:00:00 UTC").to_i)
      d.emit({'key' => 'hoge'}, Time.parse("2012-03-03 00:00:00 UTC").to_i)
      d.emit({'key' => 'hoge'}, Time.parse("2012-03-03 00:00:59 UTC").to_i)
      d.emit({'key' => 'hoge'}, Time.parse("2012-03-03 00:01:00 UTC").to_i)
    end
    assert_equal 2, d.emits.size
    assert_equal ['test', Time.parse("2012-03-03 00:00:00 UTC").to_i, {'key' => 'hoge'}], d.emits[0]
    assert_equal ['test', Time.parse("2012-03-03 00:01:00 UTC").to_i, {'key' => 'hoge'}], d.emits[1]
  end
end

