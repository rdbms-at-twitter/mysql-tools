import com.mysql.clusterj.ClusterJHelper;
import com.mysql.clusterj.SessionFactory;
import com.mysql.clusterj.Session;
import com.mysql.clusterj.Query;
import com.mysql.clusterj.query.QueryBuilder;
import com.mysql.clusterj.query.QueryDomainType;
import java.io.File;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.*;
import java.util.Properties;
import java.util.List;

public class Main {
public static void main (String[] args) 
     throws java.io.FileNotFoundException,java.io.IOException {

// Load the properties from the clusterj.properties file

File propsFile = new File("clusterj.properties");
InputStream inStream = new FileInputStream(propsFile);
Properties props = new Properties();
props.load(inStream);

//Used later to get userinput
BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

// Create a session (connection to the database)
SessionFactory factory = ClusterJHelper.getSessionFactory(props);
Session session = factory.getSession();

// Create and initialise an Employee
Employee newEmployee = session.newInstance(Employee.class);
newEmployee.setId(988);
newEmployee.setFirst("MySQLクラスター7.4");
newEmployee.setLast("ClusterJ");
newEmployee.setStarted("26 February 2015");
newEmployee.setDepartment(666);

// Write the Employee to the database
session.persist(newEmployee);


// Fetch the Employee from the database
Employee theEmployee = session.find(Employee.class, 988);

if (theEmployee == null)
 {System.out.println("employeeテーブルが見つかりませんでした。");}
else
 {
 System.out.println ("ID: " + theEmployee.getId() + "; Name: " + theEmployee.getFirst() + " " + theEmployee.getLast());
 System.out.println ("Location: " + theEmployee.getCity());
 System.out.println ("Department: " + theEmployee.getDepartment());
 System.out.println ("Started: " + theEmployee.getStarted());
 System.out.println ("Left: " + theEmployee.getEnded());
}

// Make some changes to the Employee & write back to the database
theEmployee.setDepartment(777);
theEmployee.setCity("東京");

System.out.println("Employeeテーブル変更前にデータ確認。 - 確認後にReturnキーを押して下さい。");
String ignore = br.readLine();

session.updatePersistent(theEmployee);

System.out.println("Employeesテーブルの更新したので確認して下さい。 - 確認後にReturnキーを押して下さい。100件データを追加します。");
ignore = br.readLine();

// Add 100 new Employees - all as part of a single transaction
 newEmployee.setFirst("NoSQL勉強会ユーザー");
 newEmployee.setStarted("26 June 2015");

session.currentTransaction().begin();

for (int i=700;i<800;i++) {
 newEmployee.setLast("ダミーデータ"+i);
 newEmployee.setId(i+1000);
 newEmployee.setDepartment(i);
 session.persist(newEmployee);
 }

session.currentTransaction().commit();

// Retrieve the set all of Employees in department 777
QueryBuilder builder = session.getQueryBuilder();
QueryDomainType<Employee> domain = builder.createQueryDefinition(Employee.class);
domain.where(domain.get("department").equal(domain.param("department")));
Query<Employee> query = session.createQuery(domain);
query.setParameter("department",777);

List<Employee> results = query.getResultList();
for (Employee deptEmployee: results) {
System.out.println ("ID: " + deptEmployee.getId() + "; Name: " + deptEmployee.getFirst() + " " + deptEmployee.getLast());
System.out.println ("Location: " + deptEmployee.getCity());
System.out.println ("Department: " + deptEmployee.getDepartment());
System.out.println ("Started: " + deptEmployee.getStarted());
System.out.println ("Left: " + deptEmployee.getEnded());
}

System.out.println("データ削除処理を行います。 - 確認後にReturnキーを押してデータ削除して下さい。");
ignore = br.readLine();

session.deletePersistentAll(Employee.class);
 }
}

