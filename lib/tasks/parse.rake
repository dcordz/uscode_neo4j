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
      next unless %w(title part chapter section subsection paragraph subparagraph clause subclause level).any?{ |k| k == key }

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
        mod[:number] = item_number(val)
        mod[:heading] = val['heading']
        mod.save!
        ihash(val)

      elsif key == 'part'
        # val is array of parts
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
            part.chapters << chapter
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

            section_identifier = clip_array(subsec['_identifier'].split('/')).join('/')
            section = Subsection.reflect_on_all_associations.select{ |assoc| assoc.klass == Section }.first.klass.as(:s).where('s.identifier =~ ?', section_identifier).first

            section.subsections << subsection
            # binding.pry
            ihash(subsec, 'subsection')
          end
        else
          mod = new_instance_of_key_model(key)
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          subsection = new_subsection(mod, val)
          section_identifier = clip_array(val['_identifier'].split('/')).join('/')
          section = Subsection.reflect_on_all_associations.select{ |assoc| assoc.klass == Section }.first.klass.as(:s).where('s.identifier =~ ?', section_identifier).first
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

            section_identifier = clip_array(spara['_identifier'].split('/')).join('/')
            section = SectionParagraph.reflect_on_all_associations.select{ |assoc| assoc.klass == Section }.first.klass.as(:s).where('s.identifier =~ ?', section_identifier).first

            section.section_paragraphs << section_paragraph
            # binding.pry unless spara['subparagraph'].nil?
            ihash(spara, parent)
          end
        else
          mod = new_instance_of_key_model(key)
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          section_paragraph = new_paragraph(mod, val, parent)
          section_identifier = clip_array(val['_identifier'].split('/')).join('/')
          section = SectionParagraph.reflect_on_all_associations.select{ |assoc| assoc.klass == Section }.first.klass.as(:s).where('s.identifier =~ ?', section_identifier).first
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

            section_identifier = clip_array(sspara['_identifier'].split('/')).join('/')
            subsection = SubsectionParagraph.reflect_on_all_associations.select{ |assoc| assoc.klass == Subsection }.first.klass.as(:s).where('s.identifier =~ ?', section_identifier).first

            subsection.subsection_paragraphs << subsection_paragraph
            ihash(sspara, parent)
          end
        else
          mod = SubsectionParagraph.new
          puts "mod is a new instance of #{mod} Model"#.colorize(:yellow)
          subsection_paragraph = new_paragraph(mod, val, parent)
          section_identifier = clip_array(val['_identifier'].split('/')).join('/')
          subsection = SubsectionParagraph.reflect_on_all_associations.select{ |assoc| assoc.klass == Subsection }.first.klass.as(:s).where('s.identifier =~ ?', section_identifier).first
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
            para_class = get_para_class(subpara['_identifier']) if para_class.blank?
            next if para_class.blank?

            para_identifier = clip_array(subpara['_identifier'].split('/')).join('/')
            paragraph = Subparagraph.reflect_on_all_associations.select{ |assoc| assoc.klass == para_class.constantize }.first.klass.as(:s).where('s.identifier =~ ?', para_identifier).first

            if paragraph.nil?
              # mod val parent
              if para_identifier == "/us/usc/t18/s521/a" || para_identifier == "/us/usc/t18/s1952/a" # subparagraph follows subsection
                paragraph = new_paragraph(SubsectionParagraph.new, subpara, 'subsection')
                s = Subsection.where(identifier: para_identifier).first
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
          para_identifier = clip_array(val['_identifier'].split('/')).join('/')
          paragraph = Subparagraph.reflect_on_all_associations.select{ |assoc| assoc.klass == para_class.constantize }.first.klass.as(:s).where('s.identifier =~ ?', para_identifier).first
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

            subparagraph_identifier = clip_array(claw['_identifier'].split('/')).join('/')
            subparagraph = Clause.reflect_on_all_associations.last.klass.as(:s).where('s.identifier CONTAINS ?', subparagraph_identifier).sort_by{ |s| s.created_at }.last
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
            subparagraph_identifier = clip_array(val['_identifier'].split('/')).join('/')
          rescue
            ihash(val)
            next
          end

          subparagraph = Clause.reflect_on_all_associations.last.klass.as(:s).where('s.identifier CONTAINS ?', subparagraph_identifier).sort_by{ |s| s.created_at }.last

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
      # if val.is_a?(Hash)
        # binding.pry # will it ever get here until the end?
      #   ihash(val)
      # end

      # if the value of this key-value pair is array, iterate over each object in array
      # if val.is_a?(Array)
      #   val.each{ |obj| ihash(obj) }
      # end
    end
  end

  def new_part(mod, val)
    begin
      mod[:number] = item_number(val)
      mod[:heading] = val['heading']
    rescue
      binding.pry
      mod[:number] = nil
      mod[:heading] = nil
    end
    begin
      mod.save!
    rescue
      binding.pry
    end
    mod
  end

  def new_chapter(mod, val)
    # val is a single chapter
    begin
      mod[:number] = item_number(val)
      mod[:heading] = val['heading'] || val[1]
    rescue
      binding.pry
      mod[:number] = nil
      mod[:heading] = nil
    end
    begin
      mod.save!
    rescue
      binding.pry
    end
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
        begin
          if val['content']['p'].is_a?(Array)
            mod[:text] = val['content']['p'].collect{ |p_obj| p_obj['__text'] }.join(' ')
          elsif val['content']['p']['__text'].is_a?(String)
            mod[:text] = val['content']['p']['__text']
          else
            add_text_to_mod(mod, val)
          end
        rescue
          binding.pry
        end
        mod[:text] = mod[:text].strip!
      elsif !val['chapeau'].nil? # section has chapeau, paragraphs, no subsections
        add_chapeau_to_mod(mod, val['chapeau'])
      end
    end
    unless val['continuation'].nil? # fucking continuation can be an array
      mod = add_continuation_to_mod_chapeau(mod, val['continuation'])
    end
    begin
      mod.save!
    rescue
      # binding.pry
      mod = Section.where(identifier: mod[:identifier]).first
    end
    mod
  end

  def new_subsection(mod, val)
    mod[:number] = item_number(val) # is a lower case letter
    unless val['heading'].nil?
      begin
        mod[:heading] = val['heading']['inline']['__text']
      rescue
        begin
          mod[:heading] = val['heading']
        rescue
          binding.pry
        end
      end
      mod[:heading] = mod[:heading].strip
    end
    mod[:identifier] = val['_identifier']
    unless val['chapeau'].nil?
      add_chapeau_to_mod(mod, val['chapeau'])
    end

    if !val['content'].nil? # subection has no paragraphs
      add_text_to_mod(mod, val)
      # elsif !val['paragraph'].nil?
      #   # include 'sub' as second param in ihash call
      #   val['paragraph'].each{ |para| ihash(para, 'subsection') } # paragraph is array of objects
    end
    unless val['continuation'].nil? || val['chapeau'].nil?
      mod = add_continuation_to_mod_chapeau(mod, val['continuation'])
    end
    # binding.pry
    begin
      mod.save!
    rescue
      # binding.pry
      mod = Subsection.where(identifier: mod[:identifier]).first
    end
    mod
  end



  def new_paragraph(mod, val, parent) # parent will either be section or subection
    mod[:number] = item_number(val)
    mod[:identifier] = val['_identifier']
    unless val['chapeau'].nil?
      add_chapeau_to_mod(mod, val['chapeau'])
    end
    unless val['continuation'].nil?
      mod = add_continuation_to_mod_chapeau(mod, val['continuation'])
    end

    unless val['subparagraph'].nil?
    #   if parent == 'section'
    #     val['subparagraph'].each{ |subp| ihash(subp, 'section_paragraph') }
    #   elsif parent == 'subsection'
    #     val['subparagraph'].each{ |subp| ihash(subp, 'sub_section_paragraph') }
      # end
    else
      add_text_to_mod(mod, val)
    end
    begin
      mod.save!
    rescue
      mod = SectionParagraph.where(identifier: mod[:identifier]).first || SubsectionParagraph.where(identifier: mod[:identifier]).first
    end
    mod
  end

  def new_subparagraph(mod, val)
    mod[:number] = item_number(val)
    mod[:identifier] = val['_identifier']
    unless val['chapeau'].nil?
      add_chapeau_to_mod(mod, val['chapeau'])
    end
    if val['clause'].nil?
      add_text_to_mod(mod, val)
        # val['level'][0]['content']['p'].collect{ |para| para['__text'] }.join(' ')
    # else
    # happens in ihash method
    #   val['clause'].each{ |claw| ihash(claw, 'subparagraph_clause') }
    end
    unless val['continuation'].nil?
      mod = add_continuation_to_mod_chapeau(mod, val['continuation'])
    end
    begin
      mod.save!
    rescue
      # binding.pry
      mod = Subparagraph.where(identifier: mod[:identifier]).first
    end
    mod
  end

  def new_clause(mod, val)
    mod[:number] = item_number(val)
    mod[:identifier] = val['_identifier']
    if val['subclause'].nil?
      add_text_to_mod(mod, val)
    end
    unless val['chapeau'].nil?
      add_chapeau_to_mod(mod, val['chapeau'])
    end
    begin
      mod.save!
    rescue
      c = Clause.where(identifier: mod[:identifier]).first
      mod = c unless c.nil?
    end
    mod
  end

  def new_subclause(mod, val)
    mod[:number] = item_number(val)
    mod[:identifier] = val['_identifier']
    unless val['chapeau'].nil?
      add_chapeau_to_mod(mod, val['chapeau'])
    end
    begin
      add_text_to_mod(mod, val)
    rescue
      binding.pry
    end
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
        v = val[1]['_value'].to_s
        v = nil if val[0] != 'num'
        return v
      else
        v = val['num']['_value'].to_s
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
      ""
    end
  end

  def add_chapeau_to_mod(mod, chapeau)
    if chapeau.is_a?(Array)
      mod[:chapeau] = chapeau[0]
      mod[:chapeau] = mod[:chapeau].strip
    else
      mod[:chapeau] = chapeau['__text'] || chapeau
      mod[:chapeau] = mod[:chapeau].strip
    end
    mod
  end

  def new_instance_of_key_model(key)
    puts "new_instance_of_key_model Key #{key}"
    key.titleize.constantize.new
  end

  def clip_array(array)
    array.take(array.size - 1)
  end

  def add_text_to_mod(mod, val)
    # val['level'][0]['content']['p'].collect{ |para| para['__text'] }.join(' ')
    begin
      mod[:text] = val['content']['__text'] || val['content']
      mod[:text] = mod[:text].strip
    rescue
      # binding.pry
      # SubsectionParagraph can have clauses
      # Subparagraph can have subclauses
      # if mod.class == Subparagraph && val['subclause']
      #   # think this is a one-off corner case
      #   val['subclause'].each do |claw|
      #     c = Clause.new(identifier: claw['_identifier'], number: item_number(claw))
      #     subparagraph = Subparagraph.where(identifier: val['_identifier']).first
      #     c = add_text_to_mod(c, claw)
      #     c.save!
      #     subparagraph.clauses << c
      #   end
      # end
    end
    mod
  end

  def add_continuation_to_mod_chapeau(mod, continuation)
    begin
      if continuation.is_a?(Array) && !mod[:chapeau].nil?
        continuation.each do |cont|
          begin
            mod[:chapeau] += cont['__text']
          rescue
            next
          end
        end
      elsif continuation.is_a?(String) && !mod[:chapeau].nil?
        mod[:chapeau] += continuation
      elsif !continuation['inline'].nil?
        mod[:chapeau] += continuation['inline']['__text']
      else
        mod[:chapeau] += continuation['__text']
      end
    rescue
      # binding.pry
    end
    mod
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
