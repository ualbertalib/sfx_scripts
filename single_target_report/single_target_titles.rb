require "marc"

# Class to represent a list of JOURNALS which have TARGETS
class SingleTargetTitles

  attr_reader :all, :matches

  # Instantiate the class
  def initialize(datafile)
    begin
      data = MARC::XMLReader.new(File.open(datafile))   # Read a MARCXML data file
    rescue => e
      puts "Unable to open file. Exiting (#{e})"
      exit
    end
    @all = data.entries    # Create a list of journals from the data file
  end

  # Returns how many journals had a given target name
  def matches(query)
    @matches ||= search(query)
  end

  # Returns the number of targets for a given journal
  def number_of_targets(index)
    @all[index].to_hash["fields"].select{|field| field.keys.first == "866" }.size
  end

  # Does the journal only have one target?
  def single?(index)
    number_of_targets(index) == 1
  end

  # Return a list of single-target journals that match the given target name
  def for(query)
    single_target_titles = []
    matches(query).each do |match|
      single_target_titles << {issn: match['022']['a'], sfx_object_id: match['090']['a'], title: match["245"]["a"]} if single?(@all.index(match))
    end
    single_target_titles
  end

  # Convert the list of single-target journals to CSV
  def csv(query)
    titles_array = self.for(query)
    titles_array.each_with_object([]) do |title, csv_array|
      csv_array << "#{title[:issn]}, #{title[:sfx_object_id]}, #{title[:title]}"
    end.join("\n")
  end

  private

  # Search through each journal for a given target name
  def search(query)
    @all.each_with_object([]) do |record, matches|
      matches << record if ((record['866']['t'] == query) || (record['866']['s'] == query))
    end
  end

end
