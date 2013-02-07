# encoding: utf-8
require 'minitest/autorun'
require 'ostruct'
require_relative '../handler'
require_relative '../backend/redis'
require_relative '../backend/memory'

include DataRepository

describe Handler do
  before do
    @repository  = Handler.new
  end

  describe '#store' do
    it 'persists a data structure in the passed key' do
      data  = { id: 5 }
      key   = data.fetch(:id)

      @repository.keys.wont_include key.to_s
      @repository.store(key, data)
      @repository.keys.must_include key.to_s
    end

    it 'stringifies symbols in the persisted data structure' do
      data  = { id: 5 }
      key   = data.fetch(:id)

      @repository.store(key, data)
      retrieved_data = @repository.fetch(key)

      retrieved_data.keys.wont_include :id
      retrieved_data.keys.must_include 'id'
    end
  end #store

  describe '#fetch' do
    it 'retrieves a data structure from a key' do
      data  = { id: 5 }
      key   = data.fetch(:id)

      @repository.store(key, data)
      retrieved_data = @repository.fetch(key.to_s)
      retrieved_data.fetch('id').must_equal data.fetch(:id)
    end
  end #fetch

  describe '#keys' do
    it 'returns all stored keys, stringified' do
      data  = { id: 5 }
      key   = data.fetch(:id)

      @repository.store(key, data)
      @repository.keys.must_equal [key.to_s]
    end
  end #keys
end # Handler

describe Backend::Redis do
  before do
    connection = Redis.new
    connection.select 8
    connection.flushdb

    storage = Backend::Redis.new(connection)
    @repository = Handler.new(storage)
  end

  describe '#store' do
    it 'persists a data structure in the passed key' do
      data  = { id: 5 }
      key   = data.fetch(:id)

      @repository.keys.wont_include key.to_s
      @repository.store(key, data)
      @repository.keys.must_include key.to_s
    end

    it 'stringifies symbols in the persisted data structe' do
      data  = { id: 5 }
      key   = data.fetch(:id)

      @repository.store(key, data)
      retrieved_data = @repository.fetch(key)

      retrieved_data.keys.wont_include :id
      retrieved_data.keys.must_include 'id'
    end
  end #store

  describe '#fetch' do
    it 'retrieves a data structure from a key' do
      data  = { id: 5 }
      key   = data.fetch(:id)

      @repository.store(key, data)
      retrieved_data = @repository.fetch(key)
      
      retrieved_data.fetch('id').must_equal data.fetch(:id)
    end
  end #fetch

  describe '#keys' do
    it 'returns all stored keys, stringified' do
      data  = { id: 5 }
      key   = data.fetch(:id)

      @repository.store(key, data)
      @repository.keys.must_equal [key.to_s]
    end
  end #keys
end # Backend::Redis

