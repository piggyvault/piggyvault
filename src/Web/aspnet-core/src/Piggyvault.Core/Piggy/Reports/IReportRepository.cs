using Abp.Application.Services.Dto;
using Abp.Domain.Repositories;
using Piggyvault.Piggy.Reports.Dto;
using Piggyvault.Piggy.Transactions;
using System;
using System.Threading.Tasks;

namespace Piggyvault.Piggy.Reports
{
    public interface IReportRepository : IRepository<Transaction, Guid>
    {
        Task<ListResultDto<CategoryReportListItem>> GetCategoryReport(GetCategoryReportInput input);
    }
}