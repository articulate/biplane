module Biplane
  class ChildCollection(T)
    include Enumerable(T)

    getter collection
    getter! parent

    delegate empty?, last, @collection

    def initialize(@collection : Array(T), @parent = nil)
      @collection.map! { |item| item.parent = @parent; item } unless @parent.nil?
    end

    def id_key
      T.child_key
    end

    def each
      @collection.each { |item| yield item }
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
      diff(ChildCollection.new(other))
    end

    def diff(other : ChildCollection)
      # if union of keys is empty, we have no comparable items
      all_keys = keys | other.keys
      return if all_keys.empty?

      # compare on a key-by-key basis
      diffs = all_keys.map do |k|
        this_inst = lookup(k)
        other_inst = other.lookup(k)

        result = compare(this_inst, other_inst)

        {k => result} if result && !result.empty?
      end.compact

      diffs.empty? ? nil : diffs.reduce { |memo, item| memo.merge(item) }
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
