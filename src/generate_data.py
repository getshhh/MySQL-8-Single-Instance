
import mysql.connector
import random
import string
import sys
import time

def generate_random_string(length):
    characters = string.ascii_letters + string.digits
    return ''.join(random.choice(characters) for _ in range(length))

def create_tables_and_data(host, user, password, database, port=3306):
    print(f"Connecting to MySQL at {host}:{port}...")
    
    try:
        conn = mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            database=database,
            port=port,
            connect_timeout=10
        )
        cursor = conn.cursor()
        
        print("Connection established successfully!")
        
        start_time = time.time()
        for table_num in range(200):
            table_name = f"test_table_{table_num:03d}"
            
            columns = ["id INT AUTO_INCREMENT PRIMARY KEY"]
            
            for i in range(50):
                columns.append(f"col_{i:02d} VARCHAR(20)")
            
            create_table_sql = f"CREATE TABLE IF NOT EXISTS {table_name} ({', '.join(columns)}) ENGINE=InnoDB"
            
            try:
                cursor.execute(create_table_sql)
                
                for row_num in range(10):
                    values = []
                    for col_num in range(50):
                        length = random.randint(4, 8)
                        random_value = generate_random_string(length)
                        values.append(random_value)
                    
                    placeholders = ["%s"] * 50
                    columns_names = [f"col_{i:02d}" for i in range(50)]
                    insert_sql = f"INSERT INTO {table_name} ({', '.join(columns_names)}) VALUES ({', '.join(placeholders)})"
                    
                    cursor.execute(insert_sql, values)
                
                if (table_num + 1) % 20 == 0:
                    print(f"Created and populated {table_num + 1}/200 tables...")
                    
            except mysql.connector.Error as err:
                print(f"Error with table {table_name}: {err}")
                continue
        
        conn.commit()
        elapsed_time = time.time() - start_time
        
        print(f"\nAll tables created and populated successfully in {elapsed_time:.2f} seconds!")
        
        cursor.execute("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = %s", (database,))
        table_count = cursor.fetchone()[0]
        print(f"Total tables in database: {table_count}")
        
        cursor.execute(f"SELECT COUNT(*) FROM test_table_199")
        row_count = cursor.fetchone()[0]
        print(f"Total rows in test_table_199: {row_count}")
        
    except mysql.connector.Error as e:
        print(f"Database error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()
        print("Connection closed.")

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Generate test data for MySQL database')
    parser.add_argument('--host', default='localhost', help='MySQL host address')
    parser.add_argument('--user', default='testuser', help='MySQL username')
    parser.add_argument('--password', default='testpassword', help='MySQL password')
    parser.add_argument('--database', default='test_database', help='Database name')
    parser.add_argument('--port', type=int, default=3306, help='MySQL port')
    
    args = parser.parse_args()
    
    create_tables_and_data(
        host=args.host,
        user=args.user,
        password=args.password,
        database=args.database,
        port=args.port
    )
