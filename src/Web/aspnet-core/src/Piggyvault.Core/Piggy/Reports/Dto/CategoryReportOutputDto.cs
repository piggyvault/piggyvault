using System;
using System.Collections.Generic;
using System.Text;

namespace Piggyvault.Piggy.Reports.Dto
{
    public class CategoryReportOutputDto
    {
        public string AccountName { get; set; }
        public decimal Amount { get; set; }
        public decimal AmountInDefaultCurrency { get; set; }
        public string CategoryIcon { get; set; }
        public string CategoryName { get; set; }
        public string CurrencyCode { get; set; }
    }
}