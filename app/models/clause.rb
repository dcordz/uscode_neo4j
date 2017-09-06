class Clause
  include Neo4j::ActiveNode
  property :number, type: String
  property :identifier, type: String
  property :text, type: String

  validates :identifier, presence: true
  validates_uniqueness_of :identifier

  has_one :in, :subclause, type: :HAS_SUBCLAUSE
  has_one :out, :subparagraph, type: :HAS_SUBPARAGRAPH


end
