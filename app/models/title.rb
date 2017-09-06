class Title
  include Neo4j::ActiveNode
  property :number, type: String
  property :heading, type: String
  property :identifier, type: String
  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  # creating an association
  has_many :in, :parts, type: :HAS_TITLE
  # OR
  has_many :in, :chapters, type: :CHAPTER_HAS_TITLE
  # has_many :both queries to or from model association
  # in this case, both associations are made to go in the OUT direction
  # has_many :both, :see_also_parts, type: :OFTEN_VIEWED_WITH, model_class: :Part

end

# title = Title.create(number: "1", heading: "title test")
# title = Title.first
