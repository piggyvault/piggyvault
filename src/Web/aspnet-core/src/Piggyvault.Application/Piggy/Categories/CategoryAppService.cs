using Abp.Application.Services.Dto;
using Abp.Authorization;
using Abp.AutoMapper;
using Abp.Domain.Repositories;
using Microsoft.EntityFrameworkCore;
using Piggyvault.Piggy.Categories.Dto;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Piggyvault.Piggy.Categories
{
    public class CategoryAppService : PiggyvaultAppServiceBase, ICategoryAppService
    {
        private readonly IRepository<Category, Guid> _categoryRepository;

        public CategoryAppService(IRepository<Category, Guid> categoryRepository)
        {
            _categoryRepository = categoryRepository;
        }

        [AbpAuthorize]
        public async Task CreateOrUpdateCategory(CategoryEditDto input)
        {
            if (input.Id.HasValue)
            {
                await UpdateCategoryAsync(input);
            }
            else
            {
                await CreateCategoryAsync(input);
            }
        }

        [AbpAuthorize]
        public async Task<CategoryEditDto> GetCategoryForEdit(EntityDto<Guid> input)
        {
            var tenantId = AbpSession.TenantId.Value;
            var category = await _categoryRepository.FirstOrDefaultAsync(c => c.Id == input.Id && c.TenantId == tenantId);
            return category.MapTo<CategoryEditDto>();
        }

        [AbpAuthorize]
        public async Task<ListResultDto<CategoryEditDto>> GetTenantCategories()
        {
            var tenantId = AbpSession.TenantId.Value;
            var categories = await
                _categoryRepository.GetAll().Where(c => c.TenantId == tenantId).OrderBy(c => c.Name).ToListAsync();

            return new ListResultDto<CategoryEditDto> { Items = categories.MapTo<List<CategoryEditDto>>() };
        }

        private async Task CreateCategoryAsync(CategoryEditDto input)
        {
            var category = input.MapTo<Category>();
            category.TenantId = AbpSession.TenantId.Value;
            await _categoryRepository.InsertAsync(category);
        }

        private async Task UpdateCategoryAsync(CategoryEditDto input)
        {
            var tenantId = AbpSession.TenantId.Value;
            var category = await _categoryRepository.FirstOrDefaultAsync(c => c.Id == input.Id && c.TenantId == tenantId);
            input.MapTo(category);
        }
    }
}