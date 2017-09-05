class CreateSubsectionParagraph < Neo4j::Migrations::Base
  def up
    add_constraint :SubsectionParagraph, :uuid
  end

  def down
    drop_constraint :SubsectionParagraph, :uuid
  end
end
