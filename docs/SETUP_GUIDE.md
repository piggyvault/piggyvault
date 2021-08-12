# Setup Guide

Piggy has three building blocks.

- API Backend on ASP.NET Core
- WEB front-end using Angular
- Flutter mobile app

Piggy's Backend API project and the web front-end are based on [aspnetboilerplate](https://aspnetboilerplate.com/).
Web front-end only required for initial setup to do the following,

- Tenant registration (aka Family)
- User management

The above features are not reached the flutter app yet, hence we need to rely on the default web front-end to do the same for now.
But once the above setup is done, you need to host the API project only, the web front-end is not required.

For the detailed setup guide and documentation for the backend API and front-end web project, refer to the official **aspnetboilerplate** documentation [here](https://aspnetboilerplate.com/Pages/Documents/Zero/Startup-Template-Angular).

## Database Setup

Piggy is using SQL Server database. You can initialize the database by running the `Piggyvault.Migrator` project as mentioned [here](https://aspnetboilerplate.com/Pages/Documents/Zero/Startup-Template-Angular#migrator-console-application).
That will create the database as well as seed the reference data.

The seeding includes,

- [aspnetboilerplate](https://aspnetboilerplate.com/) defaults (Default tenant, host, etc)
- Piggy account types and currencies.

## Hosting API

To host the backend, we need to rely on a .NET Core supported hosting platform and we need an MSSQL database as well.

The cheap option which I found is [SmarterASP.NET](https://www.SmarterASP.NET/index?r=100571651) and using it for many years now. They provide MSSQL DB as well as .NET Core hosting. And they offer an amazing 60-day trial too.

## Final Setup

Once we did hosting our API, then we need to build the flutter project with the updated API endpoint. You need to update the endpoint [here](https://github.com/piggyvault/piggyvault/blob/43f936defe833719332d3883cf24548a2af61ab6/src/Mobile/piggy_flutter/lib/utils/rest_client.dart#L9) and [here](https://github.com/piggyvault/piggyvault/blob/43f936defe833719332d3883cf24548a2af61ab6/src/Mobile/piggy_flutter/lib/repositories/piggy_api_client.dart#L14).

That's it, build and start adding your transactions.
