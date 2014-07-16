class Neo::Form::Submit < Neo::Form::Input
  attr_accessor :value

  def initialize(opts)
    super(opts)
  end

  def to_tag
    tag = '<input type="submit" name="'+@opts[:name]+'" id="'+@opts[:name]+'" '
    tag += 'value="'+@opts[:value]+'" ' unless @opts[:value].blank?
    tag + get_attr_string.to_s + '/>'
  end
end