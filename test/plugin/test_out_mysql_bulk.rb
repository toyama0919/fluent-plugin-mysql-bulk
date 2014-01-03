require 'helper'
require 'mysql2-cs-bind'

class MysqlBulkOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf = CONFIG, tag='test')
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::MysqlBulkOutput, tag).configure(conf)
  end

  def test_configure_error

    assert_raise(Fluent::ConfigError) {
      d = create_driver %[
        host localhost
        database test_app_development
        username root
        password hogehoge
        table users
        on_duplicate_key_update true
        on_duplicate_update_keys user_name,updated_at
        flush_interval 10s
      ]
    }

    assert_raise(Fluent::ConfigError) {
      d = create_driver %[
        host localhost
        database test_app_development
        username root
        password hogehoge
        key_names id,user_name,created_at,updated_at
        table users
        on_duplicate_key_update true
        flush_interval 10s
      ]
    }

    assert_raise(Fluent::ConfigError) {
      d = create_driver %[
        host localhost
        username root
        password hogehoge
        key_names id,user_name,created_at,updated_at
        table users
        on_duplicate_key_update true
        on_duplicate_update_keys user_name,updated_at
        flush_interval 10s
      ]
    }
  end

  def test_configure
    # not define format(default csv)
    assert_nothing_raised(Fluent::ConfigError) {
      d = create_driver %[
        host localhost
        database test_app_development
        username root
        password hogehoge
        key_names id,user_name,created_at,updated_at
        table users
        on_duplicate_key_update true
        on_duplicate_update_keys user_name,updated_at
        flush_interval 10s
      ]
    }

    assert_nothing_raised(Fluent::ConfigError) {
      d = create_driver %[
        database test_app_development
        username root
        password hogehoge
        key_names id,user_name,created_at,updated_at
        table users
      ]
    }

    assert_nothing_raised(Fluent::ConfigError) {
      d = create_driver %[
        database test_app_development
        username root
        password hogehoge
        key_names id,user_name,created_at,updated_at
        table users
        on_duplicate_key_update true
        on_duplicate_update_keys user_name,updated_at
      ]
    }
  end

end
