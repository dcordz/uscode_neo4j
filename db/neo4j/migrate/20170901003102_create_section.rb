class CreateSection < Neo4j::Migrations::Base
  def up
    add_constraint :Section, :uuid
  end

  def down
    drop_constraint :Section, :uuid
  end
end
