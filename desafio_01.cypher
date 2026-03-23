CREATE CONSTRAINT user_id_unique IF NOT EXISTS FOR (u:User) REQUIRE u.id IS UNIQUE;
CREATE CONSTRAINT movie_id_unique IF NOT EXISTS FOR (m:Movie) REQUIRE m.id IS UNIQUE;
CREATE CONSTRAINT series_id_unique IF NOT EXISTS FOR (s:Series) REQUIRE s.id IS UNIQUE;
CREATE CONSTRAINT genre_id_unique IF NOT EXISTS FOR (g:Genre) REQUIRE g.id IS UNIQUE;
CREATE CONSTRAINT actor_id_unique IF NOT EXISTS FOR (a:Actor) REQUIRE a.id IS UNIQUE;
CREATE CONSTRAINT director_id_unique IF NOT EXISTS FOR (d:Director) REQUIRE d.id IS UNIQUE;

UNWIND [
{id:'U1',name:'Alice'},
{id:'U2',name:'Bruno'},
{id:'U3',name:'Carla'},
{id:'U4',name:'Daniel'},
{id:'U5',name:'Elisa'},
{id:'U6',name:'Felipe'},
{id:'U7',name:'Gabriela'},
{id:'U8',name:'Henrique'},
{id:'U9',name:'Isabela'},
{id:'U10',name:'João'}
] AS row
MERGE (u:User {id:row.id})
SET u.name=row.name;

UNWIND [
{id:'G1',name:'Action'},
{id:'G2',name:'Drama'},
{id:'G3',name:'Crime'},
{id:'G4',name:'Sci-Fi'},
{id:'G5',name:'Fantasy'},
{id:'G6',name:'Mystery'}
] AS row
MERGE (g:Genre {id:row.id})
SET g.name=row.name;

UNWIND [
{id:'A1',name:'Leonardo DiCaprio'},
{id:'A2',name:'Keanu Reeves'},
{id:'A3',name:'Song Kang-ho'},
{id:'A4',name:'Al Pacino'},
{id:'A5',name:'Matthew McConaughey'},
{id:'A6',name:'Rumi Hiiragi'},
{id:'A7',name:'Bryan Cranston'},
{id:'A8',name:'Millie Bobby Brown'},
{id:'A9',name:'Emilia Clarke'},
{id:'A10',name:'David Tennant'}
] AS row
MERGE (a:Actor {id:row.id})
SET a.name=row.name;

UNWIND [
{id:'D1',name:'Christopher Nolan'},
{id:'D2',name:'Lana Wachowski'},
{id:'D3',name:'Bong Joon-ho'},
{id:'D4',name:'Francis Ford Coppola'},
{id:'D5',name:'Hayao Miyazaki'},
{id:'D6',name:'Vince Gilligan'},
{id:'D7',name:'Duffer Brothers'},
{id:'D8',name:'Steven Moffat'}
] AS row
MERGE (d:Director {id:row.id})
SET d.name=row.name;

UNWIND [
{id:'M1',title:'Inception',year:2010,duration:148},
{id:'M2',title:'The Matrix',year:1999,duration:136},
{id:'M3',title:'Parasite',year:2019,duration:132},
{id:'M4',title:'The Godfather',year:1972,duration:175},
{id:'M5',title:'Interstellar',year:2014,duration:169},
{id:'M6',title:'Spirited Away',year:2001,duration:125}
] AS row
MERGE (m:Movie {id:row.id})
SET m.title=row.title,m.year=row.year,m.duration=row.duration;

UNWIND [
{id:'S1',title:'Breaking Bad',startYear:2008,seasons:5},
{id:'S2',title:'Stranger Things',startYear:2016,seasons:4},
{id:'S3',title:'Game of Thrones',startYear:2011,seasons:8},
{id:'S4',title:'The Crown',startYear:2016,seasons:6},
{id:'S5',title:'The Mandalorian',startYear:2019,seasons:3},
{id:'S6',title:'Sherlock',startYear:2010,seasons:4}
] AS row
MERGE (s:Series {id:row.id})
SET s.title=row.title,s.startYear=row.startYear,s.seasons=row.seasons;

UNWIND [
{content:'M1',genre:'G4'},
{content:'M1',genre:'G2'},
{content:'M2',genre:'G4'},
{content:'M3',genre:'G2'},
{content:'M4',genre:'G3'},
{content:'M5',genre:'G4'},
{content:'M6',genre:'G5'},
{content:'S1',genre:'G3'},
{content:'S1',genre:'G2'},
{content:'S2',genre:'G4'},
{content:'S2',genre:'G6'},
{content:'S3',genre:'G5'},
{content:'S3',genre:'G3'},
{content:'S4',genre:'G2'},
{content:'S5',genre:'G5'},
{content:'S6',genre:'G6'}
] AS rel
WITH rel
CALL {
  WITH rel
  MATCH (m:Movie {id:rel.content}),(g:Genre {id:rel.genre})
  MERGE (m)-[:IN_GENRE]->(g)
} IN TRANSACTIONS OF 1 ROW;
WITH 1 AS dummy
UNWIND [
{content:'S1',genre:'G3'},
{content:'S1',genre:'G2'},
{content:'S2',genre:'G4'},
{content:'S2',genre:'G6'},
{content:'S3',genre:'G5'},
{content:'S3',genre:'G3'},
{content:'S4',genre:'G2'},
{content:'S5',genre:'G5'},
{content:'S6',genre:'G6'}
] AS rel2
MATCH (s:Series {id:rel2.content}),(g:Genre {id:rel2.genre})
MERGE (s)-[:IN_GENRE]->(g);

UNWIND [
{actor:'A1',content:'M1'},
{actor:'A2',content:'M2'},
{actor:'A3',content:'M3'},
{actor:'A4',content:'M4'},
{actor:'A5',content:'M5'},
{actor:'A6',content:'M6'},
{actor:'A7',content:'S1'},
{actor:'A8',content:'S2'},
{actor:'A9',content:'S3'},
{actor:'A10',content:'S6'},
{actor:'A2',content:'S2'},
{actor:'A1',content:'M5'}
] AS rel
WITH rel
CALL {
  WITH rel
  MATCH (a:Actor {id:rel.actor}),(m:Movie {id:rel.content})
  MERGE (a)-[:ACTED_IN]->(m)
} IN TRANSACTIONS OF 1 ROW;
WITH 1 AS dummy
UNWIND [
{actor:'A7',content:'S1'},
{actor:'A8',content:'S2'},
{actor:'A9',content:'S3'},
{actor:'A10',content:'S6'},
{actor:'A2',content:'S2'}
] AS rel2
MATCH (a:Actor {id:rel2.actor}),(s:Series {id:rel2.content})
MERGE (a)-[:ACTED_IN]->(s);

UNWIND [
{director:'D1',content:'M1'},
{director:'D2',content:'M2'},
{director:'D3',content:'M3'},
{director:'D4',content:'M4'},
{director:'D1',content:'M5'},
{director:'D5',content:'M6'},
{director:'D6',content:'S1'},
{director:'D7',content:'S2'},
{director:'D7',content:'S3'},
{director:'D7',content:'S4'},
{director:'D5',content:'S5'},
{director:'D8',content:'S6'}
] AS rel
WITH rel
CALL {
  WITH rel
  MATCH (d:Director {id:rel.director}),(m:Movie {id:rel.content})
  MERGE (d)-[:DIRECTED]->(m)
} IN TRANSACTIONS OF 1 ROW;
WITH 1 AS dummy
UNWIND [
{director:'D6',content:'S1'},
{director:'D7',content:'S2'},
{director:'D7',content:'S3'},
{director:'D7',content:'S4'},
{director:'D5',content:'S5'},
{director:'D8',content:'S6'}
] AS rel2
MATCH (d:Director {id:rel2.director}),(s:Series {id:rel2.content})
MERGE (d)-[:DIRECTED]->(s);

UNWIND [
{user:'U1',content:'M1',rating:4.5},
{user:'U1',content:'S1',rating:5.0},
{user:'U2',content:'M2',rating:4.8},
{user:'U2',content:'S2',rating:4.2},
{user:'U3',content:'M3',rating:4.6},
{user:'U3',content:'S3',rating:4.1},
{user:'U4',content:'M4',rating:4.9},
{user:'U4',content:'S4',rating:3.9},
{user:'U5',content:'M5',rating:4.7},
{user:'U5',content:'S5',rating:4.3},
{user:'U6',content:'M6',rating:4.4},
{user:'U6',content:'S6',rating:4.0},
{user:'U7',content:'M1',rating:4.2},
{user:'U8',content:'M2',rating:4.0},
{user:'U9',content:'S2',rating:4.6},
{user:'U10',content:'S3',rating:3.8},
{user:'U7',content:'S1',rating:4.9},
{user:'U8',content:'M5',rating:4.1},
{user:'U9',content:'M3',rating:4.7},
{user:'U10',content:'M4',rating:4.3}
] AS rel
WITH rel
CALL {
  WITH rel
  MATCH (u:User {id:rel.user}),(m:Movie {id:rel.content})
  MERGE (u)-[w:WATCHED]->(m)
  SET w.rating=rel.rating
} IN TRANSACTIONS OF 1 ROW;
WITH 1 AS dummy
UNWIND [
{user:'U1',content:'S1',rating:5.0},
{user:'U2',content:'S2',rating:4.2},
{user:'U3',content:'S3',rating:4.1},
{user:'U4',content:'S4',rating:3.9},
{user:'U5',content:'S5',rating:4.3},
{user:'U6',content:'S6',rating:4.0},
{user:'U7',content:'S1',rating:4.9},
{user:'U9',content:'S2',rating:4.6},
{user:'U10',content:'S3',rating:3.8}
] AS rel2
MATCH (u:User {id:rel2.user}),(s:Series {id:rel2.content})
MERGE (u)-[w:WATCHED]->(s)
SET w.rating=rel2.rating;

UNWIND [
{id:'G7',name:'Thriller'}
] AS row
MERGE (g:Genre {id:row.id})
SET g.name=row.name;

UNWIND [
{id:'A11',name:'Wagner Moura'},
{id:'A12',name:'Alice Braga'},
{id:'A13',name:'Lázaro Ramos'},
{id:'A14',name:'Fernanda Montenegro'},
{id:'A15',name:'Sônia Braga'},
{id:'A16',name:'Selton Mello'},
{id:'A17',name:'Rodrigo Santoro'}
] AS row
MERGE (a:Actor {id:row.id})
SET a.name=row.name;

UNWIND [
{id:'D9',name:'Fernando Meirelles'},
{id:'D10',name:'José Padilha'},
{id:'D11',name:'Walter Salles'},
{id:'D12',name:'Kleber Mendonça Filho'},
{id:'D13',name:'Anna Muylaert'},
{id:'D14',name:'Hector Babenco'},
{id:'D15',name:'Guel Arraes'}
] AS row
MERGE (d:Director {id:row.id})
SET d.name=row.name;

UNWIND [
{id:'M7',title:'City of God',year:2002,duration:130},
{id:'M8',title:'Elite Squad',year:2007,duration:115},
{id:'M9',title:'Central Station',year:1998,duration:113},
{id:'M10',title:'Bacurau',year:2019,duration:131},
{id:'M11',title:'The Second Mother',year:2015,duration:112},
{id:'M12',title:'Carandiru',year:2003,duration:145},
{id:'M13',title:'A Dog''s Will',year:2000,duration:104}
] AS row
MERGE (m:Movie {id:row.id})
SET m.title=row.title,m.year=row.year,m.duration=row.duration;

UNWIND [
{content:'M7',genre:'G3'},
{content:'M7',genre:'G2'},
{content:'M8',genre:'G1'},
{content:'M8',genre:'G3'},
{content:'M9',genre:'G2'},
{content:'M10',genre:'G6'},
{content:'M10',genre:'G2'},
{content:'M11',genre:'G2'},
{content:'M12',genre:'G3'},
{content:'M12',genre:'G2'},
{content:'M13',genre:'G5'},
{content:'M13',genre:'G2'}
] AS rel
MATCH (m:Movie {id:rel.content}),(g:Genre {id:rel.genre})
MERGE (m)-[:IN_GENRE]->(g);

UNWIND [
{actor:'A11',content:'M8'},
{actor:'A12',content:'M7'},
{actor:'A13',content:'M12'},
{actor:'A14',content:'M9'},
{actor:'A15',content:'M10'},
{actor:'A16',content:'M13'},
{actor:'A17',content:'M12'}
] AS rel
MATCH (a:Actor {id:rel.actor}),(m:Movie {id:rel.content})
MERGE (a)-[:ACTED_IN]->(m);

UNWIND [
{director:'D9',content:'M7'},
{director:'D10',content:'M8'},
{director:'D11',content:'M9'},
{director:'D12',content:'M10'},
{director:'D13',content:'M11'},
{director:'D14',content:'M12'},
{director:'D15',content:'M13'}
] AS rel
MATCH (d:Director {id:rel.director}),(m:Movie {id:rel.content})
MERGE (d)-[:DIRECTED]->(m);

UNWIND [
{user:'U1',content:'M7',rating:4.8},
{user:'U2',content:'M8',rating:4.7},
{user:'U3',content:'M9',rating:4.6},
{user:'U4',content:'M12',rating:4.2},
{user:'U5',content:'M10',rating:4.5},
{user:'U6',content:'M11',rating:4.1},
{user:'U7',content:'M13',rating:4.3},
{user:'U8',content:'M7',rating:4.0},
{user:'U9',content:'M8',rating:4.4},
{user:'U10',content:'M9',rating:4.5}
] AS rel
MATCH (u:User {id:rel.user}),(m:Movie {id:rel.content})
MERGE (u)-[w:WATCHED]->(m)
SET w.rating=rel.rating;
