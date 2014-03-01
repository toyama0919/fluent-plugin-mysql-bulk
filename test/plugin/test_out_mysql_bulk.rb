require 'helper'
require 'mysql2-cs-bind'

class MysqlBulkOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf = CONFIG, tag = 'test')
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::MysqlBulkOutput, tag).configure(conf)
  end

  def test_configure_error
    assert_raise(Fluent::ConfigError) do
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
    end

    assert_raise(Fluent::ConfigError) do
      d = create_driver %[
        host localhost
        database test_app_development
        username root
        password hogehoge
        column_names id,user_name,created_at,updated_at
        table users
        on_duplicate_key_update true
        flush_interval 10s
      ]
    end

    assert_raise(Fluent::ConfigError) do
      d = create_driver %[
        host localhost
        username root
        password hogehoge
        column_names id,user_name,created_at,updated_at
        table users
        on_duplicate_key_update true
        on_duplicate_update_keys user_name,updated_at
        flush_interval 10s
      ]
    end
  end

  def test_configure
    # not define format(default csv)
    assert_nothing_raised(Fluent::ConfigError) do
      d = create_driver %[
        host localhost
        database test_app_development
        username root
        password hogehoge
        column_names id,user_name,created_at,updated_at
        table users
        on_duplicate_key_update true
        on_duplicate_update_keys user_name,updated_at
        flush_interval 10s
      ]
    end

    assert_nothing_raised(Fluent::ConfigError) do
      d = create_driver %[
        database test_app_development
        username root
        password hogehoge
        column_names id,user_name,created_at,updated_at
        table users
      ]
    end

    assert_nothing_raised(Fluent::ConfigError) do
      d = create_driver %[
        database test_app_development
        username root
        password hogehoge
        column_names id,user_name,created_at,updated_at
        table users
        on_duplicate_key_update true
        on_duplicate_update_keys user_name,updated_at
      ]
    end

    assert_nothing_raised(Fluent::ConfigError) do
      d = create_driver %[
        database test_app_development
        username root
        password hogehoge
        column_names id,user_name,created_at,updated_at
        key_names id,user,created_date,updated_date
        table users
        on_duplicate_key_update true
        on_duplicate_update_keys user_name,updated_at
      ]
    end
  end
end
