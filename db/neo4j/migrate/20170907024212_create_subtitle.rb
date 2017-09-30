class CreateSubtitle < Neo4j::Migrations::Base
  def up
    add_constraint :Subtitle, :uuid
  end

  def down
    drop_constraint :Subtitle, :uuid
  end
end
