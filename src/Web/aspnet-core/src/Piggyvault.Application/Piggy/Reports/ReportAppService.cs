using Abp.Authorization;
using Abp.Domain.Repositories;
using Code.Library.Extensions;
using Microsoft.EntityFrameworkCore;
using Piggyvault.Piggy.CurrencyRates;
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
        private readonly ICurrencyRateAppService _currencyRateExchangeService;
        private readonly IReportRepository _reportRepository;
        private readonly IRepository<Transaction, Guid> _transactionRepository;

        public ReportAppService(IReportRepository reportRepository, IRepository<Transaction, Guid> transactionRepository, ICurrencyRateAppService currencyRateExchangeService)
        {
            _reportRepository = reportRepository;
            _transactionRepository = transactionRepository;
            _currencyRateExchangeService = currencyRateExchangeService;
        }

        public async Task<Abp.Application.Services.Dto.ListResultDto<CategoryReportListDto>> GetCategoryReport(GetCategoryReportRequestDto input)
        {
            var items = await _reportRepository.GetCategoryReport(new GetCategoryReportInput
            {
                StartDate = input.StartDate,
                EndDate = input.EndDate,
                UserId = AbpSession.UserId.Value
            });

            var output = ObjectMapper.Map<List<CategoryReportListDto>>(items.Items);

            foreach (var dto in output)
            {
                dto.AmountInDefaultCurrency =
                    (await _currencyRateExchangeService.GetExchangeRate(dto.CurrencyCode)) * dto.Amount;
            }

            return new Abp.Application.Services.Dto.ListResultDto<CategoryReportListDto>(output);
        }

        /// <summary>
        /// The get category wise transaction summary history.
        /// </summary>
        public async Task<Abp.Application.Services.Dto.ListResultDto<GetCategoryWiseTransactionSummaryHistoryOuputDto>> GetCategoryWiseTransactionSummaryHistory(GetCategoryWiseTransactionSummaryHistoryInputDto input)
        {
            var categoryDatasetList = new List<GetCategoryWiseTransactionSummaryHistoryOuputDto>();

            var query = _transactionRepository.GetAll()
                      .Include(t => t.Account)
                        .ThenInclude(account => account.Currency)
                      .Include(t => t.Category)
                      .Where(t => !t.IsTransferred && t.CreatorUserId == AbpSession.UserId);

            var startDate = DateTime.Today.FirstDayOfMonth().AddMonths(-input.NumberOfIteration);
            var endDate = DateTime.Today.FirstDayOfMonth().AddMonths(1);

            query = query.Where(t => t.TransactionTime >= startDate && t.TransactionTime < endDate);

            // income / expense
            query = input.TypeOfTransaction == "income" ? query.Where(t => t.Amount > 0) : query.Where(t => t.Amount < 0);

            var categories = await query.Select(t => t.Category).Distinct().OrderBy(t => t.Name).ToListAsync();

            foreach (var category in categories)
            {
                var categoryDto = new GetCategoryWiseTransactionSummaryHistoryOuputDto { CategoryName = category.Name };

                for (var i = 1; i <= input.NumberOfIteration; i++)
                {
                    var summaryDto = new TransactionSummaryInGetCategoryWiseTransactionSummaryHistoryOuputDto();

                    var newQuery = query;
                    var iterationStartDate = DateTime.Today.FirstDayOfMonth().AddMonths(-input.NumberOfIteration + i);

                    var iterationEndDate = iterationStartDate.AddMonths(1);
                    newQuery = newQuery.Where(t => t.CategoryId == category.Id && t.TransactionTime >= iterationStartDate && t.TransactionTime < iterationEndDate);

                    var transactions = await newQuery.ToListAsync();

                    foreach (var transaction in transactions)
                    {
                        summaryDto.Total += await _currencyRateExchangeService.GetAmountInDefaultCurrency(transaction);
                    }

                    summaryDto.Transactions = ObjectMapper.Map<List<TransactionPreviewDto>>(transactions);
                    categoryDto.Datasets.Add(summaryDto);
                }

                categoryDatasetList.Add(categoryDto);
            }

            return new Abp.Application.Services.Dto.ListResultDto<GetCategoryWiseTransactionSummaryHistoryOuputDto>(categoryDatasetList);
        }
    }
}