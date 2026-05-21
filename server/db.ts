import { drizzle } from "drizzle-orm/node-postgres";
import pg from "pg";
import * as schema from "@shared/schema";

const { Pool } = pg;

if (!process.env.DATABASE_URL) {
  throw new Error(
    "DATABASE_URL must be set. Did you forget to provision a database?",
  );
}

// Global setting to ignore self-signed certs for node-postgres (Required for many cloud databases)
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const isLocalhost = process.env.DATABASE_URL.includes("localhost") || process.env.DATABASE_URL.includes("127.0.0.1");

export const pool = new Pool({ 
  connectionString: process.env.DATABASE_URL,
  ssl: isLocalhost ? false : {
    rejectUnauthorized: false
  }
});

// Test connection
pool.connect()
  .then(client => {
    console.log('Successfully connected to database');
    client.release();
  })
  .catch(err => {
    console.error('Error acquiring client', err.stack);
  });

export const db = drizzle(pool, { schema });
