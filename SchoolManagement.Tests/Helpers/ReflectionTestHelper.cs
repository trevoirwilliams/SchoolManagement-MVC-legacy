using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Linq;
using System.Reflection;
using SchoolManagement.Controllers;

namespace SchoolManagement.Tests.Helpers
{
    internal static class ReflectionTestHelper
    {
        private static readonly Assembly AppAssembly = typeof(HomeController).Assembly;

        public static Type GetApplicationType(string fullTypeName)
        {
            return AppAssembly.GetType(fullTypeName, throwOnError: true);
        }

        public static TAttribute GetSingleAttribute<TAttribute>(MemberInfo memberInfo, bool inherit = true)
            where TAttribute : Attribute
        {
            return memberInfo.GetCustomAttributes(typeof(TAttribute), inherit)
                .Cast<TAttribute>()
                .Single();
        }

        public static TAttribute GetSingleOrDefaultAttribute<TAttribute>(MemberInfo memberInfo, bool inherit = true)
            where TAttribute : Attribute
        {
            return memberInfo.GetCustomAttributes(typeof(TAttribute), inherit)
                .Cast<TAttribute>()
                .SingleOrDefault();
        }

        public static MethodInfo GetHttpPostActionMethod(Type controllerType, string methodName)
        {
            return controllerType
                .GetMethods(BindingFlags.Instance | BindingFlags.Public | BindingFlags.DeclaredOnly)
                .Single(method =>
                    string.Equals(method.Name, methodName, StringComparison.Ordinal) &&
                    method.GetCustomAttributes(typeof(System.Web.Mvc.HttpPostAttribute), inherit: true).Any());
        }

        public static PropertyInfo GetRequiredProperty(Type modelType, string propertyName)
        {
            var property = modelType.GetProperty(propertyName, BindingFlags.Instance | BindingFlags.Public);
            if (property == null)
            {
                Assert.Fail($"Expected property '{propertyName}' to exist on type '{modelType.FullName}'.");
            }

            return property;
        }
    }
}
