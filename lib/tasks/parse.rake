desc "Parse json input uscode into levels"
task :parse => :environment do

  # html = "section from cornell law" # top level div
  # require 'nokogiri'
  # require 'httparty'
  # require 'pry'
  # require 'pp'

  $subtypes = %w(subsection section subparagraph paragraph clause subclause)

  # TOP LEVEL SECTION
  # section_number = html.css('div.num').text.scan(/\d+/).first
  # section_heading = html.css('div.heading').text.strip
  # chapeau = html.css('div.chapeau').text.strip

  # element is html element being iterated on, top level is section
  def parse_el(el, parent_numbers = [], master_els = [])

    # get element subtype from $subtypes
    el_type = el.name
    binding.pry if el_type.nil?
    return nil if el_type.nil?

    begin
      num = el.children.first.attributes['value'].text
    rescue
      binding.pry
    end
    # binding.pry if num.nil? || num == ""
    return nil if num.nil?

    # not sure if this will still have previous elements on recurse
    # so if I add a paragraph_number once, will it still be there on recurse
    # parent numbers can't do path, unless it's an array

    if !parent_numbers.find_index{ |n| n.keys.first.to_s == "#{el_type}_number" }.nil?
      # binding.pry
      i = parent_numbers.find_index{ |n| n.keys.first.to_s == "#{el_type}_number" }
      parent_numbers[i] = { "#{el_type}_number": num } unless num.nil?
      # binding.pry
    else
      # binding.pry
      parent_numbers << { "#{el_type}_number": num } unless num.nil?
      # binding.pry
    end
    binding.pry if parent_numbers.size > 10

    # identifier is path supplied by uscode
    begin
      identifier = el.attributes['identifier']
      identifier = identifier.value unless identifier.nil?
    rescue
      binding.pry
    end

    # path is hierarchy of element types built from parent_numbers
    path = build_path_from_parent_numbers(parent_numbers)

    heading = el.css('heading').first
    heading = heading.text.strip unless heading.nil?

    # chapeaus will be in span in div
    chapeau = el.css('chapeau').first if el_type != 'section'
    chapeau = chapeau.text.strip unless chapeau.nil?

    continuation = el.css('continuation').first if el_type != 'section'
    continuation = continuation.text.strip unless continuation.nil?

    # need to verify at bottom most el, and if not chapeau
    el_text = el.css('content').first
    el_text = el_text.text.strip unless el_text.nil? || el_text == ""

    # create a new node of the subtype
    # klass = el_type.titleize.constantize
    klass = Node.new({
      type: el_type,
      num: num,
      parent_numbers: parent_numbers,
      identifier: identifier,
      path: path,
      heading: heading,
      chapeau: chapeau,
      continuation: continuation,
      text: el_text
    })
    klass.save!

    master_els << {
      type: el_type,
      num: num,
      parent_numbers: parent_numbers,
      identifier: identifier,
      path: path,
      heading: heading,
      chapeau: chapeau,
      continuation: continuation,
      text: el_text
    }

    # add the subtype to a parent subtype
    # sections have no parents only children
    if el_type != 'section'
      parent = Node.find_by(path: get_base_path(parent_numbers)) # need up-one-level path
      parent.children << klass
    end

    el.children.each do |child|
      child_name = child.name
      next if child_name.nil? || child_name.blank?
      if $subtypes.any? { |t| child_name.include?(t) } # is the child a subtype?
        parse_el(child, parent_numbers.dup, master_els) # use .dup to remove a reference
      end
    end
    master_els
  end

  def get_base_path(parent_numbers)
    nums = parent_numbers[0..-2] # drop last parent_number, since that is our child el
    build_path_from_parent_numbers(nums)
  end

  def find_parent_instance_from_child_identifier(identifier)

    # subtypes.each do |t|
    #   klass = t.title.constantize
    #   instance = klass.find_by_identifier(identifier)
    #   return instance if !instance.nil?
    # end
  end

  def build_path_from_parent_numbers(parent_numbers = [])
    # collect the numbers of each type into an array
    return nil if parent_numbers.empty?
    nums = parent_numbers.collect_concat.with_index do |n, i|
      # don't wrap section number in ()
      if i.zero?
        n.values.first
      else
        "(#{n.values.first})"
      end
    end
    nums.join
  end

  $node_count = Node.count
  dir = '/Users/david/Rails-Projects/uscode/uscode_sections'
  files = Dir.open(dir)
  completed_files = %w(. .. usc01.xml usc02.xml usc03.xml usc04.xml usc05.xml usc05A.xml usc06.xml usc07.xml usc08.xml usc09.xml)
  files.each do |file|
    puts "On File #{file}".colorize(:green)
    puts "Number of Nodes == #{$node_count}".colorize(:yellow)
    next if completed_files.any?{ |f| f == file }
    path = "#{dir}/#{file}"
    # path = '/Users/david/Rails-Projects/uscode/uscode_sections/usc23.xml'
    f = File.open(path)
    xml = Nokogiri::XML(f)
    sections = xml.css('section')
    title_number = file.split('usc').last.split('.xml').first
    # title_number = file.match(/\d+/).to_s
    # section = sections[113]
    sections.each do |section|
      parse_el(section, [{ title_number: title_number }])
    end
    puts "Total Number of Nodes in Title #{title_number} == #{Node.count - $node_count}".colorize(:magenta)
    $node_count = Node.count
  end
end
