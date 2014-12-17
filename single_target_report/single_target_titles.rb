require "marc"

class SingleTargetTitles

  attr_reader :all, :matches

  def initialize(datafile)
    begin
      data = MARC::XMLReader.new(File.open(datafile))
    rescue => e
      puts "Unable to open file. Exiting (#{e})"
      exit
    end
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
      single_target_titles << {issn: match['022']['a'], sfx_object_id: match['090']['a'], title: match["245"]["a"]} if single?(@all.index(match))
    end
    single_target_titles
  end

  def csv(query)
    titles_array = self.for(query)
    [].tap do |csv_array|
      titles_array.each do |title|
        csv_array << "#{title[:issn]}, #{title[:sfx_object_id]}, #{title[:title]}"
      end
    end.join("\n")
  end

  private

  def search(query)
    [].tap do |matches|
      for record in @all do
        matches << record if ((record['866']['t'] == query) || (record['866']['s'] == query))
      end
    end
  end

end
