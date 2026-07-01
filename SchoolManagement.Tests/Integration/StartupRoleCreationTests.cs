using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SchoolManagement.Models;
using SchoolManagement.Tests.Infrastructure;

namespace SchoolManagement.Tests.Integration
{
    [TestClass]
    public class StartupRoleCreationTests
    {
        [TestInitialize]
        public void Initialize()
        {
            LegacyTestDatabase.EnsureCreated();
        }

        [TestMethod]
        public void Startup_CreateRolesAndUsers_CreatesAdminTeacherAndSupervisorRoles_CurrentBaseline()
        {
            // Arrange
            LegacyTestDatabase.RemoveDefaultRoles();

            var startup = new SchoolManagement.Startup();

            // Act
            startup.createRolesandUsers();

            // Assert
            AssertRoleExistsExactlyOnce("Admin");
            AssertRoleExistsExactlyOnce("Teacher");
            AssertRoleExistsExactlyOnce("Supervisor");
        }

        [TestMethod]
        public void Startup_CreateRolesAndUsers_WhenCalledTwice_DoesNotCreateDuplicateRoles_CurrentBaseline()
        {
            // Arrange
            LegacyTestDatabase.RemoveDefaultRoles();

            var startup = new SchoolManagement.Startup();

            // Act
            startup.createRolesandUsers();
            startup.createRolesandUsers();

            // Assert
            AssertRoleExistsExactlyOnce("Admin");
            AssertRoleExistsExactlyOnce("Teacher");
            AssertRoleExistsExactlyOnce("Supervisor");
        }

        private static void AssertRoleExistsExactlyOnce(string roleName)
        {
            using (var context = new ApplicationDbContext())
            {
                var count = context.Roles.Count(role => role.Name == roleName);

                Assert.AreEqual(
                    1,
                    count,
                    $"Expected role '{roleName}' to exist exactly once in the isolated test database.");
            }
        }
    }
}