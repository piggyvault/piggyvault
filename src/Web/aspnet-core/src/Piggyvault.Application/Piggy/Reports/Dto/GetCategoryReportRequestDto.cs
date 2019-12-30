using System;
using System.Collections.Generic;
using System.Text;

namespace Piggyvault.Piggy.Reports.Dto
{
    public class GetCategoryReportRequestDto
    {
        public DateTime EndDate { get; set; }
        public DateTime StartDate { get; set; }
    }
}