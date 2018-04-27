# Introduction

This project was created for two reasons, first, to learn a little bit about Neo4j, a popular graph database and second, to parse the US Code into smaller chunks.

Each chunk of the US Code is separated into a "Node" and then related to any parent Nodes in the US Code. Frankly, the US Code has many pieces, paragraphs and subparagraph but these relationships are not always strict, for example paragraphs can have subclauses instead of, as you might think, only clauses having subclauses.

This presented a challenge and the easy answer was to make every piece of the code a Node with generic parent-child relationship.

# Getting Started

Make sure neo4j is installed.
```
brew install neo4j
neo4j start
```

It's also suggested that you be using a version of ruby > 2.4.2 due to this issue:
https://github.com/puma/puma/issues/1421
https://blog.phusion.nl/2017/10/13/why-ruby-app-servers-break-on-macos-high-sierra-and-what-can-be-done-about-it/

This project uses `ruby 2.5.1`

## Setting up the project
```
git clone https://github.com/dcordz/uscode_neo4j.git
cd uscode_neo4j
bundle install
rake neo4j:install
rake neo4j:start
rake neo4j:migrate:all
```

To see what other rake tasks are available run `rake -T`

## Connection Errors
At this point if you get a connection error navigate to `http://localhost:7474`.
The initial username and password are both `neo4j`.

Change the password to whatever you want, but make sure to update `config.neo4j.password` in `application.rb` if you change the password to something other than `rails`.

Once you've done the above run `rake neo4j:migrate:all`

The below may be helpful:
https://github.com/neo4jrb/neo4j/issues/1470
https://github.com/neo4jrb/neo4j/issues/1382

#### Get an XML US Code File
Now navigate to http://uscode.house.gov/download/download.shtml and download an XML section of the US Code, put it in the directory `public/uscode_sections`. You will have to *unzip* the file first

From the project root run `rake parse`.

Depending on the how large the XML file is this could take some time.

## Neo4j visualizations
Finally, open http://localhost:7474 in your browser, provide your credentials if needed, click the Database Stack icon at the top-left corner and then under `Node Labels` click `Node`.

## Queries
To play around with Neo4j and check out some queries you can use the rails console, `rails c`

This article is informative: https://neo4jrb.readthedocs.io/en/9.1.x/Querying.html

Basic queries you can run:
```
Node.first
Node.last
nodes = Node.where(num: "3")
nodes.children
nodes.children.first.parent
nodes.children.first.parent.parent # until nil
```
