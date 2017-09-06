class ForceCreateSubclauseUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Subclause, :uuid, force: true
  end

  def down
    drop_constraint :Subclause, :uuid
  end
end
