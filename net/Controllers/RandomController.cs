using Microsoft.AspNetCore.Mvc;

namespace webapi.Controllers;

[ApiController]
[Route("[controller]")]
public class RandomController : ControllerBase
{
    [HttpGet(Name = "GetRandom")]
    public int Get(int minimum = 0, int maximum = 1000)
    {
        return new Random().Next(minimum, maximum);
    }
}
