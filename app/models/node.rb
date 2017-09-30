class Node
  include Neo4j::ActiveNode
  property :title_number, type: String
  property :type, type: String
  property :num, type: String
  property :parent_numbers # {type: number} of nodes of above child node
  property :identifier, type: String
  property :path, type: String
  property :heading, type: String
  property :chapeau, type: String
  property :continuation, type: String
  property :text, type: String

  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  serialize :parent_numbers

  # scope :find_by_identifier, -> (identifier) { find_by}

  # neo4j releationships in neo4j.rb are specified as
  # type_of_relationship :direction, :model_associated_to, type: :neo4j_relationship_type
  # has_one :out, :title, type: :HAS_PART

  # instead of specifying type: here, which refers to the relationship originally created in title.rb, specify origin: instead so we only need to specify relationship type in one place
  has_one :out, :parent, type: false, model_class: [:Node]
  has_many :in, :children, type: false, model_class: [:Node]

end
