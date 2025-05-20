const express = require('express');
const cors = require('cors');
const neo4j = require('neo4j-driver');

const app = express();
app.use(cors());

const driver = neo4j.driver(
  'bolt://localhost:7687',
  neo4j.auth.basic('neo4j', 'Om7249@123') 
);

// Function to verify database connection
async function verifyConnection() {
  const session = driver.session();
  try {
    await session.run('RETURN 1');
    console.log('Database connected');
  } catch (error) {
    console.error('Failed to connect to the database:', error);
    process.exit(1); // Exit if DB connection fails
  } finally {
    await session.close();
  }
}

app.get('/citation-check', async (req, res) => {
  const { from, to } = req.query;
  const session = driver.session();
  console.log(`Received request with from: ${from}, to: ${to}`);

  try {
    const result = await session.run(
      `MATCH (a:Paper {paper_id: $from})-[:CITES]->(b:Paper {paper_id: $to}) 
       RETURN a.paper_id AS fromPaperId, b.paper_id AS toPaperId`,
      { from, to }
    );

    console.log('Neo4j query result:', result.records);

    if (result.records.length > 0) {
      res.json({ cites: true });
    } else {
      res.json({ cites: false });
    }
  } catch (error) {
    console.error('Error occurred while querying Neo4j:', error);
    res.status(500).json({ error: 'An error occurred while checking citation' });
  } finally {
    await session.close();
  }
});

// First verify database connection, then start server
verifyConnection().then(() => {
  app.listen(3000, () => console.log('API running on http://localhost:3000'));
});
