using Abp.Application.Services.Dto;
using Abp.Authorization;
using Piggyvault.Piggy.Reports.Dto;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace Piggyvault.Piggy.Reports
{
    [AbpAuthorize]
    public class ReportAppService : PiggyvaultAppServiceBase, IReportAppService
    {
        private readonly IReportRepository _reportRepository;

        public ReportAppService(IReportRepository reportRepository)
        {
            _reportRepository = reportRepository;
        }

        public async Task<ListResultDto<CategoryReportOutputDto>> GetCategoryReport(GetCategoryReportInput input)
        {
            return await _reportRepository.GetCategoryReport(input);
        }
    }
}