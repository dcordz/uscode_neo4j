class CreateSectionParagraph < Neo4j::Migrations::Base
  def up
    add_constraint :SectionParagraph, :uuid
  end

  def down
    drop_constraint :SectionParagraph, :uuid
  end
end
