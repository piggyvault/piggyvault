using System.Threading.Tasks;
using Piggyvault.Models.TokenAuth;
using Piggyvault.Web.Controllers;
using Shouldly;
using Xunit;

namespace Piggyvault.Web.Tests.Controllers
{
    public class HomeController_Tests: PiggyvaultWebTestBase
    {
        [Fact]
        public async Task Index_Test()
        {
            await AuthenticateAsync(null, new AuthenticateModel
            {
                UserNameOrEmailAddress = "admin",
                Password = "123qwe"
            });

            //Act
            var response = await GetResponseAsStringAsync(
                GetUrl<HomeController>(nameof(HomeController.Index))
            );

            //Assert
            response.ShouldNotBeNullOrEmpty();
        }
    }
}