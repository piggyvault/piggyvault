using Abp.Authorization;
using Abp.AutoMapper;
using Abp.Domain.Repositories;
using Code.Library;
using Microsoft.EntityFrameworkCore;
using Piggyvault.Piggy.CurrencyRateExchange;
using Piggyvault.Piggy.Reports.Dto;
using Piggyvault.Piggy.Transactions;
using Piggyvault.Piggy.Transactions.Dto;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Piggyvault.Piggy.Reports
{
    [AbpAuthorize]
    public class ReportAppService : PiggyvaultAppServiceBase, IReportAppService
    {
        private readonly ICurrencyRateExchangeAppService _currencyRateExchangeService;
        private readonly IReportRepository _reportRepository;
        private readonly IRepository<Transaction, Guid> _transactionRepository;

        public ReportAppService(IReportRepository reportRepository, IRepository<Transaction, Guid> transactionRepository, ICurrencyRateExchangeAppService currencyRateExchangeService)
        {
            _reportRepository = reportRepository;
            _transactionRepository = transactionRepository;
            _currencyRateExchangeService = currencyRateExchangeService;
        }

        public async Task<Abp.Application.Services.Dto.ListResultDto<CategoryReportOutputDto>> GetCategoryReport(GetCategoryReportInput input)
        {
            return await _reportRepository.GetCategoryReport(input);
        }

        /// <summary>
        /// The get category wise transaction summary history.
        /// </summary>
        /// <param name="input">
        /// The input.
        /// </param>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        public async Task<Abp.Application.Services.Dto.ListResultDto<GetCategoryWiseTransactionSummaryHistoryOuputDto>> GetCategoryWiseTransactionSummaryHistory(GetCategoryWiseTransactionSummaryHistoryInputDto input)
        {
            var categoryDatasetList = new List<GetCategoryWiseTransactionSummaryHistoryOuputDto>();

            var query = _transactionRepository.GetAll()
                      .Include(t => t.Account)
                      .Include(t => t.Account.Currency)
                      .Include(t => t.Category).Where(t => !t.IsTransferred).Where(t => t.CreatorUserId == AbpSession.UserId);

            var startDate = DateTime.Today.FirstDayOfMonth().AddMonths(-input.NumberOfIteration);
            var endDate = DateTime.Today.FirstDayOfMonth().AddMonths(1);

            query = query.Where(t => t.TransactionTime >= startDate && t.TransactionTime < endDate);

            // income / expense
            query = input.TypeOfTransaction == "income" ? query.Where(t => t.Amount > 0) : query.Where(t => t.Amount < 0);

            var categories = await query.Select(t => t.Category).Distinct().OrderBy(t => t.Name).ToListAsync();

            foreach (var category in categories)
            {
                var categoryDto = new GetCategoryWiseTransactionSummaryHistoryOuputDto { CategoryName = category.Name };

                for (int i = 1; i <= input.NumberOfIteration; i++)
                {
                    var summaryDto = new TransactionSummaryInGetCategoryWiseTransactionSummaryHistoryOuputDto();

                    var newQuery = query;
                    var iterationStartDate = DateTime.Today.FirstDayOfMonth().AddMonths(-input.NumberOfIteration + i);

                    var iterationEndDate = iterationStartDate.AddMonths(1);
                    newQuery = newQuery.Where(t => t.CategoryId == category.Id && t.TransactionTime >= iterationStartDate && t.TransactionTime < iterationEndDate);

                    var transactions = await newQuery.ToListAsync();

                    summaryDto.Total = transactions.Any() ? transactions.Sum(t => _currencyRateExchangeService.GetAmountInDefaultCurrency(t)) : 0;
                    summaryDto.Transactions = transactions.MapTo<List<TransactionPreviewDto>>();
                    categoryDto.Datasets.Add(summaryDto);
                }

                categoryDatasetList.Add(categoryDto);
            }

            return new Abp.Application.Services.Dto.ListResultDto<GetCategoryWiseTransactionSummaryHistoryOuputDto>(categoryDatasetList);
        }
    }
}