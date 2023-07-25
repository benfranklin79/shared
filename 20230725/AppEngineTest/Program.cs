using System.IO;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;

namespace AppEngineTest
{
    public class Program
    {
        public static void Main(string[] args)
        {
            WebHost.CreateDefaultBuilder(args)
                .UseStartup<Startup>()
                .UseKestrel()
                .UseContentRoot(Directory.GetCurrentDirectory())
                .ConfigureAppConfiguration((builder, config) =>
                {
                    var env = builder.HostingEnvironment;

                    config.SetBasePath(env.ContentRootPath)
                        .AddJsonFile("appsettings.json", optional: false, reloadOnChange: env.IsDevelopment())
                        .AddJsonFile($"appsettings.{env.EnvironmentName.ToLower()}.json", optional: true,
                            reloadOnChange: env.IsDevelopment())
                        .AddInMemoryCollection()
                        .AddEnvironmentVariables();
                })
                .Build()
                .Run();
        }
    }
}
