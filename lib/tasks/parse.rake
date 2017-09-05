require 'pry'
# require 'colorize'

desc "Parse json input uscode into levels"
task :parse_us_code, [:file] => [:environment] do |t, args|
  puts "args #{args}"

  # get section from key, create new model instance
  # get values from key and new fields for instance
  # first need to parse json input, remove useless fields

  def ihash(object, parent = '')
    object.each_pair do |key, val|
      ihash(val) if key == 'main'
      next if key == 'notes'
      next if key == 'num' && val.is_a?(Hash)
      next unless %w(title part chapter section subsection paragraph subparagraph clause).any?{ |k| k == key }
      # create a new instance of the model that key refers to

      # add fields to new instance of model
      if key == 'title'
        mod = new_instance_of_key_model(key)
        puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
        mod[:number] = item_number(val)
        mod[:heading] = val['heading']
        mod.save!
      elsif key == 'part'
        # val is array of parts
        val.each do |par|
          mod = new_instance_of_key_model(key)
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          part = new_part(mod, par)
          title = Part.reflect_on_all_associations.select{ |assoc| assoc.klass == Title }.first.klass.all.sort_by{ |s| s.created_at }.last
          title.parts << part
          # binding.pry
          ihash(par) # need to trend down part before moving to next part for association
        end

      elsif key == 'chapter'
        # val is array of chapters
        val.each do |chp|
          mod = new_instance_of_key_model(key)
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          chapter = new_chapter(mod, chp)
          part = Chapter.reflect_on_all_associations.select{ |assoc| assoc.klass == Part }.first.klass.all.sort_by{ |s| s.created_at }.last
          part.chapters << chapter
          # binding.pry
          ihash(chp)
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
            ihash(sec) if !sec['subsection'].nil?
            ihash(sec, 'section') if !sec['paragraph'].nil?
          end
        else
          mod = new_instance_of_key_model(key)
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          section = new_section(mod, val)
          chapter = Section.reflect_on_all_associations.select{ |assoc| assoc.klass == Chapter }.first.klass.all.sort_by{ |s| s.created_at }.last
          chapter.sections << section
          ihash(val)
        end

      elsif key == 'subsection'
        if val.is_a?(Array)
          val.each do |subsec|
            mod = new_instance_of_key_model(key)
            puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
            subsection = new_subsection(mod, subsec)

            section_identifier = clip_array(subsec['_identifier'].split('/')).join('/')
            section = Subsection.reflect_on_all_associations.select{ |assoc| assoc.klass == Section }.first.klass.as(:s).where('s.identifier =~ ?', section_identifier).first

            section.subsections << subsection
            # binding.pry
            ihash(subsec)
          end
        else
          mod = new_instance_of_key_model(key)
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          subsection = new_subsection(mod, val)
          section_identifier = clip_array(subsec['_identifier'].split('/')).join('/')
          section = Subsection.reflect_on_all_associations.select{ |assoc| assoc.klass == Section }.first.klass.as(:s).where('s.identifier =~ ?', section_identifier).first
          ihash(val)
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

            section_identifier = clip_array(spara['_identifier'].split('/')).join('/')
            section = SectionParagraph.reflect_on_all_associations.select{ |assoc| assoc.klass == Section }.first.klass.as(:s).where('s.identifier =~ ?', section_identifier).first

            section.section_paragraphs << section_paragraph
            # binding.pry unless spara['subparagraph'].nil?
            ihash(spara, 'section')
          end
        else
          mod = new_instance_of_key_model(key)
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          section_paragraph = new_paragraph(mod, val, parent)
          section_identifier = clip_array(spara['_identifier'].split('/')).join('/')
          section = SectionParagraph.reflect_on_all_associations.select{ |assoc| assoc.klass == Section }.first.klass.as(:s).where('s.identifier =~ ?', section_identifier).first
          section.section_paragraphs << section_paragraph
          ihash(val, 'section')
        end

      elsif key == 'paragraph' && parent == 'subsection'
        # get tricky here, paragraphs can be in sections or subs
        # this matters because of how associations are built
        if val.is_a?(Array)
          val.each do |sspara|
            mod = new_instance_of_key_model(key)
            puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
            subsection_paragraph = new_paragraph(mod, sspara, parent)

            section_identifier = clip_array(sspara['_identifier'].split('/')).join('/')
            subsection = SubsectionParagraph.reflect_on_all_associations.select{ |assoc| assoc.klass == Subsection }.first.klass.as(:s).where('s.identifier =~ ?', section_identifier).first

            subsection.subsection_paragraphs << subsection_paragraph
            # binding.pry
            ihash(sspara, 'subsection')
          end
        else
          mod = SubsectionParagraph.new
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          subsection_paragraph = new_paragraph(mod, val, parent)
          subsection = SubsectionParagraph.reflect_on_all_associations.select{ |assoc| assoc.klass == Subsection }.first.klass.all.sort_by{ |s| s.created_at }.last
          subsection.subsection_paragraphs << subsection_paragraph
          ihash(val, 'subsection')
        end

      elsif key == 'subparagraph'
        # parent == section_paragraph or sub_section_paragraph
        para_class = ""
        if parent == 'section'
          para_class = 'SectionParagraph'
        else
          para_class = 'SubsectionParagraph'
        end
        if val.is_a?(Array)
          val.each do |subpara|
            mod = new_instance_of_key_model(key)
            puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
            # binding.pry
            subparagraph = new_subparagraph(mod, subpara)

            para_identifier = clip_array(subpara['_identifier'].split('/')).join('/')
            paragraph = Subparagraph.reflect_on_all_associations.select{ |assoc| assoc.klass == para_class.constantize }.first.klass.as(:s).where('s.identifier =~ ?', para_identifier).first

            # paragraph = Subparagraph.reflect_on_all_associations.keep_if{ |assoc| assoc.class_name == para_class }.first.klass.last

            paragraph.subparagraphs << subparagraph
            # binding.pry
            ihash(subpara)
          end
        else
          mod = new_instance_of_key_model(key)
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          subparagraph = new_subparagraph(mod, val)
          para_identifier = clip_array(subpara['_identifier'].split('/')).join('/')
          paragraph = Subparagraph.reflect_on_all_associations.select{ |assoc| assoc.klass == para_class.constantize }.first.klass.as(:s).where('s.identifier =~ ?', para_identifier).first
          paragraph.subparagraphs << subparagraph
          ihash(val)
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
        binding.pry
        if val.is_a?(Array)
          val.each do |claw|
            mod = new_instance_of_key_model(key)
            binding.pry
            puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
            clause = new_clause(mod, claw)
            subparagraph = Clause.reflect_on_all_associations.select{ |assoc| assoc.klass == Subparagraph }.first.klass.all.sort_by{ |s| s.created_at }.last
            binding.pry
            subparagraph.clauses << clause
          end
        else
          mod = new_instance_of_key_model(key)
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          clause = new_clause(mod, val)
          subparagraph = Clause.reflect_on_all_associations.select{ |assoc| assoc.klass == Subparagraph }.first.klass.all.sort_by{ |s| s.created_at }.last
          subparagraph.clauses << clause
        end


        # clause = new_clause(mod, val)
        # subp = Clause.reflect_on_all_associations.last.klass.last
        # subp.clauses << clause
      end

      # all models except title will need to refer to the previous parent instance
      # need the id from the previously created parent model
      # maybe can use .last on model associations?
      # Model.reflect_on_all_associations(:belongs_to).last.klass.last

      # save model
      # mod.save!
      # p "#{mod.class} created! #{mod}"

      # if the value of this key-value pair is a hash, iterate over that hash
      if val.is_a?(Hash)
        # binding.pry # will it ever get here until the end?
        ihash(val)
      end

      # if the value of this key-value pair is array, iterate over each object in array
      # if val.is_a?(Array)
      #   val.each{ |obj| ihash(obj) }
      # end
    end
  end

  def new_part(mod, val)
    mod[:number] = item_number(val)
    mod[:heading] = val['heading']
    mod.save!
    mod
  end

  def new_chapter(mod, val)
    # val is a single chapter
    mod[:number] = item_number(val)
    mod[:heading] = val['heading']
    mod.save!
    mod
  end

  def new_section(mod, val)
    mod[:number] = item_number(val)
    if val['heading'].is_a?(Hash) # section that has been repealed, or 1st section of chp
      mod[:heading] = val['_status'] unless val['_status'].nil?
      mod[:identifier] = val['_identifier']
      begin
        mod[:text] = val['heading']['date']['_date'] # date status changed for this section
      rescue
        mod[:text] = nil
      end
    elsif val['heading'].is_a?(String) # most sections have heading as a string
      mod[:heading] = val['heading'].strip
      mod[:identifier] = val['_identifier']
      # binding.pry
      if !val['content'].nil? # section that does not have subsections
        # p is an array of _text: string objects
        if val['content']['p'].is_a?(Array)
          mod[:text] = val['content']['p'].collect{ |p_obj| p_obj['__text'] }.join(' ')
        else
          mod[:text] = val['content']['p']['__text']
        end
        mod[:text] = mod[:text].strip!
      elsif !val['chapeau'].nil? # section has chapeau, paragraphs, no subsections
        # binding.pry
        mod[:chapeau] = val['chapeau']['__text'] || val['chapeau']
        mod[:chapeau] = mod[:chapeau].strip
        # include parent as second param in ihash call
        # val['paragraph'].each{ |para| ihash(para, 'section') } # paragraph is array
      # else # section with subsections
        # subsection is array of subsections
        # for some reason, doing val['subsection'].each returns a nil error
        # need to set val['subsection'] to a variable then iterate
        # subsections = val['subsection']
        # binding.pry
        # subsections.each{ |subsec| ihash(subsec) }
      end
    end
    unless val['continuation'].nil?
      begin
        mod[:chapeau] += val['continuation']['__text'] || val['continuation'] unless val['chapeau'].nil?
      rescue
        binding.pry
      end
    end
    mod.save!
    mod
  end

  def new_subsection(mod, val)
    mod[:number] = item_number(val) # is a lower case letter
    unless val['heading'].nil?
      begin
        mod[:heading] = val['heading']['inline']['__text']
      rescue
        mod[:heading] = val['heading']
      end
      mod[:heading] = mod[:heading].strip
    end
    mod[:identifier] = val['_identifier']
    mod[:chapeau] = val['chapeau']['__text'] || val['chapeau'] unless val['chapeau'].nil?
    mod[:chapeau] = mod[:chapeau].strip unless val['chapeau'].nil?
    if !val['content'].nil? # subection has no paragraphs
      mod[:text] = val['content']['__text'] || val['content']
      mod[:text] = mod[:text].strip
    # elsif !val['paragraph'].nil?
    #   # include 'sub' as second param in ihash call
    #   val['paragraph'].each{ |para| ihash(para, 'subsection') } # paragraph is array of objects
    end
    if !val['continuation'].nil?
      mod[:chapeau] += val['continuation']['__text'] || val['continuation'] unless val['chapeau'].nil?
    end
    # binding.pry
    mod.save!
    mod
  end

  def new_paragraph(mod, val, parent) # parent will either be section or subection
    mod[:number] = item_number(val)
    mod[:identifier] = val['_identifier']
    mod[:chapeau] = val['chapeau']['__text'] || val['chapeau'] unless val['chapeau'].nil?
    mod[:chapeau] = mod[:chapeau].strip unless val['chapeau'].nil?
    unless val['continuation'].nil?
      mod[:chapeau] += val['continuation']['__text'] || val['continuation'] unless val['chapeau'].nil?
    end

    unless val['subparagraph'].nil?
    #   if parent == 'section'
    #     val['subparagraph'].each{ |subp| ihash(subp, 'section_paragraph') }
    #   elsif parent == 'subsection'
    #     val['subparagraph'].each{ |subp| ihash(subp, 'sub_section_paragraph') }
      # end
    else
      mod[:text] = val['content']['__text'] || val['content']
      mod[:text] = mod[:text].strip
    end
    mod.save!
    mod
  end

  def new_subparagraph(mod, val)
    mod[:number] = item_number(val)
    mod[:identifier] = val['_identifier']
    mod[:chapeau] = val['chapeau']['__text'] || val['chapeau'] unless val['chapeau'].nil?
    mod[:chapeau] = mod[:chapeau].strip unless val['chapeau'].nil?
    unless val['clause'].nil?
      val['clause'].each{ |claw| ihash(claw, 'subparagraph_clause') }
    else
      mod[:text] = val['content']['__text'] || val['content']
      mod[:text] = mod[:text].strip
    end
    mod.save!
    mod
  end

  def new_clause(mod, val)
    mod[:number] = item_number(val)
    mod[:identifier] = val['_identifier']
    mod[:text] = val['content']['__text'] || val['content']
    mod[:text].strip
    mod.save!
    mod
  end

  def item_number(val)
    begin
      return val['num']['_value'].to_s
    rescue
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

  # get section from key, create new model instance
  # get values from key and new fields for instance
  # first need to parse json input, remove useless fields

  # dir_uscode_json_files.each do |file|
  # f is the large json object, made into a hash
  # file comes from args
  # binding.pry
  file = File.read('18.json')
  f = JSON.parse(file)
  # binding.pry
  ihash(f)
  # end

end
