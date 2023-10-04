#!/bin/bash

HDP_VERSION=$(hdp-select versions)
export HADOOP_CLASSPATH=$(hadoop classpath | sed 's/\/usr\/hdp\/$(HDP_VERSION)\/tez\/[a-zA-Z0-9-]*://g')

CONNECTION_URL=$(grep -A1 'beeline.hs2.jdbc.url.container' /etc/hive/conf/beeline-site.xml | grep '<value>' | sed -e 's/.*<value>\(.*\)<\/value>.*/\1/')

cat > HiveQueryExecutor.java <<EOF
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Arrays;
import java.util.List;
import java.util.Random;

public class HiveQueryExecutor {
    private static final String CONNECTION_URL = "${CONNECTION_URL}";
    private static final String JDBC_DRIVER = "org.apache.hive.jdbc.HiveDriver";
    private static final Random random = new Random();

    public static void main(String[] args) {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        List<String> noCloseHandles = args.length > 1 ? Arrays.asList(args[1].split(",")) : Arrays.asList();

        
        org.apache.log4j.BasicConfigurator.configure();

        try {
            Class.forName(JDBC_DRIVER);
            conn = DriverManager.getConnection(CONNECTION_URL);
            stmt = conn.createStatement();

            int queryRunTimes = args.length > 0 ? Integer.parseInt(args[0]) : 1;

            for (int i = 0; i < queryRunTimes; i++) {
                int limit = 5 + random.nextInt(496);
                System.out.println("----- Starting new query execution with LIMIT: " + limit + " -----");
                String query = "SELECT country, state, COUNT(*) AS records FROM hivesampletable GROUP BY country, state ORDER BY records DESC LIMIT " + limit;
                rs = stmt.executeQuery(query);

                while (rs.next()) {
                    System.out.println(rs.getString("country") + ", " + rs.getString("state") + ", " + rs.getString("records"));
                }

                rs.close();
                Thread.sleep(2000); // Adjust sleep time as needed
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null && !noCloseHandles.contains("rs")) {
                    rs.close();
                }
                if (stmt != null && !noCloseHandles.contains("stmt")) {
                    stmt.close();
                }
                if (conn != null && !noCloseHandles.contains("conn")) {
                    conn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
EOF

cat > log4j.properties <<EOF
log4j.logger.org.apache=OFF
log4j.logger.org.springframework=OFF
EOF

JDBC_JAR_PATH="/usr/hdp/$HDP_VERSION/hive/jdbc/hive-jdbc-3.1.2.$HDP_VERSION-standalone.jar"
javac -cp $HADOOP_CLASSPATH:$JDBC_JAR_PATH HiveQueryExecutor.java

echo "Java program has been written to HiveQueryExecutor.java and compiled successfully."
echo " "

echo "Usage instructions:"
echo "1. Running the query 1 time and closing all handles (the default behavior):"
echo "   java -cp \".:\$HADOOP_CLASSPATH:$JDBC_JAR_PATH\" HiveQueryExecutor 1"
echo ""
echo "2. Running the query 3 times and closing all handles:"
echo "   java -cp \".:\$HADOOP_CLASSPATH:$JDBC_JAR_PATH\" HiveQueryExecutor 3"
echo ""
echo "3. Running the query 5 times, but not closing the ResultSet (rs) handle:"
echo "   java -cp \".:\$HADOOP_CLASSPATH:$JDBC_JAR_PATH\" HiveQueryExecutor 5 \"rs\""
echo ""
echo "4. Running the query 7 times, but not closing the Statement (stmt) handle:"
echo "   java -cp \".:\$HADOOP_CLASSPATH:$JDBC_JAR_PATH\" HiveQueryExecutor 7 \"stmt\""
echo ""
echo "5. Running the query 10 times, but not closing the Connection (conn) handle:"
echo "   java -cp \".:\$HADOOP_CLASSPATH:$JDBC_JAR_PATH\" HiveQueryExecutor 10 \"conn\""
echo ""
echo "6. Running the query 2 times, but not closing the ResultSet (rs) and Statement (stmt) handles:"
echo "   java -cp \".:\$HADOOP_CLASSPATH:$JDBC_JAR_PATH\" HiveQueryExecutor 2 \"rs,stmt\""
echo ""
echo "7. Running the query 4 times, but not closing any of the handles:"
echo "   java -cp \".:\$HADOOP_CLASSPATH:$JDBC_JAR_PATH\" HiveQueryExecutor 4 \"rs,stmt,conn\""
echo ""


