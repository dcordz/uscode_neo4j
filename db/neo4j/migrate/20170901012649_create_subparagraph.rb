class CreateSubparagraph < Neo4j::Migrations::Base
  def up
    add_constraint :Subparagraph, :uuid
  end

  def down
    drop_constraint :Subparagraph, :uuid
  end
end
