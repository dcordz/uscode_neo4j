class Subclause
  include Neo4j::ActiveNode
  property :number, type: String
  property :text, type: String
  property :identifier, type: String
  property :chapeau, type: String

  has_one :out, :clause, type: :HAS_SUBCLAUSE


end
