using Microsoft.AspNetCore.Mvc;

namespace webapi.Controllers;

[ApiController]
[Route("[controller]")]
public class EchoController : ControllerBase
{
    [HttpGet(Name = "GetEcho")]
    public string Get(string text)
    {
        return $"{text}";
    }
}
