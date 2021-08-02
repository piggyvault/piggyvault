using Abp.Domain.Entities;
using Abp.Domain.Entities.Auditing;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Piggyvault.Piggy.Categories
{
    [Table("PvCategory")]
    public class Category : FullAuditedEntity<Guid>, IMustHaveTenant, IPassivable
    {
        public const int MaxNameLength = 100;

        public virtual string Icon { get; set; }

        public virtual bool IsActive { get; set; }

        [Required]
        [MaxLength(MaxNameLength)]
        public virtual string Name { get; set; }

        public virtual int TenantId { get; set; }
    }
}