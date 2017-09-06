require 'pry'
require 'json'
# require 'colorize'

desc "Parse json input uscode into levels"
task :parse_us_code => :environment do

  # get section from key, create new model instance
  # get values from key and new fields for instance
  # first need to parse json input, remove useless fields

  def ihash(object, parent = '')
    object.each_pair do |key, val|

      if key == 'uscDoc' && val.is_a?(Hash)
        ihash(val)
      end
      ihash(val) if key == 'main'
      next unless %w(title part chapter section subsection paragraph subparagraph clause subclause level).any?{ |k| k == key }

      puts "Key is #{key}"

      key = 'clause' if key == 'level'

      if !val.is_a?(Array) && val['num'].nil?
        ihash(val)
        next
      end
      # create a new instance of the model that key refers to
      # add fields to new instance of model
      if key == 'title'
        mod = new_instance_of_key_model(key)
        puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
        mod = create_a_new_thing(mod, val)
        mod.save!
        ihash(val)

      elsif key == 'part'
        # val is array of parts
        create_val_level(key, val)
        val.each do |par|
          mod = new_instance_of_key_model(key)
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          part = new_part(mod, par)
          next if part[:heading].nil? || part[:number].nil?

          title = Part.reflect_on_all_associations.select{ |assoc| assoc.klass == Title }.first.klass.all.sort_by{ |s| s.created_at }.last
          title.parts << part

          # binding.pry
          ihash(par) # need to trend down part before moving to next part for association
        end

      elsif key == 'chapter'
        # val is array of chapters
        if val.is_a?(Array)
          val.each do |chp|
            mod = new_instance_of_key_model(key)
            puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
            chapter = new_chapter(mod, chp)


            next if chapter[:heading].nil? || chapter[:number].nil?
            part = Chapter.reflect_on_all_associations.select{ |assoc| assoc.klass == Part }.first.klass.all.sort_by{ |s| s.created_at }.last

            if part.nil? # title has no parts, chapters related to title
              title = Chapter.reflect_on_all_associations.select{ |assoc| assoc.klass == Title }.first.klass.all.sort_by{ |s| s.created_at }.last
              title.chapters << chapter
            else
              part.chapters << chapter
            end
            binding.pry if !chp['paragraph'].nil?
            ihash(chp)
          end
        else
          mod = new_instance_of_key_model(key)
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          chapter = new_chapter(mod, val)
          next if chapter[:heading].nil? || chapter[:number].nil?
          part = Chapter.reflect_on_all_associations.select{ |assoc| assoc.klass == Part }.first.klass.all.sort_by{ |s| s.created_at }.last
          part.chapters << chapter
          binding.pry unless val['paragraph'].nil?
          ihash(val)
        end

      elsif key == 'section'
        # val is array of sections
        if val.is_a?(Array)
          val.each do |sec|
            mod = new_instance_of_key_model(key)
            puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
            section = new_section(mod, sec) # mod is still previous node

            chapter = Section.reflect_on_all_associations.select{ |assoc| assoc.klass == Chapter }.first.klass.all.sort_by{ |s| s.created_at }.last
            chapter.sections << section

            # binding.pry unless sec['chapeau'].nil?
            ihash(sec, 'section')
          end
        else
          mod = new_instance_of_key_model(key)
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          section = new_section(mod, val)
          chapter = Section.reflect_on_all_associations.select{ |assoc| assoc.klass == Chapter }.first.klass.all.sort_by{ |s| s.created_at }.last
          chapter.sections << section
          ihash(val, 'section')
        end

      elsif key == 'subsection'
        if val.is_a?(Array)
          val.each do |subsec|
            mod = new_instance_of_key_model(key)
            puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
            subsection = new_subsection(mod, subsec)
            id = subsec['identifier'] || subsec['identifier']
            begin
              sectionidentifier = clip_array(id.split('/')).join('/')
            rescue
              binding.pry
            end
            section = Subsection.reflect_on_all_associations.select{ |assoc| assoc.klass == Section }.first.klass.as(:s).where('s.identifier =~ ?', sectionidentifier).first
            begin
              section.subsections << subsection
            rescue
              binding.pry
            end
            # binding.pry
            ihash(subsec, 'subsection')
          end
        else
          mod = new_instance_of_key_model(key)
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          subsection = new_subsection(mod, val)
          id = val['identifier'] || val['identifier']
          sectionidentifier = clip_array(id.split('/')).join('/')
          section = Subsection.reflect_on_all_associations.select{ |assoc| assoc.klass == Section }.first.klass.as(:s).where('s.identifier =~ ?', sectionidentifier).first
          ihash(val, 'subsection')
        end

      elsif key == 'paragraph' && parent == 'section'
        # get tricky here, paragraphs can be in sections or subs
        # this matters because of how associations are built
        if val.is_a?(Array)
          val.each do |spara|
            mod = SectionParagraph.new
            puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
            # binding.pry unless spara['subparagraph'].nil?
            section_paragraph = new_paragraph(mod, spara, parent)
            id = spara['identifier'] || spara['identifier']
            begin
              sectionidentifier = clip_array(id.split('/')).join('/')
            rescue
              binding.pry
            end
            section = SectionParagraph.reflect_on_all_associations.select{ |assoc| assoc.klass == Section }.first.klass.as(:s).where('s.identifier =~ ?', sectionidentifier).first

            section.section_paragraphs << section_paragraph
            # binding.pry unless spara['subparagraph'].nil?
            ihash(spara, parent)
          end
        else
          mod = new_instance_of_key_model(key)
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          section_paragraph = new_paragraph(mod, val, parent)
          id = val['identifier'] || val['identifier']
          sectionidentifier = clip_array(id.split('/')).join('/')
          section = SectionParagraph.reflect_on_all_associations.select{ |assoc| assoc.klass == Section }.first.klass.as(:s).where('s.identifier =~ ?', sectionidentifier).first
          section.section_paragraphs << section_paragraph
          ihash(val, parent)
        end

      elsif key == 'paragraph' && parent == 'subsection'
        # get tricky here, paragraphs can be in sections or subs
        # this matters because of how associations are built
        if val.is_a?(Array)
          val.each do |sspara|
            mod = SubsectionParagraph.new
            puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
            subsection_paragraph = new_paragraph(mod, sspara, parent)

            sectionidentifier = clip_array(sspara['identifier'].split('/')).join('/')
            subsection = SubsectionParagraph.reflect_on_all_associations.select{ |assoc| assoc.klass == Subsection }.first.klass.as(:s).where('s.identifier =~ ?', sectionidentifier).first

            subsection.subsection_paragraphs << subsection_paragraph
            ihash(sspara, parent)
          end
        else
          mod = SubsectionParagraph.new
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          subsection_paragraph = new_paragraph(mod, val, parent)
          sectionidentifier = clip_array(val['identifier'].split('/')).join('/')
          subsection = SubsectionParagraph.reflect_on_all_associations.select{ |assoc| assoc.klass == Subsection }.first.klass.as(:s).where('s.identifier =~ ?', sectionidentifier).first
          subsection.subsection_paragraphs << subsection_paragraph
          ihash(val, parent)
        end

      elsif key == 'subparagraph'
        # parent == section_paragraph or sub_section_paragraph
        para_class = ""
        if parent == 'section'
          para_class = 'SectionParagraph'
        elsif parent == 'subsection'
          para_class = 'SubsectionParagraph'
        else
          binding.pry
          para_class = ""
        end
        if val.is_a?(Array)
          val.each do |subpara|
            mod = new_instance_of_key_model(key)
            puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
            # binding.pry
            subparagraph = new_subparagraph(mod, subpara)
            para_class = get_para_class(subpara['identifier']) if para_class.blank?
            next if para_class.blank?

            paraidentifier = clip_array(subpara['identifier'].split('/')).join('/')
            paragraph = Subparagraph.reflect_on_all_associations.select{ |assoc| assoc.klass == para_class.constantize }.first.klass.as(:s).where('s.identifier =~ ?', paraidentifier).first

            if paragraph.nil?
              # mod val parent
              if paraidentifier == "/us/usc/t18/s521/a" || paraidentifier == "/us/usc/t18/s1952/a" # subparagraph follows subsection
                paragraph = new_paragraph(SubsectionParagraph.new, subpara, 'subsection')
                s = Subsection.where(identifier: paraidentifier).first
                s.subsection_paragraphs << paragraph
                ihash(subpara)
              else
                subparagraph.destroy
                ihash(subpara)
              end
            end
            # paragraph = Subparagraph.reflect_on_all_associations.keep_if{ |assoc| assoc.class_name == para_class }.first.klass.last
            begin
              paragraph.subparagraphs << subparagraph
            rescue
              # binding.pry
            end
            # binding.pry
            ihash(subpara) unless subpara['subclause']
          end
        else
          mod = new_instance_of_key_model(key)
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          subparagraph = new_subparagraph(mod, val)
          paraidentifier = clip_array(val['identifier'].split('/')).join('/')
          paragraph = Subparagraph.reflect_on_all_associations.select{ |assoc| assoc.klass == para_class.constantize }.first.klass.as(:s).where('s.identifier =~ ?', paraidentifier).first
          paragraph.subparagraphs << subparagraph
          ihash(val) unless val['subclause']
        end


        # subp = new_subparagraph(mod, val)
        # # subparagraph would have two associations, can't use .last
        # if parent == 'section_paragraph'
        #   para_class == 'SectionParagraph'
        # else
        #   para_class = 'SubsectionParagraph'
        # end
        # paragraph = Subparagraph.reflect_on_all_associations.keep_if{ |assoc| assoc.class_name == para_class }.first.klass.last
        # paragraph.subparagraphs << subp

      elsif key == 'clause'
        if val.is_a?(Array)
          val.each do |claw|
            if claw['num'].nil?
              ihash(claw)
              next
            end
            mod = new_instance_of_key_model(key)

            puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
            clause = new_clause(mod, claw)

            subparagraphidentifier = clip_array(claw['identifier'].split('/')).join('/')
            subparagraph = Clause.reflect_on_all_associations.last.klass.as(:s).where('s.identifier CONTAINS ?', subparagraphidentifier).sort_by{ |s| s.created_at }.last
            begin
              subparagraph.clauses << clause
            rescue
              # binding.pry
              clause.destroy
            end
            ihash(clause) unless clause['subclause'].nil?
          end
        else
          next if val['num'].nil?

          mod = new_instance_of_key_model(key)
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          clause = new_clause(mod, val)
          begin
            subparagraphidentifier = clip_array(val['identifier'].split('/')).join('/')
          rescue
            ihash(val)
            next
          end

          subparagraph = Clause.reflect_on_all_associations.last.klass.as(:s).where('s.identifier CONTAINS ?', subparagraphidentifier).sort_by{ |s| s.created_at }.last

          if subparagraph.nil?
            subparagraph = Clause.reflect_on_all_associations.first.klass.all.sort_by{ |s| s.created_at }.last
          end

          subparagraph.clauses << clause
          ihash(val) unless val['subclause'].nil?
        end

      elsif key == 'subclause'
        if val.is_a?(Array)
          val.each do |claw|
            mod = new_instance_of_key_model(key)

            puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
            clause = new_subclause(mod, claw)

            parent_clause = Subclause.reflect_on_all_associations.first.klass.sort_by{ |s| s.created_at }.last
            begin
              parent_clause.subclauses << clause
            rescue
              binding.pry
              clause.destroy
            end
          end
        else
          mod = new_instance_of_key_model(key)
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          clause = new_subclause(mod, val)

          parent_clause = Subclause.reflect_on_all_associations.first.klass.sort_by{ |s| s.created_at }.last

          parent_clause.subclauses << clause
        end
      end

      # all models except title will need to refer to the previous parent instance
      # need the id from the previously created parent model
      # maybe can use .last on model associations?
      # Model.reflect_on_all_associations(:belongs_to).last.klass.last
    end
  end

  def create_val_level(key, val)
    if val.is_a?(Array)
      val.each do |child|
        mod = new_instance_of_key_model(key)
        puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
        level = method("new_#{child}").call(mod, child)

        # Model.reflect_on_all_associations.first is parent model
        parent_class = mod.class.reflect_on_all_associations.first.klass
        parent = parent_class.all.sort_by{ |s| s.created_at }.last

        plural = "#{level}".pluralize

        parent[plural] << level

      end
    else

    end
  end

  # mod is new instance of model, val is hash of data from uscode
  def create_a_new_thing(mod, val)
    mod[:number] = item_number(val)
    mod[:heading] = get_heading(val).strip
    mod[:identifier] = get_identifier(val)
    binding.pry if mod[:number].nil? || mod[:number].blank?
    binding.pry if mod[:heading].nil? || mod[:heading].blank?
    unless val['content'].nil?
      mod = add_text_to_mod(mod, val) # returns mod with mod[:text]
    unless val['chapeau'].nil?
      mod[:chapeau] = add_chapeau_to_mod(mod, val['chapeau']).strip # returns string
    end
    unless val['continuation'].nil? # fucking continuation can be an array
      # returns mod with mod[:chapeau] added to
      mod = add_continuation_to_mod_chapeau(mod, val['continuation'])
    end
    mod
  end

  def get_identifier(val)
    val['identifier'] || val['_identifier']
  end

  def get_heading(val)
    if val['heading'].is_a?(String)
      val['heading']
    elsif val['heading'].is_a?(Hash)
      if val['_status'].nil? && val['status'].nil?
        val['heading']['inline']['text'] # subsections
      else
        val['_status'] || val['status'] # parts
      end
    elsif val['heading'].is_a?(Array)
      val[1] if val[0] == 'heading'
    else
      nil
    end
  end

  def new_part(mod, val)
    mod = create_a_new_thing(mod, val)
    begin
      mod.save!
    rescue
      par = Part.where(identifier: mod[:identifier]).first
      mod = par unless par.nil?
    end
    mod
  end

  def new_chapter(mod, val)
    # val is a single chapter
    mod = create_a_new_thing(mod, val)
    begin
      mod.save!
    rescue
      c = Chapter.where(identifier: mod[:identifier]).first
      mod = c unless c.nil?
    end
    mod
  end

  def new_section(mod, val)
    mod = create_a_new_thing(mod, val)
    unless val['content'].nil? # section that does not have subsections
      mod = get_section_text(mod, val) if mod[:text].nil?
    end
    begin
      mod.save!
    rescue
      s = Section.where(identifier: mod[:identifier]).first
      mod = s unless s.nil?
    end
    mod
  end

  def get_section_text(mod, val)
    # p is an array of _text: string objects
    begin
      if val['content']['p'].is_a?(Array)
        mod[:text] = val['content']['p'].collect{ |p_obj| p_obj['text'] }.join(' ')
      elsif val['content']['p']['text'].is_a?(String)
        mod[:text] = val['content']['p']['text']
      else
        mod = add_text_to_mod(mod, val)
      end
    rescue
      binding.pry
    end
    mod[:text] = mod[:text].strip!
    mod
  end

  def new_subsection(mod, val)
    mod = create_a_new_thing(mod, val)
    begin
      mod.save!
    rescue
      # binding.pry
      ss = Subsection.where(identifier: mod[:identifier]).first
      mod = ss unless ss.nil?
    end
    mod
  end

  def new_paragraph(mod, val, parent) # parent will either be section or subection
    mod = create_a_new_thing(mod, val)
    begin
      mod.save!
    rescue
      sp = SectionParagraph.where(identifier: mod[:identifier]).first || SubsectionParagraph.where(identifier: mod[:identifier]).first
      mod = sp unless sp.nil?
    end
    mod
  end

  def new_subparagraph(mod, val)
    mod = create_a_new_thing(mod, val)
    begin
      mod.save!
    rescue
      sp = Subparagraph.where(identifier: mod[:identifier]).first
      mod = sp unless sp.nil?
    end
    mod
  end

  def new_clause(mod, val)
    mod = create_a_new_thing(mod, val)
    begin
      mod.save!
    rescue
      c = Clause.where(identifier: mod[:identifier]).first
      mod = c unless c.nil?
    end
    mod
  end

  def new_subclause(mod, val)
    mod = create_a_new_thing(mod, val)
    begin
      mod.save!
    rescue
      sc = Subclause.where(identifier: mod[:identifier]).first
      mod = sc unless sc.nil?
    end
    mod
  end

  def item_number(val)
    begin
      if val.is_a?(Array)
        binding.pry
        v = val[1]['_value'].to_s || val[1]['value'].to_s
        v = nil if val[0] != 'num'
        return v
      else
        v = val['num']['_value'].to_s
        v = val['num']['value'].to_s if v.blank?
        return v
      end
    rescue
      binding.pry
    end
    ""
  end

  def get_para_class(identifier)
    id = clip_array(identifier.split('/')).join('/')
    if !SubsectionParagraph.where(identifier: id).first.nil?
      'SubsectionParagraph'
    elsif !SectionParagraph.where(identifier: id).first.nil?
      'SectionParagraph'
    else
      binding.pry
      ""
    end
  end

  def add_chapeau_to_mod(mod, chapeau)
    if chapeau.is_a?(Array)
      chapeau[0]
    elsif chapeau.is_a?(String)
      chapeau['text'] || chapeau
    else
      binding.pry
    end
  end

  def new_instance_of_key_model(key)
    puts "new_instance_of_key_model Key #{key}"
    key.titleize.constantize.new
  end

  def clip_array(array)
    array.take(array.size - 1)
  end

  def add_text_to_mod(mod, val)
    # val['level'][0]['content']['p'].collect{ |para| para['text'] }.join(' ')
    begin
      mod[:text] = val['content']['text'] || val['content']
      mod[:text] = mod[:text].strip
    rescue
      # binding.pry
      # SubsectionParagraph can have clauses
      # Subparagraph can have subclauses
      # if mod.class == Subparagraph && val['subclause']
      # think this is a one-off corner case
    end
    mod
  end

  def add_continuation_to_mod_chapeau(mod, continuation)
    begin
      if continuation.is_a?(Array) && !mod[:chapeau].nil?
        continuation.each do |cont|
          begin
            mod[:chapeau] += cont['text']
          rescue
            next
          end
        end
      elsif continuation.is_a?(String) && !mod[:chapeau].nil?
        mod[:chapeau] += continuation
      elsif !continuation['inline'].nil?
        mod[:chapeau] += continuation['inline']['text']
      else
        mod[:chapeau] += continuation['text']
      end
    rescue
      binding.pry
    end
    mod
  end

  # get section from key, create new model instance
  # get values from key and new fields for instance

  # f is the large json object, made into a hash
  # file comes from args
  dir = Dir.open('uscode_sections')

  dir.each do |file|
    next if file == '.' || file == '..'
    #  || file == 'usc01.xml' || file == 'usc02.xml' || file == 'usc03.xml'
    xml = File.read("uscode_sections/#{file}")
    puts file
    f = Hash.from_xml(xml)
    puts "file hashed"
    ihash(f)
  end
end
