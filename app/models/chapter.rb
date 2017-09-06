class Chapter
  include Neo4j::ActiveNode
  property :number, type: String
  property :heading, type: String
  property :identifier, type: String
  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  has_one :out, :part, type: :HAS_PART
  # OR
  has_one :out, :title, type: :CHAPTER_HAS_TITLE

  has_many :in, :sections, type: :HAS_CHAPTER


end
