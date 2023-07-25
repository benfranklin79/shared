using Microsoft.AspNetCore.Mvc;

namespace AppEngineTest.Controllers
{
    public class HealthCheckController : Controller
    {
        [HttpGet]
        [Route("/healthcheck")]
        public IActionResult Index()
        {
            return Ok();
        }
    }
}
