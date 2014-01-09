# -*- encoding : utf-8 -*-
module Fluent
  class Fluent::MysqlBulkOutput < Fluent::BufferedOutput
    Fluent::Plugin.register_output('mysql_bulk', self)

    config_param :host, :string, :default => "127.0.0.1"
    config_param :port, :integer, :default => 3306
    config_param :database, :string
    config_param :username, :string
    config_param :password, :string, :default => ''

    config_param :column_names, :string
    config_param :key_names, :string, :default => nil
    config_param :table, :string

    config_param :on_duplicate_key_update, :bool, :default => false
    config_param :on_duplicate_update_keys, :string, :default => nil

    attr_accessor :handler

    def initialize
      super
      require 'mysql2-cs-bind'
    end

    def configure(conf)
      super

      if @column_names.nil?
        raise Fluent::ConfigError, "column_names MUST be specified, but missing"
      end

      if @on_duplicate_key_update
        if @on_duplicate_update_keys.nil?
          raise Fluent::ConfigError, "on_duplicate_key_update = true , on_duplicate_update_keys nil!"
        end
        @on_duplicate_update_keys = @on_duplicate_update_keys.split(',')

        @on_duplicate_key_update_sql = " ON DUPLICATE KEY UPDATE "
        updates = []
        @on_duplicate_update_keys.each{|update_column|
          updates.push(" #{update_column} = VALUES(#{update_column})")
        }
        @on_duplicate_key_update_sql += updates.join(',')
      end

      @column_names = @column_names.split(',')
      @key_names = @key_names.nil? ? @column_names : @key_names.split(',')
      @format_proc = Proc.new{|tag, time, record| @key_names.map{|k| record[k]}}

    end

    def start
      super
    end

    def shutdown
      super
    end

    def format(tag, time, record)
      [tag, time, @format_proc.call(tag, time, record)].to_msgpack
    end

    def client
      Mysql2::Client.new({
          :host => @host,
          :port => @port,
          :username => @username,
          :password => @password,
          :database => @database,
          :flags => Mysql2::Client::MULTI_STATEMENTS
        })
    end

    def write(chunk)
      @handler = client
      values_templates = []
      values = Array.new
      chunk.msgpack_each { |tag, time, data|
        values_templates.push "(#{@column_names.map{|key| '?'}.join(',')})"
        values.concat(data)
      }
      sql = "INSERT INTO #{@table} (#{@column_names.join(',')}) VALUES #{values_templates.join(',')}"
      if @on_duplicate_key_update
        sql += @on_duplicate_key_update_sql
      end

      $log.info "bulk insert sql => [#{Mysql2::Client.pseudo_bind(sql, values)}]"
      @handler.xquery(sql, values)
    end

  end
end
