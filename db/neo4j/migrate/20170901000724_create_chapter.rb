class CreateChapter < Neo4j::Migrations::Base
  def up
    add_constraint :Chapter, :uuid
  end

  def down
    drop_constraint :Chapter, :uuid
  end
end
