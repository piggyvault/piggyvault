using AutoMapper;
using Piggyvault.Piggy.Accounts;
using Piggyvault.Piggy.Accounts.Dto;
using Piggyvault.Piggy.Reports.Dto;

namespace Piggyvault
{
    internal static class CustomDtoMapper
    {
        public static void CreateMappings(IMapperConfigurationExpression configuration)
        {
            configuration.CreateMap<Account, AccountPreviewDto>()
                 .ForMember(dto => dto.AccountType, map => map.MapFrom(source => source.AccountType.Name));

            configuration.CreateMap<CategoryReportListItem, CategoryReportListDto>()
                .ForMember(dto => dto.Amount, map => map.MapFrom(source => source.Total));
        }
    }
}