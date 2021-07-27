using Abp.AutoMapper;
using System;
using System.ComponentModel.DataAnnotations;

namespace Piggyvault.Piggy.Categories.Dto
{
    [AutoMap(typeof(Category))]
    public class CategoryEditDto
    {
        public virtual string Icon { get; set; }
        public virtual Guid? Id { get; set; }

        public virtual bool IsActive { get; set; }

        [Required]
        public virtual string Name { get; set; }
    }
}