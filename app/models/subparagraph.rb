class Subparagraph
  include Neo4j::ActiveNode
  property :number, type: String
  property :identifier, type: String
  property :chapeau, type: String
  property :text, type: String
  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  has_one :out, :section_paragraph, type: :HAS_SECTION_PARAGRAPH
  # OR
  has_one :out, :subsection_paragraph, type: :HAS_SUBSECTION_PARAGRAPH

  has_many :in, :clauses, type: :HAS_SUBPARAGRAPH


end
