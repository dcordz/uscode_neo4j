class Clause
  include Neo4j::ActiveNode
  property :number, type: String
  property :identifier, type: String
  property :text, type: String

  has_one :out, :subparagraph, type: :HAS_SUBPARAGRAPH


end
