class SectionParagraph
  include Neo4j::ActiveNode
  property :number, type: String
  property :identifier, type: String
  property :text, type: String
  property :chapeau, type: String
  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  has_one :out, :section, type: :HAS_SECTION
  has_many :in, :subparagraphs, type: :HAS_SECTION_PARAGRAPH


end
