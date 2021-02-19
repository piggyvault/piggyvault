using Abp.Auditing;
using System.ComponentModel.DataAnnotations;

namespace Piggyvault.Authorization.Accounts.Dto
{
    public class ResetPasswordInput
    {
        public string ResetCode { get; set; }

        [Required]
        public long UserId { get; set; }

        [DisableAuditing]
        public string Password { get; set; }
    }
}