using System;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

namespace SchoolManagement.Tests.Infrastructure
{
    public static class LegacyTestDatabase
    {
        public const string TestDatabaseName = "SchoolManagement_Test";
        private const string SourceDatabaseName = "SchoolManagement_DB";
        private const string LocalDbServer = @"(LocalDb)\MSSQLLocalDB";

        private static readonly object SyncRoot = new object();
        private static bool _isCreated;

        private static string MasterConnectionString =>
            $@"Data Source={LocalDbServer};Initial Catalog=master;Integrated Security=True;MultipleActiveResultSets=True";

        private static string TestConnectionString =>
            $@"Data Source={LocalDbServer};Initial Catalog={TestDatabaseName};Integrated Security=True;MultipleActiveResultSets=True";

        public static void EnsureCreated()
        {
            lock (SyncRoot)
            {
                if (_isCreated)
                {
                    return;
                }

                var scriptPath = LocateDatabaseScript();
                var script = File.ReadAllText(scriptPath)
                    .Replace(SourceDatabaseName, TestDatabaseName);

                try
                {
                    ExecuteSqlBatches(MasterConnectionString, script);
                    _isCreated = true;
                }
                catch (Exception ex) when (ex is SqlException || ex is InvalidOperationException)
                {
                    throw new InvalidOperationException(
                        "The SchoolManagement test database could not be created. " +
                        "Confirm that SQL Server LocalDB is installed and that database/create-schoolmanagement-db.sql is available.",
                        ex);
                }
            }
        }

        public static void ClearGeneratedTestData(string testPrefix)
        {
            EnsureCreated();

            if (string.IsNullOrWhiteSpace(testPrefix))
            {
                throw new ArgumentException("A test-specific prefix is required for cleanup.", nameof(testPrefix));
            }

            const string sql = @"
DELETE e
FROM [dbo].[Enrollment] e
WHERE e.[CourseID] IN (SELECT c.[CourseId] FROM [dbo].[Course] c WHERE c.[Title] LIKE @Prefix)
   OR e.[StudentID] IN (SELECT s.[StudentID] FROM [dbo].[Student] s WHERE s.[FirstName] LIKE @Prefix OR s.[LastName] LIKE @Prefix)
   OR e.[LecturerId] IN (SELECT l.[Id] FROM [dbo].[Lecturers] l WHERE l.[First Name] LIKE @Prefix OR l.[Last Name] LIKE @Prefix);

DELETE FROM [dbo].[Course]
WHERE [Title] LIKE @Prefix;

DELETE FROM [dbo].[Student]
WHERE [FirstName] LIKE @Prefix
   OR [LastName] LIKE @Prefix;

DELETE FROM [dbo].[Lecturers]
WHERE [First Name] LIKE @Prefix
   OR [Last Name] LIKE @Prefix;";

            ExecuteNonQueryOnTestDatabase(sql, command =>
            {
                command.Parameters.AddWithValue("@Prefix", testPrefix + "%");
            });
        }

        public static void EnsureDefaultRoles()
        {
            EnsureCreated();

            EnsureRole("Admin");
            EnsureRole("Teacher");
            EnsureRole("Supervisor");
        }

        public static void RemoveDefaultRoles()
        {
            EnsureCreated();

            const string sql = @"
DELETE ur
FROM [dbo].[AspNetUserRoles] ur
INNER JOIN [dbo].[AspNetRoles] r ON ur.[RoleId] = r.[Id]
WHERE r.[Name] IN (N'Admin', N'Teacher', N'Supervisor');

DELETE FROM [dbo].[AspNetRoles]
WHERE [Name] IN (N'Admin', N'Teacher', N'Supervisor');";

            ExecuteNonQueryOnTestDatabase(sql);
        }

        private static void EnsureRole(string roleName)
        {
            const string sql = @"
IF NOT EXISTS (SELECT 1 FROM [dbo].[AspNetRoles] WHERE [Name] = @Name)
BEGIN
    INSERT INTO [dbo].[AspNetRoles] ([Id], [Name])
    VALUES (@Id, @Name);
END";

            ExecuteNonQueryOnTestDatabase(sql, command =>
            {
                command.Parameters.AddWithValue("@Id", "test-role-" + roleName.ToLowerInvariant());
                command.Parameters.AddWithValue("@Name", roleName);
            });
        }

        private static string LocateDatabaseScript()
        {
            var directory = new DirectoryInfo(AppDomain.CurrentDomain.BaseDirectory);

            while (directory != null)
            {
                var candidate = Path.Combine(directory.FullName, "database", "create-schoolmanagement-db.sql");

                if (File.Exists(candidate))
                {
                    return candidate;
                }

                directory = directory.Parent;
            }

            throw new FileNotFoundException(
                "Could not locate database/create-schoolmanagement-db.sql from the test execution directory.");
        }

        private static void ExecuteSqlBatches(string connectionString, string sqlScript)
        {
            var batches = Regex.Split(
                    sqlScript,
                    @"^\s*GO\s*;?\s*$",
                    RegexOptions.Multiline | RegexOptions.IgnoreCase)
                .Where(batch => !string.IsNullOrWhiteSpace(batch));

            using (var connection = new SqlConnection(connectionString))
            {
                connection.Open();

                foreach (var batch in batches)
                {
                    using (var command = connection.CreateCommand())
                    {
                        command.CommandTimeout = 120;
                        command.CommandText = batch;
                        command.ExecuteNonQuery();
                    }
                }
            }
        }

        private static void ExecuteNonQueryOnTestDatabase(
            string sql,
            Action<SqlCommand> configureCommand = null)
        {
            using (var connection = new SqlConnection(TestConnectionString))
            {
                connection.Open();

                using (var command = connection.CreateCommand())
                {
                    command.CommandTimeout = 120;
                    command.CommandText = sql;
                    configureCommand?.Invoke(command);
                    command.ExecuteNonQuery();
                }
            }
        }
    }
}