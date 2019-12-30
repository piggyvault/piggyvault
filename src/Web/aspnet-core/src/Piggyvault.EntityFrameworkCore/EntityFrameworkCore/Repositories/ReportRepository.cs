using Abp.Application.Services.Dto;
using Abp.EntityFrameworkCore;
using Piggyvault.Piggy.Reports;
using Piggyvault.Piggy.Reports.Dto;
using Piggyvault.Piggy.Transactions;
using System;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace Piggyvault.EntityFrameworkCore.Repositories
{
    public class ReportRepository : PiggyvaultRepositoryBase<Transaction, Guid>, IReportRepository
    {
        public ReportRepository(IDbContextProvider<PiggyvaultDbContext> dbContextProvider) : base(dbContextProvider)
        {
        }

        public async Task<ListResultDto<CategoryReportListItem>> GetCategoryReport(GetCategoryReportInput input)
        {
            await using var dbConn = new SqlConnection(Context.Database.GetDbConnection().ConnectionString);

            dbConn.Open();

            var output = await dbConn.QueryAsync<CategoryReportListItem>("GetCategoryReport", new { creatorUserId = input.UserId, startDate = input.StartDate, endDate = input.EndDate }, commandType: CommandType.StoredProcedure);

            return new ListResultDto<CategoryReportListItem>(output.ToList());
        }
    }
}