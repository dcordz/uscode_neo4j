# Getting Started

Make sure neo4j is installed.
```
brew install neo4j
neo4j start
```

## Setting up the project
```
git clone https://github.com/dcordz/uscode_neo4j.git
cd uscode_neo4j
bundle install
rake neo4j:install
rake neo4j:start
rake neo4j:migrate:all
```

At this point if you get a connection error navigate to `http://localhost:7474`.

The initial username and password are both `neo4j`.

Change the password to whatever you want, but make sure to update `config.neo4j.password` in `application.rb` if you change the password to something other than `rails`.

Once you've done the above:
```
rake neo4j:migrate:all
```

#### Get an XML US Code File
Now navigate to http://uscode.house.gov/download/download.shtml and download an XML section of the US Code, put it in the directory `public/uscode_sections`. You will have to *unzip* the file first

From the project root run `rake parse`.

Depending on the how large the XML file is this could take some time.

If you run into connection issues the below may be helpful:
https://github.com/neo4jrb/neo4j/issues/1470
https://github.com/neo4jrb/neo4j/issues/1382

## Neo4j visualizations
Finally, open http://localhost:7474 in your browser, provide your credentials if needed, click the Database Stack icon at the top-left corner and then under `Node Labels` click `Node`.
