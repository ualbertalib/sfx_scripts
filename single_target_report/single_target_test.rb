require "minitest/autorun"
require "./single_target_titles"

class TestSingleTargets < Minitest::Test

  def setup
    @single_target_titles = SingleTargetTitles.new("test_sfxdata.xml")
  end

  def test_object_contains_records
    refute_empty @single_target_titles.all
    assert_equal 14, @single_target_titles.all.size
  end

  def test_query_results
    query_target = "1000000000001505" #="EBSCOHOST_ACADEMIC_SEARCH_COMPLETE"
    refute_empty @single_target_titles.matches(query_target)
    assert_equal 2, @single_target_titles.matches(query_target).size
  end

  def test_number_of_targets
    assert_equal 15, @single_target_titles.number_of_targets(0)
    assert_equal 1, @single_target_titles.number_of_targets(1)
    assert_equal 2, @single_target_titles.number_of_targets(2)
  end

  def test_single_targets
    refute @single_target_titles.single?(0)
    assert @single_target_titles.single?(1)
  end

  def test_count_single_target_titles
    query_target = "1000000000001505" #="EBSCOHOST_ACADEMIC_SEARCH_COMPLETE"
    assert_equal 0, @single_target_titles.for(query_target).size
    @single_target_titles = SingleTargetTitles.new("test_sfxdata_2.xml")
    assert_equal 1, @single_target_titles.for(query_target).size
  end

  def test_array_of_single_title_records
    query_target = "1000000000001505" #="EBSCOHOST_ACADEMIC_SEARCH_COMPLETE"
    @single_target_titles = SingleTargetTitles.new("test_sfxdata_2.xml")
    assert_equal [issn: "0001-0383", sfx_object_id: "954921332002", title: "ABCA bulletin"], @single_target_titles.for(query_target)
  end

  def test_csv_output
    query_target = "1000000000001505" #="EBSCOHOST_ACADEMIC_SEARCH_COMPLETE"
    @single_target_titles = SingleTargetTitles.new("test_sfxdata_2.xml")
    assert_equal "0001-0383, 954921332002, ABCA bulletin", @single_target_titles.csv(query_target)
  end

end
