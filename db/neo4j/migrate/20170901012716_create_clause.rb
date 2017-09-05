class CreateClause < Neo4j::Migrations::Base
  def up
    add_constraint :Clause, :uuid
  end

  def down
    drop_constraint :Clause, :uuid
  end
end
