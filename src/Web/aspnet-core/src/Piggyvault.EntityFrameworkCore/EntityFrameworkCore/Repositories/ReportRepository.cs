using Abp.Application.Services.Dto;
using Abp.EntityFrameworkCore;
using Piggyvault.Piggy.Reports;
using Piggyvault.Piggy.Reports.Dto;
using Piggyvault.Piggy.Transactions;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace Piggyvault.EntityFrameworkCore.Repositories
{
    public class ReportRepository : PiggyvaultRepositoryBase<Transaction, Guid>, IReportRepository
    {
        public ReportRepository(IDbContextProvider<PiggyvaultDbContext> dbContextProvider) : base(dbContextProvider)
        {
        }

        public async Task<ListResultDto<CategoryReportOutputDto>> GetCategoryReport(GetCategoryReportInput input)
        {
            try
            {
                // TODO
                //var creatorUserIdParameter = new SqlParameter("@creatorUserId", input.UserId);
                //var startDateParameter = new SqlParameter("@startDate", input.StartDate);
                //var endDateParameter = new SqlParameter("@endDate", input.EndDate);

                //var output = await Context.Database.SqlQuery<CategoryReportOutputDto>("exec GetCategoryReport @creatorUserId, @startDate, @endDate", creatorUserIdParameter, startDateParameter, endDateParameter).ToListAsync();

                return new ListResultDto<CategoryReportOutputDto>();
            }
            catch (Exception ex)
            {
                // TODO : log
                return null;
            }
        }
    }
}