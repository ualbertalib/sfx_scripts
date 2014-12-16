require "marc"

class SingleTargetTitles

  attr_reader :all, :matches

  def initialize(datafile)
    data = MARC::XMLReader.new(File.open(datafile))
    @all = data.entries
  end

  def matches(query)
    @matches ||= search(query)
  end

  def number_of_targets(index)
    @all[index].to_hash["fields"].select{|field| field.keys.first == "866" }.size
  end

  def single?(index)
    number_of_targets(index) == 1
  end

  def for(query)
    single_target_titles = []
    matches(query).each do |match|
      single_target_titles << match if single?(@all.index(match))
    end
    single_target_titles
  end

  private

  def search(query)
    matches = []
    for record in @all do
      matches << record if record['866']['t'] == query
    end
    matches
  end

end
