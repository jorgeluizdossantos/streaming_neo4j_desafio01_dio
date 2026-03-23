// 1) Top 5 títulos por gênero pela média de rating
PARAMETERS {genreName: 'Drama'}
MATCH (c)-[:IN_GENRE]->(g:Genre {name:$genreName})
OPTIONAL MATCH (u:User)-[w:WATCHED]->(c)
WITH c, avg(w.rating) AS avgRating
RETURN labels(c)[0] AS tipo, c.title AS titulo, round(avgRating,2) AS media
ORDER BY media DESC NULLS LAST, titulo ASC
LIMIT 5;

// 2) Recomendações baseadas em gêneros preferidos do usuário
// Gêneros com média >= 4 nas avaliações do usuário e títulos que o usuário ainda não viu
PARAMETERS {userId: 'U1'}
MATCH (u:User {id:$userId})-[w:WATCHED]->(c1)-[:IN_GENRE]->(g)
WITH u, g, avg(w.rating) AS avgUserRating
WHERE avgUserRating >= 4
MATCH (c2)-[:IN_GENRE]->(g)
WHERE NOT EXISTS {
  MATCH (u)-[:WATCHED]->(c2)
}
OPTIONAL MATCH (u2:User)-[w2:WATCHED]->(c2)
WITH DISTINCT c2, g, round(avg(w2.rating),2) AS ratingGlobal
RETURN g.name AS genero, labels(c2)[0] AS tipo, c2.title AS titulo, ratingGlobal
ORDER BY ratingGlobal DESC NULLS LAST, titulo ASC
LIMIT 10;

// 3) Co-atores que contracenaram com um ator
PARAMETERS {actorName: 'Wagner Moura'}
MATCH (a:Actor {name:$actorName})-[:ACTED_IN]->(c)<-[:ACTED_IN]-(co:Actor)
RETURN co.name AS coAtor, collect(DISTINCT c.title) AS titulos, size(collect(DISTINCT c)) AS qtde
ORDER BY qtde DESC, coAtor ASC;

// 4) Diretores mais assistidos por um usuário
PARAMETERS {userId: 'U1'}
MATCH (u:User {id:$userId})-[w:WATCHED]->(c)<-[:DIRECTED]-(d:Director)
RETURN d.name AS diretor, count(DISTINCT c) AS titulosAssistidos, round(avg(w.rating),2) AS mediaUsuario
ORDER BY titulosAssistidos DESC, mediaUsuario DESC, diretor ASC;

// 5) Gêneros dominantes por ator
PARAMETERS {actorName: 'Wagner Moura'}
MATCH (a:Actor {name:$actorName})-[:ACTED_IN]->(c)-[:IN_GENRE]->(g)
RETURN g.name AS genero, count(DISTINCT c) AS titulos
ORDER BY titulos DESC, genero ASC;

// 6) Filmes brasileiros com elencos e diretores
MATCH (m:Movie)-[:DIRECTED]-(d:Director)
WHERE m.id IN ['M7','M8','M9','M10','M11','M12','M13']
OPTIONAL MATCH (a:Actor)-[:ACTED_IN]->(m)
WITH m, d, collect(DISTINCT a.name) AS elenco
RETURN m.title AS filme, m.year AS ano, d.name AS diretor, elenco
ORDER BY ano ASC;

// 7) Caminho curto entre dois atores via títulos (até 4 saltos)
PARAMETERS {fromActor:'Wagner Moura', toActor:'Fernanda Montenegro'}
MATCH p = shortestPath( (a1:Actor {name:$fromActor})-[:ACTED_IN|DIRECTED*..4]-(a2:Actor {name:$toActor}) )
RETURN p;

// 8) Séries mais bem avaliadas por usuários que viram um filme específico
PARAMETERS {movieTitle:'Inception'}
MATCH (:Movie {title:$movieTitle})<-[:WATCHED]-(u)-[w:WATCHED]->(s:Series)
RETURN s.title AS serie, round(avg(w.rating),2) AS media
ORDER BY media DESC NULLS LAST, serie ASC
LIMIT 5;

// 9) Filmes do mesmo diretor e gênero assistidos por usuários semelhantes
PARAMETERS {userId:'U1'}
MATCH (u:User {id:$userId})-[:WATCHED]->(c1)-[:IN_GENRE]->(g)<-[:IN_GENRE]-(c2)
MATCH (c1)<-[:DIRECTED]-(d)-[:DIRECTED]->(c2)
WHERE c1 <> c2 AND NOT (u)-[:WATCHED]->(c2)
OPTIONAL MATCH (u2:User)-[w2:WATCHED]->(c2)
RETURN g.name AS genero, d.name AS diretor, labels(c2)[0] AS tipo, c2.title AS titulo, round(avg(w2.rating),2) AS media
ORDER BY media DESC NULLS LAST, titulo ASC
LIMIT 10;

// 10) Atores mais presentes nos títulos assistidos (popularidade entre os usuários)
MATCH (a:Actor)-[:ACTED_IN]->(c)<-[:WATCHED]-(:User)
RETURN a.name AS ator, count(DISTINCT c) AS presencas
ORDER BY presencas DESC, ator ASC
LIMIT 10;
