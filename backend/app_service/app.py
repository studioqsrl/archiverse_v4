from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
import psycopg2
from psycopg2.extras import RealDictCursor
from config import Settings, get_settings

app = FastAPI(title="Archiverse App Service")

def get_db_connection(settings: Settings = Depends(get_settings)):
    try:
        return psycopg2.connect(
            host=settings.postgres_host,
            database=settings.postgres_db,
            user=settings.postgres_user,
            password=settings.postgres_password,
            cursor_factory=RealDictCursor
        )
    except psycopg2.Error as e:
        raise HTTPException(status_code=500, detail=f"Database connection error: {str(e)}")

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.get("/version")
async def version(settings: Settings = Depends(get_settings)):
    return {
        "version": "1.0.0",
        "name": "Archiverse App Service",
        "environment": settings.environment
    }

@app.get("/api/data")
async def get_data(settings: Settings = Depends(get_settings)):
    conn = get_db_connection(settings)
    try:
        with conn.cursor() as cur:
            # Sample query - modify based on your actual database schema
            cur.execute("""
                SELECT id, created_at, data 
                FROM sample_data 
                ORDER BY created_at DESC 
                LIMIT 10
            """)
            results = cur.fetchall()
            return {"data": results}
    except psycopg2.Error as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    finally:
        conn.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
