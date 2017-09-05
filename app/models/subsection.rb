class Subsection
  include Neo4j::ActiveNode
  property :heading, type: String
  property :identifier, type: String
  property :chapeau, type: String
  property :text, type: String
  property :number, type: String
  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  has_one :out, :section, type: :HAS_SECTION
  has_many :in, :subsection_paragraphs, type: :HAS_SUBSECTION

end
