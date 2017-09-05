class Part
  include Neo4j::ActiveNode
  property :number, type: String
  property :heading, type: String
  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  # neo4j releationships in neo4j.rb are specified as
  # type_of_relationship :direction, :model_associated_to, type: :neo4j_relationship_type
  # has_one :out, :title, type: :HAS_PART

  # instead of specifying type: here, which refers to the relationship originally created in title.rb, specify origin: instead so we only need to specify relationship type in one place
  has_one :out, :title, type: :HAS_TITLE
  has_many :in, :chapters, type: :HAS_PART
  # out is from this model to another model
  # in is from another model to this model

  # has_many :both queries to or from model association
  # in this case, both associations are made to go in the OUT direction
  # has_many :both, :see_also_parts, type: :OFTEN_VIEWED_WITH, model_class: :Part

end

# part = Part.create(number: "1", heading: "test part")
# title.parts << part
