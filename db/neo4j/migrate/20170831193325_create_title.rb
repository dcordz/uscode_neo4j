class CreateTitle < Neo4j::Migrations::Base
  def up
    add_constraint :Title, :uuid
  end

  def down
    drop_constraint :Title, :uuid
  end
end
