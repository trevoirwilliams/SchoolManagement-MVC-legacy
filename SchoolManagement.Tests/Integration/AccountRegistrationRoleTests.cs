using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SchoolManagement.Controllers;
using SchoolManagement.Models;
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
        public void Account_Register_Get_NoLongerExposesRoleSelection()
        {
            // Arrange
            using (var controller = new AccountController())
            {
                // Act
                var result = controller.Register();

                // Assert
                Assert.IsInstanceOfType(result, typeof(ViewResult), "Expected Register GET to return a view.");

                // Verify that ViewBag.Roles is not populated (role selection removed)
                var roles = controller.ViewBag.Roles;
                Assert.IsNull(roles, "Register GET should not populate ViewBag.Roles since user role selection is disabled.");
            }
        }

        [TestMethod]
        public async Task Account_Register_Post_AssignsDefaultTeacherRole_WhenNoUserRolePosted()
        {
            // Arrange
            var testPrefix = "RegTest_" + System.Guid.NewGuid().ToString("N").Substring(0, 8);
            var model = new RegisterViewModel
            {
                Username = testPrefix + "_user",
                Email = testPrefix + "@test.com",
                BirthDate = System.DateTime.Now.AddYears(-20),
                Password = "P@ssw0rd123!",
                ConfirmPassword = "P@ssw0rd123!",
                UserRole = null // No role posted by user
            };

            using (var context = new ApplicationDbContext())
            using (var controller = new AccountController())
            {
                // Act
                var result = await controller.Register(model) as RedirectToRouteResult;

                // Assert
                Assert.IsNotNull(result, "Expected successful registration to redirect.");
                Assert.AreEqual("Index", result.RouteValues["action"]);
                Assert.AreEqual("Home", result.RouteValues["controller"]);

                // Verify user was created and assigned Teacher role
                var userManager = new UserManager<ApplicationUser>(new UserStore<ApplicationUser>(context));
                var user = await userManager.FindByEmailAsync(model.Email);
                Assert.IsNotNull(user, "User should be created in database.");

                var roles = await userManager.GetRolesAsync(user.Id);
                Assert.AreEqual(1, roles.Count, "User should have exactly one role.");
                Assert.AreEqual("Teacher", roles.First(), "User should be assigned the default 'Teacher' role.");

                // Cleanup
                await userManager.DeleteAsync(user);
            }
        }

        [TestMethod]
        public async Task Account_Register_Post_RejectsTamperedUserRole()
        {
            // Arrange
            var testPrefix = "TamperTest_" + System.Guid.NewGuid().ToString("N").Substring(0, 8);
            var model = new RegisterViewModel
            {
                Username = testPrefix + "_user",
                Email = testPrefix + "@test.com",
                BirthDate = System.DateTime.Now.AddYears(-20),
                Password = "P@ssw0rd123!",
                ConfirmPassword = "P@ssw0rd123!",
                UserRole = "Admin" // Attempt to post a role (tampering simulation)
            };

            using (var context = new ApplicationDbContext())
            using (var controller = new AccountController())
            {
                // Act
                var result = await controller.Register(model) as ViewResult;

                // Assert
                Assert.IsNotNull(result, "Expected registration to be rejected and return view.");
                Assert.IsFalse(controller.ModelState.IsValid, "ModelState should be invalid when UserRole is tampered.");

                var errors = controller.ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                Assert.IsTrue(
                    errors.Any(e => e.Contains("Role cannot be specified")), 
                    "Expected error message about role tampering.");

                // Verify user was NOT created
                var userManager = new UserManager<ApplicationUser>(new UserStore<ApplicationUser>(context));
                var user = await userManager.FindByEmailAsync(model.Email);
                Assert.IsNull(user, "User should not be created when UserRole tampering is detected.");
            }
        }

        [TestMethod]
        public async Task Account_Register_Post_CreatesTeacherRole_WhenMissing()
        {
            // Arrange
            LegacyTestDatabase.RemoveDefaultRoles(); // Clear roles including Teacher
            var testPrefix = "RoleCreate_" + System.Guid.NewGuid().ToString("N").Substring(0, 8);
            var model = new RegisterViewModel
            {
                Username = testPrefix + "_user",
                Email = testPrefix + "@test.com",
                BirthDate = System.DateTime.Now.AddYears(-20),
                Password = "P@ssw0rd123!",
                ConfirmPassword = "P@ssw0rd123!",
                UserRole = null
            };

            using (var context = new ApplicationDbContext())
            using (var controller = new AccountController())
            {
                // Verify Teacher role does not exist initially
                var roleManager = new RoleManager<IdentityRole>(new RoleStore<IdentityRole>(context));
                var teacherRoleExists = await roleManager.RoleExistsAsync("Teacher");
                Assert.IsFalse(teacherRoleExists, "Teacher role should not exist at test start.");

                // Act
                var result = await controller.Register(model) as RedirectToRouteResult;

                // Assert
                Assert.IsNotNull(result, "Expected successful registration even when Teacher role is missing (auto-created).");

                // Verify Teacher role was created
                teacherRoleExists = await roleManager.RoleExistsAsync("Teacher");
                Assert.IsTrue(teacherRoleExists, "Teacher role should be created automatically during registration.");

                // Verify user was assigned the Teacher role
                var userManager = new UserManager<ApplicationUser>(new UserStore<ApplicationUser>(context));
                var user = await userManager.FindByEmailAsync(model.Email);
                Assert.IsNotNull(user, "User should be created.");

                var roles = await userManager.GetRolesAsync(user.Id);
                Assert.AreEqual(1, roles.Count, "User should have exactly one role.");
                Assert.AreEqual("Teacher", roles.First(), "User should be assigned 'Teacher' role.");

                // Cleanup
                await userManager.DeleteAsync(user);
            }

            // Restore roles for other tests
            LegacyTestDatabase.EnsureDefaultRoles();
        }
    }
}
