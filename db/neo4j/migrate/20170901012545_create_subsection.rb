class CreateSubsection < Neo4j::Migrations::Base
  def up
    add_constraint :Subsection, :uuid
  end

  def down
    drop_constraint :Subsection, :uuid
  end
end
