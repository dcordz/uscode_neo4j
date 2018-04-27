# require 'pry'
# require 'json'
#
# desc "Parse json input uscode into levels"
# task :parse_us_code => :environment do
#
#   # get section from key, create new model instance
#   # get values from key and new fields for instance
#   # first need to parse json input, remove useless fields
#
#   def ihash(object, parent = '')
#     object.each_pair do |key, val|
#
#       if key == 'uscDoc' && val.is_a?(Hash)
#         ihash(val)
#       end
#       ihash(val) if key == 'main'
#       next unless %w(title part chapter section subsection paragraph subparagraph clause subclause level).any?{ |k| k == key }
#
#       puts "Key is #{key}"
#
#       key = 'clause' if key == 'level'
#
#       if !val.is_a?(Array) && val['num'].nil?
#         ihash(val)
#         next
#       end
#       # create a new instance of the model that key refers to
#       # add fields to new instance of model
#       if key == 'title'
#         # TITLES CAN HAVE FUCKING SUBTITLES
#         # FUUUUUUUUCK
#         mod = new_instance_of_key_model(key)
#         puts "mod is a new instance of #{mod} Model".colorize(:yellow)
#         mod = create_a_new_thing(mod, val)
#         mod.save!
#         ihash(val)
#
#       elsif key == 'part'
#         # val is array of parts
#         if val.is_a?(Array)
#           val.each{ |par| new_part_from_val(key, par) }
#         else
#           new_part_from_val(key, val)
#         end
#
#       elsif key == 'chapter'
#         # val is array of chapters
#         if val.is_a?(Array)
#           val.each{ |chp| new_chapter_from_val(key, chp) }
#         else
#           new_chapter_from_val(key, val)
#         end
#
#       elsif key == 'section'
#         # val is array of sections
#         if val.is_a?(Array)
#           val.each{ |sec| new_section_from_val(key, sec) }
#         else
#           new_section_from_val(key, val)
#         end
#
#       elsif key == 'subsection'
#         if val.is_a?(Array)
#           val.each{ |subsec| new_subsection_from_val(key, subsec) }
#         else
#           new_subsection_from_val(key, val)
#         end
#
#       elsif key == 'paragraph' && parent == 'section'
#         # get tricky here, paragraphs can be in sections or subs
#         # this matters because of how associations are built
#         if val.is_a?(Array)
#           val.each{ |spara| new_section_paragraph(key, spara, parent) }
#         else
#           new_section_paragraph(key, val, parent)
#         end
#
#       elsif key == 'paragraph' && parent == 'subsection'
#         # get tricky here, paragraphs can be in sections or subs
#         # this matters because of how associations are built
#         if val.is_a?(Array)
#           val.each{ |sspara| new_subsection_paragraph(key, sspara, parent) }
#         else
#           new_subsection_paragraph(key, val, parent)
#         end
#
#       elsif key == 'subparagraph'
#         # parent == section_paragraph or sub_section_paragraph
#         parent_class = ""
#         if parent == 'section'
#           parent_class = 'SectionParagraph'
#         elsif parent == 'subsection'
#           parent_class = 'SubsectionParagraph'
#         else
#           binding.pry
#           parent_class = ""
#         end
#         if val.is_a?(Array)
#           val.each do |subpara|
#             next if new_subparagraph_from_val(key, subpara, parent_class).nil?
#           end
#         else
#           new_subparagraph_from_val(key, val, parent_class)
#         end
#
#       elsif key == 'clause'
#         if val.is_a?(Array)
#           val.each do |claw|
#             next if new_clause_from_val(key, claw).nil?
#           end
#         else
#           new_clause_from_val(key, val)
#         end
#
#       elsif key == 'subclause'
#         if val.is_a?(Array)
#           val.each{ |claw| new_subclause_from_val(key, claw) }
#         else
#           new_subclause_from_val(key, val)
#         end
#       end
#
#       # all models except title will need to refer to the previous parent instance
#       # need the id from the previously created parent model
#       # maybe can use .last on model associations?
#       # Model.reflect_on_all_associations(:belongs_to).last.klass.last
#     end
#   end
#
#   # mod is new instance of model, val is hash of data from uscode
#   def create_a_new_thing(mod, val)
#     binding.pry if val.is_a?(Array)
#     # binding.pry if mod.class == Title
#     if !val['status'].nil? && val['status'] != 'omitted' && val['status'] != 'repealed' && val['status'] != 'transferred'
#       binding.pry
#     end
#     if %w(omitted repealed transferred).any?{ |s| s == val['status'] }
#       return nil
#     end
#     mod[:number] = item_number(val)
#     if %w(title part chapter section).any?{ |k| k.titleize.constantize == mod.class }
#       mod[:heading] = get_heading(val)
#     end
#     mod[:identifier] = get_identifier(val)
#     if mod[:number].nil? || mod[:number].blank?
#       binding.pry
#     end
#     if %w(title part chapter section).any?{ |k| k.titleize.constantize == mod.class }
#       if mod[:heading].nil? || mod[:heading].blank?
#         binding.pry
#       end
#     end
#     unless val['content'].nil?
#       mod = add_text_to_mod(mod, val) # returns mod with mod[:text]
#       unless val['chapeau'].nil?
#         mod[:chapeau] = add_chapeau_to_mod(mod, val['chapeau']).strip # returns string
#       end
#       unless val['continuation'].nil? # fucking continuation can be an array
#         # returns mod with mod[:chapeau] added to
#         mod = add_continuation_to_mod_chapeau(mod, val['continuation'])
#       end
#     end
#     mod
#   end
#
#   def new_part_from_val(key, val)
#     mod = new_instance_of_key_model(key)
#     puts "mod is a new instance of #{mod} Model".colorize(:yellow)
#     part = new_part(mod, val)
#     return nil if part.nil?
#
#     title = Title.order(:created_at).last
#     title.parts << part
#
#     ihash(val) # need to trend down part before moving to next part for association
#   end
#
#   def new_chapter_from_val(key, val)
#     mod = new_instance_of_key_model(key)
#     puts "mod is a new instance of #{mod} Model".colorize(:yellow)
#     chapter = new_chapter(mod, val)
#     return nil if chapter.nil?
#
#     return nil if chapter[:heading].nil? || chapter[:number].nil?
#
#     id = chapter[:identifier]
#     part_identifier = clip_array(id.split('/')).join('/')
#     part = Part.where(identifier: part_identifier).first
#
#     if part.nil? # title has no parts, chapters related to title
#       title = Title.order(:created_at).last
#       title.chapters << chapter
#     else
#       part.chapters << chapter
#     end
#     binding.pry unless val['paragraph'].nil?
#     ihash(val)
#   end
#
#   def new_section_from_val(key, val)
#     mod = new_instance_of_key_model(key)
#     puts "mod is a new instance of #{mod} Model".colorize(:yellow)
#     section = new_section(mod, val) # mod is still previous node
#     return nil if section.nil?
#
#     id = section[:identifier]
#     chapter_identifier = clip_array(id.split('/')).join('/')
#     chapter = Chapter.as(:c)
#                      .where('c.identifier CONTAINS ?', chapter_identifier)
#                      .order(:created_at)
#                      .last
#
#     binding.pry if chapter.nil?
#
#     chapter.sections << section
#     ihash(val, 'section')
#   end
#
#   def new_subsection_from_val(key, val)
#     mod = new_instance_of_key_model(key)
#     puts "mod is a new instance of #{mod} Model".colorize(:yellow)
#     subsection = new_subsection(mod, val)
#     return nil if subsection.nil?
#     id = val['identifier'] || val['_identifier']
#     begin
#       section_identifier = clip_array(id.split('/')).join('/')
#     rescue
#       binding.pry
#     end
#     section = Section.where(identifier: section_identifier).first
#     binding.pry if section.nil?
#     section.subsections << subsection
#     ihash(val, 'subsection')
#   end
#
#   def new_section_paragraph(key, val, parent)
#     mod = SectionParagraph.new
#     puts "mod is a new instance of #{mod} Model".colorize(:yellow)
#     section_paragraph = new_paragraph(mod, val, parent)
#     return nil if section_paragraph.nil?
#
#     id = val['identifier'] || val['_identifier']
#     begin
#       section_identifier = clip_array(id.split('/')).join('/')
#     rescue
#       binding.pry
#     end
#     section = Section.where(identifier: section_identifier).first
#     binding.pry if section.nil?
#     section.section_paragraphs << section_paragraph
#     ihash(val, parent)
#   end
#
#   def new_subsection_paragraph(key, val, parent)
#     mod = SubsectionParagraph.new
#     puts "mod is a new instance of #{mod} Model".colorize(:yellow)
#     subsection_paragraph = new_paragraph(mod, val, parent)
#     return nil if subsection_paragraph.nil?
#
#     id = val['identifier'] || val['_identifier']
#     section_identifier = clip_array(id.split('/')).join('/')
#
#     subsection = Subsection.where(identifier: section_identifier).first
#     binding.pry if subsection.nil?
#     subsection.subsection_paragraphs << subsection_paragraph
#     ihash(val, parent)
#   end
#
#   def new_subparagraph_from_val(key, val, parent_class)
#     mod = new_instance_of_key_model(key)
#     puts "mod is a new instance of #{mod} Model".colorize(:yellow)
#     subparagraph = new_subparagraph(mod, val)
#     return nil if subparagraph.nil?
#
#     id = val['identifier'] || val['_identifier']
#     parent_class = get_parent_class(id) if parent_class.blank?
#     return nil if parent_class.blank?
#
#     para_identifier = clip_array(id.split('/')).join('/')
#
#     paragraph = Subparagraph.reflect_on_all_associations
#                             .select{ |assoc| assoc.klass == parent_class.constantize }
#                             .first
#                             .klass.as(:s)
#                             .where('s.identifier =~ ?', para_identifier)
#                             .first
#
#     if paragraph.nil?
#       # mod val parent
#       if para_identifier == "/us/usc/t18/s521/a" || para_identifier == "/us/usc/t18/s1952/a" # subparagraph follows subsection
#         paragraph = new_paragraph(SubsectionParagraph.new, val, 'subsection')
#         s = Subsection.where(identifier: para_identifier).first
#         s.subsection_paragraphs << paragraph
#         ihash(val)
#         return nil
#       else
#         subparagraph.destroy
#         ihash(val)
#         return nil
#       end
#     end
#     begin
#       paragraph.subparagraphs << subparagraph
#     rescue
#       binding.pry
#     end
#     ihash(val)
#   end
#
#   def new_clause_from_val(key, val)
#     if val['num'].nil?
#       ihash(val)
#       return nil
#     end
#     mod = new_instance_of_key_model(key)
#
#     puts "mod is a new instance of #{mod} Model".colorize(:yellow)
#     clause = new_clause(mod, val)
#     return nil if clause.nil?
#
#     id = val['identifier'] || val['_identifier']
#     subparagraph_identifier = clip_array(id.split('/')).join('/')
#     subparagraph = Subparagraph.where(identifier: subparagraph_identifier).first
#
#     begin
#       subparagraph.clauses << clause
#     rescue
#       binding.pry
#       clause.destroy
#       # SubsectionParagraph /us/usc/t7/s2015/b/1
#       # SubsectionParagraph /us/usc/t7/s6f/c/1
#       # SectionParagraph with clause /us/usc/t7/s1a/19
#       # Section with clause /us/usc/t2/s356
#       # SubsectionParagraph /us/usc/t7/s6f/c/1
#     end
#     ihash(val) unless clause['subclause'].nil?
#   end
#
#   def new_subclause_from_val(key, val)
#     mod = new_instance_of_key_model(key)
#
#     puts "mod is a new instance of #{mod} Model".colorize(:yellow)
#     subclause = new_subclause(mod, val)
#     return nil if subclause.nil?
#
#     id = val['identifier'] || val['_identifier']
#     clause_id = clip_array(id.split('/')).join('/')
#     parent_clause = Clause.where(identifier: clause_id).first
#
#     if parent_clause.nil?
#       parent_clause = Clause.order(:created_at).last
#     end
#
#     begin
#       parent_clause.subclauses << subclause
#     rescue
#       binding.pry
#       subclause.destroy
#     end
#   end
#
#   def get_model_parent_association(mod)
#     parent_class = mod.class.reflect_on_all_associations.first.klass
#     parent_class.all.order(:created_at).last
#   end
#
#   def get_identifier(val)
#     begin
#       return val['identifier'] || val['_identifier']
#     rescue
#       binding.pry
#     end
#   end
#
#   def get_heading(val)
#     if val['heading'].is_a?(String)
#       val['heading'].strip
#     elsif val['heading'].is_a?(Hash)
#       if val['_status'].nil? && val['status'].nil?
#         val['heading']['inline']['text'].strip # subsections
#       else
#         val['_status'] || val['status'].strip # parts
#       end
#     elsif val['heading'].is_a?(Array)
#       val[1].strip if val[0] == 'heading'
#     else
#       nil
#     end
#   end
#
#   def new_part(mod, val)
#     mod = create_a_new_thing(mod, val)
#     return nil if mod.nil?
#     begin
#       mod.save!
#     rescue
#       par = Part.where(identifier: mod[:identifier]).first
#       mod = par unless par.nil?
#     end
#     mod
#   end
#
#   def new_chapter(mod, val)
#     # val is a single chapter
#     mod = create_a_new_thing(mod, val)
#     return nil if mod.nil?
#     begin
#       mod.save!
#     rescue
#       c = Chapter.where(identifier: mod[:identifier]).first
#       mod = c unless c.nil?
#     end
#     mod
#   end
#
#   def new_section(mod, val)
#     mod = create_a_new_thing(mod, val)
#     return nil if mod.nil?
#     unless val['content'].nil? # section that does not have subsections
#       mod = get_section_text(mod, val) if mod[:text].nil?
#     end
#     begin
#       mod.save!
#     rescue
#       s = Section.where(identifier: mod[:identifier]).first
#       mod = s unless s.nil?
#     end
#     mod
#   end
#
#   def get_section_text(mod, val)
#     # p is an array of _text: string objects
#     begin
#       if val['content']['p'].is_a?(Array)
#         mod[:text] = val['content']['p'].collect{ |p_obj| p_obj['text'] }.join(' ')
#       elsif val['content']['p']['text'].is_a?(String)
#         mod[:text] = val['content']['p']['text']
#       else
#         mod = add_text_to_mod(mod, val)
#       end
#     rescue
#       binding.pry
#     end
#     mod[:text] = mod[:text].strip!
#     mod
#   end
#
#   def new_subsection(mod, val)
#     mod = create_a_new_thing(mod, val)
#     return nil if mod.nil?
#     begin
#       mod.save!
#     rescue
#       # binding.pry
#       ss = Subsection.where(identifier: mod[:identifier]).first
#       mod = ss unless ss.nil?
#     end
#     mod
#   end
#
#   def new_paragraph(mod, val, parent) # parent will either be section or subection
#     mod = create_a_new_thing(mod, val)
#     return nil if mod.nil?
#     begin
#       mod.save!
#     rescue
#       sp = SectionParagraph.where(identifier: mod[:identifier]).first || SubsectionParagraph.where(identifier: mod[:identifier]).first
#       mod = sp unless sp.nil?
#     end
#     mod
#   end
#
#   def new_subparagraph(mod, val)
#     mod = create_a_new_thing(mod, val)
#     return nil if mod.nil?
#     begin
#       mod.save!
#     rescue
#       sp = Subparagraph.where(identifier: mod[:identifier]).first
#       mod = sp unless sp.nil?
#     end
#     mod
#   end
#
#   def new_clause(mod, val)
#     mod = create_a_new_thing(mod, val)
#     return nil if mod.nil?
#     begin
#       mod.save!
#     rescue
#       c = Clause.where(identifier: mod[:identifier]).first
#       mod = c unless c.nil?
#     end
#     mod
#   end
#
#   def new_subclause(mod, val)
#     mod = create_a_new_thing(mod, val)
#     return nil if mod.nil?
#     begin
#       mod.save!
#     rescue
#       sc = Subclause.where(identifier: mod[:identifier]).first
#       mod = sc unless sc.nil?
#     end
#     mod
#   end
#
#   def item_number(val)
#     begin
#       if val.is_a?(Array)
#         val.each{ |v| ihash(v) }
#       elsif val['num'].is_a?(String)
#         return val['num']
#       elsif val['num'].is_a?(Hash)
#         v = val['num']['_value'].to_s
#         v = val['num']['value'].to_s if v.blank?
#         return v
#       end
#     rescue
#       binding.pry
#     end
#     nil
#   end
#
#   def get_para_class(identifier)
#     id = clip_array(identifier.split('/')).join('/')
#     if !SubsectionParagraph.where(identifier: id).first.nil?
#       'SubsectionParagraph'
#     elsif !SectionParagraph.where(identifier: id).first.nil?
#       'SectionParagraph'
#     else
#       binding.pry
#       ""
#     end
#   end
#
#   def add_chapeau_to_mod(mod, chapeau)
#     if chapeau.is_a?(Array)
#       chapeau[0]
#     elsif chapeau.is_a?(String)
#       chapeau['text'] || chapeau
#     else
#       binding.pry
#     end
#   end
#
#   def new_instance_of_key_model(key)
#     puts "new_instance_of_key_model Key #{key}"
#     key.titleize.constantize.new
#   end
#
#   def clip_array(array)
#     array.take(array.size - 1)
#   end
#
#   def add_text_to_mod(mod, val)
#     # val['level'][0]['content']['p'].collect{ |para| para['text'] }.join(' ')
#     begin
#       mod[:text] = val['content']['text'] || val['content']
#       mod[:text] = mod[:text].strip
#     rescue
#       # binding.pry
#       # SubsectionParagraph can have clauses
#       # Subparagraph can have subclauses
#       # if mod.class == Subparagraph && val['subclause']
#       # think this is a one-off corner case
#     end
#     mod
#   end
#
#   def add_continuation_to_mod_chapeau(mod, continuation)
#     begin
#       if continuation.is_a?(Array) && !mod[:chapeau].nil?
#         continuation.each do |cont|
#           begin
#             mod[:chapeau] += cont['text']
#           rescue
#             next
#           end
#         end
#       elsif continuation.is_a?(String) && !mod[:chapeau].nil?
#         mod[:chapeau] += continuation
#       elsif !continuation['inline'].nil?
#         mod[:chapeau] += continuation['inline']['text']
#       else
#         mod[:chapeau] += continuation['text']
#       end
#     rescue
#       binding.pry
#     end
#     mod
#   end
#
#   # get section from key, create new model instance
#   # get values from key and new fields for instance
#
#   # f is the large json object, made into a hash
#   # file comes from args
#   dir = Dir.open('uscode_sections')
#
#   dir.each do |file|
#     next if file == '.' || file == '..' || file == 'usc01.xml'  || file == 'usc05.xml'  || file == 'usc03.xml' || file == 'usc02.xml' || file == 'usc04.xml' || file == 'usc05A.xml' || file == 'usc06.xml'
#     #  8, 9, 11
#     # 10 has subtitles
#     # 11 has subchapters
#     # there are also subparts
#     #  || file == 'usc02.xml' || file == 'usc03.xml'
#     xml = File.read("uscode_sections/#{file}")
#     puts file.colorize(:green)
#     $f = Hash.from_xml(xml)
#     ihash($f)
#   end
# end
