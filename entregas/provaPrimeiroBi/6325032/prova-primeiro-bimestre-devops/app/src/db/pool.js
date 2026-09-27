const { Pool } = require('pg');

// A pool lê as variáveis padrão do driver `pg` (PGHOST, PGPORT, PGUSER,
// PGPASSWORD, PGDATABASE) OU a DATABASE_URL, se estiver definida.
// Isso permite usar tanto o Compose local quanto o RDS na AWS sem mudar código.
const pool = new Pool(
  process.env.DATABASE_URL
    ? { connectionString: process.env.DATABASE_URL, ssl: false }
    : {
        host: process.env.PGHOST || 'db',
        port: Number(process.env.PGPORT) || 5432,
        user: process.env.PGUSER || 'postgres',
        password: process.env.PGPASSWORD || 'postgres',
        database: process.env.PGDATABASE || 'reservas',
      }
);

// Cria a tabela na subida da aplicação, se ainda não existir.
// Simples e suficiente para o escopo da prova (sem ferramenta de migração).
async function initSchema() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS reservas (
      id SERIAL PRIMARY KEY,
      cliente VARCHAR(255) NOT NULL,
      data DATE NOT NULL,
      status VARCHAR(50) NOT NULL DEFAULT 'pendente',
      criado_em TIMESTAMPTZ NOT NULL DEFAULT now()
    );
  `);
}

module.exports = { pool, initSchema };
