using Microsoft.AspNetCore.Antiforgery;
using Piggyvault.Controllers;

namespace Piggyvault.Web.Host.Controllers
{
    public class AntiForgeryController : PiggyvaultControllerBase
    {
        private readonly IAntiforgery _antiforgery;

        public AntiForgeryController(IAntiforgery antiforgery)
        {
            _antiforgery = antiforgery;
        }

        public void GetToken()
        {
            _antiforgery.SetCookieTokenAndHeader(HttpContext);
        }
    }
}
