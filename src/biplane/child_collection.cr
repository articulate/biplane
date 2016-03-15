module Biplane
  class ChildCollection(T)
    include Enumerable(T)

    getter id_key
    getter collection

    delegate empty?, last, @collection

    macro typeless_hash(k, values)
      { "#{k}" => {{values}} }
    end

    def initialize(@id_key, @collection : Array(T))
    end

    def each
      @collection.each {|item| yield item }
    end

    def lookup(id)
      @collection.find do |item|
        item.lookup_key == id
      end
    end

    def keys : Array(String)
      @collection.map(&.lookup_key as String)
    end

    def ==(other : Array)
      @collection == other
    end

    def ==(other : ChildCollection)
      @collection == other.collection
    end

    def diff(other : Array)
      diff(ChildCollection.new(id_key, other))
    end

    def diff(other : ChildCollection)
      all_keys = keys | other.keys
      return if all_keys.empty?

      diffs = all_keys.map do |k|
        this_inst = lookup(k)
        other_inst = other.lookup(k)

        result = compare(this_inst, other_inst)
        typeless_hash(k, result) if result && !result.empty?
      end.compact

      diffs.empty? ? nil : diffs.reduce {|memo, item| memo.merge(item) }
    end

    # Removal
    private def compare(this : Model, other : Nil)
      Diff.new(nil, this)
    end

    # Add
    private def compare(this : Nil, other : Config)
      Diff.new(other, nil)
    end

    # Changed
    private def compare(this : Model, other : Config)
      this.diff(other)
    end

    private def compare(this : Nil, other : Nil)
      nil
    end

    def serialize
      @collection.map &.serialize
    end
  end
end
