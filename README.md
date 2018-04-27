# Getting Started

Make sure neo4j is installed.
```
brew install neo4j
neo4j start
```

Setting up the project.
```
git clone https://github.com/dcordz/uscode_neo4j.git
cd uscode_neo4j
bundle install
rake neo4j:install
rake neo4j:start

###### COUNT TO 10 WHILE NEO4JRB CONNECTS ######

rake neo4j:migrate:all
```

At this point if you get a connection error navigate to `http://localhost:7474`.

The initial username and password are both `neo4j`.

Change the password to whatever you want, but make sure to update `config.neo4j.password` in `application.rb` if you change the password to something other than `rails`.

Once you've done the above:
```
rake neo4j:migrate:all
```

Now navigate to http://uscode.house.gov/download/download.shtml and download an XML section of the US Code, put it in the directory `public/uscode_sections`.

Run: `rake parse`

Depending on the how large the XML file is this could take some time.
