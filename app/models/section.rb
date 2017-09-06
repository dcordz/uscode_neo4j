class Section
  include Neo4j::ActiveNode
  property :number, type: String
  property :heading, type: String
  property :identifier, type: String
  property :text, type: String
  property :chapeau, type: String
  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  validates :identifier, presence: true
  validates_uniqueness_of :identifier

  has_one :out, :chapter, type: :HAS_CHAPTER

  has_many :in, :section_paragraphs, type: :HAS_SECTION
  # OR
  has_many :in, :subsections, type: :HAS_SECTION


end
