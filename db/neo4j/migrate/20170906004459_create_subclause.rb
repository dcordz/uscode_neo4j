class CreateSubclause < Neo4j::Migrations::Base
  def up
    add_constraint :Subclause, :uuid
  end

  def down
    drop_constraint :Subclause, :uuid
  end
end
