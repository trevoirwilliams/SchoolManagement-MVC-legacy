using System.Linq;
using System.Web.Mvc;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SchoolManagement.Controllers;
using SchoolManagement.Tests.Infrastructure;

namespace SchoolManagement.Tests.Integration
{
    [TestClass]
    public class AccountRegistrationRoleTests
    {
        [TestInitialize]
        public void Initialize()
        {
            LegacyTestDatabase.EnsureCreated();
            LegacyTestDatabase.EnsureDefaultRoles();
        }

        [TestMethod]
        public void Account_Register_Get_ExcludesAdminFromSelectableRoles_CurrentBaseline()
        {
            // Arrange
            using (var controller = new AccountController())
            {
                // Act
                var result = controller.Register();

                // Assert
                Assert.IsInstanceOfType(result, typeof(ViewResult), "Expected Register GET to return a view.");

                var roles = controller.ViewBag.Roles as SelectList;
                Assert.IsNotNull(roles, "Expected ViewBag.Roles to be populated with a SelectList.");

                var roleNames = roles
                    .Cast<SelectListItem>()
                    .Select(item => item.Value)
                    .ToList();

                Assert.DoesNotContain(
                    "Admin",
                    roleNames, "Register GET should preserve the current baseline behavior of excluding Admin from selectable roles.");

                Assert.Contains(
                    "Teacher",
                    roleNames, "Expected Teacher to remain selectable when roles are seeded.");

                Assert.Contains(
                    "Supervisor",
                    roleNames, "Expected Supervisor to remain selectable when roles are seeded.");
            }
        }
    }
}