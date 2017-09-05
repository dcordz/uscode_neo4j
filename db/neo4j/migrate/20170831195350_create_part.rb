class CreatePart < Neo4j::Migrations::Base
  def up
    add_constraint :Part, :uuid
  end

  def down
    drop_constraint :Part, :uuid
  end
end
