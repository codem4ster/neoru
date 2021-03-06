class Neo::Database::ModelQuery < Neo::Database::Cypher
  attr_accessor :model,:labels
  def initialize
    super
    module_name, class_name = self.class.name.scan(/(.+)::Models::(.+)Query/)[0]
    @model = Kernel.const_get(module_name).const_get('Models').const_get(class_name)
    @labels = @model.new.labels
    @labels = [@labels] if @labels.kind_of?(String)
    add_match('n',@labels+ [Neo::Config[:db][:name]])
  end

  def find_one
    set_limit(1)
    found = find
    found[0] if found.length > 0
  end

  def find
    set_return('n')
    fill_model(@model)
  end

  def delete(relations=false)
    delete_string = 'n'
    delete_string += ",#{relations}" if relations
    set_delete(delete_string)
    count
  end

  def filter_by_id(id)
    self.add_where([%w(id = {id})]).add_parameters(id: id)
  end

  def count
    set_return 'COUNT(n)'
    self.get
  end

  def get_raw
    set_return 'n'
    self.get
  end
end