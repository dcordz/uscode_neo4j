class SubsectionParagraph
  include Neo4j::ActiveNode
  property :number, type: String
  property :identifier, type: String
  property :text, type: String
  property :chapeau, type: String
  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  has_one :out, :subsection, type: :HAS_SUBSECTION
  has_many :in, :subparagraphs, type: :HAS_SUBSECTION_PARAGRAPH


end
