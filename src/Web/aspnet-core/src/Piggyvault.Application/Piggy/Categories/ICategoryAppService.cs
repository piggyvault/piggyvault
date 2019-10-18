using Abp.Application.Services;
using Abp.Application.Services.Dto;
using Piggyvault.Piggy.Categories.Dto;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace Piggyvault.Piggy.Categories
{
    public interface ICategoryAppService : IApplicationService
    {
        Task CreateOrUpdateCategory(CategoryEditDto input);

        Task<CategoryEditDto> GetCategoryForEdit(EntityDto<Guid> input);

        Task<ListResultDto<CategoryEditDto>> GetTenantCategories();
    }
}