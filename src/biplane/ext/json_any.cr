struct JSON::Any
  alias BaseTypes = String | Bool | Int64 | Float64 | Nil
  alias HashType = TerminalTypes | Array(HashType) | Hash(String, HashType)

  def to_yaml(gen : YAML::Generator)
    gen << json_cast(raw)
  end

  def json_cast(value : String)
    value.to_s
  end

  def json_cast(value : Int64)
    value.to_i64
  end

  def json_cast(value : Float64)
    value.to_f64
  end

  def json_cast(value : Bool)
    value
  end

  def json_cast(value : Nil)
    nil
  end

  def json_cast(values : Array)
    values.map { |v| json_cast(v) }
  end

  def json_cast(values : Hash)
    values.reduce(Hash(String, HashType).new) do |memo, k, v|
      parsed = json_cast(v)
      memo[k.to_s] = parsed.not_nil! unless parsed.nil?
      memo
    end
  end

  def json_cast(value : JSON::Any)
    json_cast(value.raw)
  end
end
